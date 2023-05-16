local timer = require("timer")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local agent_utils = require("agent_utils")
local STATE = CSConst.ActivityState -- 活动状态

local festival_activity_utils = DECLARE_MODULE("festival_activity_utils")
local ActivityClass = DECLARE_CLASS(festival_activity_utils, "ActivityClass")

-- group_id => { activity_id => activity_obj }
local all_activity_obj_dict = DECLARE_RUNNING_ATTR(festival_activity_utils, "all_activity_obj_dict", {}) -- 所有活动对象

-- reward_id => activity_id
local reward_to_activity_dict = DECLARE_RUNNING_ATTR(festival_activity_utils, "reward_to_activity_dict", {})

-- discount_id => activity_id
local discount_to_activity_dict = DECLARE_RUNNING_ATTR(festival_activity_utils, "discount_to_activity_dict", {})

-- exchange_id => activity_id
local exchange_to_activity_dict = DECLARE_RUNNING_ATTR(festival_activity_utils, "exchange_to_activity_dict", {})

-- 启动时初始化
function festival_activity_utils.start()
    print("-------------------")
    print("festival activity start")
    print("-------------------")
    for group_id in pairs(excel_data.FestivalGroupData) do
        if type(group_id) == 'number' then
            all_activity_obj_dict[group_id] = {}
        end
    end
    for _, data in ipairs(excel_data.FestivalGroupData.all_activity_list) do
        ActivityClass.new(data)
    end
end

-- 获取正在进行的活动组 id
function festival_activity_utils.get_current_group_id()
    local now_ts = date.time_second()
    for group_id, group_data in pairs(excel_data.FestivalGroupData) do
        if type(group_id) == 'number' then
            if group_data.open_ts <= now_ts and now_ts <= group_data.close_ts then
                return group_id
            end
        end
    end
end

-- 获取指定 group_id 的 activity_dict
function festival_activity_utils.get_activity_dict(group_id)
    group_id = group_id or festival_activity_utils.get_current_group_id()
    return group_id and all_activity_obj_dict[group_id]
end

-- 获取一个活动的状态
function festival_activity_utils.get_activity_state(activity_id)
    if not activity_id then return end
    local activity_dict = festival_activity_utils.get_activity_dict()
    if not activity_dict then return end
    local activity_obj = activity_dict[activity_id]
    if not activity_obj then return end
    return activity_obj.state
end

-- 根据 reward_id 找到 recharge_id
function festival_activity_utils.get_recharge_id_by_reward_id(activity_id, reward_id)
    if not activity_id or not reward_id then return end
    local activity_dict = festival_activity_utils.get_activity_dict()
    if not activity_dict then return end
    local activity_obj = activity_dict[activity_id]
    if not activity_obj then return end
    return activity_obj.reward_to_recharge_dict[reward_id]
end

-- 检查 type_id 是否可用，如果是则返回 activity_id,content_id (started)
function festival_activity_utils.check_type_is_available(type_id)
    if not type_id then return end
    local activity_dict = festival_activity_utils.get_activity_dict()
    if not activity_dict then return end
    for activity_id, activity_obj in pairs(activity_dict) do
        if activity_obj.state == STATE.started then
            -- 同一时间最多只有一个小活动在进行，所以可以直接返回
            local content_id = activity_obj.content_dict[type_id]
            if content_id then return activity_id, content_id end
        end
    end
end

-- 检查 reward_id 是否可用，如果是则返回 activity_id (started)
function festival_activity_utils.check_reward_is_available(reward_id)
    if not reward_id then return end
    local activity_id = reward_to_activity_dict[reward_id]
    if not activity_id then return end
    local activity_dict = festival_activity_utils.get_activity_dict()
    if not activity_dict then return end
    if activity_dict[activity_id].state == STATE.started then
        return activity_id
    end
end

-- 检查 discount_id 是否可用，如果是则返回 activity_id (started)
function festival_activity_utils.check_discount_is_available(discount_id)
    if not discount_id then return end
    local activity_id = discount_to_activity_dict[discount_id]
    if not activity_id then return end
    local activity_dict = festival_activity_utils.get_activity_dict()
    if not activity_dict then return end
    if activity_dict[activity_id].state == STATE.started then
        return activity_id
    end
end

-- 检查 exchange_id 是否可用，如果是则返回 activity_obj (started|stopped|reserve)
function festival_activity_utils.check_exchange_is_available(exchange_id)
    if not exchange_id then return end
    local activity_id = exchange_to_activity_dict[exchange_id]
    if not activity_id then return end
    local activity_dict = festival_activity_utils.get_activity_dict()
    if not activity_dict then return end
    local activity_obj = activity_dict[activity_id]
    local state = activity_obj.state
    if state == STATE.started or state == STATE.stopped or state == STATE.reserve then
        return activity_obj
    end
end

