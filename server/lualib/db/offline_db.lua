local skynet = require("skynet")
local table_extend = require("table_extend")
local LRU = table_extend.LRU

local offline_db = DECLARE_MODULE("db.offline_db")

-- 普通对象类
local OfflineObjMgr = DECLARE_CLASS(offline_db, "OfflineObjMgr")
local _all_off_obj_mgr = DECLARE_RUNNING_ATTR(OfflineObjMgr, "_all_off_obj_mgr", {})

local OP_INSERT = 1
local OP_SAVE = 2
local OP_DELETE = 3

function OfflineObjMgr.new(schema, max_size, duration)
    local self = {
        _collection_name = schema.name,
        _schema = schema,
        _db_lru = LRU.new(), -- 记录最后使用时间
        _max_size = max_size,
        _duration = duration,
        _load_lock = {},
        _save_lru = LRU.new(), -- 记录最初使用时间
        _save_delay = 300,
    }
    setmetatable(self, OfflineObjMgr)
    table.insert(_all_off_obj_mgr, self)
    skynet.fork(function()
        while true do
            xpcall(self.save_once, g_log.trace_handle, self)
            skynet.sleep(1000)
        end
    end)
    return self
end

function OfflineObjMgr:_load(key, not_auto_create)
    while self._load_lock[key] do
        skynet.sleep(1)
    end
    if self._db_lru[key] then return self._db_lru[key] end
    self._load_lock[key] = true
    xpcall(function()
        local db = self._schema:load(key)
        if not db then
            if not_auto_create then return end
            self._save_lru[key] = OP_INSERT
            db = self._schema:new_obj(key)
        end
        self._db_lru[key] = db
    end, g_log.trace_handle)
    self._load_lock[key] = nil
    return self._db_lru[key]
end

function OfflineObjMgr:load_all(order, limit)
    local pn = self._schema:get_primary_name()
    for _, obj in ipairs(self._schema:load_many(nil, nil, order, limit)) do
         self._db_lru[obj[pn]] = obj
    end
end

function OfflineObjMgr:__check_save(key, value)
    local op = self._save_lru[key]
    if not op then return end
    self._save_lru[key] = nil
    if op == OP_DELETE then
        self._schema:delete(key)
        return
    end
    if not value then return end
    if op == OP_INSERT then
        self._schema:insert(key, value)
    elseif op == OP_SAVE then
        self._schema:save(value)
    else
    end
end

function OfflineObjMgr:save_all()
    xpcall(function()
        local key, op, ts
        while true do
            key, op, ts = LRU.peek(self._save_lru)
            if key == nil then
                return
            end

            self:__check_save(key, self._db_lru[key])
        end
    end, g_log.trace_handle)
end

function OfflineObjMgr:get_all()
    return self._db_lru
end

function OfflineObjMgr:is_loaded(key)
    return self._db_lru[key]
end

function OfflineObjMgr:get(key)
    local db = self._db_lru[key]
    if db then return db end
    return self:_load(key)
end

function OfflineObjMgr:find_one(key)
    local db = self._db_lru[key]
    if db then return db end
    return self:_load(key, true)
end

function OfflineObjMgr:find(query, selector, sort, limit)
    return self._schema:load_many(query, selector, sort, limit)
end

function OfflineObjMgr:set(key, value)
    value = self._schema:attach(value)
    self._db_lru[key] = value
    if not self._save_lru[key] then
        self._save_lru[key] = OP_SAVE
    end
    return value
end

function OfflineObjMgr:delete(key)
    self._db_lru[key] = nil
    local op = self._save_lru[key]
    if op == OP_INSERT then
        self._save_lru[key] = nil
    else
        self._save_lru[key] = OP_DELETE
    end
    if self.delete_callback then
        xpcall(function() self.delete_callback(key, nil) end, g_log.trace_handle)
    end
end

function OfflineObjMgr:query_count()
    return self._schema:query_count()
end

function OfflineObjMgr:set_delete_callback(func)
    self.delete_callback = func
end

function OfflineObjMgr:save_once()
    local key, value, ts, _
    while self._max_size and #self._db_lru > self._max_size do
        key, value = LRU.pop(self._db_lru)
        if self.delete_callback then
            xpcall(function() self.delete_callback(key, value) end, g_log.trace_handle)
        end
        self:__check_save(key, value)
    end
    while self._duration do
        key, value, ts = LRU.peek(self._db_lru)
        if not ts or ts + self._duration > skynet.time() then
            break
        end
        LRU.pop(self._db_lru)
        if self.delete_callback then
            xpcall(function() self.delete_callback(key, value) end, g_log.trace_handle)
        end
        self:__check_save(key, value)
    end
    while true do
        key, _, ts = LRU.peek(self._save_lru)
        if not key or ts > skynet.time() - self._save_delay then
            return
        end

        self:__check_save(key, self._db_lru[key])
    end
end

function offline_db.save_all()
    for _, mgr in ipairs(_all_off_obj_mgr) do
        xpcall(function()
            mgr:save_all()
        end, g_log.trace_handle)
    end
end

function offline_db.init()
    skynet.report_debug_info("offline_db", function()
        return offline_db.debug_info()
    end)
end

function offline_db.debug_info()
    local words = {}
    for _, mgr in ipairs(_all_off_obj_mgr) do
        table.insert(words, string.format("%s:%s:%s", mgr._collection_name, 
            #mgr._db_lru, #mgr._save_lru))
    end
    return table.concat(words, ", ")
end

return offline_db