local role_lineup = DECLARE_MODULE("meta_table.lineup")

local excel_data = require("excel_data")
local CSFunction = require("CSCommon.CSFunction")
local role_utils = require("role_utils")

local FIVE_TIMES = 5

function role_lineup.new(role)
    local self = {
        role = role,
        db = role.db,
    }
    return setmetatable(self, role_lineup)
end

function role_lineup:init_lineup()
    self:check_lineup_unlock()
end

function role_lineup:load_lineup()
    local lineup_dict = self.db.lineup_dict
    for lineup_id, lineup_info in pairs(lineup_dict) do
        local hero_id = lineup_info.hero_id
        if hero_id then
            local attr_dict = self:get_lineup_attr_dict(lineup_id)
            table.dict_attr_add(attr_dict, self.role:get_dynasty_spell_attr())
            self.role:modify_hero_attr(hero_id, nil, attr_dict)
            self:load_hero_talent_attr(hero_id)
        end
    end
end

function role_lineup:load_hero_talent_attr(hero_id)
    local lineup_dict = self.db.lineup_dict
    for _, lineup_info in pairs(lineup_dict) do
        if lineup_info.hero_id then
            local hero_data = excel_data.HeroData[lineup_info.hero_id]
            local attr_dict = self.role:get_add_talent_attr(hero_id, hero_data.power)
            self.role:modify_hero_attr(lineup_info.hero_id, nil, attr_dict)
        end
    end
end

function role_lineup:online_lineup()
    self.role:send_client("s_update_lineup_info",{lineup_dict = self.db.lineup_dict})
    self.role:send_client("s_update_reinforcements",{reinforcements_dict = self.db.reinforcements_dict})
end

function role_lineup:daily_lineup()
    for _, item in ipairs(self.db.bag_item_list) do
        if item.lucky_value and item.lucky_value > 0 then
            item.lucky_value = 0
        end
    end
    self.role:send_client("s_clear_equip_lucky_value", {})
end

-- 升级引起阵容位解锁
function role_lineup:check_lineup_unlock()
    local lineup_dict = self.db.lineup_dict
    local role_level = self.role:get_level()
    local has_change
    for i, config in ipairs(excel_data.LineupUnlockData) do
        if i <= CSConst.LineupMaxCount and role_level >= config.unlock_level then
            if not lineup_dict[i] then
                has_change = true
                lineup_dict[i] = {
                    unlock_status = CSConst.ConfirmStatus.Yes,
                    strengthen_master_lv = {
                        [CSConst.EquipPartType.Treasure] = 0,
                        [CSConst.EquipPartType.Equip] = 0,
                    },
                    refine_master_lv = {
                        [CSConst.EquipPartType.Treasure] = 0,
                        [CSConst.EquipPartType.Equip] = 0,
                    }
                }
            end
        end
    end
    if has_change then
        self.role:send_client("s_update_lineup_info",{lineup_dict = lineup_dict})
    end
end

function role_lineup:get_lineup_new_pos_id(lineup_id)
    local pos_dict = {}
    for id, lineup_info in pairs(self.db.lineup_dict) do
        if lineup_info.pos_id then
            pos_dict[lineup_info.pos_id] = true
        end
    end

    for pos_id = 1, CSConst.LineupMaxCount do
        if not pos_dict[pos_id] then
            return pos_id
        end
    end
end

-- 阵容部位英雄上场
function role_lineup:lineup_change_hero(hero_id, lineup_id)
    if not hero_id or not lineup_id then return end
    if lineup_id > CSConst.LineupMaxCount or lineup_id <= 0 then return end
    local hero_info = self.role:get_hero(hero_id)
    if not hero_info then return end
    if self:get_reinforcements_pos_id(hero_id) then return end
    local lineup_dict = self.db.lineup_dict
    for _, lineup_info in pairs(lineup_dict) do
        if lineup_info.hero_id == hero_id then return end
    end

    local lineup_info = lineup_dict[lineup_id]
    if not lineup_info or lineup_info.unlock_status ~= CSConst.ConfirmStatus.Yes then return end
    if not lineup_info.pos_id then
        lineup_info.pos_id = self:get_lineup_new_pos_id(lineup_id)
        lineup_info.lineup_id = lineup_id
    end

    local attr_dict = self:get_lineup_attr_dict(lineup_id)
    local dynasty_spell_attr = self.role:get_dynasty_spell_attr()
    if lineup_info.hero_id then
        local old_hero_id = lineup_info.hero_id
        self.role:modify_hero_attr(old_hero_id, attr_dict, nil, true)
        self.role:change_lineup_hero_talent_attr(old_hero_id, true)
        self.role:modify_hero_attr(old_hero_id, dynasty_spell_attr, nil, true)
    end
    lineup_info.hero_id = hero_id
    self.role:modify_hero_attr(hero_id, nil, attr_dict, true)
    self.role:change_lineup_hero_talent_attr(hero_id)
    self.role:modify_hero_attr(hero_id, nil, dynasty_spell_attr, true)
    self:on_lineup_change()

    self.role:updata_fight_score()
    self.role:send_client("s_update_lineup_info",{lineup_dict = {[lineup_id] = lineup_info}})
    return true