-- 构造 activity_obj
function ActivityClass.new(data)
    local self = setmetatable({}, ActivityClass)
    self.id = data.activity_id
    self.group_id = data.group_id
    self.start_ts = data.start_ts
    self.stop_ts = data.stop_ts
    self.end_ts = data.end_ts
    self.close_ts = data.close_ts
    self.welfare_stuff = data.welfare_stuff
    self.luxury_stuff = data.luxury_stuff
    local activity_data = excel_data.FestivalActivityData[self.id]
    self.reward_dict = {}   -- reward_id => true
    self.content_dict = {}  -- content_type_id => content_id
    self.discount_dict = {} -- discount_id => discount_count
    self.exchange_dict = {} -- exchange_id => exchange_count
    self.reward_to_recharge_dict = {} -- reward_id => recharge_id
    for _, content_id in ipairs(activity_data.welfare) do
        local content_type_id = excel_data.FestivalContentData[content_id].type_id
        self.content_dict[content_type_id] = content_id
    end
    for _, content_id in ipairs(activity_data.celebration) do
        local content_type_id = excel_data.FestivalContentData[content_id].type_id
        self.content_dict[content_type_id] = content_id
    end
    for _, content_id in ipairs(activity_data.activity) do
        local content_type_id = excel_data.FestivalContentData[content_id].type_id
        self.content_dict[content_type_id] = content_id
    end
    for _, content_id in pairs(self.content_dict) do
        local content_data = excel_data.FestivalContentData[content_id]
        for _, reward_id in ipairs(content_data.reward_list) do
            self.reward_dict[reward_id] = true
        end
        if content_data.recharge_ids and content_data.recharge_times then
            for recharge_id, recharge_data in pairs(content_data.recharge_dict) do
                self.reward_to_recharge_dict[recharge_data.reward] = recharge_id
            end
        end
    end
    for _, discount_id in ipairs(activity_data.discount) do
        self.discount_dict[discount_id] = excel_data.FestivalDiscountData[discount_id].limit_buy_time
    end
    for _, exchange_id in ipairs(activity_data.exchange) do
        self.exchange_dict[exchange_id] = excel_data.FestivalExchangeData[exchange_id].limit_buy_time
    end
    for reward_id, _ in pairs(self.reward_dict) do
        reward_to_activity_dict[reward_id] = self.id
    end
    for discount_id, _ in pairs(self.discount_dict) do
        discount_to_activity_dict[discount_id] = self.id
    end
    for exchange_id, _ in pairs(self.exchange_dict) do
        exchange_to_activity_dict[exchange_id] = self.id
    end
    all_activity_obj_dict[self.group_id][self.id] = self
    self:init()
    return self
end

-- 初始化 activity_obj
function ActivityClass:init()
    local now_ts = date.time_second()
    if now_ts < self.start_ts then
        self.state = STATE.nostart
        print("--- from_nostart_to_started " .. self.start_ts - now_ts)
        timer.once(self.start_ts - now_ts, function() self:from_nostart_to_started() end)
    elseif self.start_ts <= now_ts and now_ts < self.stop_ts then
        self.state = STATE.started
        print("--- from_started_to_stopped " .. self.stop_ts - now_ts)
        timer.once(self.stop_ts - now_ts, function() self:from_started_to_stopped() end)
    elseif self.stop_ts <= now_ts and now_ts < self.end_ts then
        self.state = STATE.stopped
        print("--- from_stopped_to_reserve " .. self.end_ts - now_ts)
        timer.once(self.end_ts - now_ts, function() self:from_stopped_to_reserve() end)
    elseif self.end_ts <= now_ts and now_ts < self.close_ts then
        self.state = STATE.reserve
        print("--- from_reserve_to_invalid " .. self.close_ts - now_ts)
        timer.once(self.close_ts - now_ts, function() self:from_reserve_to_invalid() end)
    else
        print("--- is nothing")
        self.state = STATE.invalid
    end
end

-- nostart -> started (此刻活动进入开始状态)
function ActivityClass:from_nostart_to_started()
    self.state = STATE.started
    timer.once(self.stop_ts - self.start_ts, function() self:from_started_to_stopped() end)
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        role.festival_activity:notify_activity_started(self.id, self)
    end
end

-- started -> stopped (此刻活动进入保留状态)
function ActivityClass:from_started_to_stopped()
    self.state = STATE.stopped
    timer.once(self.end_ts - self.stop_ts, function() self:from_stopped_to_reserve() end)
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        role.festival_activity:notify_activity_stopped(self.id)
    end
end

-- stopped -> reserve (整轮活动结束后仍可兑换)
function ActivityClass:from_stopped_to_reserve()
    self.state = STATE.reserve
    timer.once(self.close_ts - self.end_ts, function() self:from_reserve_to_invalid() end)
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        role.festival_activity:notify_activity_reserve(self.id)
    end
end

-- reserve -> invalid (兑换时间结束后再清数据)
function ActivityClass:from_reserve_to_invalid()
    self.state = STATE.invalid
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        role.festival_activity:notify_activity_invalid(self.id)
    end
end

return festival_activity_utils