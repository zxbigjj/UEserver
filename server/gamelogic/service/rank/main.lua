local skynet = require("skynet")

local function start()
    local cluster_utils = require("msg_utils.cluster_utils")
    cluster_utils.start()
    
    local lua_handles_utils = require('msg_utils.lua_handles_utils')
    lua_handles_utils.add_handle_module("lua_handles")

    skynet.register('.rank')
    require("srv_utils.reload").start()

    local rank_utils = require("rank_utils")
    rank_utils.start()
    lua_handles_utils.add_call_handle("lc_x_shutdown", function()
        rank_utils.save_rank()
    end)
    g_log:info("rank start:", skynet.self())
end

local function init()
    require("excel_data").init()
end

init()
skynet.start(start)