end

function role_lineup:on_lineup_change()
    local lineup_dict = self.db.lineup_dict
    for _, lineup_info in pairs(lineup_dict) do
        if lineup_info.hero_id then
            self.role:refresh_fate(lineup_info.hero_id)
        end
    end
    self.role:update_task(CSConst.TaskType.LineUpHero)
    self.role:update_achievement(CSConst.AchievementType.HeroLevel)
    self.role:update_achievement(CSConst.AchievementType.HeroDestiny)
end

-- 阵容位置调整
function role_lineup:adjust_pos_lineup(pos_dict)
    if not pos_dict then return end
    local lineup_dict = self.db.lineup_dict

    local sign_dict = {}
    for i = 1, CSConst.LineupMaxCount do
        local lineup_id = pos_dict[i]
        if lineup_id then
            -- 检查数值为正确值，且唯一
            if lineup_id > CSConst.LineupMaxCount or lineup_id <= 0 then return end
            if not lineup_dict[lineup_id].hero_id then return end
            if not sign_dict[lineup_id] then
                sign_dict[lineup_id] = true
            else
                return
            end
        end
    end

    local len = 0
    for i = 1, CSConst.LineupMaxCount do
        local lineup_id = pos_dict[i]
        if lineup_id and lineup_dict[lineup_id].hero_id then
            lineup_dict[lineup_id].pos_id = i
        end
    end
    self.role:send_client("s_update_lineup_info",{lineup_dict = lineup_dict})
    return true
end

function role_lineup:get_hero_lineup_id(hero_id)
    if not hero_id then return end
    local lineup_dict = self.db.lineup_dict
    for lineup_id, lineup_info in pairs(lineup_dict) do
        if lineup_info.hero_id == hero_id then
            return lineup_id
        end
    end
end

-- 阵容部位穿戴装备
function role_lineup:lineup_wear_equip(lineup_id, part_index, item_guid)
    if not lineup_id or not part_index or not item_guid then return end
    local part_data = excel_data.EquipPartData[part_index]
    if not part_data then return end
    local item = self.role:get_bag_item(item_guid)
    if not item then return end
    local lineup_dict = self.db.lineup_dict
    local lineup_info = lineup_dict[lineup_id]
    if not lineup_info and not lineup_info.hero_id then return end
    local item_data = excel_data.ItemData[item.item_id]
    if item_data.item_type ~= CSConst.ItemType.Equip then return end
    if not item_data.part_index or item_data.part_index ~= part_index then return end

    if item.lineup_id then
        self:lineup_unwear_equip(item.lineup_id, part_index, true)
    end
    local equip_dict = lineup_info.equip_dict
    local old_attr_dict = self:get_equip_suit_attr(equip_dict)
    local old_equip_guid = equip_dict[part_index]
    local old_equip
    if old_equip_guid then
        table.dict_attr_add(old_attr_dict, self:get_equip_attr(old_equip_guid))
        equip_dict[part_index] = nil
        old_equip = self.role:get_bag_item(old_equip_guid)
        old_equip.lineup_id = nil
        self.role:send_client("s_bag_item_update", {update_item = old_equip})
    end
    equip_dict[part_index] = item_guid
    item.lineup_id = lineup_id
    lineup_info.equip_info_dict[item_guid] = table.deep_copy(item)
    self.role:send_client("s_bag_item_update", {update_item = item})
    local new_attr_dict = self:get_equip_suit_attr(equip_dict)
    table.dict_attr_add(new_attr_dict, self:get_equip_attr(item_guid))
    self.role:modify_hero_attr(lineup_info.hero_id, old_attr_dict, new_attr_dict, true)
    self:check_strengthen_master_lv(lineup_info, part_data.part_type)
    self:check_refine_master_lv(lineup_info, part_data.part_type)
    self:on_wear_equip(item.item_id)
    self.role:refresh_fate(lineup_info.hero_id)

    self.role:updata_fight_score()
    self.role:send_client("s_update_lineup_equip_info",{
        lineup_id = lineup_id,
        part_index = part_index,
        equip_dict = equip_dict
    })
    self.role:log("WearEquip", {
        lineup_id = lineup_id,
        part_index = part_index,
        old_equip = old_equip,
        new_equip = item
    })
    return true
end

-- 穿戴装备触发事件
function role_lineup:on_wear_equip(equip_id)
    local item_data = excel_data.ItemData[equip_id]
    if item_data.is_treasure then
        self.role:update_task(CSConst.TaskType.WearTreasureNum)
        self.role:update_task(CSConst.TaskType.WearTreasureStrengthen)
        self.role:update_achievement(CSConst.AchievementType.HeroTreasure)
    else
        self.role:update_task(CSConst.TaskType.WearEquipNum)
        self.role:update_task(CSConst.TaskType.WearEquipStrengthen)
        self.role:update_achievement(CSConst.AchievementType.HeroEquip)
    end
