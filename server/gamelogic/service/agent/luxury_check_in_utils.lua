local timer = require("timer")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local server_data = require("server_data")

local luxury_check_in_utils = DECLARE_MODULE("luxury_check_in_utils")

-- id => obj
local all_obj_dict = DECLARE_RUNNING_ATTR(luxury_check_in_utils, "all_obj_dict", {}) -- 所有的对象
local cur_obj_dict = DECLARE_RUNNING_ATTR(luxury_check_in_utils, "cur_obj_dict", {}) -- 当前的对象(1天或7天的轮换周期)

function luxury_check_in_utils.start()
    local now_ts = date.time_second()
    local today_day0 = date.get_begin0(now_ts)
    local today_week0 = date.get_week_begin0(now_ts)
    local first_start_ts = server_data.get_server_core("server_open_time")
    local first_start_day0 = date.get_begin0(first_start_ts)
    local first_start_week0 = date.get_week_begin0(first_start_ts)
    local server_open_days = (today_day0 - first_start_day0) / CSConst.Time.Day
    local server_open_weeks = (today_week0 - first_start_week0) / (CSConst.Time.Day * CSConst.DaysInWeek)

    for id, data in pairs(excel_data.SingleRechargeData) do
        if type(id) == 'number' and data.mark then
            all_obj_dict[id] = {id = id, next_id = data.next_id}
        end
    end

    for id, obj in pairs(all_obj_dict) do
        local data = excel_data.SingleRechargeData[id]
        local reset_cycle = data.reset_cycle
        local id_list = excel_data.SingleRechargeData.recharge_dict[data.recharge_id]
        if obj.id == id_list[1] then
            if reset_cycle == CSConst.LuxuryCheckInResetCycle.Daily then
                local index = server_open_days % #id_list + 1
                local id = id_list[index]
                cur_obj_dict[id] = all_obj_dict[id]
                cur_obj_dict[id].init_ts = today_day0
                timer.once(today_day0 + CSConst.Time.Day - now_ts, function() luxury_check_in_utils.daily_timer(all_obj_dict[id]) end)
            elseif reset_cycle == CSConst.LuxuryCheckInResetCycle.Weekly then
                local index = server_open_weeks % #id_list + 1
                local id = id_list[index]
                cur_obj_dict[id] = all_obj_dict[id]
                cur_obj_dict[id].init_ts = today_week0
                timer.once(today_week0 + CSConst.Time.Day * CSConst.DaysInWeek - now_ts, function() luxury_check_in_utils.weekly_timer(all_obj_dict[id]) end)
            end
        end
    end
end

function luxury_check_in_utils.daily_timer(obj)
    cur_obj_dict[obj.id] = nil
    cur_obj_dict[obj.next_id] = all_obj_dict[obj.next_id]
    cur_obj_dict[obj.next_id].init_ts = date.get_begin0()
    timer.once(CSConst.Time.Day, function() luxury_check_in_utils.daily_timer(all_obj_dict[obj.next_id]) end)
end

function luxury_check_in_utils.weekly_timer(obj)
    cur_obj_dict[obj.id] = nil
    cur_obj_dict[obj.next_id] = all_obj_dict[obj.next_id]
    cur_obj_dict[obj.next_id].init_ts = date.get_week_begin0()
    timer.once(CSConst.Time.Day * CSConst.DaysInWeek, function() luxury_check_in_utils.weekly_timer(all_obj_dict[obj.next_id]) end)
end

return luxury_check_in_utils