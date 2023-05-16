-- 服务端和客户端共用函数放在这里

local M = DECLARE_MODULE("CSCommon.CSFunction")

local sandbox = require("CSCommon.sandbox")
local data_mgr = require("CSCommon.data_mgr")
local CSConst = require("CSCommon.CSConst")

--------------------------- hero method start -----------------------------
-- 获取英雄等级属性
function M.get_hero_level_attr(hero_id, level, break_lv)
    local data = data_mgr:GetHeroData(hero_id)
    local attr_dict = sandbox.get_hero_level_grow(data.level_grow)(hero_id, level, break_lv)
    return attr_dict
end

-- 获取英雄升级消耗
function M.get_hero_level_cost(hero_id, old_level, new_level)
    if old_level >= new_level then return end
    local data = data_mgr:GetHeroData(hero_id)
    local cost_num = 0
    for level = old_level + 1, new_level do
        cost_num = cost_num + sandbox.get_hero_level_cost(data.level_cost)(hero_id, level)
    end
    local item_id = data_mgr:GetParamData("hero_levelup_cost_coin").item_id
    return {[item_id] = cost_num}
end

-- 获取英雄突破消耗
function M.get_hero_break_cost(hero_id, break_lv)
    local data = data_mgr:GetHeroData(hero_id)
    local coin_num, item_num, fragment_num = sandbox.get_hero_break_cost(data.break_cost)(hero_id, break_lv)
    local coin_id = data_mgr:GetParamData("hero_break_cost_coin").item_id
    local item_id = data_mgr:GetParamData("hero_break_cost_item").item_id
    local fragment_id = data.fragment_id
    return {
        [coin_id] = coin_num,
        [item_id] = item_num,
        [fragment_id] = fragment_num,
    }
end

-- 获取英雄升星消耗
function M.get_hero_star_cost(hero_id, star_lv)
    local data = data_mgr:GetHeroData(hero_id)
    local coin_num, fragment_num = sandbox.get_hero_star_cost(data.star_cost)(hero_id, star_lv)
    local coin_id = data_mgr:GetParamData("hero_star_cost_coin").item_id
    local fragment_id = data.fragment_id
    return {
        [coin_id] = coin_num,
        [fragment_id] = fragment_num,
    }
end

-- 获取英雄升星属性
function M.get_hero_star_attr(hero_id, star_lv)
    local data = data_mgr:GetHeroData(hero_id)
    local attr_dict = sandbox.get_hero_star_attr(data.star_grow)(hero_id, star_lv)
    return attr_dict
end

-- 获取英雄天命属性
function M.get_hero_destiny_attr(hero_id, destiny_lv)
    local data = data_mgr:GetHeroData(hero_id)
    local attr_dict = sandbox.get_hero_destiny_attr(data.destiny_grow)(hero_id, destiny_lv)
    return attr_dict
end

-- 获取英雄缘分属性
function M.get_hero_fate_attr(fate_dict)
    local attr_dict = {}
    for fate_id in pairs(fate_dict) do
        local data = data_mgr:GetFateData(fate_id)
        for i, attr_name in ipairs(data.attr_list) do
            attr_dict[attr_name] = (attr_dict[attr_name] or 0) + data.attr_value_list[i]
        end
    end
    return attr_dict
end

