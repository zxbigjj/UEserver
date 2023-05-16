local excel_data = require("excel_data")

local role_task = DECLARE_MODULE("meta_table.task")

local TaskMapper = {
    [CSConst.TaskType.Cmd] = "cumulation_task",
    [CSConst.TaskType.Info] = "cumulation_task",
    [CSConst.TaskType.LoverNum] = "lover_num_task",
    [CSConst.TaskType.LoverLevel] = "lover_level_task",
    [CSConst.TaskType.LoverGrade] = "lover_grade_task",
    [CSConst.TaskType.Discuss] = "cumulation_task",
    [CSConst.TaskType.Dote] = "cumulation_task",
    [CSConst.TaskType.Stage] = "stage_task",
    [CSConst.TaskType.StageStar] = "cumulation_task",
    [CSConst.TaskType.Score] = "score_task",
    [CSConst.TaskType.FightScore] = "fight_score_task",
    [CSConst.TaskType.Level] = "level_task",
    [CSConst.TaskType.HeroNum] = "hero_num_task",
    [CSConst.TaskType.HeroLevel] = "hero_level_task",
    [CSConst.TaskType.HeroBreak] = "hero_break_lv_task",
    [CSConst.TaskType.HeroDestiny] = "hero_destiny_lv_task",
    [CSConst.TaskType.HeroBook] = "hero_book_task",
    [CSConst.TaskType.HeroAllBook] = "cumulation_task",
    [CSConst.TaskType.LineUpHero] = "lineup_hero_task",
    [CSConst.TaskType.ChildNum] = "child_num_task",
    [CSConst.TaskType.ChildTeach] = "cumulation_task",
    [CSConst.TaskType.Marry] = "cumulation_task",
    [CSConst.TaskType.HuntGround] = "cumulation_task",
    [CSConst.TaskType.HuntNum] = "cumulation_task",
    [CSConst.TaskType.RandomTravel] = "cumulation_task",
    [CSConst.TaskType.AssignTravel] = "cumulation_task",
    [CSConst.TaskType.ItemConsume] = "item_consume_task",
    [CSConst.TaskType.WearEquipNum] = "wear_equip_task",
    [CSConst.TaskType.WearEquipStrengthen] = "wear_equip_Strengthen_task",
    [CSConst.TaskType.WearTreasureNum] = "wear_equip_task",
    [CSConst.TaskType.WearTreasureStrengthen] = "wear_equip_Strengthen_task",
    [CSConst.TaskType.ManageCity] = "manage_city_task",
    [CSConst.TaskType.GrabTreasure] = "cumulation_task",
    [CSConst.TaskType.TreasureCompose] = "cumulation_task",
    [CSConst.TaskType.TrainStar] = "cumulation_task",
    [CSConst.TaskType.DailyDare] = "cumulation_task",
    [CSConst.TaskType.ArenaNum] = "cumulation_task",
    [CSConst.TaskType.MoneyCmd] = "cumulation_task",
    [CSConst.TaskType.FoodCmd] = "cumulation_task",
    [CSConst.TaskType.SoldierCmd] = "cumulation_task",
    [CSConst.TaskType.TorturePrison] = "cumulation_task",
}

function role_task.new(role)
    local self = {
        role = role,
        db = role.db,
    }
    return setmetatable(self, role_task)
end

function role_task:init_task()
    local group_id = 1
    local group_data = excel_data.TaskGroupData[group_id]
    local task = self.db.task
    task.group_id = group_id
    task.task_id = group_data.task_list[1]
    task.progress = 0
    task.task_type_dict = {}
    task.is_finish = false
end

function role_task:online_task()
    local task = self.db.task
    self.role:send_client("s_update_task_info", task)
end

-- 更新任务进度
function role_task:update_task(task_type, task_param)
    local task = self.db.task
    -- 全部任务做完
    if not task.group_id then return end
    self:record_task_progress(task_type, task_param)
    if not task.task_id then return end
    local task_data = excel_data.TaskData[task.task_id]
    if task_data.task_type ~= task_type then return end
    local func = TaskMapper[task_type]
    if func then
        self[func](self, task_param)
    end
end

