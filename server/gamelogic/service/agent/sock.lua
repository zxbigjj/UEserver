local skynet = require("skynet")
local cluster_utils = require("msg_utils.cluster_utils")
local co_lock = require("srv_utils.co_lock")

local MOD = DECLARE_MODULE("sock")


-------------------------SockCls begin-------------------
-- sock连接
local SockCls = DECLARE_CLASS(MOD, "SockCls")
DECLARE_RUNNING_ATTR(SockCls, "sock_dict", {})

function SockCls.new(sock_id, ip, port)
    local self = setmetatable({}, SockCls)
    self.sock_id = sock_id
    self.ip = ip
    self.port = port

    self.lock = co_lock.new(10)
    self.role = nil
    self.player = nil
    return self
end

function SockCls.add_sock(sock_id, ip, port)
    if string.sub(ip, 1, 7) == "::ffff:" then
        ip = string.sub(ip, 8, -1)
    end
    local index = string.find(ip, ":", 1, true)
    if index then
        ip = string.sub(ip, 1, index-1)
        port = string.sub(ip, index+1, -1)
        port = tonumber(port)
    end
    local sock = SockCls.new(sock_id, ip, port)
    SockCls.sock_dict[sock_id] = sock
    return sock
end

function SockCls.on_close(sock_id)
    local sock = SockCls.sock_dict[sock_id]
    if not sock then return end

    sock.player = nil
    if sock.role then
        sock.role:on_disconnect()
        sock.role = nil
    end
    -- 销毁锁
    sock.lock:destroy()
    sock.lock = nil
    SockCls.sock_dict[sock_id] = nil
end

function SockCls.get_sock(sock_id)
    return SockCls.sock_dict[sock_id]
end

function SockCls.get_role(sock_id)
    local sock = SockCls.sock_dict[sock_id]
    if sock then return sock.role end
end

function SockCls.close_sock(sock_id)
    SockCls.on_close(sock_id)
    cluster_utils.send_agent_gate("ls_close_sock", sock_id)
end

function SockCls:close()
    if self.sock_id then
        SockCls.close_sock(self.sock_id)
    end
end

function SockCls:bind_role(role)
    self.role = role
end

function SockCls:bind_player(player)
    self.player = player
end

function SockCls:send(name, data)
    if self.sock_id > 0 then
        cluster_utils.send_agent_gate("ls_sock_send", self.sock_id, name, data)
    end
end

function SockCls:response(session, name, data)
    if self.sock_id > 0 then
        cluster_utils.send_agent_gate("ls_sock_response", self.sock_id, session, name, data)
    end
end
-------------------------SockCls end-------------------

return MOD