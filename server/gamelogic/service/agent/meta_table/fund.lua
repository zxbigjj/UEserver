local excel_data = require("excel_data")
local fund_utils = require("fund_utils")

local fund = DECLARE_MODULE("meta_table.fund")

function fund.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        data = role.db.openservice_fund,
        db   = role.db,
    }
    return setmetatable(self, fund)
end

function fund:load()
    if not self.data then
        self.db.openservice_fund = { is_buy = false, fund_reward = {}, welfare_reward = {} }
        self.data = self.db.openservice_fund
        for id, _ in pairs(excel_data.OpenServiceRewardData) do
            self.data.fund_reward[id] = CSConst.RewardState.unpick
        end
        for id, _ in pairs(excel_data.OpenServiceWelfareData) do
            self.data.welfare_reward[id] = CSConst.RewardState.unpick
        end
    end
    self:update_welfare_reward()
end

function fund:online()
    local data = table.deep_copy(self.data)
    data.count = fund_utils.get_count()
    self:send(data)
end

function fund:send(data)
    self.role:send_client("s_update_openservice_fund_data", data)
end

-- 总数更新通知
function fund:notify_count_added()
    local is_changed = self:update_welfare_reward()
    if is_changed then
        self:send({count = fund_utils.get_count(), welfare_reward = self.data.welfare_reward})
    else
        self:send({count = fund_utils.get_count()})
    end
end

-- 角色升级通知
function fund:notify_level_up(new_level)
    if not self.data.is_buy then return end
    local is_changed = self:update_fund_reward(new_level)
    if is_changed then
        self:send({fund_reward = self.data.fund_reward})
    end
end

-- 更新全民福利
function fund:update_welfare_reward()
    local is_changed = false
    local total_count = fund_utils.get_count()
    for id, data in pairs(excel_data.OpenServiceWelfareData) do
        if total_count >= data.required_count then
            if self.data.welfare_reward[id] == CSConst.RewardState.unpick then
                self.data.welfare_reward[id] = CSConst.RewardState.pick
                is_changed = true
            end
        end
    end
    return is_changed
end

-- 更新基金福利
function fund:update_fund_reward(new_level)
    local is_changed = false
    for id, data in pairs(excel_data.OpenServiceRewardData) do
        if new_level >= data.required_level then
            if self.data.fund_reward[id] == CSConst.RewardState.unpick then
                self.data.fund_reward[id] = CSConst.RewardState.pick
                is_changed = true
            end
        end
    end
    return is_changed
end

-- 购买开服基金
function fund:buy_fund()
    if self.data.is_buy then return end
    local data = excel_data.OpenServiceFundData[excel_data.OpenServiceFundData.fund_data.id]
    if not data then return end
    if self.role:get_vip() < data.vip_level then return end
    if not self.role:consume_item(data.item_id, data.item_num) then return end
    self.data.is_buy = true
    fund_utils.add_count(self.uuid)
    local level = self.role:get_level()
    local fund_reward_is_changed = self:update_fund_reward(level)
    local welfare_reward_is_changed = self:update_welfare_reward()
    local data = {count = fund_utils.get_count(), is_buy = self.data.is_buy}
    if fund_reward_is_changed then
        data.fund_reward = self.data.fund_reward
    end
    if welfare_reward_is_changed then
        data.welfare_reward = self.data.welfare_reward
    end
    self:send(data)
    return true
end

-- 领取基金奖励
function fund:get_fund_reward(id)
    if not id then return end
    local data = excel_data.OpenServiceRewardData[id]
    if not data then return end
    if self.data.fund_reward[id] ~= CSConst.RewardState.pick then return end
    self.data.fund_reward[id] = CSConst.RewardState.picked
    self.role:add_item(excel_data.OpenServiceFundData.fund_data.item_id, data.item_num, g_reason.fund_personal_reward)
    self:send({fund_reward = self.data.fund_reward})
    return true
end

-- 领取福利奖励
function fund:get_welfare_reward(id)
    if not id then return end
    local data = excel_data.OpenServiceWelfareData[id]
    if not data then return end
    if self.data.welfare_reward[id] ~= CSConst.RewardState.pick then return end
    self.data.welfare_reward[id] = CSConst.RewardState.picked
    self.role:add_item(data.item_id, data.item_num, g_reason.fund_welfare_reward)
    self:send({welfare_reward = self.data.welfare_reward})
    return true
end

return fund