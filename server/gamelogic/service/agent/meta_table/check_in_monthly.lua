local check_in_monthly = DECLARE_MODULE("meta_table.check_in_monthly")
local date = require("sys_utils.date")
local excel_data = require("excel_data")

function check_in_monthly.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
        check_in_count = 0,
        replenish_remain_today = 0,
    }
    return setmetatable(self, check_in_monthly)
end

function check_in_monthly:init()
    local month, day = self:get_day()
    local check_in_monthly_info_list = self.db.check_in_monthly.check_in_monthly_info_list
    for i = 1, self:get_maxday() do
        if i <= day then
            check_in_monthly_info_list[i] = CSConst.RewardState.pick
        else
            check_in_monthly_info_list[i] = CSConst.RewardState.unpick
        end
    end

    local chest_config = excel_data.CheckInMonthlyData[month].chest_reward
    if not chest_config then return end
    local chest_info_list = self.db.check_in_monthly.chest_info_list
    for i = 1, #chest_config do
        chest_info_list[i] = CSConst.RewardState.unpick
    end

    self.db.check_in_monthly.replenish_count = excel_data.CheckInMonthlyData[month].replenish_init_num
end

-- 获取当前月份和日期
function check_in_monthly:get_day()
    local timetable = os.date("*t", date.time_second())
    return timetable.month, timetable.day
end

-- 获取当前月份最大天数
function check_in_monthly:get_maxday()
    local now = os.date("*t", date.get_begin0())
    local maxday = os.date("%d", os.time({ year = now.year, month = now.month + 1, day = 0 }))
    return tonumber(maxday)
end

function check_in_monthly:load()
    local month, day = self:get_day()
    local check_in_config = excel_data.CheckInMonthlyData[month]
    if not check_in_config then return end
    local check_in_monthly_info_list = self.db.check_in_monthly.check_in_monthly_info_list

    for i = 1, day do
        if check_in_monthly_info_list[i] == CSConst.RewardState.picked then
            self.check_in_count = self.check_in_count + 1
        end
    end
    self.replenish_remain_today = check_in_config.replenish_limit_today - self.db.check_in_monthly.replenish_used_today
end

function check_in_monthly:online()
    self:send_msg()
end

-- 每日更新签到
function check_in_monthly:daily_reset()
    local month, day = self:get_day()
    local last_online = os.date("*t", self.db.logout_ts)
    local check_in_config = excel_data.CheckInMonthlyData[month]
    local db_check_in_monthly = self.db.check_in_monthly
    local check_in_monthly_info_list = db_check_in_monthly.check_in_monthly_info_list
    -- 离线时间不是登录月份，或每月1号
    if last_online.year ~= os.date("*t", date.time_second()).year or last_online.month ~= month or day == 1 then
        db_check_in_monthly.check_in_monthly_info_list = {}
        check_in_monthly_info_list = db_check_in_monthly.check_in_monthly_info_list

        local chest_info_list = db_check_in_monthly.chest_info_list
        for i in ipairs(chest_info_list) do
            chest_info_list[i] = CSConst.RewardState.unpick
        end
        db_check_in_monthly.recharge_integral = 0
        db_check_in_monthly.replenish_count = excel_data.CheckInMonthlyData[month].replenish_init_num
        db_check_in_monthly.replenish_used_count = 0
    end
    for i = 1, self:get_maxday() do
        if not check_in_monthly_info_list[i] then check_in_monthly_info_list[i] = CSConst.RewardState.unpick end
        if i <= day then
            if check_in_monthly_info_list[i] == CSConst.RewardState.unpick then
                check_in_monthly_info_list[i] = CSConst.RewardState.pick
            end
        else
            check_in_monthly_info_list[i] = CSConst.RewardState.unpick
        end
    end
    db_check_in_monthly.today_active_replenish = false
    db_check_in_monthly.replenish_used_today = 0
    self.replenish_remain_today = check_in_config.replenish_limit_today
    self:send_msg()
end

-- 充值增加补签数量
function check_in_monthly:get_replenish_count_by_recharge(progress)
    if not progress or progress <= 0 then return end
    local db_check_data = self.db.check_in_monthly
    local old_num = db_check_data.recharge_integral
    local new_num = old_num + progress
    db_check_data.recharge_integral = new_num
    local month = self:get_day()
    local require_list = excel_data.CheckInMonthlyData[month].recharge_require
    for _, value in ipairs(require_list) do
        if new_num >= value and old_num < value then
            db_check_data.replenish_count = db_check_data.replenish_count + 1
        end
    end
    self:send_msg()
end

