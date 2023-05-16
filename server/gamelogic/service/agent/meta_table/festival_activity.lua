local date = require("sys_utils.date")
local excel_data = require("excel_data")
local festival_activity_utils = require("festival_activity_utils")
local STATE = CSConst.ActivityState -- 活动状态

local role_festival_activity = DECLARE_MODULE("meta_table.festival_activity")

function role_festival_activity.new(role)
    local self = {
        role = role,
        db   = role.db,
        data = role.db.festival_activity,
    }
    return setmetatable(self, role_festival_activity)
end

-- 加载时进行清理、初始化
function role_festival_activity:load()
    -- 获取正在进行的活动组 id, 可能为 nil
    local group_id = festival_activity_utils.get_current_group_id()

    -- 清理已过期的活动 (nostart/invalid/reserve)
    if not self.db.festival_group_id then
        self.db.festival_group_id = group_id
        if not self.db.festival_group_id then return end
    elseif self.db.festival_group_id ~= group_id then
        for activity_id, _ in pairs(self.data) do
            self:clear_activity_data(activity_id)
        end
        self.db.festival_group_id = group_id
        if not self.db.festival_group_id then return end
    else
        for activity_id, activity_data in pairs(self.data) do
            local state = festival_activity_utils.get_activity_state(activity_id)
            if state == STATE.reserve then
                self.data[activity_id] = {
                    exchange_dict = activity_data.exchange_dict,
                }
            end
            if state == STATE.nostart or state == STATE.invalid then
                self:clear_activity_data(activity_id)
            end
            if (state == STATE.started or state == STATE.stopped) and (not activity_data.progress_dict) then
                self:clear_activity_data(activity_id)
            end
        end
    end

    -- 初始化有效的活动 (started/stopped/reserve)
    for activity_id, activity_obj in pairs(festival_activity_utils.get_activity_dict(group_id)) do
        local state = activity_obj.state
        if not self.data[activity_id] then
            if state == STATE.started or state == STATE.stopped then
                self:notify_activity_started(activity_id, activity_obj, true)
            end
            if state == STATE.reserve then
                self.data[activity_id] = {exchange_dict = {}}
                for exchange_id, exchange_cnt in pairs(activity_obj.exchange_dict) do
                    self.data[activity_id].exchange_dict[exchange_id] = exchange_cnt
                end
            end
        end
    end
end

-- 每日刷新，更新登录进度
function role_festival_activity:daily()
    self:update_activity_data(CSConst.FestivalActivityType.login)
end

-- 上线时发送全部活动数据
function role_festival_activity:online()
    if #self.data == 0 then return end
    local data = table.deep_copy(self.data)
    for activity_id, activity_data in pairs(data) do
        activity_data.state = festival_activity_utils.get_activity_state(activity_id)
        if activity_data.state ~= STATE.reserve then
            for recharge_id, recharge_data in pairs(activity_data.recharge_dict) do
                activity_data.recharge_dict[recharge_id] = recharge_data.remaining_times
            end
        end
    end
    self:send(data)
end

-- 发送活动数据
function role_festival_activity:send(data)
    self.role:send_client('s_update_festival_activity_info', {activity_dict = data})
end

