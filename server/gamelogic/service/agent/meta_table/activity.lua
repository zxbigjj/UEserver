local excel_data = require("excel_data")
local rank_utils = require("rank_utils")
local activity_utils = require("activity_utils")
local STATE = CSConst.ActivityState -- 活动状态常量

local role_activity = DECLARE_MODULE("meta_table.activity")

function role_activity.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        data = role.db.activity,
    }
    return setmetatable(self, role_activity)
end

function role_activity:load()
    -- 清理无效的活动数据 (nostart/invalid)
    for activity_id, _ in pairs(self.data) do
        local state = activity_utils.get_activity_state(activity_id)
        if state ~= STATE.started and state ~= STATE.stopped then
            self.data[activity_id] = nil
        end
    end
    -- 初始化有效的活动数据 (started/stopped)
    for activity_id, activity_obj in pairs(activity_utils.activity_dict) do
        if (activity_obj.state == STATE.started or activity_obj.state == STATE.stopped) and (not self.data[activity_id]) then
            self:notify_activity_started(activity_id, activity_obj, true)
        end
    end
end

function role_activity:daily()
    self:update_activity_data(CSConst.ActivityType.LoginDays, 1)
end

function role_activity:online()
    local data = table.deep_copy(self.data)
    for activity_id, activity_data in pairs(data) do
        activity_data.state = activity_utils.get_activity_state(activity_id)
    end
    self:send(data)
end

function role_activity:send(data)
    self.role:send_client("s_activity_data_update", {activity_dict = data})
end

-- 活动开始通知
function role_activity:notify_activity_started(activity_id, activity_obj, init_db_only)
    local activity_data = {progress_dict={}, reward_dict={}}
    self.data[activity_id] = activity_data
    for detail_id, _ in pairs(activity_obj.detail_dict) do
        activity_data.progress_dict[detail_id] = 0
    end
    for reward_id, _ in pairs(activity_obj.reward_dict) do
        activity_data.reward_dict[reward_id] = CSConst.RewardState.unpick
    end
    if init_db_only then return end
    self:update_activity_data(CSConst.ActivityType.LoginDays, 1, true)
    self:send({[activity_id] = {
        progress_dict = activity_data.progress_dict,
        reward_dict = activity_data.reward_dict,
        state = STATE.started
    }})
end

-- 活动停止通知
function role_activity:notify_activity_stopped(activity_id)
    self:send({[activity_id] = {state = STATE.stopped}})
end

-- 活动过期通知
function role_activity:notify_activity_invalid(activity_id)
    self.data[activity_id] = nil
    self:send({[activity_id] = {state = STATE.invalid}})
end

-- 领取活动奖励
function role_activity:get_activity_reward(reward_id)
    local activity_id = activity_utils.check_reward_is_available(reward_id)
    if not activity_id then return end
    if self.data[activity_id].reward_dict[reward_id] ~= CSConst.RewardState.pick then return end
    self.data[activity_id].reward_dict[reward_id] = CSConst.RewardState.picked
    self.role:add_item_list(excel_data.ActivityRewardData[reward_id].item_list, g_reason.activity_reward)
    self:send({[activity_id] = {reward_dict = self.data[activity_id].reward_dict}})
    return true
end

-- 更新活动奖励
function role_activity:update_activity_reward(activity_id, detail_id)
    local activity_cond_list = excel_data.ActivityDetailData[detail_id].activity_cond_list
    local current_progress = self.data[activity_id].progress_dict[detail_id]
    local current_gear = 0
    for i = 1, #activity_cond_list do
        if current_progress >= activity_cond_list[i] then
            current_gear = i 
        else
            break
        end
    end
    local is_changed = false
    for i = 1, current_gear do
        local reward_id = excel_data.ActivityDetailData[detail_id].activity_reward_list[i]
        if self.data[activity_id].reward_dict[reward_id] == CSConst.RewardState.unpick then
            self.data[activity_id].reward_dict[reward_id] = CSConst.RewardState.pick
            is_changed = true
        end
    end
    return is_changed
end

-- 获取排行榜
function role_activity:get_activity_rank(rank_name)
    local activity_id = activity_utils.check_rank_is_available(rank_name)
    if not activity_id then return end
    local rank = rank_utils.get_rank_list(rank_name, self.uuid)
    if not rank then return end
    local detail_id = activity_utils.get_detail_id_by_rank_name(rank_name)
    rank.self_rank_score = self.data[activity_id].progress_dict[detail_id]
    rank.errcode = 0
    return rank
end

-- 更新排行榜
function role_activity:update_activity_rank(activity_id, detail_id)
    local rank_name = excel_data.ActivityDetailData[detail_id].rank_name
    if not rank_name then return end
    local current_progress = self.data[activity_id].progress_dict[detail_id]
    self.role:update_role_rank(rank_name, current_progress)
end

-- 更新活动数据
function role_activity:update_activity_data(detail_id, add_value, not_send)
    if not detail_id then return end
    if add_value <= 0 then return end
    local activity_id = activity_utils.check_detail_is_available(detail_id)
    if not activity_id then return end
    local last_progress = self.data[activity_id].progress_dict[detail_id]
    self.data[activity_id].progress_dict[detail_id] = last_progress + math.floor(add_value)
    self:update_activity_rank(activity_id, detail_id)
    local is_changed = self:update_activity_reward(activity_id, detail_id)
    if not not_send then
        self:send({[activity_id] = {
                progress_dict = self.data[activity_id].progress_dict,
                reward_dict = is_changed and self.data[activity_id].reward_dict or nil
        }})
    end
end

-- 累计消耗物品
function role_activity:update_activity_item_data(item_id, sub_count)
    self:update_activity_data(activity_utils.get_detail_id_by_item_id(item_id), sub_count)
end

return role_activity