end

-- 阵容部位卸下装备
function role_lineup:lineup_unwear_equip(lineup_id, part_index, not_notify)
    if not lineup_id or not part_index then return end
    local lineup_dict = self.db.lineup_dict
    local lineup_info = lineup_dict[lineup_id]
    if not lineup_info then return end
    local equip_dict = lineup_info.equip_dict
    local equip_guid = equip_dict[part_index]
    if not equip_guid then return end

    local old_attr_dict = self:get_equip_suit_attr(equip_dict)
    table.dict_attr_add(old_attr_dict, self:get_equip_attr(equip_guid))
    equip_dict[part_index] = nil
    lineup_info.equip_info_dict[equip_guid] = nil
    local item = self.role:get_bag_item(equip_guid)
    item.lineup_id = nil
    self.role:send_client("s_bag_item_update", {update_item = item})
    local new_attr_dict = self:get_equip_suit_attr(equip_dict)
    self.role:modify_hero_attr(lineup_info.hero_id, old_attr_dict, new_attr_dict, true)
    local part_data = excel_data.EquipPartData[part_index]
    self:check_strengthen_master_lv(lineup_info, part_data.part_type)
    self:check_refine_master_lv(lineup_info, part_data.part_type)
    self.role:refresh_fate(lineup_info.hero_id)

    if not not_notify then
        self.role:updata_fight_score()
    end
    self.role:send_client("s_update_lineup_equip_info",{
        lineup_id = lineup_id,
        part_index = part_index,
        equip_dict = equip_dict
    })
    self.role:log("UnwearEquip", {
        lineup_id = lineup_id,
        part_index = part_index,
        old_equip = item
    })
    return true
end

-- 获取装备套装属性
function role_lineup:get_equip_suit_attr(equip_dict)
    local suit_dict = {}
    for _, equip_guid in pairs(equip_dict) do
        local item = self.role:get_bag_item(equip_guid)
        local item_data = excel_data.ItemData[item.item_id]
        if item_data.suit then
            suit_dict[item_data.suit] = (suit_dict[item_data.suit] or 0) + 1
        end
    end
    local attr_dict = {}
    for suit_id, equip_num in pairs(suit_dict) do
        local suit_data = excel_data.SuitData[suit_id]
        for need_equip_num, suit_attr_dict in pairs(suit_data.suit_dict) do
            if equip_num >= need_equip_num then
                table.dict_attr_add(attr_dict, suit_attr_dict)
            end
        end
    end
    return attr_dict
end

-- 强化装备
function role_lineup:strengthen_equip(item_guid, cost_item_list, not_notify)
    print("---=== 强化装备: ")
    if not item_guid then return end
    local equip = self.role:get_bag_item(item_guid)
    if not equip then return end
    local item_data = excel_data.ItemData[equip.item_id]
    if item_data.item_type ~= CSConst.ItemType.Equip or not item_data.part_index then return end

    local part_data = excel_data.EquipPartData[item_data.part_index]
    local old_level = equip.strengthen_lv
    local new_level, new_exp, item_list
    if part_data.part_type == CSConst.EquipPartType.Equip then
        -- 普通装备
        if old_level >= self.role:get_level() * CSConst.StrengthenLimitRate then return end
        new_level = old_level + 1
        new_exp = equip.strengthen_exp
        local cost_num = CSFunction.get_equip_strengthen_cost(equip.item_id, new_level)
        local cost_coin_id = excel_data.ParamData["strengthen_equip_cost_coin"].item_id
        item_list = {{item_id = cost_coin_id, count = cost_num}}
    elseif part_data.part_type == CSConst.EquipPartType.Treasure then
        -- 宝物装备
        local strengthen_data = excel_data.StrengthenLvData
        if old_level >= #strengthen_data then return end
        new_level, new_exp, item_list = self:get_strengthen_consume(old_level, equip.strengthen_exp, cost_item_list, item_data.quality)
        if not new_level then return end
    end
    if not self.role:consume_item_list(item_list, g_reason.strengthen_equip, true) then return end

    equip.strengthen_lv = new_level
    equip.strengthen_exp = new_exp
    if equip.lineup_id then
        -- 穿戴的装备
        local old_attr_dict = CSFunction.get_equip_strengthen_attr(equip.item_id, old_level)
        local new_attr_dict = CSFunction.get_equip_strengthen_attr(equip.item_id, equip.strengthen_lv)
        local lineup_info = self.db.lineup_dict[equip.lineup_id]
        lineup_info.equip_info_dict[item_guid] = table.deep_copy(equip)
        self.role:modify_hero_attr(lineup_info.hero_id, old_attr_dict, new_attr_dict, true)
        self:check_strengthen_master_lv(lineup_info, part_data.part_type)
    end
    self:on_strengthen_equip(equip.item_id, equip.strengthen_lv)
    if not not_notify then
        self.role:updata_fight_score()
        self.role:send_client("s_bag_item_update", {update_item = equip})
    end
    return true
