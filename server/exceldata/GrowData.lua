return {
    [ "怪物成长" ] = {
        [ "ch_key" ] = "怪物成长",
        [ "lua" ] = "local monster_data = GetData(\"MonsterData\", monster_id)\
\
local attr_dict = {\
    max_hp = math.floor(50 * curr_level * monster_data.max_hp_pct),\
    att = math.floor(30 * curr_level * monster_data.att_pct),\
    def = math.floor(5 * curr_level * monster_data.def_pct),\
    crit = math.floor(20 * monster_data.crit_pct),\
    crit_def = math.floor(5 * monster_data.crit_def_pct),\
    hit = math.floor(100 * monster_data.hit_pct),\
    miss = math.floor(5 * monster_data.miss_pct),\
}\
return attr_dict",
        [ "name" ] = "怪物成长",
    },
    [ "情人升星属性成长" ] = {
        [ "ch_key" ] = "情人升星属性成长",
        [ "lua" ] = "local lover_data = GetData(\"LoverData\", lover_id)\
\
local base_role_define = GetData(\"GrowConstData\", \"base_lover_define\")\
local quality_data = GetData(\"QualityData\", lover_data.quality)\
\
local cur_star_pct = quality_data[\"r_star_pct\" .. curr_star_lv]\
\
local role_q2p = quality_data.lover_role_q2p\
\
local attr_dict = {\
    business = math.floor(base_role_define.star_business * cur_star_pct * role_q2p),\
    management = math.floor(base_role_define.star_management * cur_star_pct * role_q2p),\
    renown = math.floor(base_role_define.star_renown * cur_star_pct * role_q2p),\
    fight = math.floor(base_role_define.star_fight * cur_star_pct * role_q2p),\
    att = math.floor(base_role_define.star_att * cur_star_pct * role_q2p),\
    def = math.floor(base_role_define.star_def * cur_star_pct * role_q2p),\
    max_hp = math.floor(base_role_define.star_max_hp * cur_star_pct * role_q2p)\
}\
return attr_dict",
        [ "name" ] = "情人升星属性成长",
    },
    [ "情人升星消耗" ] = {
        [ "ch_key" ] = "情人升星消耗",
        [ "lua" ] = "local lover_data = GetData(\"LoverData\", lover_id)\
local unit_id = lover_data.unit_id\
local unit_data = GetData(\"UnitData\", unit_id)\
local quality_data = GetData(\"QualityData\", lover_data.quality)\
\
local s_consume_c0 = GetData(\"GrowConstData\", \"r_star_consume_c0\").i_value\
local s_consume_c1 = GetData(\"GrowConstData\", \"r_star_consume_c1\").i_value\
local s_consume_c2 = GetData(\"GrowConstData\", \"r_star_consume_c2\").i_value\
local l_star_2_role_pct = GetData(\"GrowConstData\", \"l_star_r_pct\").f_value\
\
local q_scale = quality_data.lover_consume_pct\
local lvl = next_star_lv\
\
local coin_num = math.ceil(q_scale*(s_consume_c2 * lvl * lvl + s_consume_c1 * lvl + s_consume_c0) * l_star_2_role_pct)\
\
local fragment_num = math.ceil(quality_data[\"r_star_frag_num\" .. lvl] * l_star_2_role_pct)\
\
return coin_num, fragment_num",
        [ "name" ] = "情人升星消耗",
    },
    [ "机器人成长" ] = {
        [ "ch_key" ] = "机器人成长",
        [ "lua" ] = "local hero_data = GetData(\"HeroData\", hero_id)\
local unit_id = hero_data.unit_id\
local unit_data = GetData(\"UnitData\", unit_id)\
\
local attr_dict = {\
    max_hp = 50 * curr_level,\
    att = 30 * curr_level,\
    def = 5 * curr_level,\
    crit = 20,\
    crit_def = 5,\
    hit = 100,\
    miss = 5,\
}\
return attr_dict",
        [ "name" ] = "机器人成长",
    },
    [ "王朝技能减伤" ] = {
        [ "ch_key" ] = "王朝技能减伤",
        [ "lua" ] = "local attr_value = 1 * curr_level                                                                                                                                                                                                                                     return attr_value",
        [ "name" ] = "王朝技能减伤",
    },
    [ "王朝技能减伤升耗" ] = {
        [ "ch_key" ] = "王朝技能减伤升耗",
        [ "lua" ] = "local player_cost = 2000 * next_level\
local dynasty_cost = 2000 * next_level                                                                                                                                                                                                                                     return player_cost, dynasty_cost",
        [ "name" ] = "王朝技能减伤升耗",
    },
    [ "王朝技能命中" ] = {
        [ "ch_key" ] = "王朝技能命中",
        [ "lua" ] = "local attr_value = 4 * curr_level                                                                                                                                                                                                                                     return attr_value",
        [ "name" ] = "王朝技能命中",
    },
    [ "王朝技能命中升耗" ] = {
        [ "ch_key" ] = "王朝技能命中升耗",
        [ "lua" ] = "local player_cost = 200 * next_level * next_level * next_level * next_level + 10000 * next_level\
local dynasty_cost = 200 * next_level * next_level * next_level * next_level + 10000 * next_level                                                                                                                                                                      return player_cost, dynasty_cost",
        [ "name" ] = "王朝技能命中升耗",
    },
    [ "王朝技能增伤" ] = {
        [ "ch_key" ] = "王朝技能增伤",
        [ "lua" ] = "local attr_value = 1 * curr_level                                                                                                                                                                                                                                     return attr_value",
        [ "name" ] = "王朝技能增伤",
    },
    [ "王朝技能增伤升耗" ] = {
        [ "ch_key" ] = "王朝技能增伤升耗",
        [ "lua" ] = "local player_cost = 2000 * next_level\
local dynasty_cost = 2000 * next_level                                                                                                                                                                                                                                     return player_cost, dynasty_cost",
        [ "name" ] = "王朝技能增伤升耗",
    },
    [ "王朝技能抗暴" ] = {
        [ "ch_key" ] = "王朝技能抗暴",
        [ "lua" ] = "local attr_value = 4 * curr_level                                                                                                                                                                                                                                     return attr_value",
        [ "name" ] = "王朝技能抗暴",
    },
    [ "王朝技能抗暴升耗" ] = {
        [ "ch_key" ] = "王朝技能抗暴升耗",
        [ "lua" ] = "local player_cost = 200 * next_level * next_level * next_level * next_level + 10000 * next_level\
local dynasty_cost = 200 * next_level * next_level * next_level * next_level + 10000 * next_level                                                                                                                                                                      return player_cost, dynasty_cost",
        [ "name" ] = "王朝技能抗暴升耗",
    },
    [ "王朝技能攻击" ] = {
        [ "ch_key" ] = "王朝技能攻击",
        [ "lua" ] = "local attr_value = 36 * curr_level                                                                                                                                                                                                                                     return attr_value",
        [ "name" ] = "王朝技能攻击",
    },
    [ "王朝技能攻击升耗" ] = {
        [ "ch_key" ] = "王朝技能攻击升耗",
        [ "lua" ] = "local player_cost = 4 * next_level * next_level + 150 * next_level + 100\
local dynasty_cost = 4 * next_level * next_level + 150 * next_level + 100                                                                                                                                                                                                return player_cost, dynasty_cost",
        [ "name" ] = "王朝技能攻击升耗",
    },
    [ "王朝技能暴击" ] = {
        [ "ch_key" ] = "王朝技能暴击",
        [ "lua" ] = "local attr_value = 4 * curr_level                                                                                                                                                                                                                                     return attr_value",
        [ "name" ] = "王朝技能暴击",
    },
    [ "王朝技能暴击升耗" ] = {
        [ "ch_key" ] = "王朝技能暴击升耗",
        [ "lua" ] = "local player_cost = 200 * next_level * next_level * next_level * next_level + 10000 * next_level\
local dynasty_cost = 200 * next_level * next_level * next_level * next_level + 10000 * next_level                                                                                                                                                                      return player_cost, dynasty_cost",
        [ "name" ] = "王朝技能暴击升耗",
    },
    [ "王朝技能生命" ] = {
        [ "ch_key" ] = "王朝技能生命",
        [ "lua" ] = "local attr_value = 480 * curr_level                                                                                                                                                                                                                                     return attr_value",
        [ "name" ] = "王朝技能生命",
    },
    [ "王朝技能生命升耗" ] = {
        [ "ch_key" ] = "王朝技能生命升耗",
        [ "lua" ] = "local player_cost = 4 * next_level * next_level + 150 * next_level + 100\
local dynasty_cost = 4 * next_level * next_level + 150 * next_level + 100                                                                                                                                                                                                return player_cost, dynasty_cost",
        [ "name" ] = "王朝技能生命升耗",
    },
    [ "王朝技能经验" ] = {
        [ "ch_key" ] = "王朝技能经验",
        [ "lua" ] = "local attr_value = 2 * curr_level                                                                                                                                                                                                                                     return attr_value",
        [ "name" ] = "王朝技能经验",
    },
    [ "王朝技能经验升耗" ] = {
        [ "ch_key" ] = "王朝技能经验升耗",
        [ "lua" ] = "local player_cost = 1000 * next_level * next_level\
local dynasty_cost = 1000 * next_level * next_level                                                                                                                                                                                                                       return player_cost, dynasty_cost",
        [ "name" ] = "王朝技能经验升耗",
    },
    [ "王朝技能闪避" ] = {
        [ "ch_key" ] = "王朝技能闪避",
        [ "lua" ] = "local attr_value = 4 * curr_level                                                                                                                                                                                                                                     return attr_value",
        [ "name" ] = "王朝技能闪避",
    },
    [ "王朝技能闪避升耗" ] = {
        [ "ch_key" ] = "王朝技能闪避升耗",
        [ "lua" ] = "local player_cost = 200 * next_level * next_level * next_level * next_level + 10000 * next_level\
local dynasty_cost = 200 * next_level * next_level * next_level * next_level + 10000 * next_level                                                                                                                                                                      return player_cost, dynasty_cost",
        [ "name" ] = "王朝技能闪避升耗",
    },
    [ "王朝技能防御" ] = {
        [ "ch_key" ] = "王朝技能防御",
        [ "lua" ] = "local attr_value = 36 * curr_level                                                                                                                                                                                                                                     return attr_value",
        [ "name" ] = "王朝技能防御",
    },
    [ "王朝技能防御升耗" ] = {
        [ "ch_key" ] = "王朝技能防御升耗",
        [ "lua" ] = "local player_cost = 4 * next_level * next_level + 150 * next_level + 100\
local dynasty_cost = 4 * next_level * next_level + 150 * next_level + 100                                                                                                                                                                                                return player_cost, dynasty_cost",
        [ "name" ] = "王朝技能防御升耗",
    },
    [ "英雄升星属性成长" ] = {
        [ "ch_key" ] = "英雄升星属性成长",
        [ "lua" ] = "local hero_data = GetData(\"HeroData\", hero_id)\
\
local base_role_define = GetData(\"GrowConstData\", \"base_role_define\")\
local quality_data = GetData(\"QualityData\", hero_data.quality)\
\
local cur_star_pct = quality_data[\"r_star_pct\" .. curr_star_lv]\
\
local role_q2p = quality_data.role_q2p\
local star_prop_pct = quality_data.r_star_prop_pct\
\
cur_star_pct = cur_star_pct * star_prop_pct\
\
local attr_dict = {\
    business = math.floor(base_role_define.star_business * cur_star_pct * hero_data.business_prefer_pct * role_q2p),\
    management = math.floor(base_role_define.star_management * cur_star_pct * hero_data.management_prefer_pct * role_q2p),\
    renown = math.floor(base_role_define.star_renown * cur_star_pct * hero_data.renown_prefer_pct * role_q2p),\
    fight = math.floor(base_role_define.star_fight * cur_star_pct * hero_data.fight_prefer_pct * role_q2p),\
    att = math.floor(base_role_define.star_att * cur_star_pct * hero_data.atk_prefer_pct * role_q2p),\
    def = math.floor(base_role_define.star_def * cur_star_pct * hero_data.defence_prefer_pct * role_q2p),\
    max_hp = math.floor(base_role_define.star_max_hp * cur_star_pct * hero_data.hp_prefer_pct * role_q2p)\
}\
return attr_dict",
        [ "name" ] = "英雄升星属性成长",
    },
    [ "英雄升星消耗" ] = {
        [ "ch_key" ] = "英雄升星消耗",
        [ "lua" ] = "local hero_data = GetData(\"HeroData\", hero_id)\
local unit_id = hero_data.unit_id\
local unit_data = GetData(\"UnitData\", unit_id)\
local quality_data = GetData(\"QualityData\", hero_data.quality)\
\
local s_consume_c0 = GetData(\"GrowConstData\", \"r_star_consume_c0\").i_value\
local s_consume_c1 = GetData(\"GrowConstData\", \"r_star_consume_c1\").i_value\
local s_consume_c2 = GetData(\"GrowConstData\", \"r_star_consume_c2\").i_value\
\
local q_scale = quality_data.consume_pct\
local lvl = next_star_lv\
\
local coin_num = math.ceil(q_scale*(s_consume_c2 * lvl * lvl + s_consume_c1 * lvl + s_consume_c0))\
\
local fragment_num = quality_data[\"r_star_frag_num\" .. lvl]\
\
return coin_num, fragment_num",
        [ "name" ] = "英雄升星消耗",
    },
    [ "英雄升级属性成长" ] = {
        [ "ch_key" ] = "英雄升级属性成长",
        [ "lua" ] = "local hero_data = GetData(\"HeroData\", hero_id)\
\
local base_role_define = GetData(\"GrowConstData\", \"base_role_define\")\
local quality_data = GetData(\"QualityData\", hero_data.quality)\
\
local base_round_num = GetData(\"GrowConstData\", \"base_round_num\").i_value\
local base_defence_pct = GetData(\"GrowConstData\", \"base_defence_pct\").f_value\
\
local role_q2p = quality_data.role_q2p\
\
local business = curr_level * base_role_define.b_grow_v\
local management = curr_level * base_role_define.m_grow_v\
local renown = curr_level * base_role_define.r_grow_v\
local fight = curr_level * base_role_define.f_grow_v\
local akt = curr_level * base_role_define.atk_grow_v\
local max_hp = curr_level * base_role_define.hp_grow_v\
local defence = 0\
\
local break_base_prop = 0\
local break_base_atk = 0\
local break_base_defence = 0\
local break_base_hp = 0\
\
if curr_break_lv > 0 and curr_level > 0 then\
    break_base_prop = base_role_define.brk_prop_base\
    break_base_atk = base_role_define.brk_atk_base\
    local cur_prop_add_v = 0\
    local cur_atk_add_v = 0\
    local break_2_lv = GetData(\"HeroBreakLvData\", curr_break_lv).level_limit\
    local pre_count_break_lv = break_2_lv <= curr_level and curr_break_lv or (curr_break_lv - 1)\
    for b_l = 2, pre_count_break_lv do\
        local b_last_lv = GetData(\"HeroBreakLvData\", b_l - 1).level_limit\
        local b_curr_lv = GetData(\"HeroBreakLvData\", b_l).level_limit\
        cur_prop_add_v = (base_role_define.brk_prop_add_v + base_role_define.brk_prop_add_acc * (b_l - 2))\
        cur_atk_add_v = (base_role_define.brk_atk_add_v + base_role_define.brk_atk_add_acc * (b_l - 2))\
        break_base_prop = break_base_prop +\
            b_l * base_role_define.brk_prop_base_mult * (b_curr_lv - b_last_lv + 1) +\
                cur_prop_add_v * (b_curr_lv - b_last_lv)\
        break_base_atk = break_base_atk +\
            b_l * base_role_define.brk_atk_base_mult * (b_curr_lv - b_last_lv + 1) +\
                cur_atk_add_v * (b_curr_lv - b_last_lv)\
    end\
    cur_prop_add_v = base_role_define.brk_prop_add_v + base_role_define.brk_prop_add_acc * (pre_count_break_lv - 1)\
    cur_atk_add_v = base_role_define.brk_atk_add_v + base_role_define.brk_atk_add_acc * (pre_count_break_lv - 1)\
    local cur_break2lvl = GetData(\"HeroBreakLvData\", pre_count_break_lv).level_limit\
    break_base_prop = break_base_prop + cur_prop_add_v * (curr_level - cur_break2lvl) +\
        curr_break_lv * base_role_define.brk_prop_base_mult * (curr_break_lv - pre_count_break_lv) * (curr_level - cur_break2lvl + 1)  -- 在查询下一突破等级属性时(当前等级不满足下一突破等级)，只加上Base差值\
    break_base_atk = break_base_atk + cur_atk_add_v * (curr_level - cur_break2lvl) +\
        curr_break_lv * base_role_define.brk_atk_base_mult * (curr_break_lv - pre_count_break_lv) * (curr_level - cur_break2lvl + 1)\
    break_base_defence = break_base_atk * base_defence_pct\
    break_base_hp = (break_base_atk - break_base_defence) * base_round_num\
end\
business = business + break_base_prop\
management = management + break_base_prop\
renown = renown + break_base_prop\
fight = fight + break_base_prop\
akt = akt + break_base_atk\
defence = defence + break_base_defence\
max_hp = max_hp + break_base_hp\
\
local attr_dict = {\
    business = math.floor(business * hero_data.business_prefer_pct * role_q2p),\
    management = math.floor(management * hero_data.management_prefer_pct * role_q2p),\
    renown = math.floor(renown * hero_data.renown_prefer_pct * role_q2p),\
    fight = math.floor(fight * hero_data.fight_prefer_pct * role_q2p),\
    att = math.floor(akt * hero_data.atk_prefer_pct * role_q2p),\
    def = math.floor(defence * hero_data.defence_prefer_pct * role_q2p),\
    max_hp = math.floor(max_hp * hero_data.hp_prefer_pct * role_q2p),\
}\
return attr_dict",
        [ "name" ] = "英雄升级属性成长",
    },
    [ "英雄升级消耗" ] = {
        [ "ch_key" ] = "英雄升级消耗",
        [ "lua" ] = "local hero_data = GetData(\"HeroData\", hero_id)\
local unit_id = hero_data.unit_id\
local unit_data = GetData(\"UnitData\", unit_id)\
local quality_data = GetData(\"QualityData\", hero_data.quality)\
\
local b_consume_c0 = GetData(\"GrowConstData\", \"r_lvlup_consume_c0\").i_value\
local b_consume_c1 = GetData(\"GrowConstData\", \"r_lvlup_consume_c1\").i_value\
local b_consume_c2 = GetData(\"GrowConstData\", \"r_lvlup_consume_c2\").i_value\
local b_consume_c3 = GetData(\"GrowConstData\", \"r_lvlup_consume_c3\").i_value\
\
local q_scale = quality_data.consume_pct\
\
local lvl = next_level - 1\
\
local cost_num = math.ceil(q_scale * (lvl * lvl * lvl * b_consume_c3 + lvl * lvl * b_consume_c2 + lvl * b_consume_c1 + b_consume_c0))\
\
return cost_num",
        [ "name" ] = "英雄升级消耗",
    },
    [ "英雄天命属性成长" ] = {
        [ "ch_key" ] = "英雄天命属性成长",
        [ "lua" ] = "local hero_data = GetData(\"HeroData\", hero_id)\
\
local base_destiny_pct = GetData(\"GrowConstData\", \"r_destiny_pct_base\").f_value\
\
local attr_dict = {\
    max_hp_pct = base_destiny_pct * (curr_destiny_lv - 1),\
    att_pct = base_destiny_pct * (curr_destiny_lv - 1),\
    def_pct = base_destiny_pct * (curr_destiny_lv - 1),\
}\
return attr_dict",
        [ "name" ] = "英雄天命属性成长",
    },
    [ "英雄突破消耗" ] = {
        [ "ch_key" ] = "英雄突破消耗",
        [ "lua" ] = "local hero_data = GetData(\"HeroData\", hero_id)\
local unit_id = hero_data.unit_id\
local unit_data = GetData(\"UnitData\", unit_id)\
local quality_data = GetData(\"QualityData\", hero_data.quality)\
\
local b_consume_c0 = GetData(\"GrowConstData\", \"r_break_consume_c0\").i_value\
local b_consume_c1 = GetData(\"GrowConstData\", \"r_break_consume_c1\").i_value\
local b_consume_c2 = GetData(\"GrowConstData\", \"r_break_consume_c2\").i_value\
local b_consume_c3 = GetData(\"GrowConstData\", \"r_break_consume_c3\").i_value\
\
local break_frag_lvl = GetData(\"GrowConstData\", \"r_break_fragment_lvl\").i_value\
\
local b_stone_c0 = quality_data.r_break_stone_c0\
local b_stone_c1 = quality_data.r_break_stone_c1\
local b_stone_c2 = quality_data.r_break_stone_c2\
local b_stone_c3 = quality_data.r_break_stone_c3\
\
local lvl = next_break_lv\
\
local q_scale = quality_data.consume_pct\
\
local coin_num = math.ceil(q_scale*(b_consume_c3 * lvl * lvl * lvl + b_consume_c2 * lvl * lvl + b_consume_c1 * lvl + b_consume_c0))\
\
local stone_num = math.ceil(q_scale * (b_stone_c3 * lvl * lvl * lvl + b_stone_c2 * lvl * lvl + b_stone_c1 * lvl + b_stone_c0))\
local fragment_num\
-- 突破等级到达8级才会消耗碎片\
if next_break_lv >= break_frag_lvl then\
    fragment_num = (next_break_lv - break_frag_lvl) * quality_data.break_frag_add + quality_data.break_init_frag_num\
end\
\
if fragment_num == 0 then\
    fragment_num = nil\
end\
\
return coin_num, stone_num, fragment_num",
        [ "name" ] = "英雄突破消耗",
    },
    [ "装备升星属性成长" ] = {
        [ "ch_key" ] = "装备升星属性成长",
        [ "lua" ] = "local item_data = GetData(\"ItemData\", item_id)\
local quality_data = GetData(\"QualityData\", item_data.quality)\
local red_quality_data = GetData(\"QualityData\", 5)\
local base_equip_define = GetData(\"GrowConstData\", \"base_equip_define\")\
\
local q_scale = quality_data.equip_q2p\
local star_base_pct = quality_data.e_star_base_pct\
local max_star_lvl = quality_data.e_max_star_lvl\
local max_star_pct = red_quality_data[\"e_star_pct\" .. max_star_lvl]\
\
local part_tb = {\
    [1] = {name = \"base_lvl_att\", prop_name = \"att\", pct = 1},                  -- weapon\
    [2] = {name = \"base_lvl_max_hp\", prop_name = \"max_hp\", pct =0.5},           -- hat\
    [3] = {name = \"base_lvl_max_hp\", prop_name = \"max_hp\", pct = 0.5},          -- belt\
    [4] = {name = \"base_lvl_def\", prop_name = \"def\", pct = 1},                  -- cloth\
}\
\
local prop_pct = q_scale * star_base_pct * max_star_pct * quality_data[\"e_star_pct\" .. curr_star_lv] * part_tb[item_data.part_index].pct\
\
\
local attr_dict = {\
    [part_tb[item_data.part_index].prop_name] = math.floor(prop_pct * base_equip_define[part_tb[item_data.part_index].name])\
}\
\
return attr_dict",
        [ "name" ] = "装备升星属性成长",
    },
    [ "装备升星消耗" ] = {
        [ "ch_key" ] = "装备升星消耗",
        [ "lua" ] = "local item_data = GetData(\"ItemData\", item_id)\
local quality_data = GetData(\"QualityData\", item_data.quality)\
\
local b_consume_c0 = GetData(\"GrowConstData\", \"e_star_consume_c0\").i_value\
local b_consume_c1 = GetData(\"GrowConstData\", \"e_star_consume_c1\").i_value\
local b_consume_c2 = GetData(\"GrowConstData\", \"e_star_consume_c2\").i_value\
local b_consume_c3 = GetData(\"GrowConstData\", \"e_star_consume_c3\").i_value\
\
local lvl = next_star_lv\
local q_scale = quality_data.consume_pct\
\
local cost_num = math.ceil(q_scale * (b_consume_c3 * lvl * lvl * lvl + b_consume_c2 * lvl * lvl + b_consume_c1 * lvl + b_consume_c0))\
local fragment_num = quality_data[\"e_star_frag_num\" .. lvl]\
\
return cost_num, fragment_num",
        [ "name" ] = "装备升星消耗",
    },
    [ "装备强化消耗" ] = {
        [ "ch_key" ] = "装备强化消耗",
        [ "lua" ] = "local item_data = GetData(\"ItemData\", item_id)\
local quality_data = GetData(\"QualityData\", item_data.quality)\
local b_consume_c0 = GetData(\"GrowConstData\", \"e_lvlup_consume_c0\").f_value\
local b_consume_c1 = GetData(\"GrowConstData\", \"e_lvlup_consume_c1\").f_value\
local b_consume_c2 = GetData(\"GrowConstData\", \"e_lvlup_consume_c2\").f_value\
local b_consume_c3 = GetData(\"GrowConstData\", \"e_lvlup_consume_c3\").f_value\
\
\
local lvl = next_strengthen_lv\
local q_scale = quality_data.consume_pct\
\
local cost_num = math.ceil(q_scale * (b_consume_c3 * lvl * lvl * lvl + b_consume_c2 * lvl * lvl + b_consume_c1 * lvl + b_consume_c0))\
\
return cost_num",
        [ "name" ] = "装备强化消耗",
    },
    [ "装备炼化消耗" ] = {
        [ "ch_key" ] = "装备炼化消耗",
        [ "lua" ] = "local item_data = GetData(\"ItemData\", item_id)\
local quality_data = GetData(\"QualityData\", item_data.quality)\
local base_equip_define = GetData(\"GrowConstData\", \"base_equip_define\")\
\
local q_scale = quality_data.consume_pct\
\
local coin_num = base_equip_define[\"smelt_money_lvl\" .. next_smelt_lv] --and math.ceil(q_scale * base_equip_define[\"smelt_money_lvl\" .. next_smelt_lv]) or nil\
local diamond_num = base_equip_define[\"smelt_diamond_lvl\" .. next_smelt_lv] --and math.ceil(q_scale * base_equip_define[\"smelt_diamond_lvl\" .. next_smelt_lv]) or nil\
local fragment_num = base_equip_define[\"smelt_frag_lvl\" .. next_smelt_lv] --and math.ceil(q_scale * base_equip_define[\"smelt_frag_lvl\" .. next_smelt_lv]) or nil\
\
-- 消耗三选一\
return coin_num, diamond_num, fragment_num",
        [ "name" ] = "装备炼化消耗",
    },
}