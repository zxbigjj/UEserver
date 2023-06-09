local excel_data = require("excel_data")
local accum_recharge_utils = require("accum_recharge_utils")

local accum_recharge = DECLARE_MODULE("meta_table.accum_recharge")

function accum_recharge.new(role)
    local self = {
        role = role,
        data = role.db.accum_recharge,
    }
    return setmetatable(self, accum_recharge)
end

-- 加载
function accum_recharge:on_load()
    local activity_obj = accum_recharge_utils.activity_obj
    -- 清理过期数据
    if table.length(self.data) ~= 0 then
        if activity_obj.state == CSConst.ActivityState.nostart or self.data.start_ts ~= activity_obj.start_ts then
            self:on_activity_expired()
        end
    end
    -- 初始化新数据
    if activity_obj.state ~= CSConst.ActivityState.nostart and table.length(self.data) == 0 then
        self:on_activity_started(activity_obj)
    end
end

-- 上线
function accum_recharge:on_online()
    if table.length(self.data) == 0 then return end
    local data = table.copy(self.data)
    local activity_obj = accum_recharge_utils.activity_obj
    data.stop_ts = activity_obj.stop_ts
    data.end_ts = activity_obj.end_ts
    data.state = activity_obj.state
    self.role:send_client("s_update_accum_recharge_data", data)
end

-- 活动开始回调
function accum_recharge:on_activity_started(activity_obj)
    self.role.db.accum_recharge = {
        start_ts = activity_obj.start_ts,
        level_gear = 0,
        recharge_amount = 0,
        reward_state_dict = {},
    }
    self.data = self.role.db.accum_recharge

    local level_gear
    local mylevel = self.role:get_level()
    for i, level in ipairs(excel_data.SingleRechargeData.accumulated_recharge_activity.accum_level_list) do
        if mylevel <= level then level_gear = i; break end
    end
    self.data.level_gear = level_gear

    for _, activity_id in ipairs(excel_data.SingleRechargeData.accumulated_recharge_activity.id_list) do
        self.data.reward_state_dict[activity_id] = CSConst.RewardState.unpick
    end

    local data = table.copy(self.data)
    data.stop_ts = activity_obj.stop_ts
    data.end_ts = activity_obj.end_ts
    data.state = activity_obj.state
    self.role:send_client("s_update_accum_recharge_data", data)
end

-- 活动结束回调
function accum_recharge:on_activity_stopped()
    self.role:send_client("s_update_accum_recharge_data", {state = CSConst.ActivityState.stopped})
end

-- 活动过期回调
function accum_recharge:on_activity_expired()
    local all_item_list = {}
    for activity_id, reward_state in pairs(self.data.reward_state_dict) do
        if reward_state == CSConst.RewardState.pick then
            local reward_id = excel_data.SingleRechargeData[activity_id].accum_reward_list[self.data.level_gear]
            local reward_data = excel_data.RewardData[reward_id]
            if reward_data.is_select then
                table.insert(all_item_list, reward_data.item_list[1])
            else
                table.extend(all_item_list, reward_data.item_list)
            end
        end
    end
    if #all_item_list ~= 0 then
        local mail_id = CSConst.MailId.AccumRechargeReward
        self.role:add_mail({mail_id = mail_id, item_list = table.deep_copy(all_item_list)})
    end
    self.role.db.accum_recharge = {}
    self.data = self.role.db.accum_recharge
    self.role:send_client("s_update_accum_recharge_data", {state = CSConst.ActivityState.invalid})
end

-- 领取奖励
function accum_recharge:receiving_reward(activity_id, select_index)
    if not activity_id then return end
    if table.length(self.data) == 0 then return end
    if self.data.reward_state_dict[activity_id] ~= CSConst.RewardState.pick then return end
    local reward_id = excel_data.SingleRechargeData[activity_id].accum_reward_list[self.data.level_gear]
    local reward_data = excel_data.RewardData[reward_id]
    local item_list
    if reward_data.is_select then
        if not select_index then return end
        local item_obj = reward_data.item_list[select_index]
        if not item_obj then return end
        item_list = {item_obj}
    else
        item_list = reward_data.item_list
    end
    self.data.reward_state_dict[activity_id] = CSConst.RewardState.picked
    self.role:add_item_list(item_list, g_reason.accum_recharge_reward)
    self.role:send_client("s_update_accum_recharge_data", {reward_state_dict = self.data.reward_state_dict})
    return true
end

-- 更新奖励
function accum_recharge:update_reward()
    local accum_recharge_data = excel_data.SingleRechargeData.accumulated_recharge_activity
    local recharge_amount_list = accum_recharge_data.recharge_amount_list
    local current_progress = self.data.recharge_amount
    local current_gear = 0
    for i = 1, #recharge_amount_list do
        if current_progress >= recharge_amount_list[i] then
            current_gear = i
        else
            break
        end
    end
    local is_change = false
    local level_gear = self.data.level_gear
    for i = 1, current_gear do
        local activity_id = accum_recharge_data.id_list[i]
        if self.data.reward_state_dict[activity_id] == CSConst.RewardState.unpick then
            is_change = true
            self.data.reward_state_dict[activity_id] = CSConst.RewardState.pick
        end
    end
    return is_change
end

-- 充值回调
function accum_recharge:on_recharge(recharge_num)
    print("accum_recharge ------ hd "..recharge_num)
    if not recharge_num then return end
    if not accum_recharge_utils.activity_is_started() then return end
    self.data.recharge_amount = self.data.recharge_amount + recharge_num
    print("accum_recharge on_recharge :"..self.data.recharge_amount)
    local is_change = self:update_reward()
    if is_change then
        self.role:send_client("s_update_accum_recharge_data", {recharge_amount = self.data.recharge_amount, reward_state_dict = self.data.reward_state_dict})
    else
        self.role:send_client("s_update_accum_recharge_data", {recharge_amount = self.data.recharge_amount})
    end
end

return accum_recharge