end

-- 强化装备触发事件
function role_lineup:on_strengthen_equip(equip_id, strengthen_lv)
    local item_data = excel_data.ItemData[equip_id]
    if item_data.is_treasure then
        self.role:update_daily_active(CSConst.DailyActiveTaskType.TreasureStrength, 1)
        self.role:update_first_week_task(CSConst.FirstWeekTaskType.TreasureStrengthNum, strengthen_lv)
        self.role:update_task(CSConst.TaskType.WearTreasureStrengthen)
    else
        self.role:update_daily_active(CSConst.DailyActiveTaskType.EquipStrength, 1)
        self.role:update_first_week_task(CSConst.FirstWeekTaskType.EquipStrengthLevel, strengthen_lv)
        self.role:update_task(CSConst.TaskType.WearEquipStrengthen)
    end
end

-- 获取宝物强化消耗
function role_lineup:get_strengthen_consume(old_level, old_exp, cost_item_list, quality)
    if not cost_item_list then return end
    local add_exp = 0
    local cost_num = 0
    local item_list = {}
    for _, item_guid in ipairs(cost_item_list) do
        local item = self.role:get_bag_item(item_guid)
        if not item then return end
        local item_data = excel_data.ItemData[item.item_id]
        if not item_data or not item_data.add_exp then return end
        if item_data.item_type ~= CSConst.ItemType.Equip then return end
        add_exp = add_exp + item_data.add_exp + item.strengthen_exp
        cost_num = cost_num + item_data.cost_coin
        table.insert(item_list, {guid = item_guid, count = 1})
    end
    local cost_coin_id = excel_data.ParamData["strengthen_equip_cost_coin"].item_id
    table.insert(item_list, {item_id = cost_coin_id, count = cost_num})
    local new_level = old_level
    local new_exp = old_exp + add_exp
    local strengthen_data = excel_data.StrengthenLvData
    for level = old_level + 1, #strengthen_data do
        local data = strengthen_data[level]
        if new_exp < data["exp_q"..quality] then break end
        new_level = level
    end

    return new_level, new_exp, item_list
end

-- 强化5次
function role_lineup:strengthen_equip_five_times(item_guid)
    if not item_guid then return end
    local equip = self.role:get_bag_item(item_guid)
    local old_level = equip.strengthen_lv
    if not equip then return end
    for i = 1, FIVE_TIMES do
        if not self:strengthen_equip(item_guid, nil, true) then break end
    end
    if equip.strengthen_lv == old_level then return end
    self.role:updata_fight_score()
    self.role:send_client("s_bag_item_update", {update_item = equip})
    return true
end

-- 一键强化
function role_lineup:quick_strengthen_equip(lineup_id)
    local lineup_info = self.db.lineup_dict[lineup_id]
    if not lineup_info then return end
    local equip_dict = lineup_info.equip_dict
    if #equip_dict == 0 then return end
    local role_level = self.role:get_level()
    for index, data in ipairs(excel_data.EquipPartData) do
        -- 只有普通装备才能一键强化，宝物不能
        if data.part_type == CSConst.EquipPartType.Equip then
            local equip_guid = equip_dict[index]
            if equip_guid then
                local equip = self.role:get_bag_item(equip_guid)
                local old_level = equip.strengthen_lv
                while true do
                    if not self:strengthen_equip(equip_guid, nil, true) then break end
                end
                if equip.strengthen_lv ~= old_level then
                    self.role:send_client("s_bag_item_update", {update_item = equip})
                end
                if equip.strengthen_lv < role_level * CSConst.StrengthenLimitRate then break end
            end
        end
    end
    self.role:updata_fight_score()
    return true
end

-- 检查强化大师等级
function role_lineup:check_strengthen_master_lv(db_lineup, part_type)
    local new_master_lv = 0
    local master_data, equip_count
    if part_type == CSConst.EquipPartType.Equip then
        master_data = excel_data.ESmasterData
        equip_count = CSConst.MasterEquipCount.Equip
    elseif part_type == CSConst.EquipPartType.Treasure then
        master_data = excel_data.TSmasterData
        equip_count = CSConst.MasterEquipCount.Treasure
    end
    local part_data = excel_data.EquipPartData
    for level, data in ipairs(master_data) do
        local count = 0
        for part_index, equip_guid in pairs(db_lineup.equip_dict) do
            if part_data[part_index].part_type == part_type then
                local equip = self.role:get_bag_item(equip_guid)
                if equip.strengthen_lv >= data.equip_lv then
                    count = count + 1
                end
            end
        end
        if count < equip_count then break end
        new_master_lv = level
    end

    local old_master_lv = db_lineup.strengthen_master_lv[part_type]
    if new_master_lv ~= old_master_lv then
        local old_attr_dict = CSFunction.get_strengthen_master_attr(part_type, old_master_lv)
        local new_attr_dict = CSFunction.get_strengthen_master_attr(part_type, new_master_lv)
        self.role:modify_hero_attr(db_lineup.hero_id, old_attr_dict, new_attr_dict, true)
        db_lineup.strengthen_master_lv[part_type] = new_master_lv
        self.role:send_client("s_update_lineup_master_lv",{
            lineup_id = db_lineup.lineup_id,
            strengthen_master_lv = db_lineup.strengthen_master_lv
        })
    end