-- 获取英雄重生返还物品
function M.get_hero_recover_item(hero_info)
    local item_dict = {}
    local hero_id = hero_info.hero_id
    -- 自身碎片
    local hero_data = data_mgr:GetHeroData(hero_id)
    local fragment_id = hero_data.fragment_id
    local fragment_data = data_mgr:GetItemData(fragment_id)
    item_dict[fragment_id] = fragment_data.synthesize_count
    -- 升级物品
    if hero_info.level > 1 then
        local cost_data = M.get_hero_level_cost(hero_id, 1, hero_info.level)
        for item_id, count in pairs(cost_data) do
            item_dict[item_id] = (item_dict[item_id] or 0) + count
        end
    end
    -- 突破物品
    if hero_info.break_lv > 0 then
        for i = 1, hero_info.break_lv do
            local cost_data = M.get_hero_break_cost(hero_id, i)
            for item_id, count in pairs(cost_data) do
                item_dict[item_id] = (item_dict[item_id] or 0) + count
            end
        end
    end
    -- 升星物品
    if hero_info.star_lv > 0 then
        for i = 1, hero_info.star_lv do
            local cost_data = M.get_hero_star_cost(hero_id, i)
            for item_id, count in pairs(cost_data) do
                item_dict[item_id] = (item_dict[item_id] or 0) + count
            end
        end
    end
    -- 天命物品
    if hero_info.destiny_lv_cost > 0 then
        local item_id = data_mgr:GetParamData("hero_destiny_cost_item").item_id
        item_dict[item_id] = (item_dict[item_id] or 0) + hero_info.destiny_lv_cost
    end
    -- 吃书物品
    local book_item_list = data_mgr:GetParamData("hero_recover_book_item").item_list
    local attr_to_item = {}
    for _, item_id in ipairs(book_item_list) do
        local data = data_mgr:GetItemData(item_id)
        attr_to_item[data.random_attr_list[1]] = {item_id = item_id, count = data.random_attr_value_list[1]}
    end
    for attr_name, value in pairs(hero_info.book_attr_dict) do
        local item = attr_to_item[attr_name]
        local count = math.floor(value/item.count)
        if count > 0 then
            item_dict[item.item_id] = (item_dict[item.item_id] or 0) + count
        end
    end
    return item_dict
end

function M.get_hero_level_limit(role_level)
    local init_level_limit = data_mgr:GetParamData("hero_init_level_limit").f_value
    local change_interval = data_mgr:GetParamData("hero_level_limit_change_interval").f_value
    local change_value = data_mgr:GetParamData("hero_level_limit_change_value").f_value
    return math.floor(role_level / change_interval) * change_value + init_level_limit
end

function M.get_hero_init_attr_dict(hero_id)
    local hero_data = data_mgr:GetHeroData(hero_id)
    local attr_dict = {}
    for _, attr in pairs(CSConst.RoleAttrName) do
        attr_dict[attr] = hero_data[attr]
    end
    local base_role_grow_data = data_mgr:GetGrowConstData("base_role_define")
    attr_dict["hit"] = base_role_grow_data.base_hit
    attr_dict["miss"] = base_role_grow_data.base_miss
    attr_dict["crit"] = base_role_grow_data.base_crit
    attr_dict["crit_def"] = base_role_grow_data.base_crit_def
    M.gather_attr_dict(attr_dict, M.get_hero_level_attr(hero_id, 1, 0))
    M.gather_attr_dict(attr_dict, M.get_hero_star_attr(hero_id, 0))
    M.gather_attr_dict(attr_dict, M.get_hero_destiny_attr(hero_id, 1))
    attr_dict = M.refresh_all_attr(attr_dict)
    return attr_dict
end
--------------------------- hero method end ------------------------------

--------------------------- equip method start ------------------------------
-- 获取装备强化消耗
function M.get_equip_strengthen_cost(item_id, strengthen_lv)
    local data = data_mgr:GetItemData(item_id)
    local cost_num = sandbox.get_equip_strengthen_cost(data.strengthen_cost)(item_id, strengthen_lv)
    return cost_num
end

-- 获取装备升星消耗
function M.get_equip_star_cost(item_id, star_lv)
    local data = data_mgr:GetItemData(item_id)
    local coin_num, fragment_num = sandbox.get_equip_star_cost(data.star_cost)(item_id, star_lv)
    local coin_id = data_mgr:GetParamData("equip_star_cost_coin").item_id
    local fragment_id = data.fragment
    return {
        [coin_id] = coin_num,
        [fragment_id] = fragment_num,
    }
end

