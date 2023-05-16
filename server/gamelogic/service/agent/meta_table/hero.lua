local role_hero = DECLARE_MODULE("meta_table.hero")
local cluster_utils = require("msg_utils.cluster_utils")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local attr_utils = require("attr_utils")
local role_utils = require("role_utils")
local CSFunction = require("CSCommon.CSFunction")
local json = require "cjson"

local TENLEVEL = 10
local OTHERSHOPNUM = 2

function role_hero.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
        shop_refresh_num_timer = nil
    }
    return setmetatable(self, role_hero)
end

function role_hero:init_hero()
    local hero_shop = self.db.hero_shop
    hero_shop.refresh_ts = date.time_second()
    local data = excel_data.ShopData["HeroShop"]
    hero_shop.free_refresh_num = data.free_refresh_num
    hero_shop.total_refresh_num = data.total_refresh_num
    self:_refresh_hero_shop()
end

function role_hero:load_hero()
    local hero_dict = self.db.hero_dict
    local attr_dict = {}
    for hero_id, hero_info in pairs(hero_dict) do
        self:refresh_hero_attr(hero_info)
        table.dict_attr_add(attr_dict, hero_info.attr_dict)
    end
    self.role:updata_fight_score()
    self.role:modify_attr(nil, attr_dict)

    local hero_shop = self.db.hero_shop
    local data = excel_data.ShopData["HeroShop"]
    if hero_shop.free_refresh_num < data.free_refresh_num then
        local now = date.time_second()
        local recover_time = data.loop_refresh_time * CSConst.Time.Minute
        local add_num = math.floor((now - hero_shop.refresh_ts) / recover_time)
        local total_num = add_num + hero_shop.free_refresh_num
        if total_num < data.free_refresh_num then
            hero_shop.free_refresh_num = total_num
            hero_shop.refresh_ts = hero_shop.refresh_ts + recover_time * add_num
            local delay = recover_time - (now - hero_shop.refresh_ts) % recover_time
            self.shop_refresh_num_timer = self.role:timer_loop(recover_time, function()
                self:shop_refresh_num_recover()
            end, delay)
        else
            hero_shop.free_refresh_num = data.free_refresh_num
            hero_shop.refresh_ts = now
        end
    end
end

-- 刷新英雄属性
function role_hero:refresh_hero_attr(hero_info)
    hero_info.score = 0
    hero_info.attr_dict = {}
    hero_info.raw_attr_dict = {}
    local raw_attr_dict = hero_info.raw_attr_dict
    local hero_id = hero_info.hero_id

    -- 基础属性
    table.dict_attr_add(raw_attr_dict, attr_utils.get_hero_init_attr())
    -- 升级属性
    table.dict_attr_add(raw_attr_dict, CSFunction.get_hero_level_attr(hero_id, hero_info.level, hero_info.break_lv))
    -- 升星属性
    table.dict_attr_add(raw_attr_dict, CSFunction.get_hero_star_attr(hero_id, hero_info.star_lv))
    -- 天命属性
    table.dict_attr_add(raw_attr_dict, CSFunction.get_hero_destiny_attr(hero_id, hero_info.destiny_lv))
    -- 突破属性
    if hero_info.break_lv > 0 then
        local hero_data = excel_data.HeroData[hero_id]
        for break_lv = 1, hero_info.break_lv do
            local talent_id = hero_data.talent[break_lv]
            if talent_id then
                local talent_data = excel_data.TalentData[talent_id]
                if talent_data.talent_type == CSConst.HeroTalentType.OwnAttr then
                    table.dict_attr_add(raw_attr_dict, talent_data.attr_dict)
                end
            end
        end
    end
    -- 缘分属性
    table.dict_attr_add(raw_attr_dict, CSFunction.get_hero_fate_attr(hero_info.fate_dict))
    -- 情人系统属性
    table.dict_attr_add(raw_attr_dict, self:get_hero_lover_attr(hero_id))
    -- 称号系统属性
    table.dict_attr_add(raw_attr_dict, self.role:get_hero_title_attr())

    hero_info.attr_dict = attr_utils.refresh_all_attr(raw_attr_dict)
    hero_info.score = attr_utils.eval_hero_score(hero_info.attr_dict)
