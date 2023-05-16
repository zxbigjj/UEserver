local daily_active = DECLARE_MODULE("meta_table.daily_active")
local excel_data = require("excel_data")

--计数类型
local CalculateType = {
    AddType = 1,          --累加型
    ConsumeItemType = 2,  --消耗物品型
    PublicCmdType = 3,    --发布命令型
}

function daily_active.new(role)
    local self = {
        role = role,
        db = role.db,
    }
    return setmetatable(self, daily_active)
end

function daily_active:online()
    self.role:send_client("s_update_daily_active_info", self:get_daily_active_info())
end

function daily_active:get_daily_active_info()
    local task_dict = self.db.daily_active.task_dict
    local msg = {}

    msg.task_dict = {}
    for task_id, task_info in pairs(task_dict) do
        local require_progress = excel_data.DailyActiveData[task_id].require_progress
        msg.task_dict[task_id] = {}
        msg.task_dict[task_id].progress = task_info.progress
        msg.task_dict[task_id].is_receive = task_info.is_receive
        msg.task_dict[task_id].require_progress = require_progress
    end
    msg.active_value = self.role:get_currency(CSConst.Virtual.ActivePoint)
    msg.chest_dict = self.db.daily_active.chest_dict
    msg.unlock_chest_num = self.db.daily_active.unlock_chest_num
    return msg
end

function daily_active:daily_reset()
    local active_value = self.role:get_currency(CSConst.Virtual.ActivePoint)
    self.role:sub_currency(CSConst.Virtual.ActivePoint, active_value, g_reason.reset_daily_active_value)
    active_value = self.role:get_currency(CSConst.Virtual.ActivePoint)

    local level = self.role:get_level()
    self.db.daily_active.today_level = level
    local task_type_info = excel_data.DailyActiveTypeData
    local all_task_info = excel_data.DailyActiveData
    local chest_info = excel_data.DailyActiveChestData
    local new_task_dict = {}
    local select_task_dict = {}
    for type, data in ipairs(task_type_info) do
        if not data.func_unlock_id or self.role:check_function_is_unlocked(data.func_unlock_id) then
            for k, id in ipairs(all_task_info.type_to_task[type]) do
                local last_id = select_task_dict[type]
                if all_task_info[id].require_level <= level then
                    if not last_id or all_task_info[last_id].require_level < all_task_info[id].require_level then
                        select_task_dict[type] = id
                    end
                end
            end
        end
    end
    local total_value = 0
    for _, task_id in pairs(select_task_dict) do
        new_task_dict[task_id] = {}
        new_task_dict[task_id].progress = 0
        new_task_dict[task_id].is_receive = false
        local reward_id = all_task_info[task_id].reward_id
        local active_count = excel_data.RewardData[reward_id].item_dict[CSConst.Virtual.ActivePoint]
        total_value = total_value + active_count
    end
    self.db.daily_active.task_dict = new_task_dict

    local new_chest_dict = {}
    for k, v in ipairs(chest_info) do
        if v.show_value > total_value then break end
        new_chest_dict[k] = false
        self.db.daily_active.unlock_chest_num = k
    end
    self.db.daily_active.chest_dict = new_chest_dict
    self.role:send_client("s_update_daily_active_info", self:get_daily_active_info())
end

-- 更新日常活跃任务进度
function daily_active:update_daily_active(task_type, progress, id)
    if not task_type or not progress then return end
    local task_dict = self.db.daily_active.task_dict
    local task_id = nil
    for k, v in pairs(excel_data.DailyActiveData) do
        if task_dict[k] and v.task_type == task_type then
            task_id = k
            break
        end
    end
    if not task_id then return end
    local last_progress = task_dict[task_id].progress
    local require_progress = excel_data.DailyActiveData[task_id].require_progress
    local calculate_type = excel_data.DailyActiveTypeData[task_type].calculate_type
    if calculate_type == CalculateType.AddType then
        if not self:update_add_type(task_id, progress) then return end
    elseif calculate_type == CalculateType.ConsumeItemType then
        local item_id = id
        if not self:update_consume_item_type(task_id, progress, item_id) then return end
    elseif calculate_type == CalculateType.PublicCmdType then
        local cmd_id = id
        if not self:update_public_cmd_type(task_id, progress, cmd_id) then return end
    else
        return
    end

    self:update_state_info()
    self.role:send_client("s_update_daily_active_info", {task_dict = self:get_daily_active_info().task_dict})
    if last_progress < require_progress and require_progress <= task_dict[task_id].progress then
        self.role:gaea_log("RoleTask", {
            taskType = g_const.LogTaskType.Daily,
            taskId = task_id,
            status = g_const.LogTaskStatus.Finish
        })
    end
