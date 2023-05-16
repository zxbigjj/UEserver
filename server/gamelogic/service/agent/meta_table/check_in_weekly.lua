local check_in_weekly = DECLARE_MODULE("meta_table.check_in_weekly")
local date = require("sys_utils.date")
local excel_data = require("excel_data")

function check_in_weekly.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
    }
    return setmetatable(self, check_in_weekly)
end

function check_in_weekly:get_day_index()
    local index_time = date.get_day_time(nil, 0) - self.db.check_in_weekly.start_day
    -- 四舍五入时间戳
    return math.floor(index_time / CSConst.Time.Day + 0.5) + 1
end

function check_in_weekly:get_excel_index(day)
    local weekly_cycle = self.db.check_in_weekly.cycle
    local index_day = day or self:get_day_index()
    return weekly_cycle * CSConst.DaysInWeek + index_day
end

function check_in_weekly:init()
    self.db.check_in_weekly.start_day = date.get_day_time(nil, 0)
    self.db.check_in_weekly.cycle = 0

    local wday = self:get_day_index()
    local index_day = self:get_excel_index()
    local first_luck_value = excel_data.ParamData["first_luck_value"].f_value
    local check_in_weekly_info_list = self.db.check_in_weekly.check_in_weekly_info_list
    for i = 1, CSConst.DaysInWeek do
        check_in_weekly_info_list[i] = CSConst.RewardState.unpick
    end
    check_in_weekly_info_list[1] = CSConst.RewardState.pick
    self.db.check_in_weekly.luck_value = first_luck_value
end

function check_in_weekly:online()
    self:send_msg()
end

-- 每日更新周签到
function check_in_weekly:daily_reset()
    local wday = self:get_day_index()
    local check_info = self.db.check_in_weekly
    if wday > CSConst.DaysInWeek then
        wday = 1
        check_info.start_day = date.get_day_time(nil, 0)
        check_info.cycle = check_info.cycle + 1
        local weekly_cycle = excel_data.ParamData["check_in_weekly_cycle"].f_value
        if check_info.cycle >= weekly_cycle then
            check_info.cycle = 0
        end

        local check_in_weekly_info_list = check_info.check_in_weekly_info_list
        for i in ipairs(check_in_weekly_info_list) do
            check_in_weekly_info_list[i] = CSConst.RewardState.unpick
        end
        check_info.luck_value = excel_data.ParamData["first_luck_value"].f_value
        check_info.luck_count = 0
    end
    for i in ipairs(check_info.check_in_weekly_info_list) do
        if i <= wday and check_info.check_in_weekly_info_list[i] == CSConst.RewardState.unpick then
            check_info.check_in_weekly_info_list[i] = CSConst.RewardState.pick
        end
    end
    self:send_msg()
end

-- 签到/补签操作
function check_in_weekly:check_in(wday)
    if not wday then return end
    if wday <= 0 or wday > CSConst.DaysInWeek then return end
    local today_wday = self:get_day_index()
    local excle_index_day = self:get_excel_index(wday)
    local check_in_config = excel_data.CheckInWeeklyData[excle_index_day]
    if not check_in_config then return end
    local max_luck_count = excel_data.ParamData["max_luck_count"].f_value
    local check_in_weekly_data = self.db.check_in_weekly
    local reason = g_reason.check_in_weekly_reward

    if check_in_weekly_data.check_in_weekly_info_list[wday] ~= CSConst.RewardState.pick then return end
    if wday ~= today_wday then
        -- 补签消耗物品
        local consume_config = excel_data.ParamData["check_in_weekly_cost"]
        if not consume_config then return end
        reason = g_reason.check_in_weekly_consume
        if not self.role:consume_item(consume_config.item_id, consume_config.count, reason) then return end
    end

    local reward_count_list = check_in_config.reward_count
    local reward_id_list = check_in_config.reward_id
    local luck_base_num = excel_data.ParamData["luck_base_num"].f_value
    local luck_per = check_in_weekly_data.luck_value / luck_base_num
    if check_in_weekly_data.luck_count >= max_luck_count then
        check_in_weekly_data.luck_value = 0
        luck_per = 0
    end
    local is_luck = false
    local reward_list = {}
    if wday == today_wday and luck_per ~=0 and math.random() < luck_per then
        -- 触发幸运签到
        is_luck = true
        reason = g_reason.check_in_weekly_luck_reward
        for i = 1, #reward_id_list do
            if check_in_config.special_reward[i] == true then
                table.insert(reward_list, {item_id = reward_id_list[i], count = reward_count_list[i] * 2})
            else
                table.insert(reward_list, {item_id = reward_id_list[i], count = reward_count_list[i]})
            end
        end
        check_in_weekly_data.luck_count = check_in_weekly_data.luck_count + 1
        self:cal_luck_value(true)
    else
        -- 普通签到
        reason = g_reason.check_in_weekly_reward
        for i = 1, #reward_id_list do
            table.insert(reward_list, {item_id = reward_id_list[i], count = reward_count_list[i]})
        end
        self:cal_luck_value(false)
    end
    check_in_weekly_data.check_in_weekly_info_list[wday] = CSConst.RewardState.picked
    self.role:add_item_list(reward_list, reason)

    local check_day = 0
    for k, v in ipairs(check_in_weekly_data.check_in_weekly_info_list) do
        if v == CSConst.RewardState.picked then
            check_day = check_day + 1
        end
    end
    self.role:gaea_log("CheckIn", {
        checkDay = check_day,
        rewardInfo = reward_list,
        checkType = g_const.CheckInType.week,
    })
    self:send_msg()
    return {
        errcode = g_tips.ok,
        is_luck = is_luck
    }
end
-- 计算幸运值
function check_in_weekly:cal_luck_value(is_luck)
    local first_luck_add_value = excel_data.ParamData["first_luck_add_value"].f_value
    local second_luck_value = excel_data.ParamData["second_luck_value"].f_value
    local second_luck_add_value = excel_data.ParamData["second_luck_add_value"].f_value
    local max_luck_count = excel_data.ParamData["max_luck_count"].f_value
    local check_in_weekly_data = self.db.check_in_weekly
    if is_luck then
        if check_in_weekly_data.luck_count < max_luck_count then
            check_in_weekly_data.luck_value = second_luck_value
        else
            check_in_weekly_data.luck_value = 0
        end
    else
        if check_in_weekly_data.luck_count == 0 then
            check_in_weekly_data.luck_value = check_in_weekly_data.luck_value + first_luck_add_value
        elseif check_in_weekly_data.luck_count < max_luck_count then
            check_in_weekly_data.luck_value = check_in_weekly_data.luck_value + second_luck_add_value
        else
            check_in_weekly_data.luck_value = 0
        end
    end
end

function check_in_weekly:send_msg()
    local msg = {}
    local check_in_weekly_info = self.db.check_in_weekly
    local check_in_weekly_info_list = check_in_weekly_info.check_in_weekly_info_list
    msg.check_in_reward = check_in_weekly_info_list
    msg.luck_reward_count = check_in_weekly_info.luck_count
    msg.luck_value = check_in_weekly_info.luck_value
    msg.start_day = check_in_weekly_info.start_day
    msg.day_index = self:get_excel_index()
    self.role:send_client("s_update_check_in_weekly_info", msg)
end

return check_in_weekly