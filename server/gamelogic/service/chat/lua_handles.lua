local lua_handles = DECLARE_MODULE("lua_handles")

local chat_utils = require("chat_utils")

function lua_handles.ls_enter_chat(uuid, channel_name)
    chat_utils.enter_channel(uuid, channel_name)
end

function lua_handles.ls_leave_chat(uuid, channel_name)
    chat_utils.leave_channel(uuid, channel_name)
end

function lua_handles.ls_dissolve_chat(channel_name)
    chat_utils.dissolve_channel(channel_name)
end

function lua_handles.ls_broad_chat(channel_name, msg)
    chat_utils.broad_chat(channel_name, msg)
end

return lua_handles