end

-- 获取情人系统增加的英雄属性
function role_hero:get_hero_lover_attr(hero_id)
    local lover_dict = self.role:get_lover_dict()
    local attr_dict = {}
    for lover_id, lover_info in pairs(lover_dict) do
        local lover_data = excel_data.LoverData[lover_id]
        -- 情人技能增加属性
        for spell_id, spell_level in pairs(lover_info.spell_dict) do
            local spell_data = excel_data.LoverSpellData[spell_id]
            if spell_data.is_all or lover_data.hero_dict[hero_id] then
                for i, attr_name in ipairs(spell_data.attr_list) do
                    attr_dict[attr_name] = (attr_dict[attr_name] or 0) + spell_level * spell_data.attr_ratio[i]
                end
            end
        end
        -- 情人升星增加属性
        if lover_data.hero_dict[hero_id] then
            table.dict_attr_add(attr_dict, CSFunction.get_lover_star_attr(lover_id, lover_info.star_lv))
        end
    end
    return attr_dict
end

function role_hero:online_hero()
    self.role:send_client("s_online_hero", {all_hero = self.db.hero_dict})
    self.role:send_client("s_update_hero_shop", self.db.hero_shop)
end

function role_hero:daily_hero()
    local hero_dict = self.db.hero_dict
    -- 每天英雄天命值清零
    for hero_id, hero_info in pairs(hero_dict) do
        if hero_info.destiny_exp > 0 then
            hero_info.destiny_exp = 0
        end
    end
    self.role:send_client("s_clear_hero_destiny_exp", {})

    local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.HeroshopRefresh)
    local data = excel_data.ShopData["HeroShop"]
    local hero_shop = self.db.hero_shop
    hero_shop.total_refresh_num = data.total_refresh_num + extra_num
    self.role:send_client("s_update_hero_shop", hero_shop)
end

-- 增加一个新英雄
function role_hero:add_hero(hero_id)
    if not hero_id then return end
    local hero_data = excel_data.HeroData[hero_id]
    if not hero_data then return end
    if self.db.hero_dict[hero_id] then return end

    self.db.hero_dict[hero_id] = {hero_id = hero_id}
    local hero_info = self.db.hero_dict[hero_id]
    self:refresh_hero_attr(hero_info)
    self.role:modify_attr(nil, hero_info.attr_dict)
    self.role:send_score_msg()
    for _, spell_id in pairs(hero_data.spell) do
        hero_info.spell_dict[spell_id] = 1
    end
    self.role:update_task(CSConst.TaskType.HeroNum)
    self.role:update_achievement(CSConst.AchievementType.HeroNum)
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.DestinyLevel, 1)

    self.role:send_client("s_add_hero", {hero_info = hero_info})
    self.role:log("AddHero", {hero_info = hero_info})
    return true
end

-- 提升英雄等级
function role_hero:upgrade_hero_level(hero_id, ten_level)
    if not hero_id then return end
    local hero_info = self.db.hero_dict[hero_id]
    if not hero_info then return end
    local old_level = hero_info.level
    local new_level
    if ten_level then
        new_level = old_level + TENLEVEL
    else
        new_level = old_level + 1
    end
    local role_level = self.role:get_level()
    local level_limit = CSFunction.get_hero_level_limit(role_level)
    new_level = new_level > level_limit and level_limit or new_level
    if new_level == old_level then return end
    local item_dict = CSFunction.get_hero_level_cost(hero_id, old_level, new_level)
    if not self.role:consume_item_dict(item_dict, g_reason.hero_lvlup) then return end
    hero_info.level = new_level
    self:on_hero_level_up(hero_info, old_level, new_level)

    self.role:send_client("s_update_hero_info", {
        hero_id = hero_id,
        level = hero_info.level
    })
    self.role:log("HeroLevelUp", {hero_id = hero_id, old_level = old_level, new_level = new_level})
    return true
