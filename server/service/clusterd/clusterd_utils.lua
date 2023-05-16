local skynet = require("skynet")
local co_lock = require("srv_utils.co_lock")
local timer = require("timer")
local gate_utils = require("srv_utils.gate_utils")

local self_node_name = skynet.getenv("cluster_nodename")
local self_node_addr = skynet.getenv("cluster_nodeaddr")
local cluster_router_name = skynet.getenv("cluster_router_name")

local msg_profile = require("msg_utils.msg_profile")

local MAX_PACK_SIZE = 1024*1024*7

local M = DECLARE_MODULE("clusterd_utils")
DECLARE_RUNNING_ATTR(M, "router_map", {}) 

DECLARE_RUNNING_ATTR(M, "server_info_version", 0)
DECLARE_RUNNING_ATTR(M, "login_server_list", {})
DECLARE_RUNNING_ATTR(M, "game_server_list", {})

DECLARE_RUNNING_ATTR(M, "lua_handler", {})      -- lua handles
DECLARE_RUNNING_ATTR(M, "conn_dict", {})    -- in connections
DECLARE_RUNNING_ATTR(M, "node_dict", {})    -- out connnections
DECLARE_RUNNING_ATTR(M, "fast_addr", {})
DECLARE_RUNNING_ATTR(M, "trace_timer", nil, function()
    return timer.loop(1, function() M._trace_send_count() end)
end)
-----------------------------------------------trace send count
local SEND_COUNT = 0
local RECV_COUNT = 0
function M._trace_send_count()
    if false then
        print("clusterd_send_count:" .. SEND_COUNT)
        print("clusterd_recv_count:" .. RECV_COUNT)
    end
    SEND_COUNT = 0
    RECV_COUNT = 0
end
-----------------------------------------------trace send count

local function get_node(node_name)
    local node = M.node_dict[node_name]
    if node then return node end
    local addr = M.router_map[node_name]
    if not addr or addr == "" then
        g_log:error("cannot find node_name:" .. node_name)
        return
    end
    node = M.NodeCls.new(node_name, addr)
    M.node_dict[node_name] = node
    return node
end

local function update_node_addr(node_name, address)
    M.router_map[node_name] = address

    local node = M.node_dict[node_name]
    if node and node.address ~= address and address ~= "" then
        node:update_address(address)
    end
    
    local server_id, tag = node_name:match("s(%d+)_(%w+)")
    if tag == "login" then
        M.server_info_version = M.server_info_version + 1
        if address == "" then
            table.delete(M.login_server_list, node_name)
        else
            if not table.index(M.login_server_list, node_name) then
                table.insert(M.login_server_list, node_name)
            end
        end
    end
end
-----------------------------------------------node class
local NodeCls = DECLARE_CLASS(M, "NodeCls")
function NodeCls.new(node_name, address)
    local self = {}
    self.node_name = node_name
    self.address = address
    self.sock_id = nil
    self.last_session_id = 1
    self.session_dict = {}
    self.lock = co_lock.new()

    setmetatable(self, NodeCls)
    return self
end

function NodeCls:close()
    if self.sock_id then
        local sock_id = self.sock_id
        self.sock_id = nil
        gate_utils.close_sock(sock_id)
    end
end

function NodeCls:on_close()
    self.sock_id = nil
end

function NodeCls:update_address(address)
    self:close()
    self.address = address
end

function NodeCls:__connect()
    if self.sock_id then return end
    self.lock:run(function()
        if self.sock_id then return end
        if self.address == nil or self.address == "" then
            error("node maybe down: " .. self.node_name)
        end
        local host, port = string.match(self.address, "([^:]+):(.*)$")
        port = tonumber(port)
        g_log:info(string.format("connect %s %s", self.node_name, self.address))
        self.sock_id = gate_utils.connect(host, port)
        self:show_self()
    end) 
end

function NodeCls:_send(cmd, session_id, addr, args)
    SEND_COUNT = SEND_COUNT + 1
    if not self.sock_id then
        self:__connect()
    end

    local data = skynet.packstring(cmd, session_id, addr, args)
    if string.len(data) < MAX_PACK_SIZE then
        gate_utils.send_sock_data(self.sock_id, string.pack(">s3", data))
        return
    end
    -- 分包
    local index=1
    local padding_size = MAX_PACK_SIZE - 1024
    local p_data = nil
    for i=1, string.len(data), padding_size do
        p_data = skynet.packstring("padding", session_id, index, string.sub(data, i, i+padding_size-1))
        gate_utils.send_sock_data(self.sock_id, string.pack(">s3", p_data))
        index = index + 1
    end
    p_data = skynet.packstring("padding", session_id, index, "")
    gate_utils.send_sock_data(self.sock_id, string.pack(">s3", p_data))
end

function NodeCls:show_self()
    self:_send("show_self", nil, nil, {self_node_name, self.node_name, self_node_addr})
end

