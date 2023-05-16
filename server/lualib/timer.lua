-- skynet服务timer
local skynet = require("skynet")
local date = require("sys_utils.date")
local msg_profile = require("msg_utils.msg_profile")

local timer = DECLARE_MODULE("timer")
DECLARE_RUNNING_ATTR(timer, "_timer_hub", {})
DECLARE_RUNNING_ATTR(timer, "_guid", 0)
DECLARE_RUNNING_ATTR(timer, "_check_started", nil)
DECLARE_RUNNING_ATTR(timer, "_last_ts", 0)

function timer.new(callback, duration, is_loop, delay)
    if not timer._check_started then
        timer._check_started = true
        timer._last_ts = date.now() - 1
        skynet.timeout(1, function() timer._check_cb() end)
    end

    duration = duration > 1 and math.floor(duration) or 1
    local self = setmetatable({}, timer)
    timer._guid = timer._guid + 1
    self.guid = timer._guid
    self.callback = callback
    self.duration = duration
    self.is_loop = is_loop

    if delay then
        delay = delay > 1 and math.floor(delay) or 1
        self.next_ts = date.now() + delay
    else
        self.next_ts = date.now() + duration
    end
    timer._plug(self)
    return self
end

function timer.once(delay_seconds, cb)
    return timer.new(cb, delay_seconds * 100)
end

function timer.loop(duration_seconds, cb, delay_seconds)
    delay_seconds = delay_seconds or duration_seconds
    return timer.new(cb, duration_seconds * 100, true, delay_seconds * 100)
end

-- 将当前时间往前移动, 方便测试
function timer.offset_time()
    -- nothing to do
end

function timer._expire(ts)
    local slot = timer._timer_hub[ts]
    if not slot then return end
    timer._timer_hub[ts] = nil
    local now = date.now()
    for _, ti in ipairs(slot) do
        skynet.fork(function()
            if not ti.cancel_flag and msg_profile.ProfileFlag then
                local info = debug.getinfo(ti.callback, "S")
                local tag = string.format("%s:%s", info.source, info.linedefined)
                skynet.set_coroutine_stop_cb(function(used_time)
                    msg_profile.on_handle_finish('t-' .. tag, used_time)
                end)
            end
            while not ti.cancel_flag do
                xpcall(ti.callback, g_log.trace_handle, ti)
                if ti.is_loop then
                    ti.next_ts = ti.next_ts + ti.duration
                    if ti.next_ts > now then
                        timer._plug(ti)
                        break
                    end
                else
                    ti.callback = nil
                    break
                end
            end
        end)
    end
end

function timer:_plug()
    local slot = timer._timer_hub[self.next_ts]
    if slot then
        table.insert(slot, self)
    else
        local next_ts = self.next_ts
        slot = {self}
        timer._timer_hub[next_ts] = slot
    end
end

function timer._check_cb()
    skynet.timeout(1, function() timer._check_cb() end)
    local now = date.now()
    while timer._last_ts < now do
        timer._last_ts = timer._last_ts + 1
        timer._expire(timer._last_ts)
    end
end

function timer:cancel()
    if self.cancel_flag then
        return
    end
    self.callback = nil
    self.cancel_flag = true
    local slot = timer._timer_hub[self.next_ts]
    if slot then
        table.remove(slot, table.index(slot, self))
    end
end

function timer:is_cancel()
    return self.cancel_flag
end

local function test()
    local once = timer.once(5, function() print("once expire") end)
    local loop = timer.loop(1, function() print("loop expire") end)
    local once2 = timer.once(3, function()
        print("once2 expire")
        once:cancel()
        loop:cancel()
    end)
end

return timer