-- 获取装备炼化消耗
function M.get_equip_smelt_cost(item_id, smelt_lv)
    local data = data_mgr:GetItemData(item_id)
    local coin_num, diamond_num, fragment_num = sandbox.get_equip_smelt_cost(data.smelt_cost)(item_id, smelt_lv)
    local fragment_id = data.fragment
    return {
        [CSConst.Virtual.Money] = coin_num,
        [CSConst.Virtual.Diamond] = diamond_num,
        [fragment_id] = fragment_num,
    }
end

-- 获取装备所有的属性
function M.get_equip_all_attr(equip)
    local item_id = equip.item_id
    local item_data = data_mgr:GetItemData(item_id)
    local attr_dict = M.get_equip_base_attr_dict(item_id)
    -- 强化属性
    M.gather_attr_dict(attr_dict, M.get_equip_strengthen_attr(item_id, equip.strengthen_lv))
    -- 精炼属性
    M.gather_attr_dict(attr_dict, M.get_equip_refine_attr(item_id, equip.refine_lv))
    -- 升星属性
    M.gather_attr_dict(attr_dict, M.get_equip_star_attr(item_id, equip.star_lv))
    -- 炼化属性
    M.gather_attr_dict(attr_dict, M.get_equip_smelt_attr(equip.item_id, equip.smelt_lv, equip.smelt_exp))
    return attr_dict
end

function M.get_equip_base_attr_dict(item_id)
    local attr_dict = {}
    local item_data = data_mgr:GetItemData(item_id)
    for i, attr_name in ipairs(item_data.base_attr_list) do
        attr_dict[attr_name] = (attr_dict[attr_name] or 0) + item_data.base_attr_value[i]
    end
    return attr_dict
end

function M.gather_attr_dict(target_dict, ori_dict)
    for k, v in pairs(ori_dict) do
        target_dict[k] = target_dict[k] and target_dict[k] + v or v
    end
end

-- 获取装备强化属性
function M.get_equip_strengthen_attr(item_id, strengthen_lv)
    if strengthen_lv == 1 then return {} end
    local attr_dict = {}
    local item_data = data_mgr:GetItemData(item_id)
    local data = data_mgr:GetAllAttributeData()
    for i, attr_name in ipairs(item_data.base_attr_list) do
        local value = item_data.strengthen_attr_value[i] * (strengthen_lv - 1)
        if not data[attr_name].is_pct then
            value = math.floor(value)
        end
        attr_dict[attr_name] = value
    end
    return attr_dict
end

-- 获取强化大师属性
function M.get_strengthen_master_attr(part_type, master_lv)
    if master_lv == 0 then return {} end
    local attr_dict = {}
    local master_data
    if part_type == CSConst.EquipPartType.Equip then
        master_data = data_mgr:GetESmasterData(master_lv)
    elseif part_type == CSConst.EquipPartType.Treasure then
        master_data = data_mgr:GetTSmasterData(master_lv)
    end
    for i, attr_name in ipairs(master_data.attr_list) do
        attr_dict[attr_name] = (attr_dict[attr_name] or 0) + master_data.attr_value_list[i]
    end
    return attr_dict
end

-- 获取装备精炼属性
function M.get_equip_refine_attr(item_id, refine_lv)
    if refine_lv == 0 then return {} end
    local attr_dict = {}
    local item_data = data_mgr:GetItemData(item_id)
    -- 精炼基础属性
    for i, attr_name in ipairs(item_data.refine_attr_list) do
        attr_dict[attr_name] = (attr_dict[attr_name] or 0) + item_data.refine_attr_value[i] * refine_lv
    end
    -- 精炼技能属性
    for i, refine_level in ipairs(item_data.refine_level_list) do
        if refine_lv < refine_level then break end
        local data = data_mgr:GetRefineSpellData(item_data.refine_spell_list[i])
        if data and data.spell_type == CSConst.RefineSpellType.Attr then
            for i, attr_name in ipairs(data.attr_list) do
                attr_dict[attr_name] = (attr_dict[attr_name] or 0) + data.attr_value_list[i]
            end
        end
    end
    return attr_dict
end