end

-- 精炼装备
function role_lineup:refine_equip(item_guid, cost_item_id)
    if not item_guid then return end
    local equip = self.role:get_bag_item(item_guid)
    if not equip then return end
    local item_data = excel_data.ItemData[equip.item_id]
    if item_data.item_type ~= CSConst.ItemType.Equip or not item_data.part_index then return end
    local part_data = excel_data.EquipPartData[item_data.part_index]
    if not part_data then return end
    local old_refine_lv = equip.refine_lv
    local refine_data = excel_data.RefineLvData
    if old_refine_lv >= #refine_data then return end

    local new_refine_lv, new_exp, cost_item_list, cost_dict
    if part_data.part_type == CSConst.EquipPartType.Equip then
        -- 普通装备
        if not cost_item_id then return end
        local cost_item_data = excel_data.ItemData[cost_item_id]
        if not cost_item_data or not cost_item_data.add_exp then return end
        new_refine_lv = old_refine_lv
        new_exp = equip.refine_exp + cost_item_data.add_exp
        for level = old_refine_lv + 1, #refine_data do
            if new_exp < refine_data[level]["exp_q"..item_data.quality] then break end
            new_refine_lv = level
        end
        cost_item_list = {{item_id = cost_item_id, count = 1}}
    elseif part_data.part_type == CSConst.EquipPartType.Treasure then
        -- 宝物装备
        new_refine_lv = old_refine_lv + 1
        new_exp = equip.refine_exp
        cost_item_list, cost_dict = self:get_refine_consume(equip, cost_item_id)
    end
    if not cost_item_list then return end
    if not self.role:consume_item_list(cost_item_list, g_reason.refine_equip) then return end

    if cost_dict then
        equip.refine_cost = equip.refine_cost or {}
        for item_id, count in pairs(cost_dict) do
            equip.refine_cost[item_id] = (equip.refine_cost[item_id] or 0) + count
        end
    end
    equip.refine_lv = new_refine_lv
    equip.refine_exp = new_exp
    if equip.lineup_id then
        -- 穿戴的装备
        local old_attr_dict = CSFunction.get_equip_refine_attr(equip.item_id, old_refine_lv)
        local new_attr_dict = CSFunction.get_equip_refine_attr(equip.item_id, equip.refine_lv)
        local lineup_info = self.db.lineup_dict[equip.lineup_id]
        lineup_info.equip_info_dict[item_guid] = table.deep_copy(equip)
        self.role:modify_hero_attr(lineup_info.hero_id, old_attr_dict, new_attr_dict, true)
        self:check_refine_master_lv(lineup_info, part_data.part_type)
    end
    self:on_refine_equip(equip.item_id, equip.refine_lv)
    self.role:updata_fight_score()
    self.role:send_client("s_bag_item_update", {update_item = equip})
    return true
end

-- 精炼装备触发事件
function role_lineup:on_refine_equip(equip_id, refine_lv)
    local item_data = excel_data.ItemData[equip_id]
    if item_data.is_treasure then
        self.role:update_first_week_task(CSConst.FirstWeekTaskType.TreasureRefineLevel, refine_lv)
    else
        self.role:update_daily_active(CSConst.DailyActiveTaskType.EquipRefine, 1)
        self.role:update_first_week_task(CSConst.FirstWeekTaskType.EquipRefineLevel, refine_lv)
    end
end

