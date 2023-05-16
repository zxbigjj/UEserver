local MOD = DECLARE_MODULE("db_utils")

local mysql_db = require("db.mysql_db")

local MAX_DB_CONN_COUNT = 1    -- 最大连接数量
if skynet.getenv("server_type") == 'game' then
    MAX_DB_CONN_COUNT = 4
end

DECLARE_RUNNING_ATTR(MOD, "_db_client_dict", {})
DECLARE_RUNNING_ATTR(MOD, "_conn_lock", nil, function()
    return require("srv_utils.co_lock").new()
end)

function CHECK_NEW_CLIENT(db_name)
    local client_list = MOD._db_client_dict[db_name]
    if not client_list then
        client_list = {}
        MOD._db_client_dict[db_name] = client_list
    end
    if #client_list >= MAX_DB_CONN_COUNT then
        return
    end
    MOD._conn_lock:run(function()
        -- check again
        if #client_list >= MAX_DB_CONN_COUNT then
            return
        end
        local db_cfg = require("srv_utils.server_env").get_db_cfg(db_name)
        table.insert(client_list, mysql_db.new(db_cfg))
    end)
end

function MOD.get_db_client(db_name, key)
    local client_list = MOD._db_client_dict[db_name]
    if not client_list then
        for i=1, MAX_DB_CONN_COUNT do
            CHECK_NEW_CLIENT(db_name)
        end
        client_list = MOD._db_client_dict[db_name]
    end

    if tonumber(key) then
        key = math.floor(tonumber(key))
        key = key % 10103
    elseif type(key) == 'string' then
        key = string.hash(key)
    else
        key = math.random(0, 10103)
    end
    return client_list[1+key%(#client_list)]
end

return MOD