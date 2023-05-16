local global = DECLARE_MODULE("gate_global")

local gate_utils = require('srv_utils.gate_utils')

DECLARE_RUNNING_ATTR(global, "sock_dict", {})
DECLARE_RUNNING_ATTR(global, "role_sock_mapper", {})
DECLARE_RUNNING_ATTR(global, "role_count", 0)

function global.get_uuid(sock_id)
    local sock = global.sock_dict[sock_id]
    if sock then return sock.uuid end
end

function global.unbind_sock(sock_id)
    local sock = global.sock_dict[sock_id]
    if sock then
        if sock.uuid then
            g_log:gate("UnbindSock", sock_id, sock.uuid)
            global.role_sock_mapper[sock.uuid] = nil
            global.role_count = global.role_count - 1
            gate_utils.bind(sock_id, 0)
        end
        sock.uuid = nil
    end
end

function global.unbind_role(uuid)
    local sock_id = global.role_sock_mapper[uuid]
    if sock_id then
        g_log:gate("UnbindRole", uuid, sock_id)
        local sock = global.sock_dict[sock_id]
        if sock then
            sock.uuid = nil
        end
        global.role_sock_mapper[uuid] = nil
        global.role_count = global.role_count - 1
        gate_utils.bind(sock_id, 0)
    end
end

function global.bind_role(sock_id, uuid)
    global.unbind_sock(sock_id)
    global.unbind_role(uuid)

    g_log:gate("Bind", sock_id, uuid)
    local sock = global.sock_dict[sock_id]
    if sock then
        sock.uuid = uuid
        global.role_sock_mapper[uuid] = sock_id
        global.role_count = global.role_count + 1
        gate_utils.bind(sock_id, uuid)
    end
end

return global