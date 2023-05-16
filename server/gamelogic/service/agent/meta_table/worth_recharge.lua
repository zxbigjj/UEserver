local worth_recharge = DECLARE_MODULE("meta_table.worth_recharge")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local recharge_activity_utils = require("recharge_activity_utils")

function worth_recharge.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
    }
    return setmetatable(self, worth_recharge)
end

function worth_recharge:init_activity(activity_id, init_only)
    self.db.worth_recharge[activity_id] = {}
    local worth_recharge = self.db.worth_recharge[activity_id]
    worth_recharge.receive_count_dict = {}
    worth_recharge.reach_dict = {}
    for id, data in ipairs(excel_data.WorthRechargeData) do
        if data.activity_id == activity_id then
            worth_recharge.receive_count_dict[id] = 0
            worth_recharge.reach_dict[id] = 0
        end
    end
    if not init_only then
        self.role:send_client("s_update_worth_recharge_info", {recharge_dict = self.db.worth_recharge})
    end
end

function worth_recharge:load()
    self:clear_activity()
    local worth_recharge = self.db.worth_recharge
    local id_list = recharge_activity_utils.check_available_activity(CSConst.RechargeActivity.WorthRecharge)
    for _, id in ipairs(id_list) do
        if not worth_recharge[id] then
            self:init_activity(id, true)
        end
    end
end

function worth_recharge:online()
    local id_list = recharge_activity_utils.check_available_activity(CSConst.RechargeActivity.WorthRecharge)
    if #id_list > 0 then
        self.role:send_client("s_update_worth_recharge_info", {recharge_dict = self.db.worth_recharge})
    end
end

-- 清理无效活动数据
function worth_recharge:clear_activity(activity_id)
    local worth_recharge = self.db.worth_recharge
    if activity_id then
        worth_recharge[activity_id] = nil
        return
    end
    for id in pairs(worth_recharge) do
        if not recharge_activity_utils.can_receive_activity(id) then
            worth_recharge[id] = nil
        end
    end
end

-- 充值解锁档位
function worth_recharge:unlock_worth_recharge(recharge_id)
    if not recharge_id then return end
    local recharge_info = excel_data.WorthRechargeData[recharge_id]
    if not recharge_activity_utils.can_receive_activity(recharge_info.activity_id) then return end
    local worth_recharge = self.db.worth_recharge[recharge_info.activity_id]
    if worth_recharge.receive_count_dict[recharge_id] >= recharge_info.limit_num then return end
    local remain = recharge_info.limit_num - worth_recharge.receive_count_dict[recharge_id]
    if worth_recharge.reach_dict[recharge_id] > remain then return end
    worth_recharge.reach_dict[recharge_id] = worth_recharge.reach_dict[recharge_id] + 1
    local diamond_count = excel_data.RechargeData[recharge_id].diamond_count
    self.role:add_vip_exp(diamond_count, g_reason.recharge_worth_recharge)
    self.role:send_client("s_update_worth_recharge_info", {recharge_dict = self.db.worth_recharge})
    return true
end

-- 领取充值档位奖励
function worth_recharge:receive_reward(recharge_id, select_list)
    if not recharge_id or not select_list then return end
    local recharge_info = excel_data.WorthRechargeData[recharge_id]
    if not recharge_activity_utils.can_receive_activity(recharge_info.activity_id) then return end
    if #select_list ~= recharge_info.select_num then return end
    local worth_recharge = self.db.worth_recharge[recharge_info.activity_id]
    local receive_count = worth_recharge.receive_count_dict[recharge_id]
    if receive_count >= recharge_info.limit_num then return end
    if worth_recharge.reach_dict[recharge_id] <= 0 then return end
    worth_recharge.receive_count_dict[recharge_id] = receive_count + 1
    worth_recharge.reach_dict[recharge_id] = worth_recharge.reach_dict[recharge_id] - 1
    local reward_dict = {}
    for k, index in ipairs(select_list) do
        local item_id = recharge_info.item_id[index]
        reward_dict[item_id] = recharge_info.item_count[index]
    end
    local reason = g_reason.worth_recharge_reward
    self.role:add_item_dict(reward_dict, reason)
    self.role:send_client("s_update_worth_recharge_info", {recharge_dict = self.db.worth_recharge})
    return true
end

return worth_recharge