-- 一键精炼
function role_lineup:quick_refine_equip(item_guid, cost_item_dict)
    if not item_guid or not cost_item_dict then return end
    local equip = self.role:get_bag_item(item_guid)
    if not equip then return end
    local item_data = excel_data.ItemData[equip.item_id]
    if item_data.item_type ~= CSConst.ItemType.Equip or not item_data.part_index then return end
    local part_data = excel_data.EquipPartData[item_data.part_index]
    -- 只有普通装备才能一键精炼，宝物不能
    if part_data.part_type ~= CSConst.EquipPartType.Equip then return end
    local old_refine_lv = equip.refine_lv
    local refine_data = excel_data.RefineLvData
    if old_refine_lv >= #refine_data then return end
    local new_exp = equip.refine_exp
    for item_id, count in pairs(cost_item_dict) do
        local data = excel_data.ItemData[item_id]
        if not data or not data.add_exp then return end
        new_exp = new_exp + data.add_exp * count
    end
    if not self.role:consume_item_dict(cost_item_dict, g_reason.refine_equip) then return end

    local new_refine_lv = old_refine_lv
    for level = old_refine_lv + 1, #refine_data do
        if new_exp < refine_data[level]["exp_q"..item_data.quality] then break end
        new_refine_lv = level
    end
    equip.refine_lv = new_refine_lv
    equip.refine_exp = new_exp
    if equip.lineup_id then
        -- 穿戴的装备
        local old_attr_dict = CSFunction.get_equip_refine_attr(equip.item_id, old_refine_lv)
        local new_attr_dict = CSFunction.get_equip_refine_attr(equip.item_id, equip.refine_lv)
        local lineup_info = self.db.lineup_dict[equip.lineup_id]
        lineup_info.equip_info_dict[item_guid] = table.deep_copy(equip)
        self.role:modify_hero_attr(lineup_info.hero_id, old_attr_dict, new_attr_dict, true)
        self:check_refine_master_lv(lineup_info, part_data.part_type)
    end
    self:on_refine_equip(equip.item_id, new_refine_lv)
    self.role:updata_fight_score()
    self.role:send_client("s_bag_item_update", {update_item = equip})
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.EquipRefineLevel, new_refine_lv)
    return true
end

-- 获取宝物精炼消耗
function role_lineup:get_refine_consume(equip, cost_item_id)
    local item_list = {}
    local refine_data = excel_data.RefineLvData[equip.refine_lv]
    if not refine_data.item_num then return end
    local cost_coin_id = excel_data.ParamData["refine_equip_cost_coin"].item_id
    table.insert(item_list, {item_id = cost_coin_id, count = refine_data.coin_num})
    local item_id = excel_data.ParamData["refine_treasure_cost_item"].item_id
    table.insert(item_list, {item_id = item_id, count = refine_data.item_num})
    local item_data = excel_data.ItemData[equip.item_id]
    local cost_item_count
    if item_data.quality == CSConst.EquipMaxQuality then
        -- 暗金品质宝物
        if refine_data.treasure_count > 0 then
            if not cost_item_id then return end
            local cost_item_data = excel_data.ItemData[cost_item_id]
            if cost_item_data.part_index ~= item_data.part_index then return end
            if cost_item_data.quality ~= item_data.quality - 1 then return end
            cost_item_count = refine_data.treasure_count
        end
    else
        -- 其他品质宝物
        if refine_data.treasure_num > 0 then
            cost_item_id = equip.item_id
            cost_item_count = refine_data.treasure_num
        end
    end
    local cost_dict = {}
    if cost_item_count then
        table.insert(item_list, {item_id = cost_item_id, count = cost_item_count})
        cost_dict[cost_item_id] = cost_item_count
    end

    return item_list, cost_dict
end

-- 检查精炼大师等级
function role_lineup:check_refine_master_lv(lineup_info, part_type)
    local new_master_lv = 0
    local master_data, equip_count
    if part_type == CSConst.EquipPartType.Equip then
        master_data = excel_data.ERmasterData
        equip_count = CSConst.MasterEquipCount.Equip
    elseif part_type == CSConst.EquipPartType.Treasure then
        master_data = excel_data.TRmasterData
        equip_count = CSConst.MasterEquipCount.Treasure
    end
    local part_data = excel_data.EquipPartData
    for level, data in ipairs(master_data) do
        local count = 0
        for part_index, equip_guid in pairs(lineup_info.equip_dict) do
            if part_data[part_index].part_type == part_type then
                local equip = self.role:get_bag_item(equip_guid)
                if equip.refine_lv >= data.equip_lv then
                    count = count + 1
                end
            end
        end
        if count < equip_count then break end
        new_master_lv = level
    end

    local old_master_lv = lineup_info.refine_master_lv[part_type]
    if new_master_lv ~= old_master_lv then
        local old_attr_dict = CSFunction.get_refine_master_attr(part_type, old_master_lv)
        local new_attr_dict = CSFunction.get_refine_master_attr(part_type, new_master_lv)
        self.role:modify_hero_attr(lineup_info.hero_id, old_attr_dict, new_attr_dict, true)
        lineup_info.refine_master_lv[part_type] = new_master_lv
        self.role:send_client("s_update_lineup_master_lv",{
            lineup_id = lineup_info.lineup_id,
            refine_master_lv = lineup_info.refine_master_lv
        })
    end
end

