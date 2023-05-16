local skynet = require("skynet")

local function start()
    require("msg_utils.cluster_utils").start()
    
    local lua_handles_utils = require('msg_utils.lua_handles_utils')
    lua_handles_utils.add_handle_module("lua_handles")

    skynet.register('.gm_router')
    require("srv_utils.reload").start()
    require("gm_router").start()

    local cluster_utils = require("msg_utils.cluster_utils")

    g_log:info("gm_router start:", skynet.self())
end

local function init()
end

init()
skynet.start(start)