local skynet = require("skynet")

local function start()
    local lua_handles_utils = require('msg_utils.lua_handles_utils')
    lua_handles_utils.add_handle_module("lua_handles")

    skynet.register('.cluster_router')
    require("srv_utils.reload").start()
    require("addr_mgr").start()
    g_log:info("cluster_router start:", skynet.self())
end

local function init()
end

init()
skynet.start(start)