-- 获取精炼大师属性
function M.get_refine_master_attr(part_type, master_lv)
    if master_lv == 0 then return {} end
    local attr_dict = {}
    local master_data
    if part_type == CSConst.EquipPartType.Equip then
        master_data = data_mgr:GetERmasterData(master_lv)
    elseif part_type == CSConst.EquipPartType.Treasure then
        master_data = data_mgr:GetTRmasterData(master_lv)
    end
    for i, attr_name in ipairs(master_data.attr_list) do
        attr_dict[attr_name] = (attr_dict[attr_name] or 0) + master_data.attr_value_list[i]
    end
    return attr_dict
end

-- 获取装备升星属性
function M.get_equip_star_attr(item_id, star_lv)
    local data = data_mgr:GetItemData(item_id)
    if data.is_treasure then return {} end
    return sandbox.get_equip_star_attr_grow(data.star_attr_grow)(item_id, star_lv)
end

-- 获取装备炼化属性
function M.get_equip_smelt_attr(item_id, smelt_lv, smelt_exp)
    if smelt_lv == 0 and smelt_exp == 0 then return {} end
    local item_data = data_mgr:GetItemData(item_id)
    if item_data.is_treasure then return {} end
    local value = 0
    if smelt_lv > 0 then
        for i= 1, smelt_lv do
            value = value + item_data.smelt_attr_value[i] + item_data.smelt_extra_attr_value[i]
        end
    end
    if smelt_lv < #item_data.smelt_attr_value then
        local smelt_data = data_mgr:GetEquipSmeltData(smelt_lv + 1)
        value = value + smelt_exp / smelt_data.exp * item_data.smelt_attr_value[smelt_lv + 1]
    end
    return {[item_data.smelt_attr] = math.floor(value)}
end

-- 获取装备重生归还物品
function M.get_equip_recover_item(equip)
    local item_dict = {}
    local param_data = data_mgr:GetAllParamData()
    local equip_data = data_mgr:GetItemData(equip.item_id)
    -- 强化物品
    if equip.strengthen_lv > 1 or equip.strengthen_exp > 0 then
        if equip_data.is_treasure then
            -- 宝物
            local cost_coin_id = param_data["strengthen_equip_cost_coin"].item_id
            local exp_treasure_list = param_data["exp_treasure_list"].item_list
            for i = #exp_treasure_list, 1, -1 do
                local item_id = exp_treasure_list[i]
                local data = data_mgr:GetItemData(item_id)
                local count = math.floor(equip.strengthen_exp/data.add_exp)
                if count > 0 then
                    equip.strengthen_exp = equip.strengthen_exp - count * data.add_exp
                    item_dict[item_id] = (item_dict[item_id] or 0) + count
                    item_dict[cost_coin_id] = (item_dict[cost_coin_id] or 0) + count * data.cost_coin
                end
            end
        else
            -- 装备
            local item_id = param_data["strengthen_equip_cost_coin"].item_id
            local count = 0
            for i = 2, equip.strengthen_lv do
                count = count + M.get_equip_strengthen_cost(equip.item_id, i)
            end
            item_dict[item_id] = (item_dict[item_id] or 0) + count
        end
    end
    -- 精炼物品
    if equip.refine_lv > 0 or equip.refine_exp > 0 then
        if equip_data.is_treasure then
            -- 宝物
            local cost_coin_id = param_data["refine_equip_cost_coin"].item_id
            local cost_coin_count = 0
            local cost_item_id = param_data["refine_treasure_cost_item"].item_id
            local cost_item_count = 0
            for i = 1, equip.refine_lv do
                local refine_data = data_mgr:GetRefineLvData(i)
                cost_coin_count = cost_coin_count + refine_data.coin_num
                cost_item_count = cost_item_count + refine_data.item_num
            end
            item_dict[cost_coin_id] = (item_dict[cost_coin_id] or 0) + cost_coin_count
            item_dict[cost_item_id] = (item_dict[cost_item_id] or 0) + cost_item_count
            if equip.refine_cost then
                for item_id, count in pairs(equip.refine_cost) do
                    item_dict[item_id] = (item_dict[item_id] or 0) + count
                end
            end
        else
            -- 装备
            local refine_item_list = param_data["equip_refine_item_list"].item_list
            for i = #refine_item_list, 1, -1 do
                local item_id = refine_item_list[i]
                local data = data_mgr:GetItemData(item_id)
                local count = math.floor(equip.refine_exp/data.add_exp)
                if count > 0 then
                    equip.refine_exp = equip.refine_exp - count * data.add_exp
                    item_dict[item_id] = (item_dict[item_id] or 0) + count
                end
            end
        end
    end
    -- 升星物品
    if equip.star_lv > 0 then
        for i = 1, equip.star_lv do
            local cost_data = M.get_equip_star_cost(equip.item_id, i)
            for item_id, count in pairs(cost_data) do
                item_dict[item_id] = (item_dict[item_id] or 0) + count
            end
        end
    end
    -- 炼化物品
    if equip.smelt_cost then
        for item_id, count in pairs(equip.smelt_cost) do
            item_dict[item_id] = (item_dict[item_id] or 0) + count
        end
    end
    return item_dict
