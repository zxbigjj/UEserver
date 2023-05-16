local skynet = require "skynet"
local coroutine = coroutine
local xpcall = xpcall
local table = table

local co_lock = DECLARE_MODULE("srv_utils.co_lock")
local _timeout_lock_dict = DECLARE_RUNNING_ATTR(co_lock, "_timeout_lock_dict", {})

DECLARE_RUNNING_ATTR(co_lock, "_last_check_ts", math.floor(skynet.time()))
DECLARE_RUNNING_ATTR(co_lock, "_waiting_wake_list", {})
DECLARE_RUNNING_ATTR(co_lock, "_wake_thread", nil)

DECLARE_RUNNING_ATTR(co_lock, "_check_timeout_loop", nil, function()
    local now = skynet.time()
    return require("timer").loop(1, function() co_lock.check_timeout() end, math.ceil(now) - now + 0.00001)
end)


function co_lock.check_timeout()
    co_lock._last_check_ts = co_lock._last_check_ts + 1
    local last_ts = co_lock._last_check_ts

    local dict = co_lock._timeout_lock_dict[last_ts]
    if dict then
        co_lock._timeout_lock_dict[last_ts] = nil
        for lock, _ in pairs(dict) do
            lock:on_timeout()
        end
    end
end

local LockCls = DECLARE_CLASS(co_lock, "LockCls")
-- TODO(weiw) to forbid dead lock, must add a time stamp check when _lock func is called
function LockCls.new(cb_free, timeout)
    if timeout then
        timeout = math.ceil(timeout)
        if timeout < 1 then
            timeout = nil
        end
    end
    local self = {
        -- current_thread = nil,
        ref = 0,
        -- thread_queue = nil,
        -- destroyed = nil,
        cb_free = cb_free,
        timeout = timeout,
    } 

    setmetatable(self, LockCls)
    return self
end

function LockCls:_push_timeout()
    local ts = math.ceil(skynet.time()) + self.timeout
    self.timeout_ts = ts

    local di = _timeout_lock_dict[ts]
    if not di then
        di = {}
        _timeout_lock_dict[ts] = di
    end
    di[self] = true
end

function LockCls:_pop_timeout()
    if self.timeout_ts then
        local di = _timeout_lock_dict[self.timeout_ts]
        if di then
            di[self] = nil
            if not next(di) then
                _timeout_lock_dict[self.timeout_ts] = nil
            end
        end
        self.timeout_ts = nil
    end
end

function LockCls:_wait(thread)
    if self.thread_queue then
        table.insert(self.thread_queue, thread)
    else
        self.thread_queue = {thread}
    end
    skynet.wait()
    assert(self.ref == 0 or self.destroyed)
end

function co_lock._wake_waiting()
    co_lock._wake_thread = nil
    local list = co_lock._waiting_wake_list
    co_lock._waiting_wake_list = {}
    for _, lock in ipairs(list) do
        if lock.current_thread then
            -- 可能又被锁住了，正常
        else
            local thread = table.remove(lock.thread_queue, 1)
            if thread then
                lock.current_thread = thread
                skynet.wakeup(thread)
            else
                -- 正常，因为lock可能被多次插入_waiting_wake_list
            end
        end
    end
end

function LockCls:_wake_next()
    self.current_thread = nil
    if self.thread_queue then
        if next(self.thread_queue) then
            table.insert(co_lock._waiting_wake_list, self)
            if not co_lock._wake_thread then
                co_lock._wake_thread = skynet.fork(function()
                    co_lock._wake_waiting()
                end)
            end
        else
            if self.cb_free then
                pcall(self.cb_free)
            end
        end
    else
        if self.cb_free then
            pcall(self.cb_free)
        end
    end
end

function LockCls:_unlock(ok, ...)
    local thread = coroutine.running()
    if self.current_thread ~= thread then
        -- 超时， 锁已经给别人了
        assert(ok, "lock run error")
        return ...
    end
    if self.timeout_ts then
        self:_pop_timeout()
    end
    self.ref = self.ref - 1
    if self.ref == 0 then
        self.current_thread = nil
        self:_wake_next()
    end
    if not ok then
        error(self.err)
    end
    return ...
end

