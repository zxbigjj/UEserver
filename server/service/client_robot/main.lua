local skynet = require("skynet")

local function start_func()
    require("sys_utils.log").no_log_service = true

    local lua_handles_utils = require('msg_utils.lua_handles_utils')
    lua_handles_utils.add_handle_module("lua_handles")

    skynet.register('.client_robot')
end

local function init()
end

init()
skynet.start(start_func)