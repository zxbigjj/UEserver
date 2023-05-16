local M = DECLARE_MODULE("role_utils")

local excel_data = require("excel_data")
local attr_utils = require("attr_utils")
local CSFunction = require("CSCommon.CSFunction")

function M.get_attr_dict_diff(old_attr_dict, new_attr_dict)
    if not old_attr_dict and not new_attr_dict then return end
    new_attr_dict = new_attr_dict or {}
    local attr_diff_dict = {}
    if old_attr_dict then
        for attr_name, attr_value in pairs(new_attr_dict) do
            attr_diff_dict[attr_name] = attr_value
        end
        for attr_name, attr_value in pairs(old_attr_dict) do
            attr_diff_dict[attr_name] = (attr_diff_dict[attr_name] or 0) - attr_value
        end
    else
        attr_diff_dict = new_attr_dict
    end

    local ret = {}
    for attr_name, attr_value in pairs(attr_diff_dict) do
        if attr_value ~= 0 then
            ret[attr_name] = attr_value
        end
    end
    return ret
end

-- 获取装备buff
function M.get_lineup_equip_buff(equip_dict)
    local buff_list = {}
    for _, equip in pairs(equip_dict) do
        if equip.refine_lv > 0 then
            local item_data = excel_data.ItemData[equip.item_id]
            for i, refine_lv in ipairs(item_data.refine_level_list) do
                if equip.refine_lv < refine_lv then break end
                local data = excel_data.RefineSpellData[item_data.refine_spell_list[i]]
                if data.spell_type == CSConst.RefineSpellType.Buff then
                    table.insert(buff_list, data.buff_id)
                end
            end
        end
    end
    return buff_list
end

-- 获取玩家战斗数据
function M.get_role_fight_data(lineup_dict, hero_dict)
    local pos_dict = {}
    for _, lineup_info in pairs(lineup_dict) do
        local hero_id = lineup_info.hero_id
        if hero_id then
            local buff_list = M.get_lineup_equip_buff(lineup_info.equip_info_dict)
            local hero_info = hero_dict[hero_id]
            local add_anger = (hero_info.attr_dict["init_anger"] or 0)
            pos_dict[lineup_info.pos_id] = {
                hero_id = hero_id,
                buff_list = buff_list,
                add_anger = add_anger
            }
        end
    end
    if not next(pos_dict) then return end

    local fight_data = {}
    for i = 1, CSConst.LineupMaxCount do
        local data = pos_dict[i]
        if data then
            local hero_data = excel_data.HeroData[data.hero_id]
            local hero_info = hero_dict[data.hero_id]
            fight_data[i] = {
                hero_id = data.hero_id,
                unit_id = hero_data.unit_id,
                score = hero_info.score,
                spell_dict = table.deep_copy(hero_info.spell_dict),
                fight_attr_dict = table.deep_copy(hero_info.attr_dict),
                buff_list = data.buff_list,
                add_anger = data.add_anger
            }
        else
            fight_data[i] = {}
        end
    end

    return fight_data
end

-- 构建机器人英雄数据
function M.build_robot_hero_data(robot_hero_id, hero_level)
    local robot_data = excel_data.HeroRobotData[robot_hero_id]
    local hero_id = robot_data.hero_id
    local hero_data = excel_data.HeroData[hero_id]
    local spell_dict = {}
    for _, spell_id in ipairs(hero_data.spell) do
        spell_dict[spell_id] = 1
    end
    local attr_dict = attr_utils.get_robot_hero_attr(robot_hero_id, hero_level)
    local score = attr_utils.eval_hero_score(attr_dict)
    return {
        hero_id = hero_id,
        unit_id = hero_data.unit_id,
        score = score,
        spell_dict = spell_dict,
        fight_attr_dict = attr_dict,
    }
end

-- 获取怪物组战斗数据
function M.get_monster_fight_data(monster_group_id, monster_level)
    return CSFunction.get_fight_data_by_group_id(monster_group_id, monster_level)
end

-- 获取通关星星评分
function M.get_boss_stage_star_num(victory_id, result)
    if victory_id then
        local star_num = 1
        local victory_data = excel_data.VictoryData[victory_id]
        if victory_data.remian_hp then
            -- 条件为剩余一定的百分比血量
            for i, remian_hp_pct in ipairs(victory_data.remian_hp) do
                if result.remain_hp/result.total_hp < remian_hp_pct then break end
                star_num = i
            end
        elseif victory_data.death_num then
            -- 条件为死亡人数
            for i, death_num in ipairs(victory_data.death_num) do
                if result.death_num > death_num then break end
                star_num = i
            end
        elseif victory_data.round_num then
            -- 条件为一定回合内通关
            for i, round_num in ipairs(victory_data.round_num) do
                if result.round_num > round_num then break end
                star_num = i
            end
        end
        return star_num
    else
        return CSConst.Stage.MaxStar
    end
end

-- 获取排行榜奖励
function M.get_rank_reward(rank_data, rank)
    local reward_id
    for i, v in ipairs(rank_data.reward_tier) do
        if rank <= v then
            reward_id = rank_data.reward_list[i]
            break
        end
    end
    if not reward_id and rank_data.join_reward then
        reward_id = rank_data.join_reward
    end
    return reward_id
end

return M