-- 活动开始通知
function role_festival_activity:notify_activity_started(activity_id, activity_obj, init_db_only)
    local activity_data = {
        reward_dict   = {}, 
        progress_dict = {}, 
        recharge_dict = {}, 
        discount_dict = {}, 
        exchange_dict = {},
    }
    self.data[activity_id] = activity_data
    self.db.festival_group_id = activity_obj.group_id
    for reward_id, _ in pairs(activity_obj.reward_dict) do
        activity_data.reward_dict[reward_id] = CSConst.RewardState.unpick
    end
    for discount_id, discount_cnt in pairs(activity_obj.discount_dict) do
        activity_data.discount_dict[discount_id] = discount_cnt
    end
    for exchange_id, exchange_cnt in pairs(activity_obj.exchange_dict) do
        activity_data.exchange_dict[exchange_id] = exchange_cnt
    end
    for type_id, content_id in pairs(activity_obj.content_dict) do
        if type_id == CSConst.FestivalActivityType.recharge then
            for recharge_id, recharge_data in pairs(excel_data.FestivalContentData[content_id].recharge_dict) do
                activity_data.recharge_dict[recharge_id] = { remaining_times = recharge_data.count, available_reward = 0 }
            end
        elseif type_id ~= CSConst.FestivalActivityType.login then
            activity_data.progress_dict[type_id] = 0
        end
    end
    if init_db_only then return end
    self:update_activity_data(CSConst.FestivalActivityType.login, {not_send_data = true})
    local data = table.deep_copy(activity_data)
    data.state = STATE.started
    for recharge_id, recharge_data in pairs(data.recharge_dict) do
        data.recharge_dict[recharge_id] = recharge_data.remaining_times
    end
    self:send({[activity_id] = data})
end

-- 活动结束通知
function role_festival_activity:notify_activity_stopped(activity_id)
    self:send({[activity_id] = {state = STATE.stopped}})
end

-- 活动保留通知
function role_festival_activity:notify_activity_reserve(activity_id)
    self.data[activity_id] = {
        exchange_dict = self.data[activity_id].exchange_dict,
    }
    self:send({[activity_id] = {state = STATE.reserve}})
end

-- 活动过期通知
function role_festival_activity:notify_activity_invalid(activity_id)
    self:clear_activity_data(activity_id)
    self:send({[activity_id] = {state = STATE.invalid}})
end

-- 清空活动数据
function role_festival_activity:clear_activity_data(activity_id)
    if not activity_id or not self.data[activity_id] then return end
    local activity_obj = festival_activity_utils.get_activity_dict(self.db.festival_group_id)[activity_id]
    local welfare_stuff = activity_obj.welfare_stuff
    local luxury_stuff = activity_obj.luxury_stuff
    local welfare_stuff_count = self.role:get_item_count(welfare_stuff)
    local luxury_stuff_count = self.role:get_item_count(luxury_stuff)
    if welfare_stuff_count > 0 then
        self.role:consume_item(welfare_stuff, welfare_stuff_count, g_reason.festival_activity_expired)
    end
    if luxury_stuff_count > 0 then
        self.role:consume_item(luxury_stuff, luxury_stuff_count, g_reason.festival_activity_expired)
    end
    self.data[activity_id] = nil
end

-- 判断今天是活动进行的第几天 (>=1)
function role_festival_activity:get_day_of_duration(activity_id)
    local activity_obj = festival_activity_utils.get_activity_dict(self.db.festival_group_id)[activity_id]
    local start_ts = activity_obj.start_ts
    local stop_ts = activity_obj.stop_ts + 1
    local now_ts = date.time_second()
    for i = 1, (stop_ts - start_ts) / CSConst.Time.Day do
        local curday_beg_ts = start_ts + CSConst.Time.Day * (i - 1)
        local curday_end_ts = curday_beg_ts + CSConst.Time.Day - 1
        if curday_beg_ts <= now_ts and now_ts <= curday_end_ts then
            return i
        end
    end
end

-- 限时折扣
function role_festival_activity:buy_discount(discount_id, discount_cnt)
    if not discount_id then return end
    discount_cnt = discount_cnt or 1
    if discount_cnt <= 0 then return end

    local activity_id = festival_activity_utils.check_discount_is_available(discount_id)
    if not activity_id then return end
    local remaining_count = self.data[activity_id].discount_dict[discount_id]
    if remaining_count <= 0 then return end
    if discount_cnt > remaining_count then discount_cnt = remaining_count end

    local discount_data = excel_data.FestivalDiscountData[discount_id]
    local consume_item_id = discount_data.cost_item_id
    local consume_item_num = discount_data.cost_item_num
    local add_item_id = discount_data.sell_item_id
    local add_item_num = discount_data.sell_item_num

    local consume_expect_num = consume_item_num * discount_cnt
    local consume_actual_num = self.role:get_item_count(consume_item_id)
    while consume_actual_num < consume_expect_num do
        consume_expect_num = consume_expect_num - consume_item_num
        discount_cnt = discount_cnt - 1
    end
    if discount_cnt <= 0 then return end
    local add_expect_num = add_item_num * discount_cnt

    self.data[activity_id].discount_dict[discount_id] = self.data[activity_id].discount_dict[discount_id] - discount_cnt
    self.role:consume_item(consume_item_id, consume_expect_num, g_reason.festival_discount_consume)
    self.role:add_item(add_item_id, add_expect_num, g_reason.festival_discount_reward)
    self:send({[activity_id] = {discount_dict = self.data[activity_id].discount_dict}})
    return true
