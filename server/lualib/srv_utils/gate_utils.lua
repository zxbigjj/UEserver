-- 管理gate收发socket
-- 每个service只能起一个gate
local core = require("skynet.core")
local skynet = require('skynet')
local socket = require("skynet.socket")
local bin_utils = require("bin_utils")

local gate_utils = DECLARE_MODULE("srv_utils.gate_utils")
DECLARE_RUNNING_ATTR(gate_utils, "gate_service", nil)
DECLARE_RUNNING_ATTR(gate_utils, "connecting_socks", {})
DECLARE_RUNNING_ATTR(gate_utils, "on_recv_data", function(...)
    print("gate on_recv_data", ...)
end)
DECLARE_RUNNING_ATTR(gate_utils, "on_accept_sock", function(...)
    print("gate on_accept_sock", ...)
end)
DECLARE_RUNNING_ATTR(gate_utils, "on_close_sock", function(...)
    print("gate on_close_sock", ...)
end)

local MAX_MSG = 1024*1024*15 + 1024*1023

function gate_utils.start(bind_port, max_connect_count, head_type, sender_count, unpack)
    -- 注册协议
    head_type = head_type or "S"
    skynet.register_protocol({
        name = 'client',
        id = skynet.PTYPE_CLIENT,
        pack = function() error("never get here") end,
        unpack = unpack or skynet.tostring,
        dispatch = function (sock_id, address, ...)
            gate_utils.on_recv_data(sock_id, ...)
            skynet.ignoreret()
        end
    })

    -- 启动gate
    local bind_address = "!"    -- 不监听端口
    if bind_port then
        bind_address = string.format(":::%d", bind_port)
    end
    sender_count = sender_count or 2
    gate_utils.gate_service = skynet.launch('gate', head_type, 
        skynet.address(skynet.self()), bind_address, skynet.PTYPE_CLIENT, max_connect_count, sender_count)
end

function gate_utils.close_gate()
    skynet.call(gate_utils.gate_service, 'text', 'close')
end

function gate_utils.start_sock(sock_id)
    skynet.call(gate_utils.gate_service, 'text', 'start', sock_id)
end

function gate_utils.close_sock(sock_id)
    skynet.send(gate_utils.gate_service, 'text', 'kick', sock_id)
end

function gate_utils.discard_income(sock_id, value)
    if value then
        skynet.send(gate_utils.gate_service, 'text', 'discard_income_on', sock_id)
    else
        skynet.send(gate_utils.gate_service, 'text', 'discard_income_off', sock_id)
    end
end

function gate_utils.bind(sock_id, uuid)
    skynet.send(gate_utils.gate_service, 'text', 'bind', sock_id, uuid or 0)
end

-- connect
function gate_utils.connect(host, port)
    local sock_id = skynet.call(gate_utils.gate_service, 'text', 'connect', host, port)
    sock_id = tonumber(sock_id)
    if not sock_id or sock_id <= 0 then
        error(string.format("connect fail: %s, %s", host, port))
    end
    local co = coroutine.running()
    gate_utils.connecting_socks[sock_id] = co
    skynet.wait(co)
    local err = gate_utils.connecting_socks[sock_id]
    gate_utils.connecting_socks[sock_id] = nil
    if err ~= 'ok' then
        --测试
        print(debug.traceback())
        error(string.format("connect fail: %s, %s, %s", host, port, err))
    end
    return sock_id
end

function gate_utils.on_connect_finish(sock_id, result)
    local co = gate_utils.connecting_socks[sock_id]
    if not co then return end
    gate_utils.connecting_socks[sock_id] = result
    skynet.wakeup(co)
end

function gate_utils.send_sock_data(sock_id, data)
    -- sock_id放到session_id
    core.send(gate_utils.gate_service, skynet.PTYPE_CLIENT, sock_id, data)
end

-- uuid_list 是二进制编码， 4位一个
function gate_utils.broad_sock_data(uuid_list, data, exclude_uuid)
    if not uuid_list then return end
    if type(uuid_list) ~= "string" then
        uuid_list = bin_utils.pack_int32_list(uuid_list)
    end
    local len = math.floor(#uuid_list/4)
    exclude_uuid = exclude_uuid or 0
    core.send(gate_utils.gate_service, skynet.PTYPE_CLIENT, 0, 
        data .. uuid_list .. string.pack("<i4i4", len, exclude_uuid))
end

function gate_utils.set_recv_data_handle(func)
    gate_utils.on_recv_data = func
end

function gate_utils.set_accept_sock_handle(func)
    gate_utils.on_accept_sock = func
end

function gate_utils.set_close_sock_handle(func)
    gate_utils.on_close_sock = func
end

function gate_utils._on_accept_sock(session, address, param)
    local sock_id, ip, port = string.match(param, "(%d+) ([^ ]+):(%d+)")
    sock_id = tonumber(sock_id)
    port = tonumber(port)

    if gate_utils.on_accept_sock(sock_id, ip, port) == false then
        -- 失败
        gate_utils.close_sock(sock_id)
        return
    end
    gate_utils.start_sock(sock_id)
end

function gate_utils._on_close_sock(session, address, param)
    local sock_id = tonumber(param)
    if gate_utils.connecting_socks[sock_id] then
        gate_utils.on_connect_finish(sock_id, "close")
    end
    gate_utils.on_close_sock(sock_id)
end

function gate_utils._on_sock_error(session, address, param)
    local sock_id = tonumber(param)
    if gate_utils.connecting_socks[sock_id] then
        gate_utils.on_connect_finish(sock_id, "error")
    end
    gate_utils.on_close_sock(sock_id)
end

function gate_utils._on_sock_connect(session, address, param)
    local sock_id = tonumber(param)
    if gate_utils.connecting_socks[sock_id] then
        gate_utils.on_connect_finish(sock_id, 'ok')
    end
end

local text_handles_utils = require("msg_utils.text_handles_utils")
text_handles_utils.add_handle("accept_sock", gate_utils._on_accept_sock)
text_handles_utils.add_handle("close_sock", gate_utils._on_close_sock)
text_handles_utils.add_handle("sock_error", gate_utils._on_sock_error)
text_handles_utils.add_handle("sock_connect", gate_utils._on_sock_connect)
return gate_utils