end

function role_hero:on_hero_level_up(db_hero, old_level, new_level)
    self:modify_attr_by_level(db_hero, old_level, new_level)
    self.role:update_daily_active(CSConst.DailyActiveTaskType.LevelUpNero, new_level - old_level)
    self.role:update_task(CSConst.TaskType.HeroLevel)
    self.role:update_achievement(CSConst.AchievementType.HeroLevel)
end

function role_hero:modify_attr_by_level(db_hero, old_level, new_level)
    local hero_id = db_hero.hero_id
    local old_attr_dict = CSFunction.get_hero_level_attr(hero_id, old_level, db_hero.break_lv)
    local new_attr_dict = CSFunction.get_hero_level_attr(hero_id, new_level, db_hero.break_lv)
    self:modify_hero_attr(hero_id, old_attr_dict, new_attr_dict, true)
    self.role:send_score_msg()
end

-- 修改英雄属性
function role_hero:modify_hero_attr(hero_id, old_attr_dict, new_attr_dict, not_notify)
    local attr_diff_dict = role_utils.get_attr_dict_diff(old_attr_dict, new_attr_dict)
    if not attr_diff_dict or not next(attr_diff_dict) then return end
    local db_hero = self.db.hero_dict[hero_id]
    if not db_hero then return end

    local ret = {}
    local raw_attr_dict = db_hero.raw_attr_dict
    for attr_name, attr_value in pairs(attr_diff_dict) do
        raw_attr_dict[attr_name] = (raw_attr_dict[attr_name] or 0) + attr_value
        table.update(ret, attr_utils.on_modify_raw(raw_attr_dict, attr_name))
    end
    local modify_attr_dict = {}
    local attr_dict = db_hero.attr_dict
    for attr_name, attr_value in pairs(ret) do
        modify_attr_dict[attr_name] = attr_value - attr_dict[attr_name]
        attr_dict[attr_name] = attr_value
    end
    -- 修改英雄属性同步到人物属性上
    self.role:modify_attr(nil, modify_attr_dict)

    db_hero.score = attr_utils.eval_hero_score(attr_dict)
    if self.role:get_hero_lineup_id(db_hero.hero_id) then
        self.role:updata_fight_score(not_notify)
    end

    self.role:send_client("s_update_hero_info", {
        hero_id = db_hero.hero_id,
        attr_dict = attr_dict,
        score = db_hero.score
    })
    self.role:log("ModifyHeroAttr", {hero_id = db_hero.hero_id, attr_diff_dict = attr_diff_dict, result = ret})
end

-- 获取所有英雄战力之和
function role_hero:get_all_hero_score()
    local total_score = 0
    for _, hero_info in pairs(self.db.hero_dict) do
        total_score = total_score + hero_info.score
    end
    return total_score
end

-- 英雄突破
function role_hero:hero_breakthrough(hero_id)
    if not hero_id then return end
    local hero_info = self.db.hero_dict[hero_id]
    if not hero_info then return end
    local old_break_lv = hero_info.break_lv
    local break_data = excel_data.HeroBreakLvData
    if old_break_lv >= #break_data then return end
    local new_break_lv = old_break_lv + 1
    if hero_info.level < break_data[new_break_lv].level_limit then return end

    local item_dict = CSFunction.get_hero_break_cost(hero_id, new_break_lv)
    if not self.role:consume_item_dict(item_dict, g_reason.hero_breakthrough) then return end
    hero_info.break_lv = new_break_lv
    self:on_hero_breakthrough(hero_info, old_break_lv, new_break_lv)

    self.role:send_client("s_update_hero_info", {
        hero_id = hero_id,
        break_lv = hero_info.break_lv
    })
    self.role:log("HeroBreakLvUp", {hero_id = hero_id, old_break_lv = old_break_lv, new_break_lv = new_break_lv})
    return true
