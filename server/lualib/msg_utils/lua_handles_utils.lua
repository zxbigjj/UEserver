-- lua handle入口
local skynet = require("skynet")
local msg_utils = DECLARE_MODULE("msg_utils.lua_handles_utils")
local msg_profile = require("msg_utils.msg_profile")

DECLARE_RUNNING_ATTR(msg_utils, "default_handle", nil)
DECLARE_RUNNING_ATTR(msg_utils, "handles_hub", {})
DECLARE_RUNNING_ATTR(msg_utils, "handle_mod_mapper", {})

function msg_utils.add_handle_module(mod_name)
    local reload = require("srv_utils.reload")
    local mod = require(mod_name)
    reload.set_reload_after_callback(mod, function() 
        msg_utils.add_handle_module(mod_name)
    end)
    -- 添加
    for name, func in pairs(mod) do
        if type(func) == "function" then
            if string.match(name, "^ls_") then
                msg_utils.add_send_handle(name, func, mod_name)
            elseif string.match(name, "^lc_") then
                msg_utils.add_call_handle(name, func, mod_name)
            else
                -- ignore
            end
        end
    end
end

function msg_utils.get_handle_mod_name(name)
    return msg_utils.handle_mod_mapper[name]
end

function msg_utils.add_send_handle(name, func, mod_name)
    mod_name = mod_name or ""
    local old_mod_name = msg_utils.handle_mod_mapper[name]
    if old_mod_name and old_mod_name ~= mod_name then
        error(string.format("%s has registered:%s %s", name, old_mod_name, mod_name))
    end
    msg_utils.handle_mod_mapper[name] = mod_name
    msg_utils.handles_hub[name] = func
end

function msg_utils.add_call_handle(name, func, mod_name)
    mod_name = mod_name or ""
    local old_mod_name = msg_utils.handle_mod_mapper[name]
    if old_mod_name and old_mod_name ~= mod_name then
        error(string.format("%s has registered:%s %s", name, old_mod_name, mod_name))
    end
    msg_utils.handle_mod_mapper[name] = mod_name
    msg_utils.handles_hub[name] = function(...)
        skynet.retpack(func(...))
    end
end

function msg_utils.set_default_handle(func)
    msg_utils.default_handle = func
end

function msg_utils._lua_handle(session, address, cmd, ...)
    if msg_profile.ProfileFlag then
        skynet.set_coroutine_stop_cb(function(used_time)
            msg_profile.on_handle_finish('l-' .. cmd, used_time)
        end)
    end
    local func = msg_utils.handles_hub[cmd]
    if func then
        func(...)
    else
        if msg_utils.default_handle then
            msg_utils.default_handle(session, address, cmd, ...)
        else
            g_log:error("no lua handle for: " .. cmd, address, ...)
            error("no lua handle for: " .. cmd)
        end
    end
end

function msg_utils.register_dispatch()
    skynet.dispatch("lua", function(...) return msg_utils._lua_handle(...) end)
    msg_utils.handles_hub["ls_x_clusterd"] = function(data)
        msg_utils._lua_handle(nil, nil, skynet.unpack(data))
    end
    msg_utils.handles_hub["lc_x_clusterd"] = function(data)
        msg_utils._lua_handle(nil, nil, skynet.unpack(data))
    end
    skynet.timeout(1, function()
        local clusterd = nil
        while true do
            clusterd = skynet.localname(".clusterd")
            if clusterd then break end
            skynet.sleep(100)
        end
        if skynet.self() ~= clusterd then
            skynet.send(clusterd, "lua", "ls_set_fast_mode", skynet.self())
        end
    end)
end

if msg_utils.__RELOADING then
    -- 热更新
else
    -- 第一次加载
    msg_utils.register_dispatch()
end
return msg_utils