end

-- 商品兑换
function role_festival_activity:get_exchange(exchange_id, exchange_cnt)
    if not exchange_id then return end
    exchange_cnt = exchange_cnt or 1
    if exchange_cnt <= 0 then return end

    local activity_obj = festival_activity_utils.check_exchange_is_available(exchange_id)
    if not activity_obj then return end
    local activity_id = activity_obj.id
    local remaining_count = self.data[activity_id].exchange_dict[exchange_id]
    if remaining_count <= 0 then return end
    if exchange_cnt > remaining_count then exchange_cnt = remaining_count end

    local exchange_data = excel_data.FestivalExchangeData[exchange_id]
    local consume_item_id = nil
    if exchange_data.cost_item_type == CSConst.FestivalStuffType.welfare then
        consume_item_id = activity_obj.welfare_stuff
    elseif exchange_data.cost_item_type == CSConst.FestivalStuffType.luxury then
        consume_item_id = activity_obj.luxury_stuff
    end
    if not consume_item_id then return end
    local consume_item_num = exchange_data.cost_item_num
    local add_item_id = exchange_data.sell_item_id
    local add_item_num = exchange_data.sell_item_num

    local consume_expect_num = consume_item_num * exchange_cnt
    local consume_actual_num = self.role:get_item_count(consume_item_id)
    while consume_actual_num < consume_expect_num do
        consume_expect_num = consume_expect_num - consume_item_num
        exchange_cnt = exchange_cnt - 1
    end
    if exchange_cnt <= 0 then return end
    local add_expect_num = add_item_num * exchange_cnt

    self.data[activity_id].exchange_dict[exchange_id] = self.data[activity_id].exchange_dict[exchange_id] - exchange_cnt
    self.role:consume_item(consume_item_id, consume_expect_num, g_reason.festival_exchange_consume)
    self.role:add_item(add_item_id, add_expect_num, g_reason.festival_exchange_reward)
    self:send({[activity_id] = {exchange_dict = self.data[activity_id].exchange_dict}})
    return true
end

-- 领取奖励
function role_festival_activity:pick_reward(reward_id)
    local activity_id = festival_activity_utils.check_reward_is_available(reward_id)
    local recharge_id = festival_activity_utils.get_recharge_id_by_reward_id(activity_id, reward_id)
    if not activity_id then return end
    if recharge_id then
        local remaining_times = self.data[activity_id].recharge_dict[recharge_id].remaining_times
        local available_reward = self.data[activity_id].recharge_dict[recharge_id].available_reward
        if available_reward <= 0 then return end
        self.data[activity_id].recharge_dict[recharge_id].remaining_times = remaining_times - 1
        self.data[activity_id].recharge_dict[recharge_id].available_reward = available_reward - 1
        if self.data[activity_id].recharge_dict[recharge_id].available_reward <= 0 then
            if self.data[activity_id].recharge_dict[recharge_id].remaining_times <= 0 then
                self.data[activity_id].reward_dict[reward_id] = CSConst.RewardState.picked
            else
                self.data[activity_id].reward_dict[reward_id] = CSConst.RewardState.unpick
            end
            self:send({[activity_id] = {
                recharge_dict = {[recharge_id] = self.data[activity_id].recharge_dict[recharge_id].remaining_times},
                reward_dict = self.data[activity_id].reward_dict,
            }})
        else
            self:send({[activity_id] = {
                recharge_dict = {[recharge_id] = self.data[activity_id].recharge_dict[recharge_id].remaining_times},
            }})
        end
    else
        if self.data[activity_id].reward_dict[reward_id] ~= CSConst.RewardState.pick then return end
        self.data[activity_id].reward_dict[reward_id] = CSConst.RewardState.picked
        self:send({[activity_id] = {reward_dict = self.data[activity_id].reward_dict}})
    end
    self.role:add_item_list(excel_data.FestivalRewardData[reward_id].item_list, g_reason.festival_activity_reward)
    return true