end

function role_hero:on_hero_breakthrough(db_hero, old_break_lv, new_break_lv)
    -- 突破属性, 突破主要是影响升级属性
    local old_attr_dict = {}
    local new_attr_dict = {}
    table.dict_attr_add(old_attr_dict, CSFunction.get_hero_level_attr(db_hero.hero_id, db_hero.level, old_break_lv))
    table.dict_attr_add(new_attr_dict, CSFunction.get_hero_level_attr(db_hero.hero_id, db_hero.level, new_break_lv))
    -- 天赋属性
    local HeroData = excel_data.HeroData
    local hero_data = HeroData[db_hero.hero_id]
    local talent_id = hero_data.talent[new_break_lv]
    if talent_id then
        local talent_data = excel_data.TalentData[talent_id]
        if talent_data.talent_type == CSConst.HeroTalentType.OwnAttr then
            -- 给自己加属性
            table.dict_attr_add(new_attr_dict, talent_data.attr_dict)
        elseif talent_data.talent_type == CSConst.HeroTalentType.AllAttr then
            -- 给所有出战英雄加属性（包括自己）
            if self.role:get_hero_lineup_id(db_hero.hero_id) then
                -- 需要自己出战才生效
                local lineup_dict = self.db.lineup_dict
                for _, lineup_info in pairs(lineup_dict) do
                    local hero_id = lineup_info.hero_id
                    if hero_id then
                        local attr_dict = {}
                        table.dict_attr_add(attr_dict, talent_data.attr_dict)
                        if talent_data.extra_attr_dict then
                            if hero_data.power == HeroData[hero_id].power then
                                -- 相同势力，属性有额外加成
                                table.dict_attr_add(attr_dict, talent_data.extra_attr_dict)
                            end
                        end
                        self:modify_hero_attr(hero_id, nil, attr_dict, true)
                    end
                end
            end
        end
    end
    self:modify_hero_attr(db_hero.hero_id, old_attr_dict, new_attr_dict, true)
    self.role:send_score_msg()

    -- 激活超合击
    local super_spell_break_lv = excel_data.ParamData["hero_super_spell_break_lv"].f_value
    if new_break_lv == super_spell_break_lv then
        for spell_id, spell_level in pairs(db_hero.spell_dict) do
            local spell_data = excel_data.SpellData[spell_id]
            if spell_data.super_spell_id then
                -- 把合击技能替换成超合击技能
                db_hero.spell_dict[spell_data.super_spell_id] = spell_level
                db_hero.spell_dict[spell_id] = nil
                self.role:send_client("s_update_hero_info", {
                    hero_id = hero_id,
                    spell_dict = db_hero.spell_dict
                })
                break
            end
        end
    end

    self.role:update_task(CSConst.TaskType.HeroBreak)
end

-- 清除或添加出战英雄增加的天赋属性
function role_hero:change_lineup_hero_talent_attr(hero_id, is_clear)
    local db_hero = self.db.hero_dict[hero_id]
    if not db_hero then return end
    local lineup_dict = self.db.lineup_dict
    local HeroData = excel_data.HeroData

    -- 自己对他人的属性
    if db_hero.break_lv > 0 then
        for _, lineup_info in pairs(lineup_dict) do
            if lineup_info.hero_id and lineup_info.hero_id ~= hero_id then
                local hero_data = HeroData[lineup_info.hero_id]
                local attr_dict = self:get_add_talent_attr(hero_id, hero_data.power)
                if is_clear then
                    self:modify_hero_attr(lineup_info.hero_id, attr_dict, nil, true)
                else
                    self:modify_hero_attr(lineup_info.hero_id, nil, attr_dict, true)
                end
            end
        end
    end

    -- 他人对自己的属性（包括自己对自己的属性）
    local attr_dict = {}
    local hero_data = HeroData[hero_id]
    for _, lineup_info in pairs(lineup_dict) do
        if lineup_info.hero_id then
            table.dict_attr_add(attr_dict, self:get_add_talent_attr(lineup_info.hero_id, hero_data.power))
        end
    end
    if is_clear then
        self:modify_hero_attr(hero_id, attr_dict, nil, true)
    else
        self:modify_hero_attr(hero_id, nil, attr_dict, true)
    end
