local excel_data = require("excel_data")
local rank_utils = require("rank_utils")
local agent_utils = require("agent_utils")
local cluster_utils = require("msg_utils.cluster_utils")
local rush_activity_utils = require("rush_activity_utils")
local agent_utils = require("agent_utils")
local STATE = CSConst.ActivityState -- 活动状态

local role_rush_activity = DECLARE_MODULE("meta_table.rush_activity")
local json = require("json")

function role_rush_activity.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        data = role.db.rush_activity,
    }
    return setmetatable(self, role_rush_activity)
end

function role_rush_activity:load()
    -- 清理无效的活动数据 (nostart/expired)
    for activity_id, activity_data in pairs(self.data) do
        local activity_obj = rush_activity_utils.activity_dict[activity_id]
        print("role_rush_activity activity_obj :"..json.encode(activity_obj))
        print("role_rush_activity activity_data :"..json.encode(activity_data))
        if not activity_obj or activity_obj.start_ts ~= activity_data.start_ts then
            self.data[activity_id] = nil
        end
    end
    -- 初始化有效的活动数据 (started/stopped)
    for activity_id, activity_obj in pairs(rush_activity_utils.activity_dict) do
        print("role_rush_activity load :"..json.encode(activity_obj))
        local state = activity_obj.state
        local start_ts = activity_obj.start_ts
        if (state == STATE.started or state == STATE.stopped) and (not self.data[activity_id]) then
            self.data[activity_id] = {start_ts = start_ts, self_value = 0}
        end
    end
end

function role_rush_activity:online()
    local data = table.deep_copy(self.data)
    print("role_rush_activity online data:"..json.encode(data))
    for activity_id, activity_data in pairs(data) do
        local activity_obj = rush_activity_utils.activity_dict[activity_id]
        local rank_name = excel_data.RushActivityData[activity_id].rank
        if activity_id == CSConst.RushActivityType.dynasty then
            local dynasty_id = self.role:get_dynasty_id()
            if dynasty_id then
                activity_data.self_rank = cluster_utils.call_dynasty("lc_get_dynasty_rank_index", rank_name, dynasty_id) or CSConst.RushListActivityRankNil
            else
                activity_data.self_rank = CSConst.RushListActivityRankNil
            end
        else
            activity_data.self_rank = rank_utils.get_role_rank(rank_name, self.uuid) or CSConst.RushListActivityRankNil
        end
        activity_data.stop_ts = activity_obj.stop_ts
        activity_data.end_ts = activity_obj.end_ts
        activity_data.state = activity_obj.state
    end
    agent_utils.get_server_day()
    print("role_rush_activity online current:"..json.encode(data))
    self:send(data)
end

function role_rush_activity:send(data)
    self.role:send_client("s_rush_activity_data_update", {activity_dict = data})
end

-- 活动开始通知
function role_rush_activity:notify_activity_started(activity_id, activity_obj)
    self.data[activity_id] = {start_ts = activity_obj.start_ts, self_value = 0}
    local data = table.deep_copy(self.data[activity_id])
    data.stop_ts = activity_obj.stop_ts
    data.end_ts = activity_obj.end_ts
    data.state = STATE.started
    if activity_id == CSConst.RushActivityType.dynasty then
        local dynasty_id = self.role:get_dynasty_id()
        if dynasty_id then
            local rank_name = excel_data.RushActivityData[activity_id].rank
            data.self_rank = cluster_utils.call_dynasty("lc_get_dynasty_rank_index", rank_name, dynasty_id) or CSConst.RushListActivityRankNil
        else
            data.self_rank = CSConst.RushListActivityRankNil
        end
    else
        data.self_rank = CSConst.RushListActivityRankNil
    end
    self:send({[activity_id] = data})
end

-- 活动停止通知
function role_rush_activity:notify_activity_stopped(activity_id)
    self:send({[activity_id] = {state = STATE.stopped}})
end

-- 活动过期通知
function role_rush_activity:notify_activity_invalid(activity_id)
    self.data[activity_id] = nil
    self:send({[activity_id] = {state = STATE.invalid}})
end

