local M = DECLARE_MODULE("robot")

local gate_utils = require("srv_utils.gate_utils")
local sproto_msg_utils = require("msg_utils.sproto_msg_utils")
local timer = require("timer")
local io_utils = require("sys_utils.io_utils")

function M.new(account)
    local self = {
        _sock = nil,
        _session_guid = 0,
        _session_dict = {},
        _discard_all_msg = nil,

        account = account,
        smsg_handlers = {},
        event_waiter = {},
        event_waiter_args = {},

        urs = nil,
        uuid = nil,
    }
    setmetatable(self, M)
    self.heartbreak_timer = timer.loop(3, function()
        if self._sock then
            self:send("c_heartbeat", {}, true)
        end
    end)
    return self
end

function M:on_recv(data)
    if self._discard_all_msg then return end
    local t, name, msg = sproto_msg_utils.decode_server_msg(data)
    if t == 'req' then
        if self.smsg_handlers[name] then
            skynet.fork(function()
                local ok, msg = pcall(self.smsg_handlers[name], msg)
                if not ok then
                    self:log("HandleError", name)
                end
            end)
        else
            self:handle_smsg(name, msg)
        end
        
    elseif t == 'resp' then
        local session = name
        local req_info = self._session_dict[session]
        if not req_info then return end
        self._session_dict[session] = sproto_msg_utils.decode_c2s_response(req_info[1], msg)
        skynet.wakeup(req_info[2])
    else
        assert(false, 'never got here')
    end
end

function M:_send(name, args, session)
    local data = sproto_msg_utils.encode_c2s_req(name, args, session)
    data = sproto_msg_utils.pack_client_msg(data)
    gate_utils.send_sock_data(self._sock, data)
end

function M:discard_all_msg(value)
    self._discard_all_msg = value
    if self._sock then
        gate_utils.discard_income(self._sock, value)
    end
end

function M:handle_smsg(name, msg)
    if M[name] then
        skynet.fork(function()
            local ok, msg = pcall(M[name], self, msg)
            if not ok then
                self:log("HandleError", name, msg)
            end
        end)
    end
    self:fire_event("smsg:" .. name, msg)
end

function M:send(name, args, no_resp)
    args = args or {}
    local proto = sproto_msg_utils.query_c2s_proto(name)
    if proto.response and not no_resp then
        local session = self._session_guid + 1
        self._session_guid = session
        local co = coroutine.running()
        self._session_dict[session] = {name, co}
        self:_send(name, args, session)
        skynet.wait()
        local resp = self._session_dict[session]
        self._session_dict[session] = nil
        return resp
    else
        self:_send(name, args)
    end
end

function M:wait_event(event_name)
    local waiter_list = self.event_waiter[event_name]
    if not waiter_list then
        waiter_list = {}
        self.event_waiter[event_name] = waiter_list
    end
    local co = coroutine.running()
    table.insert(waiter_list, co)
    skynet.wait()
    local args = self.event_waiter_args[co]
    self.event_waiter_args[co] = nil
    return args
end

function M:fire_event(event_name, args)
    local waiter_list = self.event_waiter[event_name]
    if not waiter_list then return end
    self.event_waiter[event_name] = nil

    for _, co in ipairs(waiter_list) do
        self.event_waiter_args[co] = args
        skynet.wakeup(co)
    end
end

function M:wait_smsg(smsg_name)
    return self:wait_event("smsg:" .. smsg_name)
end

function M:connect(host, port)
    self:close()
    self._sock = gate_utils.connect(host, port)
    return self._sock
end

function M:close()
    if self._sock then
        gate_utils.close_sock(self._sock)
        self._sock = nil
        self:log("Close")
    end
end

function M:log(tag, ...)
    local out_list = {string.format("----> %s: %s", tag, self.account)}
    local args = table.pack(...)
    for i=1, args.n do
        table.insert(out_list, tostring(args[i]))
    end
    print(table.concat(out_list, ", "))
end

---------------------------------基础功能-----------------
function M:login()
    local resp = self:send('c_login', {urs=self.account})
    self.urs = resp.urs
    self.token = resp.token
    if resp.no_role then
        self:send('c_new_role', {urs=self.urs, role_name=self.urs, role_id=1})
    end
end

function M:gm(cmd, arg1, ...)
    if arg1 ~= nil then
        cmd = string.format(cmd, arg1, ...)
    end
    self:send("c_gm", {cmd=cmd}, true)
end

function M:sleep(seconds)
    skynet.sleep(seconds * 100)
end
------------------------------smsg handler------------------
function M:s_update_base_info(msg)
    -- PRINT("-------s_update_base_info--------", msg)
end
---------------------------------------测试逻辑---------------------
function M:test()
    PRINT("---------test--------")
    self:gm("test")
end

return M