end

-- 获取出战英雄增加的天赋属性
function role_hero:get_add_talent_attr(hero_id, self_power)
    local hero_info = self.db.hero_dict[hero_id]
    local hero_data = excel_data.HeroData[hero_id]
    local attr_dict = {}
    if hero_info.break_lv > 0 then
        for break_lv = 1, hero_info.break_lv do
            local talent_id = hero_data.talent[break_lv]
            if talent_id then
                local talent_data = excel_data.TalentData[talent_id]
                if talent_data.talent_type == CSConst.HeroTalentType.AllAttr then
                    -- 给所有出战英雄加属性
                    table.dict_attr_add(attr_dict, talent_data.attr_dict)
                    if talent_data.extra_attr_dict then
                        if hero_data.power == self_power then
                            -- 相同势力，属性有额外加成
                            table.dict_attr_add(attr_dict, talent_data.extra_attr_dict)
                        end
                    end
                end
            end
        end
    end
    return attr_dict
end

-- 英雄升星
function role_hero:upgrade_hero_star_lv(hero_id)
    if not hero_id then return end
    local hero_info = self.db.hero_dict[hero_id]
    if not hero_info then return end
    local old_star_lv = hero_info.star_lv
    local max_level = excel_data.ParamData["hero_star_lv_limit"].f_value
    if old_star_lv >= max_level then return end

    local new_star_lv = old_star_lv + 1
    local item_dict = CSFunction.get_hero_star_cost(hero_id, new_star_lv)
    if not self.role:consume_item_dict(item_dict, g_reason.upgrade_hero_star_lv) then return end
    hero_info.star_lv = new_star_lv
    local old_attr_dict = CSFunction.get_hero_star_attr(hero_id, old_star_lv)
    local new_attr_dict = CSFunction.get_hero_star_attr(hero_id, new_star_lv)
    self:modify_hero_attr(hero_id, old_attr_dict, new_attr_dict, true)
    self.role:send_score_msg()

    self.role:send_client("s_update_hero_info", {
        hero_id = hero_id,
        star_lv = hero_info.star_lv
    })
    self.role:log("HeroStarLvUp", {hero_id = hero_id, old_star_lv = old_star_lv, new_star_lv = new_star_lv})
    return true
end

