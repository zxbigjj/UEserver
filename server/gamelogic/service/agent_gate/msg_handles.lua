local skynet = require('skynet')
local socket = require("skynet.socket")
local sproto_msg_utils = require("msg_utils.sproto_msg_utils")
local global = require("gate_global")
local gate_utils = require("srv_utils.gate_utils")
local cluster_utils = require("msg_utils.cluster_utils")

local server_error_code = 1002

local LOG_C2S = false
local CHECK_IP = false
local IP_LIST = {
    "::ffff:192.168.",
    "::ffff:10.1.",
}

local msg_handles = DECLARE_MODULE("msg_handles")
DECLARE_RUNNING_ATTR(msg_handles, "_check_sock_", nil)

if not msg_handles._check_sock_ then
    msg_handles._check_sock_ = true
    skynet.timeout(100*5, function()
        msg_handles.check_sock()
    end)
end

function msg_handles.check_sock()
    skynet.timeout(100*5, function()
        msg_handles.check_sock()
    end)
    -- 10秒没有心跳就踢掉
    local kick_ts = skynet.time() - 30
    local kick_list = {}
    for sock_id, sock in pairs(global.sock_dict) do
        -- print('----------------------------')
        -- print(sock.uuid, sock.heartbreak_ts, kick_ts)
        if sock.heartbreak_ts < kick_ts then
            -- print('---- is kick ----')
            table.insert(kick_list, sock_id)
        end
    end
    for _, sock_id in pairs(kick_list) do
        gate_utils.close_sock(sock_id)
    end
end

local SockCls = DECLARE_CLASS(msg_handles, "SockCls")
function SockCls.new(sock_id, ip, port)
    local self = {}
    self.sock_id = sock_id
    self.ip = ip
    self.port = port
    self.uuid = nil
    self.heartbreak_ts = skynet.time()
    return self
end

function ip_is_valid(ip)
    for _, p in ipairs(IP_LIST) do
        if string.find(ip, p, 1, true) then return true end
    end
end

function msg_handles.handle_accept_sock(sock_id, ip, port)
    assert(global.sock_dict[sock_id] == nil)
    if CHECK_IP and not ip_is_valid(ip) then
        return false
    end
    local sock = SockCls.new(sock_id, ip, port)
    global.sock_dict[sock_id] = sock
    g_log:gate("OnAccept", sock_id, ip, port)
    skynet.send(".agent", "lua", "ls_on_accept_sock", sock_id, ip, port)
end

function msg_handles.handle_close_sock(sock_id)
    local sock = global.sock_dict[sock_id]
    if sock then
        global.unbind_sock(sock_id)
        global.sock_dict[sock_id] = nil
    end
    g_log:gate("OnClose", sock_id)
    skynet.send(".agent", "lua", "ls_on_close_sock", sock_id)
end

function msg_handles.send_sock(sock_id, data)
    data = string.pack(">I3", string.len(data)) .. data
    gate_utils.send_sock_data(sock_id, data)
end

-- uuid_list==nil 表示全服广播
function msg_handles.broad_sock(uuid_list, data, exclude_uuid)
    local pack_data = string.pack(">I3", string.len(data)) .. data
    if not uuid_list then
        uuid_list = table.keys(global.role_sock_mapper)
    end
    gate_utils.broad_sock_data(uuid_list, pack_data, exclude_uuid)
end

function msg_handles.handle_c2s_msg(sock_id, data)
    -- todo:解密
    local proto_name, args, session = sproto_msg_utils.decode_client_msg(data)
    if LOG_C2S then
        g_log:gate("Recv", sock_id, proto_name, args)
    end
    if proto_name == 'c_heartbeat' then
        local sock = global.sock_dict[sock_id]
        if sock then
            sock.heartbreak_ts = skynet.time()
        end
    end
    skynet.send(".agent", "lua", "ls_on_recv_sock", sock_id, session, proto_name, args)
end

local gate_utils = require("srv_utils.gate_utils")
gate_utils.set_recv_data_handle(msg_handles.handle_c2s_msg)
gate_utils.set_accept_sock_handle(msg_handles.handle_accept_sock)
gate_utils.set_close_sock_handle(msg_handles.handle_close_sock)

return msg_handles