function NodeCls:wait_session(session)
    skynet.wait(session.co)
    self.session_dict[session.id] = nil
    if session.err then
        g_log:error(session.err, table.unpack(session.result, 1, session.result.n))
        error(session.err)
    end
    return table.unpack(session.result, 1, session.result.n)
end

function NodeCls:new_session()
    local session_id = self.last_session_id
    while true do
        session_id = session_id + 1
        if session_id >= 0x7fffffff then
            session_id = 1
        end
        if not self.session_dict[session_id] then break end
    end
    self.last_session_id = session_id
    local session = {id=session_id, co=coroutine.running()}
    self.session_dict[session_id] = session
    return session
end

-- 检查目标节点和服务是否存在
function NodeCls:probe(service_name)
    if service_name and string.sub(service_name, 1, 1) ~= "." then
        error("probe service_name must start with .")
    end
    local session = self:new_session()
    local status, ret, addr = pcall(function()
        self:_send("probe", session.id, service_name)
        return self:wait_session(session)
    end)
    if status then return ret, addr end
    return false
end

function NodeCls:send(addr, args)
    self:_send("send", nil, addr, args)
end

function NodeCls:call(addr, args)
    local session = self:new_session()
    self:_send("call", session.id, addr, args)
    return self:wait_session(session)
end

function NodeCls:resp(session_id, err, args)
    self:_send("resp", session_id, err, args)
end

function NodeCls:on_call_result(session_id, err, result)
    local session = self.session_dict[session_id]
    if not session then
        error("unknown resp", session_id, self.node_name)
    end
    self.session_dict[session_id] = nil
    session.err = err
    session.result = result
    skynet.wakeup(session.co)
end
-----------------------------------------------node class

-----------------------------------------------conn class
local ConnCls = DECLARE_CLASS(M, "ConnCls")
function ConnCls.new(fd, address)
    local self = {}
    self.fd = fd
    self.address = address
    self.node_name = nil
    self.padding = nil
    setmetatable(self, ConnCls)
    return self
end

function ConnCls:close()
    if self.fd then
        local fd = self.fd
        self.fd = nil
        gate_utils.close_sock(fd)
    end
end

function ConnCls:recv_msg(cmd, session, addr, args)
    RECV_COUNT = RECV_COUNT + 1
    if msg_profile.ProfileFlag then
        skynet.set_coroutine_stop_cb(function(used_time)
            msg_profile.on_handle_finish('_recv_msg', used_time)
        end)
    end
    local func = self["on_" .. cmd]
    func(self, session, addr, args)
end

function ConnCls:on_show_self(_, addr, args)
    g_log:info("clusterd show_self " .. args[1])
    if args[2] ~= self_node_name then
        g_log:error("show self error:" .. args[2])
        self:close()
        return
    end
    self.node_name = args[1]
    if args[3] then
        update_node_addr(args[1], args[3])
    end
end

function ConnCls:on_padding(session_id, index, data)
    if not self.padding then
        assert(index == 1)
        self.padding = {data_list={}, session_id=session_id}
        self.padding.data_list[index] = data
        return
    else
        if self.padding.session_id ~= session_id then
            g_log:error("clusterd session_id error")
            self.padding = nil
            self:on_padding(session_id, index, data)
            return
        end
        self.padding.data_list[index] = data
        if data == "" then
            -- over
            local msg = table.concat(self.padding.data_list, "")
            self.padding = nil
            self:recv_msg(msg)
        end
    end
end

function ConnCls:on_probe(session_id, service_name, args)
    local node = get_node(self.node_name)
    if not node then
        error("recv probe from unknown node:" .. self.fd .. "," .. self.node_name)
    end
    
    local status = xpcall(function()
        if service_name then
            local addr = skynet.localname(service_name)
            if addr then
                node:resp(session_id, nil, table.pack(true, addr))
            else
                node:resp(session_id, nil, table.pack(false))
            end
        else
            node:resp(session_id, nil, table.pack(true))
        end
    end, g_log.trace_handle)
    if not status then
        local err = string.format("cluster call fail:%s %s", self.node_name, service_name)
        node:resp(session_id, err, args)
    end
end

local addr_cache = {}
local function convert_addr(addr)
    if string.sub(addr, 1, 1) == "." then
        local ret = skynet.localname(addr)
        if not ret then
            error("unknown addr:" .. addr)
        end
        addr_cache[addr] = ret
        return ret
    else
        addr_cache[addr] = addr
        return addr
    end
end

function ConnCls:on_send(session_id, addr, args)
    addr = addr_cache[addr] or convert_addr(addr)
    if M.fast_addr[addr] then
        skynet.send(addr, "lua", "ls_x_clusterd", args)
    else
        skynet.send(addr, "lua", skynet.unpack(args))
    end
