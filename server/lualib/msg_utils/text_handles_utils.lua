-- text handle入口
local skynet = require("skynet")
local msg_utils = DECLARE_MODULE("msg_utils.text_handles_utils")
DECLARE_RUNNING_ATTR(msg_utils, "handles_hub", {})
DECLARE_RUNNING_ATTR(msg_utils, "default_handle", nil)

function msg_utils.add_handle_module(mod)
    local reload = require("srv_utils.reload")
    if type(mod) == "string" then
        mod = require(mod)
    end
    reload.set_reload_after_callback(mod, function() 
        msg_utils.add_handle_module(mod)
    end)
    -- 添加
    for name, func in pairs(mod) do
        if type(func) == "function" then
            msg_utils.handles_hub[name] = func
        end
    end
end

function msg_utils.add_handle(name, func)
    msg_utils.handles_hub[name] = func
end

function msg_utils.set_default_handle(func)
    msg_utils.default_handle = func
end

function msg_utils._text_handle(session, address, text)
    local cmd, param = string.match(text, "([%w_]+) (.*)")
    local func = msg_utils.handles_hub[cmd]
    if func then
        func(session, address, param)
    else
        default_handle = msg_utils.default_handle
        if default_handle then
            default_handle(session, address, cmd, param)
        else
            g_log:error("no text handle for: " .. cmd)
        end
    end
end

function msg_utils._start()
    skynet.register_protocol({
        name = "text",
        id = skynet.PTYPE_TEXT,
        pack = function (...)
            local n = select ("#" , ...)
            if n == 0 then
                return ""
            elseif n == 1 then
                return tostring(...)
            else
                return table.concat({...}," ")
            end
        end,
        unpack = skynet.tostring,
        dispatch = function (...)
            msg_utils._text_handle(...)
        end
    })
end

if msg_utils.__RELOADING then
    -- 热更新
else
    -- 第一次加载
    msg_utils._start()
end
return msg_utils