-- 英雄天命升级
function role_hero:upgrade_hero_destiny_lv(hero_id)
    if not hero_id then return end
    local hero_info = self.db.hero_dict[hero_id]
    if not hero_info then return end
    local old_destiny_lv = hero_info.destiny_lv
    if old_destiny_lv >= #excel_data.HeroDestinyData then return end
    local destiny_data = excel_data.HeroDestinyData[old_destiny_lv]
    local cost_item = excel_data.ParamData["hero_destiny_cost_item"].item_id
    if not self.role:consume_item(cost_item, destiny_data.cost_num, g_reason.upgrade_hero_destiny_lv) then return end

    hero_info.destiny_exp = hero_info.destiny_exp + destiny_data.cost_num
    hero_info.destiny_curr_cost = hero_info.destiny_curr_cost + destiny_data.cost_num
    local new_destiny_lv
    if self:check_destiny_level_up(destiny_data, hero_info.destiny_exp) then
        -- 升级成功
        hero_info.destiny_lv = hero_info.destiny_lv + 1
        hero_info.destiny_exp = 0
        new_destiny_lv = hero_info.destiny_lv
        hero_info.destiny_lv_cost = hero_info.destiny_lv_cost + hero_info.destiny_curr_cost
        hero_info.destiny_curr_cost = 0
        local old_attr_dict = CSFunction.get_hero_destiny_attr(hero_id, old_destiny_lv)
        local new_attr_dict = CSFunction.get_hero_destiny_attr(hero_id, new_destiny_lv)
        self:modify_hero_attr(hero_id, old_attr_dict, new_attr_dict)
        -- 天命会提升英雄技能等级
        self:upgrade_hero_spell(hero_id)
        self.role:update_task(CSConst.TaskType.HeroDestiny)
        self.role:update_achievement(CSConst.AchievementType.HeroDestiny)
        self.role:update_first_week_task(CSConst.FirstWeekTaskType.DestinyLevel, new_destiny_lv)
        self.role:log("HeroDestinyLvUp", {hero_id = hero_id, old_destiny_lv = old_destiny_lv, new_destiny_lv = new_destiny_lv})
    end

    self.role:send_client("s_update_hero_info", {
        hero_id = hero_id,
        destiny_exp = hero_info.destiny_exp,
        destiny_lv = new_destiny_lv,
        destiny_lv_cost = hero_info.destiny_lv_cost
    })
    return true
end

-- 检查天命升级是否成功
function role_hero:check_destiny_level_up(destiny_data, destiny_exp)
    -- 天命经验达到上限，直接升级成功
    if destiny_exp >= destiny_data.exp_limit then return true end
    -- 概率提升
    local rate = 0
    for i, exp in ipairs(destiny_data.upgrade_range) do
        if destiny_exp < exp then break end
        rate = destiny_data.upgrade_rate[i]
    end
    if math.random() < rate then
        return true
    end
end

-- 提升英雄技能等级
function role_hero:upgrade_hero_spell(hero_id)
    local spell_dict = self.db.hero_dict[hero_id].spell_dict
    local hero_data = excel_data.HeroData[hero_id]
    for i, spell_id in ipairs(hero_data.destiny_spell_list) do
        if spell_dict[spell_id] then
            spell_dict[spell_id] = spell_dict[spell_id] + 1
        else
            local spell_data = excel_data.SpellData[spell_id]
            if spell_data.super_spell_id and spell_dict[spell_data.super_spell_id] then
                spell_dict[spell_data.super_spell_id] = spell_dict[spell_data.super_spell_id] + 1
            end
        end
    end

    self.role:send_client("s_update_hero_info", {
        hero_id = hero_id,
        spell_dict = spell_dict
    })
end

-- 英雄重生
function role_hero:hero_recover(hero_id)
    if not hero_id then return end
    local hero_dict = self.db.hero_dict
    local hero_info = hero_dict[hero_id]
    if not hero_info then return end
    if self.role:get_hero_lineup_id(hero_id) then return end
    local cost_data = excel_data.ParamData["hero_recover_cost"]
    if not self.role:consume_item(cost_data.item_id, cost_data.count, g_reason.hero_recover) then return end
    hero_dict[hero_id] = nil
    local item_dict = CSFunction.get_hero_recover_item(hero_info)
    self.role:add_item_dict(item_dict, g_reason.hero_recover)
    self.role:modify_attr(hero_info.attr_dict)
    self.role:send_score_msg()
    return true
end

-- 判断英雄是否穿戴某件装备
function role_hero:is_wear_equip(hero_id, equip_id)
    local lineup_id = self.role:get_hero_lineup_id(hero_id)
    if not lineup_id then return end
    local lineup_info = self.role:get_lineup_info()
    for _, v in pairs(lineup_info[lineup_id].equip_info_dict) do
        if v.item_id == equip_id then
            return true
        end
    end
end

