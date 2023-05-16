local prison = DECLARE_MODULE("meta_table.prison")
local excel_data = require("excel_data")
local drop_utils = require("drop_utils")

function prison.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
    }
    return setmetatable(self, prison)
end

function prison:online_prison()
    local prison = self.db.prison
    self.role:send_client("s_update_prison_info", {criminal_num = prison.criminal_num, criminal_id = prison.criminal_id, torture_remain_num = prison.torture_remain_num })
end

function prison:stage_to_criminal()
    local curr_stage = self.role:get_curr_stage() - 1
    local curr_prestige_count = excel_data.StageData[curr_stage].prestige_count
    local last_prestige_count = 0
    if curr_stage > 1 then
        last_prestige_count = excel_data.StageData[curr_stage - 1].prestige_count
    end
    self:add_torture(curr_prestige_count - last_prestige_count)

    for prison_id, config in ipairs(excel_data.PrisonData) do
        local prison = self.db.prison
        if prison.criminal_num < prison_id and curr_stage >= config.stage then
            self:add_criminal_num()
        end
    end
end

-- 每日刷新, 增加威望
function prison:daily_prison()
    local prison = self.db.prison
    if prison.criminal_num <= 0 then return end
    prison.criminal_id = 1
    prison.torture_remain_num = excel_data.PrisonData[prison.criminal_id].max_torture_num
    self.role:send_client("s_update_prison_info", {criminal_id = prison.criminal_id, torture_remain_num = prison.torture_remain_num})
    self:add_torture()
end

-- 增加罪犯数量
function prison:add_criminal_num()
    local prison = self.db.prison
    prison.criminal_num = prison.criminal_num + 1
    if not prison.criminal_id then
        prison.criminal_id = 1
        prison.torture_remain_num = excel_data.PrisonData[prison.criminal_id].max_torture_num
    else
        if prison.torture_remain_num == 0 then
            prison.criminal_id = prison.criminal_id + 1
            prison.torture_remain_num = excel_data.PrisonData[prison.criminal_id].max_torture_num
        end
    end
    self.role:send_client("s_update_prison_info", {criminal_num = prison.criminal_num, criminal_id = prison.criminal_id, torture_remain_num = prison.torture_remain_num})
    -- 检查是否抓了第一个犯人
    self.role:guide_event_trigger_check(CSConst.GuideEventTriggerType.GetFirstPrisoner)
end

-- 拷打,消耗威望，特定拷打方式有额外消耗，奖励掉落物品
function prison:torture(torture_type, torture_num)
    if not torture_type or not torture_num then return end
    local prison = self.db.prison
    if prison.torture_remain_num - torture_num < 0 then return end
    local prison_config = excel_data.PrisonData[prison.criminal_id]
    if not prison_config then return end

    local sub_item_list = {}
    local count = prison_config.prestige_cost * torture_num
    local item_id = excel_data.ParamData["prison_prestige"].item_id
    table.insert(sub_item_list, {item_id = item_id, count = count} )

    local torture_id = prison_config.torture_type_list[torture_type]
    local torture_config = excel_data.TortureData[torture_id]
    if torture_config.cost_item_id_list then
        for index, item_id in ipairs(torture_config.cost_item_id_list) do
            local count = torture_config.cost_num_list[index] * torture_num
            table.insert(sub_item_list, {item_id = item_id, count = count} )
        end
    end
    local reason = g_reason.prison_torture_criminal
    if not self.role:consume_item_list(sub_item_list, reason) then return end

    prison.torture_remain_num = prison.torture_remain_num - torture_num
    if prison.torture_remain_num <= 0 and prison.criminal_id < prison.criminal_num then
        prison.criminal_id = prison.criminal_id + 1
        prison.torture_remain_num = excel_data.PrisonData[prison.criminal_id].max_torture_num
    end
    local drop_id = prison_config.drop_list[torture_type]
    local item_dict = {}
    for i = 1, torture_num do
        local item_list = drop_utils.roll_drop(drop_id)
        for _, v in ipairs(item_list) do
            item_dict[v.item_id] = (item_dict[v.item_id] or 0) + v.count
        end
    end
    self.role:add_item_dict(item_dict, reason)
    self.role:send_client("s_update_prison_info", {criminal_id = prison.criminal_id, torture_remain_num = prison.torture_remain_num })
    self.role:update_achievement(CSConst.AchievementType.Torture, torture_num)
    self.role:update_daily_active(CSConst.DailyActiveTaskType.PunishPrisonerNum, torture_num)
    self.role:update_task(CSConst.TaskType.TorturePrison, {progress = torture_num})
    return true
end

function prison:add_torture(add_count)
    local item_id = excel_data.ParamData["prison_prestige"].item_id
    local current_count = self.role:get_currency(item_id)
    local prestige_count = excel_data.StageData[self.role:get_curr_stage() - 1].prestige_count
    local max_count = prestige_count * excel_data.ParamData["max_prestige_trans_rate"].f_value
    if current_count >= max_count then return end
    local reason
    if not add_count then
        reason = g_reason.stage_reward
        add_count = prestige_count
    else
        reason = g_reason.prison_daily_refresh
    end
    if add_count + current_count >= max_count then
        add_count = max_count - current_count
    end
    self.role:add_currency(item_id, add_count, reason)
    return true
end

return prison