local skynet = require("skynet")

local function agent_start()
    xpcall(function()
        skynet.register('.agent')

        require("lua_handles")
        require("msg_utils.cluster_utils").start()
        require("msg_utils.cluster_utils")._is_agent_service = true
        require("db.schema").check_refresh_schema('schema_game')
        require("role_db").init()
        require("db.offline_db").init()
        require("server_data").start()
        require("agent_utils").on_server_start()
        require("msg_handles")
        require("global_mail").load_all_mail()
        require("questionnaire").load_all_question()

        require("srv_utils.reload").start()
        require("pay_order").start()
        skynet.call(".debug_console", "lua", "register_gm", "lc_x_gm")

        while agent_utils.check_agent_correlate_node() do
            skynet.sleep(10)
        end

        require("role_cls")
        require("cache_utils").start()
        require("hunt_utils").start()
        require("arena_utils").start()
        require("rank_utils").start()
        require("activity_utils").start()
        require("rush_activity_utils").start()
        require("recharge_activity_utils").start()
        require("festival_activity_utils").start()
        require("action_point_utils").start()
        require("fund_utils").start()
        require("luxury_check_in_utils").start()
        require("accum_recharge_utils").start()
        require("traitor_utils").start()
        require("traitor_boss_utils").start()
        require("daily_utils").start()

        -- 测试
        --require("flash_event_utils").start()
        --g_log:warn("flash_event_utils")

        -- 启动gate
        skynet.newservice("agent_gate")

        g_log:info("agent_start:", skynet.self())
    end, function(...) print(...) print(debug.traceback()) end)
end

local function init()
    require("excel_data").init()
end

init()
skynet.start(agent_start)