end
--------------------------- equip method end ------------------------------
function M.item_list_to_dict(item_list)
    local item_dict = {}
    for _, v in ipairs(item_list) do
        item_dict[v.item_id] = (item_dict[v.item_id] or 0) + v.count
    end
    return item_dict
end

--------------------------- score method start ------------------------------
function M.get_native_hero_battle_data(self_group_id, enemy_group_id)
    local fight_data = {
        seed = math.random(1, 2000000000),
        own_fight_data = M.get_fight_data_by_group_id(self_group_id),
        enemy_fight_data = M.get_fight_data_by_group_id(enemy_group_id),
    }
    return fight_data
end

function M.get_fight_data_by_group_id(monster_group_id, monster_level)
    local fight_data = {}
    local monster_group_data = data_mgr:GetMonsterGroupData(monster_group_id)
    monster_level = monster_level or monster_group_data.level
    for pos, data in ipairs(monster_group_data.pos_list) do
        if data.monster_id then
            local monster_data = data_mgr:GetMonsterData(data.monster_id)
            local hero_data = data_mgr:GetHeroData(monster_data.hero_id)
            fight_data[pos] = {
                monster_id = data.monster_id,
                unit_id = hero_data.unit_id,
                spell_dict = hero_data.spell_dict,
                fight_attr_dict = M.get_monster_attr_dict(data.monster_id, monster_level),
                add_anger = monster_data.add_anger
            }
        else
            fight_data[pos] = {}
        end
    end
    return fight_data
end

function M.get_monster_attr_dict(monster_id, monster_level)
    local monster_data = data_mgr:GetMonsterData(monster_id)
    return sandbox.get_monster_attr(monster_data.monster_grow)(monster_id, monster_level)
end

function M.get_monster_group_score(monster_group_id, level)
    local monster_group_data = data_mgr:GetMonsterGroupData(monster_group_id)
    local score = 0
    for pos, data in ipairs(monster_group_data.pos_list) do
        if data.monster_id then
            score = score + M.get_monster_score(data.monster_id, level or monster_group_data.level or 1)
        end
    end
    return score
end

-- 获取激活缘分 -- 默认当前缘分只存在一对一关系
function M.get_active_fate_by_list(hero_id_list, hero_id_to_equip_dict)
    local hero_id_to_active_fate = {}
    for _, main_hero_id in ipairs(hero_id_list) do
        local is_fate_active = M.get_hero_active_fate_dict(main_hero_id, hero_id_list, hero_id_to_equip_dict[main_hero_id])
        hero_id_to_active_fate[main_hero_id] = is_fate_active
    end
    return hero_id_to_active_fate
end

