local skynet = require("skynet")

local function start()
    local cluster_utils = require("msg_utils.cluster_utils")
    cluster_utils.start()
    require("db.schema").check_refresh_schema('schema_world')

    local lua_handles_utils = require('msg_utils.lua_handles_utils')
    lua_handles_utils.add_handle_module("lua_handles")

    require("gift_key").start()

    require("pay_order").start()

    skynet.register('.world')
    require("srv_utils.reload").start()
    g_log:info("world start:", skynet.self())
end

local function init()
end

init()
skynet.start(start)