end

function daily_active:update_add_type(task_id, progress)
    local task_info = self.db.daily_active.task_dict[task_id]
    task_info.progress = task_info.progress + progress
    return true
end

function daily_active:update_consume_item_type(task_id, progress, item_id)
    if not item_id then return end
    local task_data = excel_data.DailyActiveData[task_id]
    local task_type_info = excel_data.DailyActiveTypeData
    local task_info = self.db.daily_active.task_dict[task_id]
    if task_type_info[task_data.task_type].consume_item_id ~= item_id then return end
    task_info.progress = task_info.progress + progress
    return true
end

function daily_active:update_public_cmd_type(task_id, progress, cmd_id)
    if not cmd_id then return end
    local task_data = excel_data.DailyActiveData[task_id]
    local task_type_info = excel_data.DailyActiveTypeData
    local task_info = self.db.daily_active.task_dict[task_id]
    if task_type_info[task_data.task_type].cmd_id ~= cmd_id then return end
    task_info.progress = task_info.progress + progress
    return true
end

-- 领取活跃任务以及奖励
function daily_active:receive_active_task_reward(task_id)
    if not task_id then return end
    local task_dict = self.db.daily_active.task_dict
    if task_dict[task_id].is_receive ~= true then return end
    local task_info = excel_data.DailyActiveData[task_id]
    local require_progress = task_info.require_progress
    if not require_progress or task_dict[task_id].progress < require_progress then return end

    local reward_info = {}
    local reward_id = task_info.reward_id
    self.db.daily_active.task_dict[task_id].is_receive = nil
    if reward_id then
        local reward_data = excel_data.RewardData[reward_id]
        local reason = g_reason.daily_active_task_reward
        self.role:add_item_list(reward_data.item_list, reason)
        local active_value = reward_data.item_dict[CSConst.Virtual.ActivePoint]
        if active_value then
            self.role:update_dynasty_task(CSConst.DynastyTaskType.DailyActive, active_value)
        end
    end
    self.role:get_replenish_count_by_active(excel_data.DailyActiveChestData[self.db.daily_active.unlock_chest_num].require_active)
    self:update_state_info()
    self.role:send_client("s_update_daily_active_info", self:get_daily_active_info())
    return g_tips.ok_resp
end
-- 刷新状态
function daily_active:update_state_info()
    local task_dict = self.db.daily_active.task_dict
    for task_id, task_info in pairs(task_dict) do
        local require_progress = excel_data.DailyActiveData[task_id].require_progress
        if task_info.is_receive ~= nil then
            if task_info.progress >= require_progress then
                task_info.is_receive = true
            else
                task_info.is_receive = false
            end
        end
    end

    local active_value = self.role:get_currency(CSConst.Virtual.ActivePoint)
    local level = self.db.daily_active.today_level
    local chest_info = excel_data.DailyActiveChestData
    local chest_dict = self.db.daily_active.chest_dict
    for k, v in pairs(chest_dict) do
        if active_value >= chest_info[k].require_active then
            chest_dict[k] = true
        end
    end
end

-- 领取活跃度宝箱
function daily_active:receive_active_chest_reward(chest_id)
    if not chest_id or chest_id > self.db.daily_active.unlock_chest_num then return end
    local chest_dict = self.db.daily_active.chest_dict
    if not chest_dict[chest_id] then return end
    local chest_info = excel_data.DailyActiveChestData[chest_id]
    local active_value = self.role:get_currency(CSConst.Virtual.ActivePoint)
    if not chest_info or active_value < chest_info.require_active then return end

    local reason = g_reason.daily_active_chest_reward
    local reward_id = chest_info.reward_id
    local reward_data = excel_data.RewardData[reward_id]
    chest_dict[chest_id] = nil
    self.role:add_item_list(reward_data.item_list, reason)
    self.role:send_client("s_update_daily_active_info", self:get_daily_active_info())
    return true
end

return daily_active