function M.get_hero_active_fate_dict(main_hero_id, compare_hero_id_list, equip_dict)
    local is_fate_active = {}
    for _, compare_hero_id in ipairs(compare_hero_id_list) do
        local active_fate_dict = M.get_active_fate(main_hero_id, compare_hero_id)
        for k, v in pairs(active_fate_dict) do
            is_fate_active[k] = v
        end
    end
    if equip_dict then
        local equip_active_fate = M.get_active_fate_by_equip_dict(main_hero_id, equip_dict)
        for k,v in pairs(equip_active_fate) do
            is_fate_active[k] = v
        end
    end
    return is_fate_active
end

function M.get_active_fate(main_hero_id, compare_hero_id)
    local is_fate_active = {}
    if main_hero_id == compare_hero_id then return is_fate_active end
    local fate_list = data_mgr:GetHeroData(main_hero_id).fate
    local fate_data
    for _, fate_id in ipairs(fate_list) do
        fate_data = data_mgr:GetFateData(fate_id)
        if fate_data.fate_hero and fate_data.fate_hero == compare_hero_id then
            is_fate_active[fate_id] = true
        end
    end
    return is_fate_active
end

function M.get_aid_active_fate(main_hero_id, compare_hero_id_list)
    local is_fate_active = {}
    for _, compare_hero_id_id in ipairs(compare_hero_id_list) do
        local active_fate_dict = M.get_active_fate(compare_hero_id_id, main_hero_id)
        for k, v in pairs(active_fate_dict) do
            is_fate_active[k] = v
        end
    end
    return is_fate_active
end

function M.get_active_fate_by_equip_dict(main_hero_id, equip_dict)
    local is_fate_active = {}
    local fate_list = data_mgr:GetHeroData(main_hero_id).fate
    local fate_data
    for _, fate_id in ipairs(fate_list) do
        fate_data = data_mgr:GetFateData(fate_id)
        if fate_data.fate_item and table.contains(equip_dict, fate_data.fate_item) then
            is_fate_active[fate_id] = true
        end
    end
    return is_fate_active
end

-- 获取激活缘分 end

function M.get_monster_score(monster_id, monster_level)
    local attr_dict = M.get_monster_attr_dict(monster_id, monster_level)
    return M.eval_hero_score(attr_dict)
end

-- 派对情人加成
function M.get_add_ratio(lover_level)
    local level_to_ratio = data_mgr:GetParamData("party_lover_level_to_ratio").f_value
    local add_ratio = lover_level * level_to_ratio
    add_ratio = math.floor(add_ratio * 100) / 100
    return add_ratio
end

function M.get_party_point(party_info)
    local count = math.floor(data_mgr:GetPartyData(party_info.party_type_id).init_party_point)
    for _, guests_info in ipairs(party_info.guests_list) do
        local gift_config = data_mgr:GetPartyGiftData(guests_info.gift_id)
        if gift_config then
            count = count + gift_config.init_party_point
        end
    end
    local add_count = math.floor(count * M.get_add_ratio(party_info.lover_level))
    local count_sum = count + add_count
    return count_sum, count, add_count
end
--------------------------- score method end ------------------------------

--------------------------- attr method start ------------------------------
local MODIFY_MAPPER = {}
for attr_name in pairs(data_mgr:GetAllAttributeData()) do
    MODIFY_MAPPER[attr_name] = {}
    table.insert(MODIFY_MAPPER[attr_name], attr_name)
