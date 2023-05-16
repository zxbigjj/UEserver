local skynet = require('skynet')
local launch_utils = require('launch_utils')
local server_env = require('srv_utils.server_env')
local sproto_msg_utils = require("msg_utils.sproto_msg_utils")
local timer = require("timer")
local bin_utils = require("bin_utils")
local io_utils = require("sys_utils.io_utils")
local lua_handles_utils = require("msg_utils.lua_handles_utils")

local self_node_name = server_env.get_node_name()
local agent_gate_node_name = launch_utils.get_service_node_name(".agent_gate")
local agent_node_name = launch_utils.get_service_node_name(".agent")

local cluster_utils = DECLARE_MODULE("msg_utils.cluster_utils")

DECLARE_RUNNING_ATTR(cluster_utils, "_login_server_list", nil)
DECLARE_RUNNING_ATTR(cluster_utils, "_game_server_dict", nil)
DECLARE_RUNNING_ATTR(cluster_utils, "_query_server_info_version", -1)

DECLARE_RUNNING_ATTR(cluster_utils, "_query_server_info_timer", 
    timer.loop(10, function() cluster_utils._query_server_info() end, 0.1)
)
DECLARE_RUNNING_ATTR(cluster_utils, "_role_broad_pack", nil)
DECLARE_RUNNING_ATTR(cluster_utils, "_is_agent_service", nil)

cluster_utils.agent_gate_node_name = agent_gate_node_name
cluster_utils.agent_node_name = agent_node_name

local clusterd = skynet.localname(".clusterd")
assert(clusterd, "clusterd is nil")
local cluster_config_content = nil

function cluster_utils.start()
    cluster_utils._query_server_info()
end

function cluster_utils.probe(node_name, srv_name)
    node_name = node_name or launch_utils.get_service_node_name(srv_name)
    return skynet.call(clusterd, "lua", "lc_probe", node_name, srv_name)
end

function cluster_utils.call(node, address, ...)
    if not node or self_node_name == node then
        return skynet.call(address, "lua", ...)
    else
        return skynet.call(clusterd, "lua", "lc_call", node, address, skynet.pack(...))
    end
end

function cluster_utils.send(node, address, ...)
    if not node or self_node_name == node then
        skynet.send(address, "lua", ...)
    else
        skynet.send(clusterd, "lua", "ls_send", node, address, skynet.pack(...))
    end
end

function cluster_utils.remote_newservice(node, service_name, ...)
    return cluster_utils.call(node, '.launcher', "LAUNCH", "snlua", service_name, ...)
end

function cluster_utils.lua_call(node, address, cmd_name, ...)
    assert(string.sub(cmd_name, 1, 3) == "lc_")
    if not node or self_node_name == node then
        return skynet.call(address, "lua", cmd_name, ...)
    else
        return skynet.call(clusterd, "lua", "lc_call", node, address, skynet.pack(cmd_name, ...))
    end
end

function cluster_utils.lua_send(node, address, cmd_name, ...)
    assert(string.sub(cmd_name, 1, 3) == "ls_")
    if not node or self_node_name == node then
        skynet.send(address, "lua", cmd_name, ...)
    else
        skynet.send(clusterd, "lua", "ls_send", node, address, skynet.pack(cmd_name, ...))
    end
end

function cluster_utils.get_lua_send(srv_name, node_name)
    node_name = node_name or launch_utils.get_service_node_name(srv_name)
    if node_name and node_name ~= self_node_name then
        return function (cmd_name, ...)
                        assert(string.sub(cmd_name, 1, 3) == "ls_")
                        skynet.send(clusterd, "lua", "ls_send", node_name, srv_name, skynet.pack(cmd_name, ...))
                    end
    else
        return function (cmd_name, ...)
                        assert(string.sub(cmd_name, 1, 3) == "ls_")
                        skynet.send(srv_name, 'lua', cmd_name, ...)
                    end
    end
end

function cluster_utils.get_lua_call(srv_name, node_name)
    node_name = node_name or launch_utils.get_service_node_name(srv_name)
    if node_name and node_name ~= self_node_name then
        return function (cmd_name, ...)
                assert(string.sub(cmd_name, 1, 3) == "lc_")
                return skynet.call(clusterd, "lua", "lc_call", node_name, srv_name, skynet.pack(cmd_name, ...))
            end
    else
        return function (cmd_name, ...)
                assert(string.sub(cmd_name, 1, 3) == "lc_")
                return skynet.call(srv_name, "lua", cmd_name, ...)
            end
    end
