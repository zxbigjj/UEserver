local skynet = require("skynet")
local cluster_utils = require("msg_utils.cluster_utils")

local function dynasty_mgr_start()
    local cluster_utils = require("msg_utils.cluster_utils")
    cluster_utils.start()
    
    require("db.schema").check_refresh_schema('schema_dynasty')
    local lua_handles_utils = require('msg_utils.lua_handles_utils')
    lua_handles_utils.add_handle_module("lua_handles")

    skynet.register('.dynasty')
    require("srv_utils.reload").start()
    if skynet.getenv("server_type") == "game" then
        local dynasty_utils = require("dynasty_utils")
        dynasty_utils.init()
        lua_handles_utils.add_call_handle("lc_x_shutdown", function()
            dynasty_utils.save_all()
        end)
        while true do
            local ok = pcall(function() cluster_utils.call_agent(nil, nil, "lc_set_agent_start", "dynasty") end)
            if ok then break end
            skynet.sleep(10)
        end
    elseif skynet.getenv("server_type") == "cross" then
        local dynasty_rank = require("dynasty_rank")
        dynasty_rank.init(true)
        lua_handles_utils.add_call_handle("lc_x_shutdown", function()
            dynasty_rank.save_rank()
        end)
    end
    g_log:info("dynasty_mgr_start start:", skynet.self())
end

local function init()
    require("excel_data").init()
end

init()
skynet.start(dynasty_mgr_start)