-- 加入王朝通知
function role_rush_activity:on_join_dynasty(dynasty_id)
    local activity_id = CSConst.RushActivityType.dynasty
    if not rush_activity_utils.check_activity_is_available(activity_id) then return end
    local rank_name = excel_data.RushActivityData[CSConst.RushActivityType.dynasty].rank
    local self_rank = cluster_utils.call_dynasty("lc_get_dynasty_rank_index", rank_name, dynasty_id)
    if self_rank then
        self:send({[activity_id] = {self_rank = self_rank}})
    end
end

-- 退出王朝通知
function role_rush_activity:on_quit_dynasty()
    local activity_id = CSConst.RushActivityType.dynasty
    if not rush_activity_utils.check_activity_is_available(activity_id) then return end
    self:send({[activity_id] = {self_rank = CSConst.RushListActivityRankNil}})
end

-- 刷新排行榜
function role_rush_activity:get_self_rank(activity_id)
    local rank_dict = {} -- key: activity_id, value: rank
    if activity_id then
        if not self.data[activity_id] then return end
        rank_dict[activity_id] = 0
    else
        for activity_id in pairs(self.data) do
            local activity_state = rush_activity_utils.activity_dict[activity_id].state
            if activity_state == STATE.started then rank_dict[activity_id] = 0 end
        end
    end
    for activity_id, rank in pairs(rank_dict) do
        local rank_name = excel_data.RushActivityData[activity_id].rank
        if activity_id == CSConst.RushActivityType.dynasty then
            local dynasty_id = self.role:get_dynasty_id()
            if dynasty_id then
                rank_dict[activity_id] = cluster_utils.call_dynasty("lc_get_dynasty_rank_index", rank_name, dynasty_id) or CSConst.RushListActivityRankNil
            else
                rank_dict[activity_id] = CSConst.RushListActivityRankNil
            end
        else
            rank_dict[activity_id] = rank_utils.get_role_rank(rank_name, self.uuid) or CSConst.RushListActivityRankNil
        end
    end
    return {rank_dict = rank_dict}
end

-- 获取排行榜
function role_rush_activity:get_activity_rank(rank_name)
    local activity_id = rush_activity_utils.check_rank_is_available(rank_name)
    if not activity_id then return end
    local rank = rank_utils.get_rank_list(rank_name, self.uuid)
    if not rank then return end
    rank.self_rank_score = self.data[activity_id].self_value
    rank.errcode = 0
    return rank
end

-- 获取王朝排行榜
function role_rush_activity:get_dynasty_rank()
    local rank_name = excel_data.RushActivityData[CSConst.RushActivityType.dynasty].rank
    local activity_id = rush_activity_utils.check_rank_is_available(rank_name)
    if not activity_id then return end
    local dynasty_id = agent_utils.get_dynasty_id(self.uuid)
    local rank_data = cluster_utils.call_dynasty("lc_get_dynasty_rank_list", rank_name, dynasty_id)
    if not rank_data then return end
    if dynasty_id and (not rank_data.self_rank_score) then
        rank_data.self_rank_score = 0
    end
    return rank_data
end

-- 更新排行榜
function role_rush_activity:update_activity_rank(activity_id, rank_name)
    self.role:update_role_rank(rank_name, self.data[activity_id].self_value)
    local self_rank = rank_utils.get_role_rank(rank_name, self.uuid) or CSConst.RushListActivityRankNil
    self:send({[activity_id] = {self_rank = self_rank}})
end

-- 更新活动数据
function role_rush_activity:update_activity_data(activity_id, add_value)
    if not add_value or add_value <= 0 or not activity_id then return end
    if not rush_activity_utils.check_activity_is_available(activity_id) then return end
    self.data[activity_id].self_value = self.data[activity_id].self_value + math.floor(add_value)
    self:update_activity_rank(activity_id, excel_data.RushActivityData[activity_id].rank)
end

-- 累计物品增长
function role_rush_activity:update_activity_item_data(item_id, add_count)
    self:update_activity_data(rush_activity_utils.item_to_activity_dict[item_id], add_count)
end

return role_rush_activity