end
local FORMULA_DICT = {}
local param_data = data_mgr:GetAllParamData()
for attr_name, attr_config in pairs(data_mgr:GetAllAttributeData()) do
    local pct_attr = attr_config.pct_attr
    if attr_name == "max_hp" then
        local business_to_hp_ratio = param_data["business_to_hp_ratio"].f_value
        local management_to_hp_ratio = param_data["management_to_hp_ratio"].f_value
        local renown_to_hp_ratio = param_data["renown_to_hp_ratio"].f_value
        FORMULA_DICT[attr_name] = function(x)
            return (x[attr_name] + (x["business"] or 0) * (1 + 0.01 * (x["business_pct"] or 0)) * business_to_hp_ratio
                + (x["management"] or 0) * (1 + 0.01 * (x["management_pct"] or 0)) * management_to_hp_ratio
                + (x["renown"] or 0) * (1 + 0.01 * (x["renown_pct"] or 0)) * renown_to_hp_ratio)
                * (1 + 0.01 * (x[pct_attr] or 0))
        end
        table.insert(MODIFY_MAPPER["business"], attr_name)
        table.insert(MODIFY_MAPPER["business_pct"], attr_name)
        table.insert(MODIFY_MAPPER["management"], attr_name)
        table.insert(MODIFY_MAPPER["management_pct"], attr_name)
        table.insert(MODIFY_MAPPER["renown"], attr_name)
        table.insert(MODIFY_MAPPER["renown_pct"], attr_name)
        table.insert(MODIFY_MAPPER[pct_attr], attr_name)
    elseif attr_name == "att" then
        local fight_to_att_ratio = param_data["fight_to_att_ratio"].f_value
        FORMULA_DICT[attr_name] = function(x)
            return (x[attr_name] + (x["fight"] or 0) * (1 + 0.01 * (x["fight_pct"] or 0)) * fight_to_att_ratio) * (1 + 0.01 * (x[pct_attr] or 0))
        end
        table.insert(MODIFY_MAPPER["fight"], attr_name)
        table.insert(MODIFY_MAPPER["fight_pct"], attr_name)
        table.insert(MODIFY_MAPPER[pct_attr], attr_name)
    else
        if pct_attr then
            FORMULA_DICT[attr_name] = function(x)
                return x[attr_name] * (1 + 0.01 * (x[pct_attr] or 0))
            end
            table.insert(MODIFY_MAPPER[pct_attr], attr_name)
        else
            FORMULA_DICT[attr_name] = function(x)
                return x[attr_name]
            end
        end
    end
end

-- 修改原始属性后刷新
function M.on_modify_raw(raw_dict, modify_raw_name)
    if not MODIFY_MAPPER[modify_raw_name] then
        error("unknow attr:" .. modify_raw_name)
    end
    local ret = {}
    for _, name in ipairs(MODIFY_MAPPER[modify_raw_name]) do
        ret[name] = FORMULA_DICT[name](raw_dict)
    end
    return ret
end

-- 根据原始属性计算最终属性
function M.refresh_all_attr(raw_dict)
    local attr_dict = {}
    for attr_name in pairs(raw_dict) do
        attr_dict[attr_name] = FORMULA_DICT[attr_name](raw_dict)
    end
    return attr_dict
end

-- 战斗力=FLOOR(（攻击常量 X 面板攻击+血量常量 X 面板血量+防御常量 X 面板防御）*（1+命中率+闪避率+暴击率+抗暴率+伤害加成+伤害减免+暴击伤害加成）*（1+最终伤害加成))
-- 计算英雄战力
function M.eval_hero_score(attr_dict)
    local param_data = data_mgr:GetAllParamData()
    local att_const = param_data["attack_constant"].f_value
    local hp_const = param_data["hp_constant"].f_value
    local def_const = param_data["defense_constant"].f_value
    local score = (att_const*attr_dict["att"] + hp_const*attr_dict["max_hp"] + def_const*attr_dict["def"])
                *(1 + 0.01*(attr_dict["hit"] + (attr_dict["miss"] or 0) + (attr_dict["crit"] or 0) + (attr_dict["crit_def"] or 0)
                    + (attr_dict["add_hurt"] or 0) + (attr_dict["hurt_def"] or 0)))
                *(1 + 0.01*(attr_dict["add_final_hurt"] or 0))
    return math.floor(score)
end
--------------------------- attr method end ------------------------------

--------------------------- dynasty method start -------------------------
-- 获取王朝技能消耗
function M.get_dynasty_spell_cost(spell_id, spell_level)
    local data = data_mgr:GetDynastySpellData(spell_id)
    local player_cost, dynasty_cost = sandbox.get_dynasty_spell_cost(data.cost_grow)(spell_id, spell_level)
    return {player_cost = player_cost, dynasty_cost = dynasty_cost}
