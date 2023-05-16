local timer = require("timer")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local agent_utils = require("agent_utils")
local STATE = CSConst.ActivityState -- 活动状态

local action_point_utils = DECLARE_MODULE("action_point_utils")
local ActionPointClass = DECLARE_CLASS(action_point_utils, "ActionPointClass")

-- id -> obj
local action_point_dict = DECLARE_RUNNING_ATTR(action_point_utils, "action_point_dict", {})

-- 启动时初始化
function action_point_utils.start()
    for _, data in pairs(excel_data.ActionPointData) do
        ActionPointClass.new(data)
    end
end

-- 获取正在进行或将要开始的活动
function action_point_utils.get_available_activity()
    local list = {}
    for id, obj in pairs(action_point_dict) do
        if obj.state == STATE.started then
            return id, obj
        end
        table.insert(list, obj)
    end
    table.sort(list, function(obj1, obj2) return obj1.start_ts < obj2.start_ts end)
    return list[1].id, list[1]
end

-- 构造 action_point_object
function ActionPointClass.new(data)
    local self = setmetatable({}, ActionPointClass)
    self.id = data.id
    self.start_sec = data.start_sec
    self.stop_sec = data.stop_sec
    action_point_dict[self.id] = self
    self:init()
    return self
end

-- 初始化 action_point_object
function ActionPointClass:init()
    local now_ts = date.time_second()
    self.start_ts = date.get_begin0(now_ts) + self.start_sec
    self.stop_ts = date.get_begin0(now_ts) + self.stop_sec
    if now_ts < self.start_ts then
        self.state = STATE.nostart
        timer.once(self.start_ts - now_ts, function() self:from_nostart_to_started() end)
    elseif self.start_ts <= now_ts and now_ts < self.stop_ts then
        self.state = STATE.started
        timer.once(self.stop_ts - now_ts, function() self:from_started_to_nostart() end)
    elseif self.stop_ts <= now_ts then
        self.state = STATE.nostart
        self.start_ts = self.start_ts + CSConst.Time.Day
        self.stop_ts = self.stop_ts + CSConst.Time.Day
        timer.once(self.start_ts - now_ts, function() self:from_nostart_to_started() end)
    end
end

-- 定时器函数, nostart -> started
function ActionPointClass:from_nostart_to_started()
    self.state = STATE.started
    timer.once(self.stop_ts - self.start_ts, function() self:from_started_to_nostart() end)
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        role.action_point:notify_started(self.id, self)
    end
end

-- 定时器函数, started -> nostart
function ActionPointClass:from_started_to_nostart()
    self.state = STATE.nostart
    self.start_ts = self.start_ts + CSConst.Time.Day
    self.stop_ts = self.stop_ts + CSConst.Time.Day
    timer.once(self.start_ts - date.time_second(), function() self:from_nostart_to_started() end)
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        role.action_point:notify_invalid()
    end
end

return action_point_utils