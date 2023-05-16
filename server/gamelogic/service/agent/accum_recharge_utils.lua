local timer = require("timer")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local agent_utils = require("agent_utils")
local server_data = require("server_data")

local accum_recharge_utils = DECLARE_MODULE("accum_recharge_utils")
DECLARE_RUNNING_ATTR(accum_recharge_utils, "activity_obj", nil) -- 活动对象

function accum_recharge_utils.start()
    accum_recharge_utils.new_obj(excel_data.SingleRechargeData.accumulated_recharge_activity)
end

-- 活动是否开启
function accum_recharge_utils.activity_is_started()
    return accum_recharge_utils.activity_obj.state == CSConst.ActivityState.started
end

-- 初始化活动对象
function accum_recharge_utils.new_obj(data)
    accum_recharge_utils.activity_obj = {
        duration_sec = data.duration_sec,
        reserve_sec = data.reserve_sec,
        interval_sec = data.interval_sec,
    }
    local obj = accum_recharge_utils.activity_obj

    local now_ts = date.time_second()
    local open_ts = date.get_begin0(server_data.get_server_core("server_open_time"))
    local loop_sec = obj.duration_sec + obj.reserve_sec + obj.interval_sec
    local total_sec = now_ts - open_ts + obj.interval_sec
    local loop_count = total_sec // loop_sec

    obj.start_ts = open_ts + loop_sec * loop_count
    obj.stop_ts = obj.start_ts + obj.duration_sec
    obj.end_ts = obj.stop_ts + obj.reserve_sec

    if now_ts < obj.start_ts then
        obj.state = CSConst.ActivityState.nostart
        timer.once(obj.start_ts - now_ts, accum_recharge_utils.on_activity_started)
    elseif obj.start_ts <= now_ts and now_ts < obj.stop_ts then
        obj.state = CSConst.ActivityState.started
        timer.once(obj.stop_ts - now_ts, accum_recharge_utils.on_activity_stopped)
    elseif obj.stop_ts <= now_ts and now_ts < obj.end_ts then
        obj.state = CSConst.ActivityState.stopped
        timer.once(obj.end_ts - now_ts, accum_recharge_utils.on_activity_expired)
    end
end

-- 活动开始回调
function accum_recharge_utils.on_activity_started()
    local obj = accum_recharge_utils.activity_obj
    obj.state = CSConst.ActivityState.started
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        agent_utils.get_role(uuid).accum_recharge:on_activity_started(obj)
    end
    timer.once(obj.duration_sec, accum_recharge_utils.on_activity_stopped)
end

-- 活动结束回调
function accum_recharge_utils.on_activity_stopped()
    local obj = accum_recharge_utils.activity_obj
    obj.state = CSConst.ActivityState.stopped
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        agent_utils.get_role(uuid).accum_recharge:on_activity_stopped(obj)
    end
    timer.once(obj.reserve_sec, accum_recharge_utils.on_activity_expired)
end

-- 活动过期回调
function accum_recharge_utils.on_activity_expired()
    local obj = accum_recharge_utils.activity_obj
    obj.start_ts = obj.end_ts + obj.interval_sec
    obj.stop_ts = obj.start_ts + obj.duration_sec
    obj.end_ts = obj.stop_ts + obj.reserve_sec
    obj.state = CSConst.ActivityState.nostart
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        agent_utils.get_role(uuid).accum_recharge:on_activity_expired(obj)
    end
    timer.once(obj.interval_sec, accum_recharge_utils.on_activity_started)
end

return accum_recharge_utils