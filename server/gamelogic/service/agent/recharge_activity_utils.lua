local timer = require("timer")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local agent_utils = require("agent_utils")

local recharge_activity_utils = DECLARE_MODULE("recharge_activity_utils")
local ActivityCls = DECLARE_CLASS(recharge_activity_utils, "ActivityCls")
-- 键为activity_id
local ready_activity_dict = DECLARE_RUNNING_ATTR(recharge_activity_utils, "ready_activity_dict", {}) -- 未开始的活动
local started_activity_dict = DECLARE_RUNNING_ATTR(recharge_activity_utils, "started_activity_dict", {}) -- 进行中的活动
local receive_activity_dict = DECLARE_RUNNING_ATTR(recharge_activity_utils, "receive_activity_dict", {}) -- 可领取的活动

-- 键为activity_id => 中奖信息{user_name, time, award_id}
local activity_award_dict = DECLARE_RUNNING_ATTR(recharge_activity_utils, "activity_award_dict", {})
local MaxAwardCount = 30

local ActivityMapper = {
    [CSConst.RechargeActivity.SingleRecharge] = "single_recharge",
    [CSConst.RechargeActivity.WorthRecharge] = "worth_recharge",
    [CSConst.RechargeActivity.RechargeDraw] = "recharge_draw",
}

function recharge_activity_utils.start()
    print("=====================")
    print("充值 activity start")
    print("=====================")
    for _, data in pairs(excel_data.RechargeActivityData) do
        ActivityCls.new(data)
    end
end

function recharge_activity_utils.check_available_activity(activity_type)
    local id_list = {}
    for id, data in pairs(excel_data.RechargeActivityData) do
        if data.activity_type == activity_type and recharge_activity_utils.can_receive_activity(id) then
            table.insert(id_list, id)
        end
    end
    return id_list
end

-- 活动是否在进行状态
function recharge_activity_utils.is_ongoing_activity(activity_id)
    if not activity_id then return false end
    if started_activity_dict[activity_id] then return true end
    return false
end

-- 活动是否在可领取状态
function recharge_activity_utils.can_receive_activity(activity_id)
    if not activity_id then return false end
    if started_activity_dict[activity_id] then return true end
    if receive_activity_dict[activity_id] then return true end
    return false
end

-- 插入中奖信息 activity_id => {user_name, time, award_id}
function recharge_activity_utils.insert_player_award(activity_id, award_info)
    if not excel_data.RechargeActivityData[activity_id].show_other_reward then return end
    if not recharge_activity_utils.can_receive_activity(activity_id) then return end
    if activity_award_dict[activity_id] == nil then activity_award_dict[activity_id] = {} end
    table.insert(activity_award_dict[activity_id], award_info)
    if #activity_award_dict[activity_id] > MaxAwardCount then
        table.remove(activity_award_dict[activity_id], 1)
    end
end

-- 获取中奖信息 LIST => {user_name, time, award_id}
function recharge_activity_utils.get_player_award(activity_id)
    if not excel_data.RechargeActivityData[activity_id].show_other_reward then return end
    if not recharge_activity_utils.can_receive_activity(activity_id) then return end
    return activity_award_dict[activity_id] or {}
end


function ActivityCls.new(data)
    local now_time = date.time_second()
    if now_time >= data.activity_close_time then return nil end
    local self = setmetatable({}, ActivityCls)
    self.id = data.id
    self.start_time = data.activity_start_time
    self.end_time = data.activity_end_time
    self.close_time = data.activity_close_time
    self.type = data.activity_type
    if now_time < self.start_time then
        ready_activity_dict[self.id] = self
        print("======= is from_nostart_to_started " .. self.start_time - now_time)
        timer.once(self.start_time - now_time, function() self:from_nostart_to_started() end)
    elseif self.start_time <= now_time and now_time < self.end_time then
        started_activity_dict[self.id] = self
        print("======= is from_started_to_end " .. self.end_time - now_time)
        timer.once(self.end_time - now_time, function() self:from_started_to_end() end)
    elseif self.end_time <= now_time and now_time < self.close_time then
        receive_activity_dict[self.id] = self
        print("======= is from_end_to_close " .. self.close_time - now_time)
        timer.once(self.close_time - now_time, function() self:from_end_to_close() end)
    end
    return self
end

-- nostart -> started (活动进入进行中状态)
function ActivityCls:from_nostart_to_started()
    started_activity_dict[self.id] = self
    ready_activity_dict[self.id] = nil
    timer.once(self.end_time - self.start_time, function() self:from_started_to_end() end)
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        local main_func = ActivityMapper[self.type]
        role[main_func]:init_activity(self.id)
    end
end

-- started -> end (活动进入可领取状态)
function ActivityCls:from_started_to_end()
    receive_activity_dict[self.id] = self
    started_activity_dict[self.id] = nil
    timer.once(self.close_time - self.end_time, function() self:from_end_to_close() end)
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        local main_func = ActivityMapper[self.type]
        if role[main_func].stop_activity then
            role[main_func]:stop_activity(self.id)
        end
        role:send_client("s_end_recharge_activity", {activity_id = self.id})
    end
end

-- end -> close (关闭活动)
function ActivityCls:from_end_to_close()
    receive_activity_dict[self.id] = nil
    if activity_award_dict[self.id] then
        activity_award_dict[self.id] = nil
    end
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        local main_func = ActivityMapper[self.type]
        role[main_func]:clear_activity(self.id)
        role:send_client("s_close_recharge_activity", {activity_id = self.id})
    end
end

return recharge_activity_utils