-- 刷新英雄缘分
function role_hero:refresh_fate(hero_id)
    local hero_info = self.db.hero_dict[hero_id]
    if not hero_info then return end
    local old_attr_dict = CSFunction.get_hero_fate_attr(hero_info.fate_dict)
    local flag
    if self.role:get_hero_lineup_id(hero_id) then
        local fate_list = excel_data.HeroData[hero_id].fate or {}
        for _, fate_id in ipairs(fate_list) do
            local fate_data = excel_data.FateData[fate_id]
            if fate_data.fate_hero and (self.role:get_hero_lineup_id(fate_data.fate_hero)
                or self.role:get_reinforcements_pos_id(fate_data.fate_hero)) then
                if not hero_info.fate_dict[fate_id] then
                    flag = true
                    hero_info.fate_dict[fate_id] = true
                end
            elseif fate_data.fate_item and self:is_wear_equip(hero_id, fate_data.fate_item) then
                if not hero_info.fate_dict[fate_id] then
                    flag = true
                    hero_info.fate_dict[fate_id] = true
                end
            else
                if hero_info.fate_dict[fate_id] then
                    flag = true
                    hero_info.fate_dict[fate_id] = nil
                end
            end
        end
    end
    if not flag then return end
    local new_attr_dict = CSFunction.get_hero_fate_attr(hero_info.fate_dict)
    self:modify_hero_attr(hero_id, old_attr_dict, new_attr_dict, true)
    self.role:send_client("s_update_hero_info", {
        hero_id = hero_id,
        fate_dict = hero_info.fate_dict
    })
end