-- 记录计数任务进度
function role_task:record_task_progress(task_type, task_param)
    if not task_param then return end
    local task = self.db.task
    if TaskMapper[task_type] == "cumulation_task" then
        task.task_type_dict[task_type] = (task.task_type_dict[task_type] or 0) + task_param.progress
    elseif TaskMapper[task_type] == "item_consume_task" then
        local item_id = task_param.item_id
        if excel_data.TaskData.item_dict[item_id] then
            task.task_type_dict[item_id] = (task.task_type_dict[item_id] or 0) + task_param.progress
        end
    end
end

function role_task:update_task_progress(progress)
    local task = self.db.task
    task.progress = progress
    local task_data = excel_data.TaskData[task.task_id]
    if not task.is_finish and task.progress >= task_data.total_progress then
        task.is_finish = true
        self.role:gaea_log("RoleTask", {
            taskType = g_const.LogTaskType.Main,
            taskId = task.task_id,
            status = g_const.LogTaskStatus.Finish
        })
    end
    self.role:send_client("s_update_task_info", task)
end

-- 累加计数任务
function role_task:cumulation_task(task_param)
    local task = self.db.task
    local task_data = excel_data.TaskData[task.task_id]
    local progress = task.task_type_dict[task_data.task_type]
    if not progress then return end
    self:update_task_progress(progress)
end

-- 情人数量任务
function role_task:lover_num_task(task_param)
    local task = self.db.task
    local lover_dict = self.role:get_lover_dict()
    local progress = #lover_dict
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 情人等级任务
function role_task:lover_level_task(task_param)
    local task = self.db.task
    local task_data = excel_data.TaskData[task.task_id]
    local lover_dict = self.role:get_lover_dict()
    local progress = 0
    for _, lover_info in pairs(lover_dict) do
        if lover_info.level >= task_data.task_param[1] then
            progress = progress + 1
        end
    end
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 情人品级任务
function role_task:lover_grade_task(task_param)
    local task = self.db.task
    local task_data = excel_data.TaskData[task.task_id]
    local lover_dict = self.role:get_lover_dict()
    local progress = 0
    for _, lover_info in pairs(lover_dict) do
        if lover_info.grade >= task_data.task_param[1] then
            progress = progress + 1
        end
    end
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 关卡通关任务
function role_task:stage_task(task_param)
    local task = self.db.task
    local progress = self.role:get_curr_stage() - 1
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 国力任务
function role_task:score_task(task_param)
    local task = self.db.task
    local progress = math.floor(self.role:get_score())
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 战力任务
function role_task:fight_score_task(task_param)
    local task = self.db.task
    local progress = math.floor(self.role:get_fight_score())
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 等级任务
function role_task:level_task(task_param)
    local task = self.db.task
    local progress = self.role:get_level()
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 英雄数量任务
function role_task:hero_num_task(task_param)
    local task = self.db.task
    local hero_dict = self.role:get_hero_dict()
    local progress = #hero_dict
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 英雄等级任务
function role_task:hero_level_task(task_param)
    local task = self.db.task
    local task_data = excel_data.TaskData[task.task_id]
    local hero_dict = self.role:get_hero_dict()
    local progress = 0
    for _, hero_info in pairs(hero_dict) do
        if hero_info.level >= task_data.task_param[1] then
            progress = progress + 1
        end
    end
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 英雄突破等级任务
function role_task:hero_break_lv_task(task_param)
    local task = self.db.task
    local task_data = excel_data.TaskData[task.task_id]
    local hero_dict = self.role:get_hero_dict()
    local progress = 0
    for _, hero_info in pairs(hero_dict) do
        if hero_info.break_lv >= task_data.task_param[1] then
            progress = progress + 1
        end
    end
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 英雄天命等级任务
function role_task:hero_destiny_lv_task(task_param)
    local task = self.db.task
    local task_data = excel_data.TaskData[task.task_id]
    local hero_dict = self.role:get_hero_dict()
    local progress = 0
    for _, hero_info in pairs(hero_dict) do
        if hero_info.destiny_lv >= task_data.task_param[1] then
            progress = progress + 1
        end
    end
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 英雄培养任务
function role_task:hero_book_task(task_param)
    local task = self.db.task
    local task_data = excel_data.TaskData[task.task_id]
    local hero_dict = self.role:get_hero_dict()
    local progress = 0
    for _, hero_info in pairs(hero_dict) do
        if hero_info.book_num >= task_data.task_param[1] then
            progress = progress + 1
        end
    end
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 上阵英雄数量任务
function role_task:lineup_hero_task(task_param)
    local progress = 0
    local lineup_dict = self.role:get_lineup_info()
    for _, info in pairs(lineup_dict) do
        if info.hero_id then
            progress = progress + 1
        end
    end
    local task = self.db.task
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 孩子数量任务
function role_task:child_num_task(task_param)
    local task = self.db.task
    local progress = self.role:get_child_count()
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 消耗物品任务
function role_task:item_consume_task(task_param)
    local task = self.db.task
    local task_data = excel_data.TaskData[task.task_id]
    if task_param and (task_data.item_id ~= task_param.item_id) then return end
    local progress = task.task_type_dict[task_data.item_id]
    if not progress then return end
    self:update_task_progress(progress)
