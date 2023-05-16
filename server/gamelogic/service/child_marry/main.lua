local skynet = require("skynet")
local cluster_utils = require("msg_utils.cluster_utils")

local function start()
    local cluster_utils = require("msg_utils.cluster_utils")
    cluster_utils.start()
    
    local lua_handles_utils = require('msg_utils.lua_handles_utils')
    lua_handles_utils.add_handle_module("lua_handles")

    skynet.register('.child_marry')
    require("srv_utils.reload").start()
    if skynet.getenv("server_type") == "game" then
        require("child_utils"):init("schema_game")
    elseif skynet.getenv("server_type") == "cross" then
        require("db.schema").check_refresh_schema('schema_cross')
        require("child_utils"):init("schema_cross")
    end

    lua_handles_utils.add_call_handle("lc_x_shutdown", function()
        require("child_utils").save_all()
    end)
    g_log:info("child_marry start:", skynet.self())
end

local function init()
end

init()
skynet.start(start)