-- 装备升星
function role_lineup:upgrade_equip_star_lv(item_guid)
    if not item_guid then return end
    local equip = self.role:get_bag_item(item_guid)
    if not equip then return end
    local item_data = excel_data.ItemData[equip.item_id]
    if item_data.item_type ~= CSConst.ItemType.Equip or not item_data.part_index then return end
    local quality_data = excel_data.QualityData[item_data.quality]
    local old_level = equip.star_lv
    if old_level >= quality_data.equip_star_lv_limit then return end

    local new_level = old_level + 1
    local item_dict = CSFunction.get_equip_star_cost(equip.item_id, new_level)
    if not self.role:consume_item_dict(item_dict, g_reason.upgrade_equip_star_lv) then return end

    equip.star_lv = new_level
    if equip.lineup_id then
        -- 穿戴的装备
        local old_attr_dict = CSFunction.get_equip_star_attr(equip.item_id, old_level)
        local new_attr_dict = CSFunction.get_equip_star_attr(equip.item_id, equip.star_lv)
        local lineup_info = self.db.lineup_dict[equip.lineup_id]
        lineup_info.equip_info_dict[item_guid] = table.deep_copy(equip)
        self.role:modify_hero_attr(lineup_info.hero_id, old_attr_dict, new_attr_dict)
    end
    self.role:send_client("s_bag_item_update", {update_item = equip})
    return true
end

-- 装备炼化
function role_lineup:equip_smelt(item_guid, cost_item_id)
    if not item_guid then return end
    local equip = self.role:get_bag_item(item_guid)
    if not equip then return end
    local item_data = excel_data.ItemData[equip.item_id]
    if item_data.item_type ~= CSConst.ItemType.Equip or not item_data.part_index then return end
    if not excel_data.QualityData[item_data.quality].can_smelt then return end
    local old_level = equip.smelt_lv
    local smelt_data = excel_data.EquipSmeltData[old_level + 1]
    if not smelt_data then return end

    local item_dict = CSFunction.get_equip_smelt_cost(equip.item_id, old_level + 1)
    local cost_num = item_dict[cost_item_id]
    if not cost_num then return end
    if not self.role:consume_item(cost_item_id, cost_num, g_reason.equip_smelt) then return end
    equip.smelt_cost = equip.smelt_cost or {}
    equip.smelt_cost[cost_item_id] = (equip.smelt_cost[cost_item_id] or 0) + cost_num
    local old_exp = equip.smelt_exp
    local rate
    if smelt_data.init_rate == 1 then
        rate = smelt_data.init_rate
    else
        rate = smelt_data.init_rate + (1 - smelt_data.init_rate) * equip.lucky_value / smelt_data.luck_limit
    end
    local is_success = false
    local crit
    if math.random() < rate then
        -- 炼化成功
        is_success = true
        local smelt_exp = smelt_data.each_exp
        local random = math.random()
        if random < smelt_data.crit_rate2 then
            -- 2倍暴击
            smelt_exp = smelt_exp * CSConst.SmeltCritRate2
            crit = CSConst.SmeltCritRate2
        elseif random < smelt_data.crit_rate1 then
            -- 1.5倍暴击
            smelt_exp = smelt_exp * CSConst.SmeltCritRate1
            crit = CSConst.SmeltCritRate1
        end
        smelt_exp = math.floor(smelt_exp) + old_exp
        if smelt_exp >= smelt_data.exp then
            equip.smelt_exp = 0
            equip.smelt_lv = old_level + 1
            equip.lucky_value = 0
        else
            equip.smelt_exp = smelt_exp
        end
    else
        -- 炼化失败
        equip.lucky_value = equip.lucky_value + smelt_data.add_luck
        if equip.lucky_value >= smelt_data.luck_limit then
            equip.lucky_value = smelt_data.luck_limit
        end
    end

    if equip.lineup_id then
        -- 穿戴的装备
        local old_attr_dict = CSFunction.get_equip_smelt_attr(equip.item_id, old_level, old_exp)
        local new_attr_dict = CSFunction.get_equip_smelt_attr(equip.item_id, equip.smelt_lv, equip.smelt_exp)
        local lineup_info = self.db.lineup_dict[equip.lineup_id]
        lineup_info.equip_info_dict[item_guid] = table.deep_copy(equip)
        self.role:modify_hero_attr(lineup_info.hero_id, old_attr_dict, new_attr_dict)
    end
    self.role:send_client("s_bag_item_update", {update_item = equip})
    return is_success, crit
end

-- 获取阵容位置属性
function role_lineup:get_lineup_attr_dict(lineup_id)
    local attr_dict = {}
    local lineup_info = self.db.lineup_dict[lineup_id]
    local equip_dict = lineup_info.equip_dict
    -- 装备属性
    for _, equip_guid in pairs(equip_dict) do
        table.dict_attr_add(attr_dict, self:get_equip_attr(equip_guid))
    end
    -- 套装属性
    table.dict_attr_add(attr_dict, self:get_equip_suit_attr(equip_dict))
    -- 强化大师属性
    for part_type, master_lv in pairs(lineup_info.strengthen_master_lv) do
        table.dict_attr_add(attr_dict, CSFunction.get_strengthen_master_attr(part_type, master_lv))
    end
    -- 精炼大师属性
    for part_type, master_lv in pairs(lineup_info.refine_master_lv) do
        table.dict_attr_add(attr_dict, CSFunction.get_refine_master_attr(part_type, master_lv))
    end

    return attr_dict
