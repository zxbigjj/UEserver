local skynet = require('skynet')
local Mongo = require('skynet.db.mongo')
local Bson = require('bson')

local db_cls = DECLARE_MODULE("db.mongo_db")

DECLARE_RUNNING_ATTR(db_cls, "_game_db", nil)
DECLARE_RUNNING_ATTR(db_cls, "_friend_db", nil)

db_cls.__index = db_cls

local ops = {'insert', 'batch_insert', 'delete', 'update'}
for _, v in ipairs(ops) do
    db_cls[v] = function(self, c_name, ...)
            local collection = self.db[c_name]
            collection[v](collection, ...)
            local ret = self.db:runCommand('getLastError')
            local success = ret and ret.ok == 1 and not ret.code
            if not success then
                g_log:error("DbError", {op=v, c_name=c_name, args=table.pack(...), last_error=ret})
            end
            return success, ret.err
        end
end

function db_cls:drop(c_name)
    if not c_name then
        return
    end
    local collection = self.db[c_name]
    collection:dropIndex("*")
    collection:drop()
end

function db_cls:raw_delete(c_name, ...)
    self.db[c_name]:delete(...)
end

function db_cls:raw_update(c_name, ...)
    self.db[c_name]:update(...)
end

function db_cls:find_one(c_name, ...)
    return self.db[c_name]:findOne(...)
end

function db_cls:find(c_name, query, selector, sort, limit)
    local cursor = self.db[c_name]:find(query, selector)
    if sort then
        cursor:sort(sort)
    end
    if limit then
        cursor:limit(limit)
    end
    local ret = {}
    while cursor:hasNext() do
        table.insert(ret, cursor:next())
    end
    return ret
end

function db_cls:find_and_modify(c_name, ...)
    local c = self.db[c_name]
    local ret = c:findAndModify(...)

    local r = ret.lastErrorObject
    if not r then
        g_log:warn("find_and_modify fail, no last error object, c_name:" .. c_name, ...)
        return false, "find_and_modify fail, no last error object"
    end

    if r.err and r.err ~= Bson.null then
        g_log:warn("find_and_modify failed, c_name:" .. c_name .. "err:" .. r.err, ...)
        return false, r.err
    end

    local ok = r.updatedExisting and r.n > 0
    if not ok then
        g_log:warn("find_and_modify,  nothing changed, c_name:" .. c_name, ...)
        return false, "find_and_modify fail, nothing changed"
    end
    return true, ret.value
end

function db_cls:ensureIndex(c_name, args)
    return self.db[c_name]:ensureIndex(args)
end

function db_cls:init(db_cfg)
    self._client = Mongo.client(db_cfg)
    self.db = self._client[db_cfg.db]
end

function db_cls:close()
    self._client:logout()
    self._client:disconnect()
end

function db_cls.new(db_cfg)
    local ret = {}
    setmetatable(ret, db_cls)
    ret:init(db_cfg)
    return ret
end

function db_cls.gamedb()
    if db_cls._game_db then
        return db_cls._game_db
    end
    local server_env = require('srv_utils.server_env')
    local db_cfg = server_env.get_db_cfg('gamedb')
    if not db_cfg then
        error('no gamedb config')
    end
    db_cls._game_db = db_cls.new(db_cfg)
    return db_cls._game_db
end

function db_cls.frienddb()
    if db_cls._friend_db then
        return db_cls._friend_db
    end
    local server_env = require('srv_utils.server_env')
    local db_cfg = server_env.get_db_cfg('friend_db')
    if not db_cfg then
        error('no frienddb config')
    end
    db_cls._friend_db = db_cls.new(db_cfg)
    return db_cls._friend_db
end

return db_cls