end

-- 获取王朝技能属性值
function M.get_dynasty_spell_attr_value(spell_id, spell_level)
    local data = data_mgr:GetDynastySpellData(spell_id)
    return sandbox.get_dynasty_spell_attr_value(data.attr_grow)(spell_id, spell_level)
end

-- 获取王朝技能经验加成
function M.get_dynasty_spell_add_exp(spell_dict, exp)
    local level = spell_dict[CSConst.DynastyExpSpellId]
    if not level then return 0 end
    local value = M.get_dynasty_spell_attr_value(CSConst.DynastyExpSpellId, level)
    return math.floor(0.01 * value * exp)
end
--------------------------- dynasty method end ---------------------------
function M.get_cmd_cooldown(score)
    local cmd_cooldown_param = data_mgr:GetParamData("cmd_cooldown_param").f_value
    return math.min(math.floor(score/cmd_cooldown_param) + 1, 30) * 60
end

-- 获取情人升星消耗
function M.get_lover_star_cost(lover_id, star_lv)
    local data = data_mgr:GetLoverData(lover_id)
    local coin_num, fragment_num = sandbox.get_lover_star_cost(data.star_cost)(lover_id, star_lv)
    return {
        [CSConst.Virtual.Money] = coin_num,
        [data.fragment_id] = fragment_num,
    }
end

-- 获取情人升星属性
function M.get_lover_star_attr(lover_id, star_lv)
    local data = data_mgr:GetLoverData(lover_id)
    local attr_dict = sandbox.get_lover_star_attr(data.star_grow)(lover_id, star_lv)
    return attr_dict
end

-- 判断名字合法性
function M.check_player_name_legality(name)
    local length = string.len(name)
    if length > 16 or length < 3 then
        return false, CSConst.NameLegalityErrorCode.LengthLimit
    end
    if string.sub(name, 1, 1) == " " or string.sub(name, -1, -1) == " " then
        return false, CSConst.NameLegalityErrorCode.SpaceInBothEnd
    end
    if string.find(name, "  ") then
        return false, CSConst.NameLegalityErrorCode.SpaceInRow
    end
    if M.check_has_bad_word(name) then
        return false, CSConst.NameLegalityErrorCode.HasBadWord
    end
    return true
end

function M.check_has_bad_word(str)
    return data_mgr:CheckHasBadWord(str)
end

function M.filter_bad_word(str)
    return data_mgr:FilterBadWord(str)
end

-- vip额外次数增加计算 ----------------------------------------
function M.get_bar_game_refresh_limit(vip, bar_type)
    local hero_base_count = SpecMgrs.data_mgr:GetParamData("bar_hero_refresh_basic_times").f_value
    local lover_base_count = SpecMgrs.data_mgr:GetParamData("bar_lover_refresh_basic_times").f_value
    local vip_data = SpecMgrs.data_mgr:GetVipData(vip)
    if bar_type == CSConst.BarType.Hero then
        return hero_base_count + vip_data.bar_hero_refresh_extra_times
    elseif bar_type == CSConst.BarType.Lover then
        return lover_base_count + vip_data.bar_lover_refresh_extra_times
    end
end

function M.get_date_lover_num(vip, level)
    local level = ComMgrs.dy_data_mgr:ExGetRoleLevel()
    local level_data = SpecMgrs.data_mgr:GetLevelData(level)
    local vip_data = SpecMgrs.data_mgr:GetVipData(vip)
    return vip_data.date_lover_num + level_data.discuss_max_count
end

function M.get_train_challenge_buy_time(vip)
    local vip_data = SpecMgrs.data_mgr:GetVipData(vip)
    return vip_data.train_challenge_buy_time
end

function M.get_tratior_challenge_buy_time(vip)
    local vip_data = SpecMgrs.data_mgr:GetVipData(vip)
    return vip_data.tratior_challenge_buy_time
end

return M