-- 赠送英雄物品
function role_hero:give_hero_item(hero_id, item_id, item_count)
    if not hero_id or not item_id or not item_count then return end
    local hero_info = self.db.hero_dict[hero_id]
    if not hero_info then return end
    local item_data = excel_data.ItemData[item_id]
    if not item_data then return end
    if not item_data.random_attr_list then return end
    if not self.role:consume_item(item_id, item_count, g_reason.hero_give_item) then return end

    local attr_dict = {}
    for i = 1, item_count do
        local index = math.random(1, #item_data.random_attr_list)
        local attr_name = item_data.random_attr_list[index]
        local value = item_data.random_attr_value_list[index]
        attr_dict[attr_name] = (attr_dict[attr_name] or 0) + value
        hero_info.book_attr_dict[attr_name] = (hero_info.book_attr_dict[attr_name] or 0) + value
    end
    hero_info.book_num = hero_info.book_num + item_count
    self.role:update_task(CSConst.TaskType.HeroBook)
    self.role:update_task(CSConst.TaskType.HeroAllBook, {progress = item_count})
    self:modify_hero_attr(hero_id, nil, attr_dict, true)
    self.role:send_score_msg()
    self.role:send_client("s_update_hero_info", {
        hero_id = hero_id,
        book_attr_dict = hero_info.book_attr_dict
    })
    return true
end

function role_hero:shop_refresh_num_recover()
    local hero_shop = self.db.hero_shop
    local data = excel_data.ShopData["HeroShop"]
    if hero_shop.free_refresh_num < data.free_refresh_num then
        hero_shop.free_refresh_num = hero_shop.free_refresh_num + 1
        hero_shop.refresh_ts = date.time_second()
        self.role:send_client("s_update_hero_shop", hero_shop)
    end
    if hero_shop.free_refresh_num >= data.free_refresh_num then
        self.shop_refresh_num_timer:cancel()
        self.shop_refresh_num_timer = nil
    end
end

-- 刷新头目商店
function role_hero:refresh_hero_shop()
    local hero_shop = self.db.hero_shop
    local data = excel_data.ShopData["HeroShop"]
    if hero_shop.total_refresh_num <= 0 then return end
    if hero_shop.free_refresh_num > 0 then
        hero_shop.free_refresh_num = hero_shop.free_refresh_num - 1
        if hero_shop.free_refresh_num < data.free_refresh_num then
            if not self.shop_refresh_num_timer then
                hero_shop.refresh_ts = date.time_second()
                local recover_time = data.loop_refresh_time * CSConst.Time.Minute
                self.shop_refresh_num_timer = self.role:timer_loop(recover_time, function()
                    self:shop_refresh_num_recover()
                end)
            end
        end
    else
        if not self.role:consume_item(data.refresh_item, data.refresh_price, g_reason.refresh_hero_shop) then return end
    end
    hero_shop.total_refresh_num = hero_shop.total_refresh_num - 1
    self:_refresh_hero_shop()
    self.role:send_client("s_update_hero_shop", hero_shop)
    return true
end

function role_hero:_refresh_hero_shop()
    local hero_shop = self.db.hero_shop
    hero_shop.shop_dict = {}
    local role_level = self.role:get_level()
    local shop_data = excel_data.HeroShopData
    local weight_table = {}
    for key, v in pairs(shop_data.other_shop) do
        if v.open_level and role_level >= v.open_level then
            weight_table[key] = v.weight
        end
    end
    for i = 1, OTHERSHOPNUM do
        local shop_id = math.roll(weight_table)
        hero_shop.shop_dict[shop_id] = 0
        weight_table[shop_id] = nil
    end
    weight_table = {}
    for key, v in pairs(shop_data.hero_shop) do
        if v.open_level and role_level >= v.open_level then
            weight_table[key] = v.weight
        end
    end
    local data = excel_data.ShopData["HeroShop"]
    local num = data.refresh_item_num - OTHERSHOPNUM
    for i = 1, num do
        local shop_id = math.roll(weight_table)
        hero_shop.shop_dict[shop_id] = 0
        weight_table[shop_id] = nil
    end
end

function role_hero:buy_hero_shop_item(shop_id)
    local hero_shop = self.db.hero_shop
    if not shop_id then return end
    local data = excel_data.HeroShopData[shop_id]
    if not data then return end
    if not hero_shop.shop_dict[shop_id] or hero_shop.shop_dict[shop_id] >= 1 then return end
    if not self.role:consume_item_list(data.cost_item_list, g_reason.hero_shop) then return end
    hero_shop.shop_dict[shop_id] = hero_shop.shop_dict[shop_id] + 1
    self.role:add_item(data.item_id, data.item_count, g_reason.hero_shop)
    self.role:send_client("s_update_hero_shop", hero_shop)
    self.role:gaea_log("ShopConsume", {
        itemId = data.item_id,
        itemCount = data.item_count,
        consume = data.cost_item_list
    })
    return true
end

-- vip升级获得额外商店刷新次数次数
function role_hero:vip_level_up_privilege_heroshop_num(old_level, new_level)
    local old_level_info = excel_data.VipData[old_level]
    local new_level_info = excel_data.VipData[new_level]
    local lock_info = excel_data.VIPPrivilegeData
    local lock_name = lock_info[CSConst.VipPrivilege.HeroshopRefresh].vip_data_name
    local extra_num = new_level_info[lock_name]
    if old_level > 0 then extra_num = extra_num - old_level_info[lock_name] end
    local hero_shop = self.db.hero_shop
    hero_shop.total_refresh_num = hero_shop.total_refresh_num + extra_num
    self.role:send_client("s_update_hero_shop", hero_shop)
end

---------------------------------------------------------   排行榜
-- 获取跨服战力排行榜
function role_hero:get_rank()
    local rank_info = cluster_utils.call_cross_rank("lc_get_rank_list", "cross_fight_score_rank", self.uuid)
    return rank_info
end

-- 获取跨服战力排行榜
function role_hero:get_cross_score_rank()
    local rank_info = cluster_utils.call_cross_rank("lc_get_rank_list", "cross_score_rank", self.uuid)
    return rank_info
end

-- 获取跨服战力排行榜
function role_hero:get_cross_stage_start_rank()
    local rank_info = cluster_utils.call_cross_rank("lc_get_rank_list", "cross_stage_start_rank", self.uuid)
    return rank_info
end

---------------------------------------------------------

return role_hero