end

function cluster_utils._query_server_info()
    local clusterd = skynet.localname(".clusterd")
    if not clusterd then return end
    local result = skynet.call(clusterd, "lua", 
        "lc_query_server_info", cluster_utils._query_server_info_version)
    if result then
        cluster_utils._query_server_info_version = result.version
        cluster_utils._login_server_list = result.login_server_list
        cluster_utils._game_server_dict = {}
        for _, info in ipairs(result.game_server_list) do
            cluster_utils._game_server_dict[info.server_id] = info
            if not info.mapped_server_id then
                info.mapped_server_id = info.server_id
            end
        end
    end
end

function cluster_utils.get_login_server_list()
    return cluster_utils._login_server_list
end

function cluster_utils.get_game_server_dict()
    return cluster_utils._game_server_dict
end

function cluster_utils.query_cluster_router()
    return skynet.call(clusterd, "lua", "lc_query_router_map")
end

function cluster_utils.register_shutdown(func)
    lua_handles_utils.add_call_handle("lc_x_shutdown", function()
        func()
        return "shutdown over"
    end)
    skynet.call(".debug_console", "lua", "register_shutdown", "lc_x_shutdown")
end

function cluster_utils.get_role_server_id(uuid)
    uuid = tonumber(uuid)
    if not uuid then return end
    local server_id = uuid // g_const.Max_Role_Num
    local info = cluster_utils._game_server_dict[server_id]
    return info and info.mapped_server_id
end

function cluster_utils.map_game_server_id(server_id)
    local info = cluster_utils._game_server_dict[tonumber(server_id)]
    return info and info.mapped_server_id
end

function cluster_utils.get_server_id(uuid)
    return cluster_utils.get_role_server_id(uuid)
end

function cluster_utils.get_server_id_by_dynasty(dynasty_id)
    dynasty_id = tonumber(dynasty_id)
    if not dynasty_id then return end
    local server_id = dynasty_id // g_const.Max_Dynasty_Num
    local info = cluster_utils._game_server_dict[server_id]
    return info and info.mapped_server_id
end

function cluster_utils.is_player_uuid_valid(uuid)
    return cluster_utils.get_role_server_id(uuid) and true or false
end

function cluster_utils.is_in_same_server(uuid1, uuid2)
    return (cluster_utils.get_role_server_id(uuid1) == cluster_utils.get_role_server_id(uuid2))
end

function cluster_utils.get_agent_node_name(uuid)
    return string.format("s%d_game", cluster_utils.get_server_id(uuid))
end

function cluster_utils.get_agent_gate_node_name(uuid)
    return string.format("s%d_game", cluster_utils.get_server_id(uuid))
end

-- 服务器内call agent
function cluster_utils.call_agent(node_name, uuid, cmd, ...)
    if uuid then
        node_name = node_name or cluster_utils.get_agent_node_name(uuid)
        if node_name == self_node_name and cluster_utils._is_agent_service then
            local Mod_Name = lua_handles_utils.get_handle_mod_name(cmd)
            if Mod_Name then
                return require(Mod_Name)[cmd](uuid, ...)
            end
        end
        return cluster_utils.lua_call(node_name, ".agent", cmd, uuid, ...)
    else
        node_name = node_name or agent_node_name
        return cluster_utils.lua_call(node_name, ".agent", cmd, ...)
    end
end

function cluster_utils.send_agent(node_name, uuid, cmd, ...)
    if uuid then
        node_name = node_name or cluster_utils.get_agent_node_name(uuid)
        if node_name == self_node_name and cluster_utils._is_agent_service then
            local Mod_Name = lua_handles_utils.get_handle_mod_name(cmd)
            if Mod_Name then
                return require(Mod_Name)[cmd](uuid, ...)
            end
        end
        return cluster_utils.lua_send(node_name, ".agent", cmd, uuid, ...)
    else
        node_name = node_name or agent_node_name
        return cluster_utils.lua_send(node_name, ".agent", cmd, ...)
    end
end

function cluster_utils.begin_pack_client_msg()
    if cluster_utils._role_broad_pack == nil then
        cluster_utils._role_broad_pack = {}
        skynet.fork(function()
            local pack_dict = cluster_utils._role_broad_pack
            cluster_utils._role_broad_pack = nil

            for node_name, list in pairs(pack_dict) do
                if list.uuid_list and #list.uuid_list == 0 then
                    list.uuid_list = nil
                end
                cluster_utils.send(node_name, ".agent_gate", "ls_role_broad_pack", list)
            end
        end)
    end
