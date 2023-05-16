local excel_data = require("excel_data")

local role_achievement = DECLARE_MODULE("meta_table.achievement")

local AchievementMapper = {
    [CSConst.AchievementType.RoleLevel] = "border_achievement",
    [CSConst.AchievementType.StageStar] = "cumulation_achievement",
    [CSConst.AchievementType.Score] = "border_achievement",
    [CSConst.AchievementType.FightScore] = "border_achievement",
    [CSConst.AchievementType.HandleInfo] = "cumulation_achievement",
    [CSConst.AchievementType.PublishCmd] = "cumulation_achievement",
    [CSConst.AchievementType.Torture] = "cumulation_achievement",
    [CSConst.AchievementType.LoverNum] = "cumulation_achievement",
    [CSConst.AchievementType.LoverLevel] = "cumulation_achievement",
    [CSConst.AchievementType.HeroNum] = "hero_num_achievement",
    [CSConst.AchievementType.TravelNum] = "cumulation_achievement",
    [CSConst.AchievementType.HeroLevel] = "hero_level_achievement",
    [CSConst.AchievementType.HeroDestiny] = "hero_level_achievement",
    [CSConst.AchievementType.HeroEquip] = "hero_equip_achievement",
    [CSConst.AchievementType.HeroTreasure] = "hero_equip_achievement",
    [CSConst.AchievementType.TrainStar] = "cumulation_achievement",
    [CSConst.AchievementType.Vip] = "cumulation_achievement",
    [CSConst.AchievementType.TraitorKill] = "cumulation_achievement",
    [CSConst.AchievementType.Stage] = "cumulation_achievement",
    [CSConst.AchievementType.Marry] = "cumulation_achievement",
    [CSConst.AchievementType.Discuss] = "cumulation_achievement",
    [CSConst.AchievementType.Dote] = "cumulation_achievement",
    [CSConst.AchievementType.ChildNum] = "cumulation_achievement",
}

function role_achievement.new(role)
    local self = {
        role = role,
        db = role.db,
    }
    return setmetatable(self, role_achievement)
end

function role_achievement:init_achievement()
    local achievement_dict = self.db.achievement_dict
    for achievement_type, achievement_list in pairs(excel_data.AchievementData["achievement_dict"]) do
        achievement_dict[achievement_type] = {
            progress = 0,
            achievement_id = achievement_list[1]
        }
    end
    self:update_achievement(CSConst.AchievementType.RoleLevel, self.role:get_level())
end

function role_achievement:online_achievement()
    local achievement_dict = self.db.achievement_dict
    self.role:send_client("s_update_achievement_info", {achievement_dict = achievement_dict})
end

-- 更新成就进度
function role_achievement:update_achievement(achievement_type, progress)
    local achievement = self.db.achievement_dict[achievement_type]
    if not achievement or not achievement.achievement_id then return end
    local func = AchievementMapper[achievement_type]
    if func then
        self[func](self, achievement_type, progress)
    end
end

function role_achievement:update_achievement_progress(achievement_type, progress)
    local achievement = self.db.achievement_dict[achievement_type]
    local achievement_data = excel_data.AchievementData[achievement.achievement_id]
    achievement.progress = progress
    if not achievement.is_reach and achievement.progress >= achievement_data.progress then
        achievement.is_reach = true
        self.role:gaea_log("RoleTask", {
            taskType = g_const.LogTaskType.Achievement,
            taskId = achievement.achievement_id,
            status = g_const.LogTaskStatus.Finish
        })
    end
    self.role:send_client("s_update_achievement_info", {
        achievement_dict = {[achievement_type] = achievement}
    })
end

-- 计数成就
function role_achievement:cumulation_achievement(achievement_type, progress)
    local achievement = self.db.achievement_dict[achievement_type]
    local achievement_data = excel_data.AchievementData[achievement.achievement_id]
    progress = achievement.progress + progress
    self:update_achievement_progress(achievement_type, progress)
end

function role_achievement:border_achievement(achievement_type, progress)
    self:update_achievement_progress(achievement_type, progress)
end

-- 英雄数量成就
function role_achievement:hero_num_achievement(achievement_type, progress)
    local achievement = self.db.achievement_dict[achievement_type]
    local achievement_data = excel_data.AchievementData[achievement.achievement_id]
    local progress = #self.role:get_hero_dict()
    if achievement.progress >= progress then return end
    self:update_achievement_progress(achievement_type, progress)
end

-- 英雄等级任务
function role_achievement:hero_level_achievement(achievement_type, progress)
    local achievement = self.db.achievement_dict[achievement_type]
    local achievement_data = excel_data.AchievementData[achievement.achievement_id]
    local hero_dict = self.role:get_hero_dict()
    local lineup_dict = self.role:get_lineup_info()
    progress = 0
    if #lineup_dict >= CSConst.LineupMaxCount then
        progress = achievement_data.progress
        for _, info in pairs(lineup_dict) do
            if info.hero_id then
                local hero_info = hero_dict[info.hero_id]
                local level = hero_info.level
                if achievement_type == CSConst.AchievementType.HeroDestiny then
                    level = hero_info.destiny_lv
                end    
                if level < progress then
                    progress = level
                end
            else
                progress = 0
                break
            end
        end
    end
    if achievement.progress >= progress then return end
    self:update_achievement_progress(achievement_type, progress)
end

-- 英雄装备任务
function role_achievement:hero_equip_achievement(achievement_type, progress)
    local achievement = self.db.achievement_dict[achievement_type]
    local achievement_data = excel_data.AchievementData[achievement.achievement_id]
    local hero_dict = self.role:get_hero_dict()
    local lineup_dict = self.role:get_lineup_info()
    progress = 0
    if #lineup_dict >= CSConst.LineupMaxCount then
        progress = achievement_data.progress
        local part_type = CSConst.EquipPartType.Equip
        if achievement_type == CSConst.AchievementType.HeroTreasure then
            part_type = CSConst.EquipPartType.Treasure
        end
        local lineup_dict = self.role:get_lineup_info()
        for _, info in pairs(lineup_dict) do
            local num = 0
            for part_index in pairs(info.equip_dict) do
                local part_data = excel_data.EquipPartData[part_index]
                if part_data.part_type == part_type then
                    num = num + 1
                end
            end
            if num < progress then
                progress = num
            end
        end
    end
    if achievement.progress >= progress then return end
    self:update_achievement_progress(achievement_type, progress)
end

-- 领取成就奖励
function role_achievement:get_achievement_reward(achievement_type)
    local achievement = self.db.achievement_dict[achievement_type]
    if not achievement or not achievement.is_reach then return end
    local achievement_data = excel_data.AchievementData[achievement.achievement_id]
    achievement.is_reach = nil
    local reward_data = excel_data.RewardData[achievement_data.reward_id]
    self.role:add_item_list(reward_data.item_list, g_reason.achievement_reward)

    local achievement_list = excel_data.AchievementData["achievement_dict"][achievement_type]
    if achievement_data.finish_order == #achievement_list then
        -- 最后一个成就
        achievement.achievement_id = nil
    else
        achievement.achievement_id = achievement_list[achievement_data.finish_order + 1]
        local data = excel_data.AchievementData[achievement.achievement_id]
        -- 接取新成就时自动刷一遍成就完成状态
        if achievement.progress >= data.progress then
            achievement.is_reach = true
        end
    end
    self.role:send_client("s_update_achievement_info", {
        achievement_dict = {[achievement_type] = achievement}
    })
    return true
end

return role_achievement