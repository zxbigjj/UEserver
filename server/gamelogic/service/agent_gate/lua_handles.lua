local skynet = require('skynet')
local gate_utils = require("srv_utils.gate_utils")
local sproto_msg_utils = require("msg_utils.sproto_msg_utils")
local global = require("gate_global")
local msg_handles = require("msg_handles")
local timer = require("timer")
local bin_utils = require("bin_utils")

local lua_handles = DECLARE_MODULE("lua_handles")
DECLARE_RUNNING_ATTR(lua_handles, "TRACE_MSG_DICT", {})
DECLARE_RUNNING_ATTR(lua_handles, "TRACE_TIMER", nil, function()
    return timer.loop(1, function()
        lua_handles.print_trace_msg()
    end)
end)

local TRACE_MSG_FLAG = false
local LOG_MSG = false

local function trace_msg(name, count, broad_count)
    broad_count = broad_count or 1
    local v = lua_handles.TRACE_MSG_DICT[name]
    if not v then
        v = { name, 0, 0 }
        lua_handles.TRACE_MSG_DICT[name] = v
    end
    v[2] = v[2] + count
    v[3] = v[3] + count * broad_count
end

function lua_handles.print_trace_msg()
    if not TRACE_MSG_FLAG then return end
    print("=============print_trace_msg begin")
    local values = table.values(lua_handles.TRACE_MSG_DICT)
    table.sort(values, function(x, y) return y[3] < x[3] end)
    for _, v in ipairs(values) do
        print(string.format('==========================%20s %10d %10d', v[1], v[2], v[3]))
    end
    print("=============print_trace_msg over")
    lua_handles.TRACE_MSG_DICT = {}
end

function lua_handles.ls_close_sock(sock_id)
    gate_utils.close_sock(sock_id)
    g_log:gate("Close", sock_id)
end

function lua_handles.ls_sock_send(sock_id, proto_name, data)
    if type(data) ~= "string" then
        data = sproto_msg_utils.encode_s2c_req(proto_name, data)
    end
    if TRACE_MSG_FLAG then
        trace_msg(proto_name, 1)
    end
    if LOG_MSG then
        g_log:gate("RoleSend", sock_id, proto_name, sproto_msg_utils.decode_s2c_req(data))
    end
    msg_handles.send_sock(sock_id, data)
end

function lua_handles.ls_sock_response(sock_id, session, proto_name, args)
    local data
    if type(args) ~= "string" then
        data = sproto_msg_utils.encode_c2s_resp(session, proto_name, args)
    else
        data = args
    end
    if LOG_MSG then
        local _, _, bin = sproto_msg_utils.decode_server_msg(data)
        g_log:gate("Resp", sock_id, session, proto_name, sproto_msg_utils.decode_c2s_response(proto_name, bin))
    end
    if TRACE_MSG_FLAG then
        trace_msg(proto_name, 1)
    end
    msg_handles.send_sock(sock_id, data)
end

function lua_handles.ls_role_send(uuid, proto_name, data)
    print("role send: " .. proto_name, uuid)
    -- print("====: " .. json.encode(data))

    if type(data) ~= "string" then
        data = sproto_msg_utils.encode_s2c_req(proto_name, data)
    end
    if TRACE_MSG_FLAG then
        trace_msg(proto_name, 1)
    end
    if LOG_MSG then
        g_log:gate("RoleSend", uuid, proto_name, sproto_msg_utils.decode_s2c_req(data))
    end
    local sock_id = global.role_sock_mapper[uuid]
    if sock_id then
        msg_handles.send_sock(sock_id, data)
    end
end

function lua_handles.ls_role_broadcast(uuid_list, proto_name, data, exclude_uuid)
    if type(data) ~= "string" then
        data = sproto_msg_utils.encode_s2c_req(proto_name, data)
    end
    print("proto_name :" .. tostring(proto_name))
    print("proto_name :" .. json.encode(data))

    local a, b = sproto_msg_utils.decode_s2c_req(data)
    print(a, json.encode(b))

    if TRACE_MSG_FLAG then
        trace_msg(proto_name, 1, uuid_list and #uuid_list / 4 or global.role_count)
    end
    if LOG_MSG then
        g_log:gate("RoleBroad", uuid_list and bin_utils.unpack_int32_list(uuid_list), sproto_msg_utils.decode_s2c_req(data))
    end
    msg_handles.broad_sock(uuid_list, data, exclude_uuid)
end

-- 打包广播
function lua_handles.ls_role_broad_pack(args_list)
    for _, args in ipairs(args_list) do
        local mode = args[1]
        if mode == 'b' then
            lua_handles.ls_role_broadcast(table.unpack(args, 2, 5))
        elseif mode == 'c' then
            local uuid_list = args_list.uuid_list[args[2]]
            lua_handles.ls_role_broadcast(uuid_list, table.unpack(args, 3, 5))
        elseif mode == 's' then
            lua_handles.ls_role_send(table.unpack(args, 2, 4))
        end
    end
end

function lua_handles.ls_bind_role(sock_id, uuid)
    global.bind_role(sock_id, uuid)
end

function lua_handles.ls_unbind_role(uuid)
    global.unbind_role(uuid)
end

function lua_handles.ls_unbind_sock(sock_id)
    global.unbind_sock(sock_id)
end

return lua_handles