end

-- 服务器内发送客户端消息
function cluster_utils.send_client_msg(node_name, uuid, proto_name, args)
    node_name = node_name or cluster_utils.get_agent_gate_node_name(uuid)
    SCHEMA_CHECK_FLAG = false
    local data = sproto_msg_utils.encode_s2c_req(proto_name, args)
    SCHEMA_CHECK_FLAG = true
    if cluster_utils._role_broad_pack then
        -- cache
        local list = cluster_utils._role_broad_pack[node_name]
        if not list then
            list = {uuid_list={}}
            cluster_utils._role_broad_pack[node_name] = list
        end
        table.insert(list, {'s', uuid, proto_name, data})
    else
        cluster_utils.send(node_name, ".agent_gate", "ls_role_send", uuid, proto_name, data)
    end
end

function cluster_utils.notify_client_tips(uuid, content, notify_type)
    notify_type = notify_type or CSConst.NotifyType.FloatWord
    cluster_utils.send_client_msg(nil, uuid, "s_notify_msg", {errstr=content, notify_type=notify_type})
end

-- 服务器内广播消息，uuid_list为nil时广播全服
function cluster_utils.broad_client_msg(node_name, uuid_list, proto_name, args, exclude_uuid)
    if uuid_list then
        uuid_list = bin_utils.pack_int32_list(uuid_list)
    end
    node_name = node_name or agent_gate_node_name
    SCHEMA_CHECK_FLAG = false
    local data = sproto_msg_utils.encode_s2c_req(proto_name, args)
    SCHEMA_CHECK_FLAG = true
    if cluster_utils._role_broad_pack then
        -- cache
        local list = cluster_utils._role_broad_pack[node_name]
        if not list then
            list = {uuid_list={}}
            cluster_utils._role_broad_pack[node_name] = list
        end
        if list.uuid_list then
            local index = table.index(list.uuid_list, uuid_list)
            if not index then
                table.insert(list.uuid_list, uuid_list)
                index = #list.uuid_list
            end
            table.insert(list, {'c', index, proto_name, data, exclude_uuid})
        else
            table.insert(list, {'b', uuid_list, proto_name, data, exclude_uuid})
        end
    else
        cluster_utils.send(node_name, ".agent_gate", "ls_role_broadcast", uuid_list, proto_name, data, exclude_uuid)
    end
end

-- agent给gate发
function cluster_utils.send_agent_gate(cmd, ...)
    cluster_utils.lua_send(agent_gate_node_name, ".agent_gate", cmd, ...)
end

function cluster_utils.call_agent_gate(cmd, ...)
    return cluster_utils.lua_call(agent_gate_node_name, ".agent_gate", cmd, ...)
end

function cluster_utils.send_world(cmd, ...)
    cluster_utils.lua_send("s2801_world", '.world', cmd, ...)
end

function cluster_utils.call_world(cmd, ...)
    return cluster_utils.lua_call("s2801_world", '.world', cmd, ...)
end

function cluster_utils.send_login(cmd, urs, uuid, ...)
    skynet.fork(function(cmd, urs, uuid, ...)
        local login_server_list = cluster_utils.get_login_server_list()
        if #login_server_list == 0 then
            error('login_server_list is nil')
        end
        local len = #login_server_list
        local role_uuid = tonumber(uuid)
        local index = role_uuid%len + 1
        local count = 0
        while true do
            count = count + 1
            local node_name = login_server_list[index]
            local status = pcall(cluster_utils.lua_send, node_name, ".login", cmd, urs, uuid, ...)
            if not status then
                if index == len then
                    index = 1
                else
                    index = index + 1
                end
            else
                break
            end
            if count == len then
                error('all login_server die')
            end
        end
    end, cmd, urs, uuid, ...)
end

function cluster_utils.call_login(cmd, ...)
    local login_server_list = cluster_utils.get_login_server_list()
    if #login_server_list == 0 then
        error('login_server_list is nil')
    end
    local len = #login_server_list
    local index = math.random(1, 2)%len + 1
    local count = 0
    while true do
        count = count + 1
        local node_name = login_server_list[index]
        local ok, ret = xpcall(function(...)
            return cluster_utils.lua_call(node_name, ".login", cmd, ...) end, function() end, ...)
        if not ok then
            if index == len then
                index = 1
            else
                index = index + 1
            end
        else
            return ret
        end
        if count == len then
            return false
        end
    end
