local skynet = require('skynet')
require('skynet.manager')

local server_env = require('srv_utils.server_env')

local function db_service_start()
    require("patch_utils").do_patch()
    
    local lua_handles_utils = require('msg_utils.lua_handles_utils')
    lua_handles_utils.add_handle_module("lua_handles")

    skynet.register('.gamedb')
    require("srv_utils.reload").start()
    g_log:info("gamedb service boot success!")
end

skynet.start(db_service_start)