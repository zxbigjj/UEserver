local skynet = require("skynet")

local function start_func()
    require("msg_utils.cluster_utils").start()
    
    local pay_order = require("pay_order")
    login_utils.db_init()
    local lua_handles_utils = require('msg_utils.lua_handles_utils')
    lua_handles_utils.add_handle_module("lua_handles")
    skynet.register('.pay')
    require("srv_utils.reload").start()
    local pay_order = require("pay_order")
    login_utils.listen_http()
end

local function init()
end

init()
skynet.start(start_func)