end

-- 穿戴装备数量任务
function role_task:wear_equip_task(task_param)
    local task = self.db.task
    local task_data = excel_data.TaskData[task.task_id]
    local part_type = CSConst.EquipPartType.Equip
    if task_data.task_type == CSConst.TaskType.WearTreasureNum then
        part_type = CSConst.EquipPartType.Treasure
    end
    local progress = 0
    local lineup_dict = self.role:get_lineup_info()
    for _, info in pairs(lineup_dict) do
        for part_index in pairs(info.equip_dict) do
            local part_data = excel_data.EquipPartData[part_index]
            if part_data.part_type == part_type then
                progress = progress + 1
            end
        end
    end
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 穿戴装备强化任务
function role_task:wear_equip_Strengthen_task(task_param)
    local task = self.db.task
    local task_data = excel_data.TaskData[task.task_id]
    local part_type = CSConst.EquipPartType.Equip
    if task_data.task_type == CSConst.TaskType.WearTreasureStrengthen then
        part_type = CSConst.EquipPartType.Treasure
    end
    local progress = 0
    local lineup_dict = self.role:get_lineup_info()
    for _, info in pairs(lineup_dict) do
        for part_index, equip_guid in pairs(info.equip_dict) do
            local part_data = excel_data.EquipPartData[part_index]
            if part_data.part_type == part_type then
                local equip = self.role:get_bag_item(equip_guid)
                if equip.strengthen_lv >= task_data.task_param[1] then
                    progress = progress + 1
                end
            end
        end
    end
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 管辖城市任务
function role_task:manage_city_task(task_param)
    local task = self.db.task
    local progress = self.role:get_manage_city_count()
    if task.progress >= progress then return end
    self:update_task_progress(progress)
end

-- 领取当前任务奖励
function role_task:get_task_reward()
    local task = self.db.task
    if not task.task_id then return end
    local task_data = excel_data.TaskData[task.task_id]
    if not task.is_finish then return end
    task.progress = 0
    task.is_finish = false
    local reward_data = excel_data.RewardData[task_data.reward_id]
    self.role:add_item_list(reward_data.item_list, g_reason.task_reward)
    local group_data = excel_data.TaskGroupData[task.group_id]
    local task_index = group_data.task_dict[task.task_id]
    if task_index == #group_data.task_list then
        -- 任务组的最后一个任务
        task.task_id = nil
    else
        task.task_id = group_data.task_list[task_index + 1]
        local data = excel_data.TaskData[task.task_id]
        -- 接取新任务时自动刷一遍任务进度
        self:update_task(data.task_type)
    end
    -- 获得第一本培养书事件检测
    self.role:guide_event_trigger_check(task_data.trigger_event_id)
    self.role:send_client("s_update_task_info", task)
    return true
end

-- 领取任务组奖励
function role_task:get_task_group_reward()
    local task = self.db.task
    if not task.group_id or task.task_id then return end
    local group_data = excel_data.TaskGroupData[task.group_id]
    local reward_data = excel_data.RewardData[group_data.reward_id]
    self.role:add_item_list(reward_data.item_list, g_reason.task_group_reward)
    if task.group_id == #excel_data.TaskGroupData then
        -- 最后一组任务
        task.group_id = nil
        task.task_type_dict = nil
    else
        task.group_id = task.group_id + 1
        group_data = excel_data.TaskGroupData[task.group_id]
        task.task_id = group_data.task_list[1]
        local data = excel_data.TaskData[task.task_id]
        self:update_task(data.task_type)
    end
    self.role:send_client("s_update_task_info", task)
    return true
end

return role_task