local skynet = require "skynet"
local M = {}

local self_node_name = nil
function M.get_node_name()
    if self_node_name then
        return self_node_name
    end
    self_node_name = skynet.getenv("cluster_nodename")
    return self_node_name
end

function M.get_platform()
    return "android"
end

function M.get_server_id()
    return tonumber(skynet.getenv("server_id"))
end

function M.get_cluster_config_url()
    return skynet.getenv("cluster_config_url")
end

function M.get_cluster_port()
    return skynet.getenv("cluster_port")
end

function M.get_server_name()
    return skynet.getenv("server_name")
end

function M.get_db_cfg(db_type)
    local db_name = skynet.getenv(db_type)
    assert(db_name, 'db_type not exist:' .. db_type)
    return {
        host = skynet.getenv("db_host"),
        port = skynet.getenv("db_port"),
        user = skynet.getenv("db_user") or 'root',
        passwd = skynet.getenv("db_passwd") or '',
        db_name = db_name,
    }
end

return M