end

-- 更新奖励
function role_festival_activity:update_reward(activity_id, content_id, type_id, reward_id)
    if reward_id then
        -- 只更新指定奖励
        if self.data[activity_id].reward_dict[reward_id] == CSConst.RewardState.unpick then
            self.data[activity_id].reward_dict[reward_id] = CSConst.RewardState.pick
        end
        return
    end
    local condition_list = excel_data.FestivalContentData[content_id].condition_list
    local current_progress = self.data[activity_id].progress_dict[type_id]
    local current_gear = 0
    for i = 1, #condition_list do
        if current_progress >= condition_list[i] then
            current_gear = i
        else
            break
        end
    end
    local reward_list = excel_data.FestivalContentData[content_id].reward_list
    local is_changed = false
    for i = 1, current_gear do
        reward_id = reward_list[i]
        if self.data[activity_id].reward_dict[reward_id] == CSConst.RewardState.unpick then
            self.data[activity_id].reward_dict[reward_id] = CSConst.RewardState.pick
            is_changed = true
        end
    end
    return is_changed
end

-- 更新数据
function role_festival_activity:update_activity_data(type_id, args)
    local activity_id, content_id = festival_activity_utils.check_type_is_available(type_id)
    if not activity_id or not content_id then return end
    args = args or {}
    if type_id == CSConst.FestivalActivityType.recharge then
        local recharge_id = args.recharge_id
        if not recharge_id then return end
        local recharge_dict = excel_data.FestivalContentData[content_id].recharge_dict
        if recharge_dict[recharge_id] then
            local old_recharge_count = self.data[activity_id].recharge_dict[recharge_id].remaining_times
            local old_reward_count = self.data[activity_id].recharge_dict[recharge_id].available_reward
            if old_recharge_count == old_reward_count then return end
            self.data[activity_id].recharge_dict[recharge_id].available_reward = old_reward_count + 1
            if self.data[activity_id].reward_dict[recharge_dict[recharge_id].reward] ~= CSConst.RewardState.pick then
                self.data[activity_id].reward_dict[recharge_dict[recharge_id].reward] = CSConst.RewardState.pick
                self:send({[activity_id] = {reward_dict = self.data[activity_id].reward_dict}})
            end
        end
    elseif type_id == CSConst.FestivalActivityType.login then
        local day_of_duration = self:get_day_of_duration(activity_id) 
        if not day_of_duration then return end
        local reward_id = excel_data.FestivalContentData[content_id].reward_list[day_of_duration]
        if not reward_id then return end
        self:update_reward(activity_id, content_id, type_id, reward_id)
        if not args.not_send_data then self:send({[activity_id] = {reward_dict = self.data[activity_id].reward_dict}}) end
    else
        local add_value = args.add_value or 1
        if add_value <= 0 then return end
        local old_progress = self.data[activity_id].progress_dict[type_id]
        self.data[activity_id].progress_dict[type_id] = old_progress + add_value
        local is_changed = self:update_reward(activity_id, content_id, type_id)
        self:send({[activity_id] = {
            progress_dict = self.data[activity_id].progress_dict,
            reward_dict = is_changed and self.data[activity_id].reward_dict or nil
        }})
    end
end

return role_festival_activity