end

-- 获取装备属性
function role_lineup:get_equip_attr(equip_guid)
    local equip = self.role:get_bag_item(equip_guid)
    return CSFunction.get_equip_all_attr(equip)
end

-- 计算出战英雄战力
function role_lineup:eval_fight_score()
    local fight_score = 0
    local lineup_dict = self.db.lineup_dict
    for _, lineup_info in pairs(lineup_dict) do
        if lineup_info.hero_id then
            local hero_info = self.role:get_hero(lineup_info.hero_id)
            fight_score = fight_score + hero_info.score
        end
    end
    return math.floor(fight_score)
end

-- 获取战斗数据
function role_lineup:get_role_fight_data()
    local lineup_dict = self.db.lineup_dict
    local hero_dict = self.db.hero_dict
    return role_utils.get_role_fight_data(lineup_dict, hero_dict)
end

-- 装备重生
function role_lineup:equip_recover(equip_guid)
    if not equip_guid then return end
    local equip = self.role:get_bag_item(equip_guid)
    if not equip or equip.lineup_id then return end
    local item_data = excel_data.ItemData[equip.item_id]
    if item_data.item_type ~= CSConst.ItemType.Equip then return end
    if not item_data.part_index then return end
    local cost_data = excel_data.ParamData["equip_recover_cost"]
    if not self.role:consume_item(cost_data.item_id, cost_data.count, g_reason.equip_recover) then return end
    -- 重生归还物品
    local item_dict = CSFunction.get_equip_recover_item(equip)
    if item_data.is_treasure then
        -- 宝物
        equip.star_lv = 0
        equip.refine_lv = 0
        equip.refine_exp = 0
        equip.refine_cost = nil
        equip.strengthen_lv = 1
        equip.strengthen_exp = 0
        equip.smelt_lv = 0
        equip.smelt_exp = 0
        equip.smelt_cost = nil
        equip.lucky_value = 0
        self.role:send_client("s_bag_item_update", {update_item = equip})
    else
        -- 普通装备（不保留原来装备，自动分解为碎片）
        local fragment_id = item_data.fragment
        item_dict[fragment_id] = excel_data.ItemData[fragment_id].synthesize_count
        if not self.role:consume_item(equip.item_id, equip.count, g_reason.equip_recover, nil, true) then return end
    end
    self.role:add_item_dict(item_dict, g_reason.equip_recover)
    return true
end

-- 检查是否上阵有英雄
function role_lineup:check_lineup_has_hero()
    local lineup_dict = self.db.lineup_dict
    for _, v in pairs(lineup_dict) do
        if v.hero_id then
            return true
        end
    end
end

function role_lineup:check_reinforcements_unlock()
    local reinforcements_dict = self.db.reinforcements_dict
    local role_level = self.role:get_level()
    local has_change
    for i, config in ipairs(excel_data.DeinforcementsData) do
        if role_level >= config.unlock_level and not reinforcements_dict[i] then
            has_change = true
            reinforcements_dict[i] = {pos_id = i}
        end
    end
    if has_change then
        self.role:send_client("s_update_reinforcements",{reinforcements_dict = reinforcements_dict})
    end
end

function role_lineup:get_reinforcements_pos_id(hero_id)
    if not hero_id then return end
    local reinforcements_dict = self.db.reinforcements_dict
    for pos_id, info in pairs(reinforcements_dict) do
        if info.hero_id == hero_id then
            return pos_id
        end
    end
end

-- 援军
function role_lineup:reinforcements_change(pos_id, hero_id)
    if not pos_id then return end
    local reinforcements_dict = self.db.reinforcements_dict
    local info = reinforcements_dict[pos_id]
    if not info or (info.hero_id == hero_id) then return end
    local num = 0
    local lineup_dict = self.db.lineup_dict
    for _, v in pairs(lineup_dict) do
        if v.hero_id then
            num = num + 1
        end
    end
    -- 要上满阵容位置，才能上援军
    if num ~= CSConst.LineupMaxCount then return end
    if hero_id then
        if self:get_hero_lineup_id(hero_id) then return end
        local old_pos_id = self:get_reinforcements_pos_id(hero_id)
        if old_pos_id then
            reinforcements_dict[old_pos_id].hero_id = nil
        end
    end
    info.hero_id = hero_id
    self:on_reinforcements_change()
    self.role:send_client("s_update_reinforcements",{reinforcements_dict = reinforcements_dict})
    return true
end

function role_lineup:on_reinforcements_change()
    local lineup_dict = self.db.lineup_dict
    for _, lineup_info in pairs(lineup_dict) do
        if lineup_info.hero_id then
            self.role:refresh_fate(lineup_info.hero_id)
        end
    end
    self.role:send_score_msg()
end

return role_lineup