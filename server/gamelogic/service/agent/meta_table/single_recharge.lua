local single_recharge = DECLARE_MODULE("meta_table.single_recharge")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local recharge_activity_utils = require("recharge_activity_utils")

function single_recharge.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
    }
    return setmetatable(self, single_recharge)
end

function single_recharge:init_activity(activity_id, init_only)
    self.db.single_recharge[activity_id] = {}
    local single_recharge = self.db.single_recharge[activity_id]
    single_recharge.receive_count_dict = {}
    single_recharge.reach_dict = {}
    for id, data in ipairs(excel_data.SingleRechargeData) do
        if data.activity_id == activity_id then
            single_recharge.receive_count_dict[id] = 0
            single_recharge.reach_dict[id] = 0
        end
    end
    if not init_only then
        self.role:send_client("s_update_single_recharge_info", {recharge_dict = self.db.single_recharge})
    end
end

function single_recharge:load()
    self:clear_activity()
    local single_recharge = self.db.single_recharge
    local id_list = recharge_activity_utils.check_available_activity(CSConst.RechargeActivity.SingleRecharge)
    for _, id in ipairs(id_list) do
        if not single_recharge[id] then
            self:init_activity(id, true)
        end
    end
end

function single_recharge:online()
    local id_list = recharge_activity_utils.check_available_activity(CSConst.RechargeActivity.SingleRecharge)
    if #id_list > 0 then
        self.role:send_client("s_update_single_recharge_info", {recharge_dict = self.db.single_recharge})
    end
end

function single_recharge:clear_activity(activity_id)
    local single_recharge = self.db.single_recharge
    if activity_id then
        single_recharge[activity_id] = nil
        return
    end
    for id in pairs(single_recharge) do
        if not recharge_activity_utils.can_receive_activity(id) then
            single_recharge[id] = nil
        end
    end
end

function single_recharge:daily_reset()
    local single_recharge = self.db.single_recharge
    self:clear_activity()
    local id_list = recharge_activity_utils.check_available_activity(CSConst.RechargeActivity.SingleRecharge)
    for _, activity_id in pairs(id_list) do
        self:init_activity(activity_id, true)
    end
    if #id_list > 0 then
        self.role:send_client("s_update_single_recharge_info", {recharge_dict = self.db.single_recharge})
    end
end

-- 充值解锁档位
function single_recharge:unlock_single_recharge(recharge_rank)
    if not recharge_rank then return end
    local single_recharge = self.db.single_recharge
    local is_change = false
    for id, data in pairs(excel_data.SingleRechargeData) do
        if data.recharge_rank == recharge_rank and data.activity_id then
            local reward_info = single_recharge[data.activity_id]
            if recharge_activity_utils.is_ongoing_activity(data.activity_id) and
                reward_info.receive_count_dict[id] < data.limit_num then

                local remain = data.limit_num - single_recharge[data.activity_id].receive_count_dict[id]
                if reward_info.reach_dict[id] < remain then
                    reward_info.reach_dict[id] = reward_info.reach_dict[id] + 1
                    is_change = true
                end
            end
        end
    end
    if is_change then
        self.role:send_client("s_update_single_recharge_info", {recharge_dict = self.db.single_recharge})
    end
    return true
end

-- 领取充值档位奖励
function single_recharge:receive_reward(recharge_id, select_list)
    if not recharge_id or not select_list then return end
    local recharge_data = excel_data.SingleRechargeData[recharge_id]
    if not recharge_data then return end
    if not recharge_activity_utils.is_ongoing_activity(recharge_data.activity_id) then return end
    if #select_list ~= recharge_data.select_num then return end
    local single_recharge = self.db.single_recharge[recharge_data.activity_id]
    local receive_count = single_recharge.receive_count_dict[recharge_id]
    if receive_count >= recharge_data.limit_num then return end
    if single_recharge.reach_dict[recharge_id] <= 0 then return end
    single_recharge.receive_count_dict[recharge_id] = receive_count + 1
    single_recharge.reach_dict[recharge_id] = single_recharge.reach_dict[recharge_id] - 1
    local reward_dict = {}
    local reward_exldata = excel_data.RewardData[recharge_data.reward_id]
    for _, index in ipairs(select_list) do
        local item_id = reward_exldata.reward_item_list[index]
        reward_dict[item_id] = reward_exldata.reward_num_list[index]
    end
    local reason = g_reason.single_recharge_reward
    self.role:add_item_dict(reward_dict, reason)
    self.role:send_client("s_update_single_recharge_info", {recharge_dict = self.db.single_recharge})
    return true
end

return single_recharge