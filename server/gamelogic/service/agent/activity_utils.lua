local timer = require("timer")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local rank_utils = require("rank_utils")
local agent_utils = require("agent_utils")
local STATE = CSConst.ActivityState -- 活动状态

local activity_utils = DECLARE_MODULE("activity_utils")
local ActivityClass = DECLARE_CLASS(activity_utils, "ActivityClass")

-- activity_id => activity_obj
local activity_dict = DECLARE_RUNNING_ATTR(activity_utils, "activity_dict", {}) -- 所有的活动对象

-- rank_name => detail_id
local rank_to_detail_dict = DECLARE_RUNNING_ATTR(activity_utils, "rank_to_detail_dict", {})

-- item_id => detail_id
local item_to_detail_dict = DECLARE_RUNNING_ATTR(activity_utils, "item_to_detail_dict", {})

-- 启动时初始化
function activity_utils.start()
    print("+++++++++++++++++++")
    print("activity start")
    print("+++++++++++++++++++")
    for _, data in pairs(excel_data.ActivityData) do
        ActivityClass.new(data)
    end
end

-- 获取一个活动的状态(nostart/started/stopped/invalid)
function activity_utils.get_activity_state(activity_id)
    if not activity_id then return end
    local activity_obj = activity_dict[activity_id]
    if not activity_obj then return end
    return activity_obj.state
end

-- 获取 rank_name 对应的 detail_id
function activity_utils.get_detail_id_by_rank_name(rank_name)
    if not rank_name then return end
    return rank_to_detail_dict[rank_name]
end

-- 获取 item_id 对应的 detail_id
function activity_utils.get_detail_id_by_item_id(item_id)
    if not item_id then return end
    return item_to_detail_dict[item_id]
end

-- 检查 detail 是否可用 (started), 返回 activity_id
function activity_utils.check_detail_is_available(detail_id)
    if not detail_id then return end
    for activity_id, activity_obj in pairs(activity_dict) do
        if activity_obj.state == STATE.started and activity_obj.detail_dict[detail_id] then
            return activity_id
        end
    end
end

-- 检查 reward 是否可用 (started|stopped), 返回 activity_id
function activity_utils.check_reward_is_available(reward_id)
    if not reward_id then return end
    for activity_id, activity_obj in pairs(activity_dict) do
        if (activity_obj.state == STATE.started or activity_obj.state == STATE.stopped) and activity_obj.reward_dict[reward_id] then
            return activity_id
        end
    end
end

-- 检查 rank 是否可用 (started|stopped), 返回 activity_id
function activity_utils.check_rank_is_available(rank_name)
    if not rank_name then return end
    local detail_id = activity_utils.get_detail_id_by_rank_name(rank_name)
    if not detail_id then return end
    for activity_id, activity_obj in pairs(activity_dict) do
        if (activity_obj.state == STATE.started or activity_obj.state == STATE.stopped) and activity_obj.detail_dict[detail_id] then
            return activity_id
        end
    end
end

-- 构造活动对象
function ActivityClass.new(data)
    local self = setmetatable({}, ActivityClass)
    self.id = data.id
    self.start_ts = data.activity_start_timestamp
    self.stop_ts = data.activity_stop_timestamp
    self.end_ts = data.activity_end_timestamp
    self.detail_dict = {}
    self.reward_dict = {}
    self.rank_dict   = {}
    for _, group_id in ipairs(data.activity_group_list) do
        for _, detail_id in ipairs(excel_data.ActivityGroupData[group_id].activity_detail_list) do
            self.detail_dict[detail_id] = true
            local detail_record = excel_data.ActivityDetailData[detail_id]
            if detail_record.rank_name then 
                self.rank_dict[detail_record.rank_name] = true 
                rank_to_detail_dict[detail_record.rank_name] = detail_id
            end
            if detail_record.item_id then
                item_to_detail_dict[detail_record.item_id] = detail_id
            end
            for _, reward_id in ipairs(detail_record.activity_reward_list) do
                self.reward_dict[reward_id] = true
            end
        end
    end
    activity_dict[self.id] = self
    self:init()
    return self
end

-- 初始化活动对象
function ActivityClass:init()
    local now_ts = date.time_second()
    if now_ts < self.start_ts then
        self.state = STATE.nostart
        print("++++ is from_nostart_to_started " .. self.start_ts - now_ts)
        timer.once(self.start_ts - now_ts, function() self:from_nostart_to_started() end)
    elseif self.start_ts <= now_ts and now_ts < self.stop_ts then
        self.state = STATE.started
        print("++++ is from_started_to_stopped " .. self.stop_ts - now_ts)
        timer.once(self.stop_ts - now_ts, function() self:from_started_to_stopped() end)
    elseif self.stop_ts <= now_ts and now_ts < self.end_ts then
        self.state = STATE.stopped
        print("++++ is from_stopped_to_invalid " .. self.end_ts - now_ts)
        timer.once(self.end_ts - now_ts, function() self:from_stopped_to_invalid() end)
    else
        self.state = STATE.invalid
        print("++++ is nothing")
        for rank_name, _ in pairs(self.rank_dict) do
            rank_utils.clear_rank_data(rank_name)
        end
    end
end

-- nostart -> started
function ActivityClass:from_nostart_to_started()
    self.state = STATE.started
    timer.once(self.stop_ts - self.start_ts, function() self:from_started_to_stopped() end)
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        role.activity:notify_activity_started(self.id, self)
    end
end

-- started -> stopped
function ActivityClass:from_started_to_stopped()
    self.state = STATE.stopped
    timer.once(self.end_ts - self.stop_ts, function() self:from_stopped_to_invalid() end)
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        role.activity:notify_activity_stopped(self.id)
    end
end

-- stopped -> invalid
function ActivityClass:from_stopped_to_invalid()
    self.state = STATE.invalid
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        role.activity:notify_activity_invalid(self.id)
    end
    for rank_name, _ in pairs(self.rank_dict) do
        rank_utils.clear_rank_data(rank_name)
    end
end

return activity_utils