-- 日活跃增加补签次数
function check_in_monthly:get_replenish_count_by_active(require_num)
    local check_in = self.db.check_in_monthly
    if check_in.today_active_replenish == true then return end
    local active = self.role:get_currency(CSConst.Virtual.ActivePoint)
    if active >= require_num then
        check_in.today_active_replenish = true
        local month_limit = excel_data.ParamData["month_check_limit"].f_value
        if check_in.replenish_count < month_limit then
            check_in.replenish_count = check_in.replenish_count + 1
            self.role:send_client("s_update_check_in_monthly_info", {replenish_num = check_in.replenish_count - check_in.replenish_used_count})
        end
    end
    self:send_msg()
end

-- 签到/补签操作
function check_in_monthly:check_in(day)
    if not day then return end
    local maxday = self:get_maxday()
    if day <= 0 or day > maxday then return end
    local month, today = self:get_day()
    local check_in_config = excel_data.CheckInMonthlyData[month]
    if not check_in_config then return end
    local monthly_data = self.db.check_in_monthly
    local check_in_monthly_info_list = monthly_data.check_in_monthly_info_list
    local reason = g_reason.check_in_monthly_reward

    if day ~= today then
        local month_limit = excel_data.ParamData["month_check_limit"].f_value
        if monthly_data.replenish_used_count >= month_limit then return end
        if monthly_data.replenish_used_today < check_in_config.replenish_limit_today and monthly_data.replenish_count - monthly_data.replenish_used_count > 0 then
            monthly_data.replenish_used_today = monthly_data.replenish_used_today + 1
            monthly_data.replenish_used_count = monthly_data.replenish_used_count + 1
            self.replenish_remain_today = check_in_config.replenish_limit_today - monthly_data.replenish_used_today
        else
            return
        end
    end
    -- vip双倍奖励
    local reward_count = check_in_config.reward_count[day]
    local vip_level = self.role:get_vip()
    for i, value in ipairs(check_in_config.vip_day) do
        if value == day and vip_level >= check_in_config.vip_level_request[i] then
            reward_count = reward_count + reward_count
            reason = g_reason.check_in_monthly_double_reward
        end
    end

    if check_in_monthly_info_list[day] == CSConst.RewardState.pick then
        check_in_monthly_info_list[day] = CSConst.RewardState.picked
        self.check_in_count = self.check_in_count + 1
        self.role:add_item(check_in_config.reward_id[day], reward_count, reason)
    else
        return
    end

    -- 刷新宝箱状态
    local chest_info_list = self.db.check_in_monthly.chest_info_list
    for i in ipairs(chest_info_list) do
        if self.check_in_count >= check_in_config.chest_day_request[i] and chest_info_list[i] == CSConst.RewardState.unpick then
            chest_info_list[i] = CSConst.RewardState.pick
        end
    end

    self.role:gaea_log("CheckIn", {
        checkDay = self.check_in_count,
        rewardInfo = {{item_id = check_in_config.reward_id[day],  count = reward_count}},
        checkType = g_const.CheckInType.month,
    })
    self:send_msg()
    return true
end
-- 领取每月签到宝箱
function check_in_monthly:receive_chest_award(chest_id)
    if not chest_id then return end
    local month, today = self:get_day()
    local check_in_config = excel_data.CheckInMonthlyData[month]
    if not check_in_config then return end
    if chest_id > #check_in_config.chest_reward or chest_id <= 0 then return end
    local chest_state = self.db.check_in_monthly.chest_info_list
    local reason = g_reason.check_in_monthly_chest_reward
    local reward_list = excel_data.RewardData[check_in_config.chest_reward[chest_id]]
    if not reward_list then return end

    if chest_state[chest_id] ~= CSConst.RewardState.pick then return end
    chest_state[chest_id] = CSConst.RewardState.picked
    self.role:add_item_list(reward_list.item_list, reason)
    self:send_msg()
    return true
end

function check_in_monthly:send_msg()
    local msg = {}
    local check_in = self.db.check_in_monthly
    local check_in_monthly_info_list = check_in.check_in_monthly_info_list
    msg.check_in_date_reward = check_in_monthly_info_list
    msg.check_in_chest_reward = check_in.chest_info_list
    msg.check_in_count = self.check_in_count
    msg.replenish_num = check_in.replenish_count - check_in.replenish_used_count
    msg.replenish_remain_today = self.replenish_remain_today
    -- todo 充值积分数量，等待充值系统上线
    msg.chenck_in_integral = check_in.recharge_integral
    self.role:send_client("s_update_check_in_monthly_info", msg)
end

return check_in_monthly