end
-------------------------- chat star -------------------------------------
function cluster_utils.enter_chat(uuid, channel_name)
    local server_id = cluster_utils.get_server_id(uuid)
    local node_name = launch_utils.get_service_node_name('.chat', server_id)
    cluster_utils.lua_send(node_name, '.chat', "ls_enter_chat", uuid, channel_name)
end

function cluster_utils.leave_chat(uuid, channel_name)
    local server_id = cluster_utils.get_server_id(uuid)
    local node_name = launch_utils.get_service_node_name('.chat', server_id)
    cluster_utils.lua_send(node_name, '.chat', "ls_leave_chat", uuid, channel_name)
end

function cluster_utils.dissolve_chat(uuid, channel_name)
    local server_id = uuid and cluster_utils.get_server_id(uuid)
    local node_name = launch_utils.get_service_node_name('.chat', server_id)
    cluster_utils.lua_send(node_name, '.chat', "ls_dissolve_chat", channel_name)
end

function cluster_utils.broad_chat(uuid, channel_name, msg)
    local server_id = cluster_utils.get_server_id(uuid)
    local node_name = launch_utils.get_service_node_name('.chat', server_id)
    cluster_utils.lua_send(node_name, '.chat', "ls_broad_chat", channel_name, msg)
end

function cluster_utils.enter_cross_chat(uuid, channel_name)
    cluster_utils.lua_send("s70_cross", '.chat', "ls_enter_chat", uuid, channel_name)
end

function cluster_utils.leave_cross_chat(uuid, channel_name)
    cluster_utils.lua_send("s70_cross", '.chat', "ls_leave_chat", uuid, channel_name)
end

function cluster_utils.broad_cross_chat(uuid, channel_name, msg)
    cluster_utils.lua_send("s70_cross", '.chat', "ls_broad_chat", channel_name, msg)
end
-------------------------- chat end -------------------------------------

function cluster_utils.call_cross_marry(cmd, ...)
    return cluster_utils.lua_call("s70_cross", '.child_marry', cmd, ...)
end

function cluster_utils.send_cross_marry(cmd, ...)
    cluster_utils.lua_send("s70_cross", '.child_marry', cmd, ...)
end

function cluster_utils.call_cross_salon(cmd, ...)
    return cluster_utils.lua_call("s70_cross", '.salon', cmd, ...)
end

function cluster_utils.send_cross_salon(cmd, ...)
    cluster_utils.lua_send("s70_cross", '.salon', cmd, ...)
end

function cluster_utils.send_dynasty(cmd, uuid, ...)
    local server_id = uuid and cluster_utils.get_server_id(uuid)
    local node_name = launch_utils.get_service_node_name('.dynasty', server_id)
    cluster_utils.lua_send(node_name, '.dynasty', cmd, uuid, ...)
end

function cluster_utils.call_dynasty(cmd, uuid, ...)
    local server_id = uuid and cluster_utils.get_server_id(uuid)
    local node_name = launch_utils.get_service_node_name('.dynasty', server_id)
    return cluster_utils.lua_call(node_name, '.dynasty', cmd, uuid, ...)
end

function cluster_utils.send_cross_dynasty(cmd, ...)
    cluster_utils.lua_send("s70_cross", '.dynasty', cmd, ...)
end

function cluster_utils.call_cross_dynasty(cmd, ...)
    return cluster_utils.lua_call("s70_cross", '.dynasty', cmd, ...)
end

function cluster_utils.call_cross_party(cmd, ...)
    return cluster_utils.lua_call("s70_cross", '.party', cmd, ...)
end

function cluster_utils.send_cross_party(cmd, ...)
    cluster_utils.lua_send("s70_cross", '.party', cmd, ...)
end

function cluster_utils.call_cross_traitor(cmd, ...)
    return cluster_utils.lua_call("s70_cross", '.traitor', cmd, ...)
end

function cluster_utils.send_cross_traitor(cmd, ...)
    cluster_utils.lua_send("s70_cross", '.traitor', cmd, ...)
end

function cluster_utils.call_cross_rank(cmd, ...)
    return cluster_utils.lua_call("s70_cross", '.rank', cmd, ...)
end

function cluster_utils.send_cross_rank(cmd, ...)
    cluster_utils.lua_send("s70_cross", '.rank', cmd, ...)
end

function cluster_utils.call_db(cmd, ...)
    if skynet.getenv("server_type") == 'game' then
        return cluster_utils.lua_call(agent_node_name, ".gamedb", cmd, ...)
    else
        return skynet.call('.gamedb', "lua", cmd, ...)
    end
end

return cluster_utils