local date = require("sys_utils.date")
local excel_data = require("excel_data")
local action_point_utils = require("action_point_utils")
local STATE = CSConst.ActivityState -- 活动状态

local action_point = DECLARE_MODULE("meta_table.action_point")

function action_point.new(role)
    local self = {
        role = role,
        data = role.db.fixed_action_point,
        db   = role.db,
    }
    return setmetatable(self, action_point)
end

function action_point:load()
    local data_id, data_obj = action_point_utils.get_available_activity()
    if self.data.data_id ~= data_id or self.data.last_init_ts < data_obj.start_ts then
        self.db.fixed_action_point = {
            data_id = data_id,
            lover_id = self.role:get_random_lover(),
            reward_status = data_obj.state == STATE.started and CSConst.RewardState.pick or CSConst.RewardState.unpick,
            last_init_ts = data_obj.state == STATE.started and date.time_second() or data_obj.start_ts,
        }
        self.data = self.db.fixed_action_point
    end
end

-- 添加初始情人时再随机一位情人
function action_point:on_add_init_lover()
    if self.data.lover_id then return end
    self.data.lover_id = self.role:get_random_lover()
end

function action_point:online()
    self:send(self.data)
end

function action_point:send(data)
    self.role:send_client("s_update_fixed_action_point_info", data)
end

-- 新开的(通知客户端)
function action_point:notify_started(data_id, data_obj)
    self.data.reward_status = CSConst.RewardState.pick
    self:send({reward_status = self.data.reward_status})
end

-- 已过期(防止领奖励)
function action_point:notify_invalid()
    local data_id, data_obj = action_point_utils.get_available_activity()
    self.db.fixed_action_point = {
        data_id = data_id,
        lover_id = self.role:get_random_lover(),
        reward_status = CSConst.RewardState.unpick,
        last_init_ts = data_obj.start_ts,
    }
    self.data = self.db.fixed_action_point
    self:send(self.data)
end

-- 领取定点体力的奖励
function action_point:pick_reward()
    local data_id = self.data.data_id
    if self.data.reward_status ~= CSConst.RewardState.pick then return end
    self.data.reward_status = CSConst.RewardState.picked
    self.role:change_action_point(excel_data.ActionPointData[data_id].action_point, true)
    local is_add_exp = false
    if math.random() < excel_data.ActionPointData[data_id].lover_exp_ratio then
        is_add_exp = true
        self.role:add_lover_exp(self.data.lover_id, excel_data.ActionPointData[data_id].lover_exp_value)
    end
    self:send({reward_status = self.data.reward_status})
    return {errcode = g_tips.ok, is_add_exp = is_add_exp}
end

return action_point