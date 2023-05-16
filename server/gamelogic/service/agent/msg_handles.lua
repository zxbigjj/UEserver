local skynet = require('skynet')

-- 原生消息， 以socket_id为参数
local HANDLE_TYPE_RAW = 1
-- 角色消息， 以role为参数
local HANDLE_TYPE_ROLE = 2

local handle_modules = {
    login = HANDLE_TYPE_RAW,
    role = HANDLE_TYPE_ROLE,
    hero = HANDLE_TYPE_ROLE,
    lover = HANDLE_TYPE_ROLE,
    child = HANDLE_TYPE_ROLE,
    hunt = HANDLE_TYPE_ROLE,
    bag = HANDLE_TYPE_ROLE,
    stage = HANDLE_TYPE_ROLE,
    lineup = HANDLE_TYPE_ROLE,
    arena = HANDLE_TYPE_ROLE,
    treasure = HANDLE_TYPE_ROLE,
    train = HANDLE_TYPE_ROLE,
    mail = HANDLE_TYPE_ROLE,
    party = HANDLE_TYPE_ROLE,
    dynasty = HANDLE_TYPE_ROLE,
    friend = HANDLE_TYPE_ROLE,
    recharge = HANDLE_TYPE_ROLE,
    traitor = HANDLE_TYPE_ROLE,
    title = HANDLE_TYPE_ROLE,
    activity = HANDLE_TYPE_ROLE,
}

local msg_handles = DECLARE_MODULE("msg_handles")
DECLARE_RUNNING_ATTR(msg_handles, "handles_hub", {})
DECLARE_RUNNING_ATTR(msg_handles, "msg_profile", nil, function()
    return require("msg_utils.msg_profile").MsgProfile.New()
end)

function msg_handles.add_handle_module(mod_name, handle_type)
    local reload = require("srv_utils.reload")
    local mod = require(mod_name)
    reload.set_reload_after_callback(mod, function()
        msg_handles.add_handle_module(mod_name, handle_type)
    end)
    -- 添加
    for name, func in pairs(mod) do
        if type(func) == "function" and string.sub(name, 1, 2) ~= "__" then
            if msg_handles.handles_hub[name] and msg_handles.handles_hub[name].mod_name ~= mod_name then
                error(string.format("重复的msg handler:%s %s %s", name, mod_name, msg_handles.handles_hub[name].mod_name))
            end
            msg_handles.handles_hub[name] = {func=func, handle_type=handle_type, mod_name=mod_name}
        end
    end
end

function msg_handles.handle_c2s_msg(sock, proto_name, args)
    skynet.set_coroutine_stop_cb(function(used_time) msg_handles.msg_profile:on_handle_finish(proto_name, used_time) end)
    local handle = msg_handles.handles_hub[proto_name]
    if not handle then
        error("proto name:" .. proto_name .. " no handles function")
    end
    if handle.handle_type == HANDLE_TYPE_ROLE then
        if not sock.role then
            -- error("proto name:" .. proto_name .. " need role object")
            return
        end
        return handle.func(sock.role, args)
    else
        return handle.func(sock, args)
    end
end

-- 注册
skynet.report_debug_info("msg_handle", function() return table.concat(msg_handles.msg_profile:format_lines(), "\n") end)
for mod_name, handle_type in pairs(handle_modules) do
	msg_handles.add_handle_module('msg_handles.' .. mod_name, handle_type)
end

return msg_handles