end
function ConnCls:on_call(session_id, addr, args)
    addr = addr_cache[addr] or convert_addr(addr)
    local node = get_node(self.node_name)
    if not node then
        error("recv call from unknown node:" .. self.fd .. "," .. self.node_name)
    end
    local status = xpcall(function()
        if M.fast_addr[addr] then
            node:resp(session_id, nil, table.pack(
                skynet.call(addr, "lua", "lc_x_clusterd", args)))
        else
            node:resp(session_id, nil, table.pack(
                skynet.call(addr, "lua", skynet.unpack(args))))
        end
    end, g_log.trace_handle)
    if not status then
        local err = string.format("cluster call fail:%s %s", self_node_name, addr)
        node:resp(session_id, err, table.pack(skynet.unpack(args)))
    end
end
function ConnCls:on_resp(session_id, err, result)
    local node = get_node(self.node_name)
    if not node then
        error("recv resp from unknown node:" .. self.fd .. "," .. self.node_name)
    end
    node:on_call_result(session_id, err, result)
end
-----------------------------------------------conn class

-----------------------------------------------lua cmd
local lua_handler = M.lua_handler

function lua_handler.lc_probe(node_name, address)
    local node = get_node(node_name)
    if not node then
        return false
    end
    return node:probe(address)
end

function lua_handler.ls_send(node_name, address, buffer, sz)
    local args = skynet.tostring(buffer, sz)
    skynet.trash(buffer, sz)
    local node = get_node(node_name)
    if not node then
        g_log:error("ls_send unknown node", node_name, address, args)
        error("unknown node:" .. node_name)
    end
    node:send(address, args)
end

function lua_handler.lc_call(node_name, address, buffer, sz)
    local args = skynet.tostring(buffer, sz)
    skynet.trash(buffer, sz)
    local node = get_node(node_name)
    if not node then
        g_log:error("ls_send unknown node", node_name, address, args)
        error("unknown node:" .. node_name)
    end
    return node:call(address, args)
end

function lua_handler.ls_update_node_addr(addr_dict)
    for node_name, address in pairs(addr_dict) do
        if type(address) == "string" then
            update_node_addr(node_name, address)
        else
            error(string.format("node address error:%s %s", node_name, address))
        end
    end
end

function lua_handler.ls_update_all_game(game_server_list)
    M.game_server_list = game_server_list
    M.server_info_version = M.server_info_version + 1
end

function lua_handler.ls_set_fast_mode(addr)
    addr = addr_cache[addr] or convert_addr(addr)
    M.fast_addr[addr] = true
end

function lua_handler.lc_query_server_info(version)
    if version < M.server_info_version then
        return {
            version = M.server_info_version,
            login_server_list = M.login_server_list, 
            game_server_list=M.game_server_list,
        }
    end
end

function lua_handler.lc_query_router_map()
    return M.router_map
end

function lua_handler.lc_shutdown()
    if self_node_name ~= cluster_router_name then
        pcall(function()
            lua_handler.lc_call(cluster_router_name, ".cluster_router", 
                skynet.pack("lc_node_shutdown", self_node_name))
        end)
    end
end

-----------------------------------------------lua cmd
function M.reg_lua_handles()
    local lua_handles_utils = require("msg_utils.lua_handles_utils")
    for k,v in pairs(M.lua_handler) do
        if string.match(k, "^ls_") then
            lua_handles_utils.add_send_handle(k, v)
        elseif string.match(k, "^lc_") then
            lua_handles_utils.add_call_handle(k, v)
        end
    end
end

local refresh_all_count = 3

function M.send_heartbreak()
    skynet.timeout(100, function() M.send_heartbreak() end)

    local ok = pcall(function()
        lua_handler.ls_send(cluster_router_name, ".cluster_router", 
            skynet.pack("ls_node_heartbreak", self_node_name, self_node_addr, refresh_all_count > 0))
    end)
    if not ok then
        g_log:error("cluster_router may crashed!")
    else
        if refresh_all_count > 0 then
            refresh_all_count = refresh_all_count - 1
        end
    end
end

function M.on_accept_sock(sock_id, ip, port)
    local address = string.format("%s:%s", ip, port)
    g_log:info(string.format("socket accept from %s, %d", address, sock_id))
    assert(M.conn_dict[sock_id] == nil)
    M.conn_dict[sock_id] = ConnCls.new(sock_id, address)
end

function M.on_close_sock(sock_id)
    g_log:info("close socket " .. sock_id)
    M.conn_dict[sock_id] = nil
    for _, node in pairs(M.node_dict) do
        if node.sock_id == sock_id then
            node:on_close()
        end
    end
end

function M.on_recv_data(sock_id, ...)
    local conn = M.conn_dict[sock_id]
    if conn then
        conn:recv_msg(...)
    end
end

function M.start()
    M.router_map[cluster_router_name] = skynet.getenv("cluster_router")
    gate_utils.start(skynet.getenv("cluster_port"), 65535, "M", nil, skynet.unpack)
    gate_utils.set_recv_data_handle(M.on_recv_data)
    gate_utils.set_accept_sock_handle(M.on_accept_sock)
    gate_utils.set_close_sock_handle(M.on_close_sock)

    M.reg_lua_handles()
    if self_node_name ~= cluster_router_name then
        M.send_heartbreak()
    end
end

if M.__RELOADING then
    -- reloading
    M.reg_lua_handles()
end

return M