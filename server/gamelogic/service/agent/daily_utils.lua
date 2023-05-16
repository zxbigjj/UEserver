local date = require("sys_utils.date")

local daily_utils = DECLARE_MODULE("daily_utils")

-- 6点刷新
function daily_utils.check_six_loop()
    skynet.timeout(100, function() daily_utils.check_six_loop() end)
    local server_data = require("server_data")
    local last_daily_ts = server_data.get_server_core("last_daily_ts")
    local now = date.time_second()
    if last_daily_ts >= date.get_begin6(now) then
        return
    end
    server_data.set_server_core("last_daily_ts", now)
    --先刷新系统模块-----------------------

    ---------------------------------------
    -- 刷新所有在线玩家
    -- local sleep_count = 10
    -- for _, uuid in pairs(agent_utils.get_online_uuid()) do
    --     local role = agent_utils.get_role(uuid)
    --     if role then
    --         xpcall(function() return role:check_daily_refresh() end, g_log.trace_handle)
    --         sleep_count = sleep_count - 1
    --         if sleep_count == 0 then
    --             sleep_count = 10
    --             skynet.sleep(1)
    --         end
    --     end
    -- end
end

-- 0点刷新
function daily_utils.check_zero_loop()
    skynet.timeout(100, function() daily_utils.check_zero_loop() end)
    local server_data = require("server_data")
    local last_zero_daily_ts = server_data.get_server_core("last_zero_daily_ts")
    local now = date.time_second()
    if last_zero_daily_ts >= date.get_begin0(now) then
        return
    end
    server_data.set_server_core("last_zero_daily_ts", now)
    --先刷新系统模块-----------------------
    xpcall(function() return agent_utils.refresh_dynasty() end, g_log.trace_handle)
    xpcall(function() return require("traitor_utils").daily_refresh() end, g_log.trace_handle)
    xpcall(function() return require("traitor_boss_utils").daily_refresh() end, g_log.trace_handle)

    ---------------------------------------
    -- 刷新所有在线玩家
    local sleep_count = 10
    for _, uuid in pairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        if role then
            xpcall(function() return role:check_daily_zero_refresh() end, g_log.trace_handle)
            sleep_count = sleep_count - 1
            if sleep_count == 0 then
                sleep_count = 10
                skynet.sleep(1)
            end
        end
    end
end

function daily_utils.check_hour_loop()
    skynet.timeout(100, function() daily_utils.check_hour_loop() end)
    local server_data = require("server_data")
    local last_hour_ts = server_data.get_server_core("last_hour_ts")
    local now = date.time_second()
    if last_hour_ts >= date.get_hour_begin6(now) then
        return
    end
    server_data.set_server_core("last_hour_ts", now)
    --先刷新系统模块-----------------------
    xpcall(function() return require("arena_utils").give_rank_reward(last_hour_ts) end, g_log.trace_handle)

    ---------------------------------------
    -- 刷新所有在线玩家
    local sleep_count = 10
    for _, uuid in pairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        if role then
            xpcall(function() return role:check_hourly_refresh() end, g_log.trace_handle)
            sleep_count = sleep_count - 1
            if sleep_count == 0 then
                sleep_count = 10
                skynet.sleep(1)
            end
        end
    end
end

function daily_utils.start()
    daily_utils.check_hour_loop()
    daily_utils.check_six_loop()
    daily_utils.check_zero_loop()
end

return daily_utils