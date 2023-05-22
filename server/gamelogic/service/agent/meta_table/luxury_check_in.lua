local excel_data = require("excel_data")
local luxury_check_in_utils = require("luxury_check_in_utils")

local luxury_check_in = DECLARE_MODULE("meta_table.luxury_check_in")

function luxury_check_in.new(role)
    local self = {
        role = role,
        data = role.db.luxury_check_in,
    }
    return setmetatable(self, luxury_check_in)
end

function luxury_check_in:daily()
    -- 清除旧数据
    local cur_obj_dict = luxury_check_in_utils.cur_obj_dict
    for id, data in pairs(self.data) do
        if not cur_obj_dict[id] or data.init_ts ~= cur_obj_dict[id].init_ts then
            self:clear_data(id)
        end
    end
    -- 初始化新数据
    for id, obj in pairs(cur_obj_dict) do
        if not self.data[id] then
            self:init_data(id, obj)
        end
    end
end

function luxury_check_in:online()
    local datas = table.deep_copy(self.data)
    for id, data in pairs(datas) do
        if data.reward_times > 0 then
            data.reward_state = CSConst.RewardState.pick
        else
            data.reward_state = data.recharge_times > 0 and CSConst.RewardState.unpick or CSConst.RewardState.picked
        end
    end
    print("====luxury_check_in datas :==="..json.encode(datas))
    self:send(datas)
end

function luxury_check_in:send(datas)
    print('======豪华签到数据==============' .. json.encode(datas))
    self.role:send_client("s_update_luxurycheckin_data", {checkin_data = datas})
end

-- 初始化新数据
function luxury_check_in:init_data(id, obj)
    self.data[id] = {}
    local dbdata = self.data[id]
    local exldata = excel_data.SingleRechargeData[id]
    dbdata.init_ts = obj.init_ts
    dbdata.recharge_times = exldata.rechargeable_times
    dbdata.reward_times = 0
    local mylevel = self.role:get_level()
    print("===luxury_check_in mylevel==="..mylevel)
    for i, level in ipairs(exldata.level_list) do
        print("===luxury_check_in level==="..level)
        if mylevel <= level then
            dbdata.reward_id = exldata.reward_list[i]
            break
        end
    end
    local cpydata = table.copy(dbdata)
    cpydata.reward_state = CSConst.RewardState.unpick
    self:send({[id] = cpydata})
end

-- 清除旧数据
function luxury_check_in:clear_data(id)
    if self.data[id].reward_times <= 0 then
        self.data[id] = nil
        return
    end
    local mail_id = CSConst.MailId.LuxuryCheckIn
    local all_item_list = {}
    local item_list = excel_data.RewardData[self.data[id].reward_id].item_list
    for i = 1, self.data[id].reward_times do
        table.extend(all_item_list, table.deep_copy(item_list))
    end
    self.role:add_mail({mail_id = mail_id, item_list = all_item_list})
    self.data[id] = nil
end

-- 领取奖励
function luxury_check_in:receiving_reward(id)
    if not id then return end
    local data = self.data[id]
    if not data then return end
    if data.reward_times <= 0 then return end
    data.reward_times = data.reward_times - 1
    data.recharge_times = data.recharge_times - 1
    if data.reward_times <= 0 then
        local reward_state = data.recharge_times <= 0 and CSConst.RewardState.picked or CSConst.RewardState.unpick
        self:send({[id] = {recharge_times = data.recharge_times, reward_state = reward_state}})
    else
        self:send({[id] = {recharge_times = data.recharge_times}})
    end
    self.role:add_item_list(excel_data.RewardData[data.reward_id].item_list, g_reason.luxury_check_in_reward)
    return true
end

-- 充值事件
function luxury_check_in:recharge_event(recharge_id)
    if not recharge_id then return end
    local id_list = excel_data.SingleRechargeData.recharge_dict[recharge_id]
    if not id_list then return end
    local matching_id = nil
    for _, id in ipairs(id_list) do
        if self.data[id] then
            matching_id = id
            break
        end
    end
    if not matching_id then return end
    local data = self.data[matching_id]
    if data.recharge_times == data.reward_times then return end
    data.reward_times = data.reward_times + 1
    if data.reward_times == 1 then
        self:send({[matching_id] = {reward_state = CSConst.RewardState.pick}})
    end
end

return luxury_check_in