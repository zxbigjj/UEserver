local skynet = require('skynet')
local SockCls = require("sock").SockCls
local msg_handles = require("msg_handles")

local M = DECLARE_MODULE("lua_handles.gate")

function M.ls_on_accept_sock(sock_id, ip, port)
    SockCls.add_sock(sock_id, ip, port)
end

function M.ls_on_close_sock(sock_id)
    SockCls.on_close(sock_id)
end

function M.ls_on_recv_sock(sock_id, session, proto_name, args)
    local sock = SockCls.sock_dict[sock_id]
    if not sock then return end
    sock.lock:run(function()
        local status, ret = xpcall(msg_handles.handle_c2s_msg, g_log.trace_handle, sock, proto_name, args)
        if session then
            if status then
                if ret then
                    sock:response(session, proto_name, ret)
                end
            else
                sock:response(session, proto_name, {errcode=1})
            end
        end
    end)
end

return M