function LockCls:on_timeout()
    if not self.timeout_ts then
        print('co_lock timeout_ts error')
        print(debug.traceback(self.current_thread))
        return
    end
    self.ref = 0
    self.current_thread = nil
    self:_wake_next()
end

function LockCls:run(f)
    local thread = coroutine.running()
    if self.current_thread and self.current_thread ~= thread then
        self:_wait(thread)
    end
    if self.destroyed then
        return f()
    end
    self.current_thread = thread
    self.ref = self.ref + 1
    if self.timeout and not self.timeout_ts then
        self:_push_timeout()
    end
    return self:_unlock(xpcall(f, function(err) self.err = debug.traceback(err, 2) end))
end

function LockCls:destroy()
    if self.destroyed then return end
    self.destroyed = true

    if self.timeout_ts then
        self:_pop_timeout()
    end
    self.current_thread = nil
    if self.thread_queue then
        for i, thread in ipairs(self.thread_queue) do
            skynet.wakeup(thread)
        end
    end
    if self.cb_free then
        pcall(self.cb_free)
    end
end

function co_lock.new(timeout)
    return LockCls.new(nil, timeout)
end

function co_lock.new_lock_mgr(timeout)
    local lock_dict = {}

    local function run(self, lock_id, f)
        local lock = lock_dict[lock_id]
        if not lock then
            lock = LockCls.new(function()
                lock_dict[lock_id] = nil
            end, timeout)
            lock_dict[lock_id] = lock
        end
        return lock:run(f)
    end

    return {run=run}
end

local CoQueue = DECLARE_CLASS(co_lock, "CoQueue")

function CoQueue.new()
    local self = {
        list = require("table_extend").Deque.new(),
        read_threads = {},
    }
    setmetatable(self, CoQueue)
    return self
end

function CoQueue:push(obj)
    self.list:append(obj)
    if #self.read_threads then
        local thread = table.remove(self.read_threads, 1)
        skynet.wakeup(thread)
    end
end

function CoQueue:pop()
    local thread = nil
    while true do
        if #self.list > 0 then
            return self.list:popleft()
        end
        thread = thread or coroutine.running()
        table.insert(self.read_threads, thread)
        skynet.wait()
    end
end

function co_lock.new_queue()
    return CoQueue.new()
end

local function test_lock()
    local lock = LockCls.new(nil, 1)
    print('test_lock begin', skynet.time())
    skynet.fork(function()
        lock:run(function()
            skynet.sleep(300)
            print('lock 111', skynet.time())
        end)
    end)
    
    skynet.fork(function()
        lock:run(function()
            skynet.sleep(300)
            print('lock 222', skynet.time())
        end)
    end)

    skynet.fork(function()
        lock:run(function()
            skynet.sleep(300)
            print('lock 333', skynet.time())
        end)
    end)
    skynet.sleep(1000)
    lock:destroy()
    print('test_lock over', skynet.time())
end

local function test_lock_reenter()
    local lock = LockCls.new()
    skynet.fork(function()
        lock:run(function()
            skynet.sleep(100)
            print('lock 111', skynet.time())
            lock:run(function()
                skynet.sleep(100)
                print('lock 222', skynet.time())
            end)
        end)
    end)

    skynet.fork(function()
        lock:run(function()
            skynet.sleep(100)
            print('lock 333', skynet.time())
            lock:run(function()
                skynet.sleep(100)
                error("lock 444")
            end)
        end)
    end)
    
    skynet.sleep(500)
    print('test_lock_reenter over', lock.ref)
end

local function test_lock_mgr()
    local mgr = co_lock.new_lock_mgr()
    skynet.fork(function()
        PRINT("1 enter")
        mgr:run("somekey", function()
            skynet.sleep(100)
        end)
        PRINT("1 exit")
    end)
    skynet.fork(function()
        PRINT("2 enter")
        mgr:run("somekey", function()
        end)
        PRINT("2 exit")
    end)
end

local function test_queue()
    local q = co_lock.new_queue()
    skynet.fork(function()
        while true do
            PRINT("=pop", #q.list, q:pop())
            --skynet.sleep(math.floor(math.random() * 100))
        end
    end)
    skynet.fork(function()
        for v=1,1000 do
            q:push(v)
            PRINT("push", #q.list, v)
            skynet.sleep(math.floor(math.random() * 100))
        end
    end)
end

return co_lock