local role_base = DECLARE_MODULE("meta_table.base")

local cluster_utils = require("msg_utils.cluster_utils")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local CSFunction = require("CSCommon.CSFunction")

-- base_info
local BASIC_KEYS = {
    "level",
    "exp",
    "uuid",
    "name",
    "role_id",
    "currency",
    "score",
    "attr_dict",
    "fight_score",
    "flag_id",
    "not_comment"
}

function role_base.new(role)
    local self = {
        role = role,
        urs = role.urs,
        uuid = role.uuid,
        db = role.db,
    }
    return setmetatable(self, role_base)
end

function role_base:init(role_data)
    -- 初始化数据库
    local role = self.role

    role.total_hall:init_hall()
    role.lover:init_lover()
    role.child:init_child()
    role.hunt:init_hunt()
    role.stage:init_stage()
    role.travel:init_travel()
    role.arena:init_arena()
    role.treasure:init_treasure()
    role.dare_tower:init()
    role.hero:init_hero()
    role.lineup:init_lineup()
    role.train:init_train()
    role.task:init_task()
    role.achievement:init_achievement()
    role.check_in_monthly:init()
    role.check_in_weekly:init()
    role.dynasty:init_dynasty()
    role.traitor:init_traitor()
    role.first_week:init()
    role.guide:init_guide()
    role.recharge:init()
    role.vip:init()
    role.bar:on_init()
end

function role_base:on_load()
    g_log:role("RoleLoad", {urs=self.urs, uuid=self.uuid})
    local role = self.role
    role.is_doing_load = true

    role.activity:load()
    role.rush_activity:load()
    role.festival_activity:load()
    role.attr:load_attr()
    role.title:load()
    role.hero:load_hero()
    role.lineup:load_lineup()
    role.lover:load_lover()
    role.bag:load_bag()
    role.stage:load_stage()
    role.total_hall:load_hall()
    role.child:load_child()
    role.chat:load_chat()
    role.mail:load_mail()
    role.arena:load_arena()
    role.dynasty:load_dynasty()
    role.check_in_monthly:load()
    role.traitor:load_traitor()
    role.action_point:load()
    role.fund:load()
    role.crystal_shop:load()
    role.single_recharge:load()
    --role.worth_recharge:load()
    role.recharge_draw:load()
    role.party:load_party()
    role.travel:load_travel()
    role.accum_recharge:on_load()

    role.is_doing_load = nil
end

function role_base:on_online()
    local role = self.role
    role.is_doing_online = true
    -- 先刷新
    role.is_doing_load = true
    self:check_daily_zero_refresh()
    self:check_hourly_refresh()
    role.is_doing_load = nil

    self:online_base()
    role:online_total_hall()
    role.hero:online_hero()
    role.lover:online_lover()
    role.child:online_child()
    role.hunt:online_hunt()
    role.stage:online_stage()
    role.bag:online_bag()
    role.prison:online_prison()
    role.mail:online_mail()
    role.travel:online_travel()
    role.lineup:online_lineup()
    role.daily_dare:online_dare()
    role.salon:online_salon()
    role.arena:online_arena()
    role.treasure:online_treasure()
    role.dare_tower:online()
    role.train:online_train()
    role.party:online()
    role.dynasty:online_dynasty()
    role.task:online_task()
    role.achievement:online_achievement()
    role.check_in_monthly:online()
    role.check_in_weekly:online()
    role.daily_active:online()
    role.traitor:online_traitor()
    role.first_week:online()
    role.friend:online()
    role.normal_shop:online()
    role.crystal_shop:online()
    role.recharge:online()
    role.vip:online()
    role.single_recharge:online()
    --role.worth_recharge:online()
    role.recharge_draw:online()
    role.guide:online_guide()
    role.activity:online()
    role.rush_activity:online()
    role.festival_activity:online()
    role.action_point:online()
    role.fund:online()
    role.luxury_check_in:online()
    role.daily_recharge:online()
    role.title:online()
    role.monthly_card:on_online()
    role:check_send_question()
    role.accum_recharge:on_online()
    role.bar:on_online()
    role.lover_activities:online()
    role.hero_activities:online()

    require("hotfix_utils").do_role_hotfix(role)
    require("cache_utils").clear_role_cache(self.uuid)
    require("offline_cmd").online_do_offline_cmd(role)
    require("global_mail").check_send_global_mail(role)

    role.is_doing_online = nil
end

-- 0点刷新
function role_base:check_daily_zero_refresh(is_gm)
    local role = self.role
    local now = date.time_second()
    -- 每日刷新
    if is_gm or role.db.last_daily_ts < date.get_begin0(now) then
        local old_daily_ts = role.db.last_daily_ts
        role.db.last_daily_ts = now
        role:log("DailyRefresh")

        role.lover:daily_lover()
        role.hunt:daily_hunt()
        role.stage:daily_stage()
        role.travel:daily_travel()
        role.prison:daily_prison()
        role.hero:daily_hero()
        role.lineup:daily_lineup()
        role.salon:daily_salon()
        role.train:daily_train()
        role.dare_tower:daily_tower()
        role.party:daily_refresh()
        role.dynasty:daily_dynasty()
        role.check_in_monthly:daily_reset()
        role.check_in_weekly:daily_reset()
        role.daily_active:daily_reset()
        role.traitor:daily_traitor()
        role.arena:daily_arena()
        role.first_week:daily()
        role.friend:daily_reset()
        role.normal_shop:daily_reset()
        role.vip:daily_reset()
        role.activity:daily()
        role.festival_activity:daily()
        role.luxury_check_in:daily()
        role.daily_recharge:daily()
        role.title:daily()
        role.single_recharge:daily_reset()
        role.monthly_card:on_daily(old_daily_ts)
        role.bar:on_daily()
        role.daily_gift_package_activities:daily_gift(role)
    end
    -- 每周刷新
    if role.db.last_weekly_ts < date.get_week_begin0(now) then
        role.db.last_weekly_ts = now
        role:log("WeeklyRefresh")

        role.crystal_shop:weekly_reset()
        role.vip:weekly_reset()
    end
end

-- 每小时刷新
function role_base:check_hourly_refresh()
    local role = self.role
    local now = date.time_second()
    local pre_hourly_ts = role.db.last_hourly_ts
    local now_hour = date.get_hour(now)
    local pre_hour = date.get_hour(pre_hourly_ts)
    if pre_hour < now_hour or (now - pre_hourly_ts > CSConst.Time.Hour) then
        role.db.last_hourly_ts = now
        role:log("HourlyRefresh")

        role.party:hourly_party(pre_hourly_ts)
        role.salon:hourly_salon(pre_hourly_ts)
        role.title:hourly()
        role.bar:on_hourly(pre_hourly_ts)
        role.mail:check_deadline_mail()
    end
end

function role_base:online_base()
    -- 最先推服务器时间
    self.role:send_client("s_online_server_time", {server_time = date.time_second()})
    local base_info = {}
    for _, key in ipairs(BASIC_KEYS) do
        base_info[key] = self.db[key]
    end
    self.role:send_client("s_update_base_info", base_info)
end

function role_base:set_level(new_level, reason)
    if new_level >= #excel_data.LevelData then
        new_level = #excel_data.LevelData
    end
    local old_level = self.db.level
    if new_level <= old_level then
        self.db.level = new_level
        self.db.exp = excel_data.LevelData[new_level].exp
        self.role:send_client("s_update_base_info", {level=self.db.level, exp = self.db.exp})
    else
        local need_exp = excel_data.LevelData[new_level].exp - self.db.exp
        self:add_exp(need_exp, reason)
    end
end

function role_base:add_exp(exp, reason, not_addition)
    if not not_addition then
        -- 王朝技能经验加成
        exp = exp + self.role:get_dynasty_spell_add_exp(exp)
    end
    exp = math.floor(exp)
    if exp <= 0 then
        self.role:error("add exp must > 0: " .. reason)
        return
    end
    local old_exp = self.db.exp
    local new_exp = old_exp + exp
    self.db.exp = new_exp

    self.role:log("AddExp", {exp=exp, old_exp=old_exp, new_exp=new_exp, reason=reason})
    self.role:gaea_log("RoleExp", {
        expNum = exp,
        oldExp = old_exp,
        newExp = new_exp,
        reason = reason or "",
    })
    self:_check_lvlup(reason)
    if new_exp == self.db.exp then
        self.role:send_client("s_update_base_info", {exp=new_exp})
    end
    return true
end

-- 扣除经验
function role_base:delete_exp(exp, reason)
    if exp <= 0 then
        self.role:error("add exp must > 0: " .. reason)
        return
    end
    local old_level = self.db.level
    local old_exp = self.db.exp
    if old_exp <= 0 then return end
    if exp > old_exp then
        exp = old_exp
    end
    local new_exp = old_exp - exp
    local new_level
    self.db.exp = new_exp
    local LevelData = excel_data.LevelData
    if old_level > 1 then
        for i = old_level, 1, -1 do
            if new_exp >= LevelData[i].exp then
                break
            end
            new_level = i - 1
        end
    end
    if new_level then
        self.db.level = new_level
        self.role:gaea_log("RoleLvlup", {oldLevel = old_level, newLevel = new_level})
    end
    self.role:gaea_log("RoleExp", {
        expNum = exp,
        oldExp = old_exp,
        newExp = new_exp,
        reason = reason or "",
    })
    self.role:send_client("s_update_base_info", {exp=new_exp, level=new_level})
    return true
end

function role_base:_check_lvlup(reason)
    local db = self.db
    if db.level >= #excel_data.LevelData then return end
    if db.exp < excel_data.LevelData[db.level + 1].exp then return end
    local old_level = db.level
    local new_level = old_level + 1
    db.level = new_level

    self:_on_lvlup(new_level)
    self.role:log("LvlUp", {new_level = new_level, reason = reason})
    self.role:gaea_log("RoleLvlup", {oldLevel = old_level, newLevel = new_level})
    self:_check_lvlup(reason)
    if new_level == db.level then
        self.role:send_client("s_update_base_info", {level = new_level})
    end
    return true
end

function role_base:_on_lvlup(new_level)
    local role = self.role
    role:unlock_hunt_ground()
    role:update_login_role_info("level", new_level)
    role:lvlup_check_lineup_unlock()
    role:unlock_travel_tolvlup()
    role:daily_dare_unlock_lvl()
    role:update_dynasty_role_info({level = new_level})
    role:update_achievement(CSConst.AchievementType.RoleLevel, new_level)
    role:update_first_week_task(CSConst.FirstWeekTaskType.PlayerLevel, new_level)
    self.role:update_role_rank("level_rank", new_level)
    self.role:update_rank_role_info({level = new_level})
    role:update_task(CSConst.TaskType.Level)
    -- 检查等级事件
    role:level_event_trigger_check(new_level)
    role:check_reinforcements_unlock()
    role:check_send_question()

    -- 每次升级会增加一定的行动点和活力
    local level_data = excel_data.LevelData[new_level]
    role:change_action_point(level_data.add_action_point, true)
    role:change_vitality(level_data.add_vitality_point, true)

    -- 升级时检查是否可以领取开服基金奖励
    role:notify_fund_level_up(new_level)
end

function role_base:add_currency(id, value, reason)
    local item_data = excel_data.ItemData[id]
    if not item_data then return end
    if item_data.sub_type ~= CSConst.ItemSubType.Currency then return end
    value = math.floor(value)
    if value < 0 then
        self.role:error("add currency must >= 0")
        return
    end
    local old_currency = self.db.currency[id]
    local new_currency = old_currency + value
    if new_currency > CSConst.MaxIntNum then
        new_currency = CSConst.MaxIntNum
    end
    self.db.currency[id] = new_currency
    self.role:send_client("s_update_base_info", {currency = {[id] = new_currency}})
    self.role:log("AddCurrency", {currency=id, old_currency=old_currency, new_currency=new_currency, reason=reason})
    self.role:gaea_log("VirtualCoin", {
       coinNum = value,
       coinType = CSConst.LogCoinName[id] or "",
       type = reason or "",
       isGain = 1,
       totalCoin = new_currency,
    })

    if id == CSConst.Virtual.HuntPoint then
        self.role:add_hunt_point(value)
    elseif id == CSConst.Virtual.Dedicate then
        self.role:update_dynasty_role_info({dedicate = value})
    end

    self.role:update_rush_activity_item_data(id, value) -- 冲榜活动-虚拟物品增长

    return true
end

function role_base:sub_currency(id, value, reason)
    local item_data = excel_data.ItemData[id]
    if not item_data then return end
    if item_data.sub_type ~= CSConst.ItemSubType.Currency then return end
    value = math.floor(value)
    if value < 0 then
        self.role:error("sub currency must >= 0")
        return
    end
    local old_currency = self.db.currency[id]
    if value > old_currency then return end
    local new_currency = old_currency - value
    self.db.currency[id] = new_currency
    self.role:send_client("s_update_base_info", {currency = {[id] = new_currency}})
    self.role:log("SubCurrency", {currency=id, old_currency=old_currency, new_currency=new_currency, reason=reason})
    self.role:gaea_log("VirtualCoin", {
       coinNum = value,
       coinType = CSConst.LogCoinName[id] or "",
       type = reason or "",
       isGain = 0,
       totalCoin = new_currency,
    })
    self.role:update_activity_item_data(id, value) -- 限时活动-物品消耗统计
    return true
end

function role_base:get_role_info()
    return {
        uuid = self.uuid,
        role_id = self.role:get_role_id(),
        name = self.role:get_name(),
        level = self.role:get_level(),
        vip = self.role:get_vip(),
        score = self.role:get_score(),
        fight_score = self.role:get_fight_score(),
    }
end

function role_base:updata_fight_score(not_notify)
    local new_score = self.role:eval_fight_score()
    local old_score = self.db.fight_score
    self.db.fight_score = new_score
    if self.db.fight_score > self.db.max_fight_score then
        local old_max_fight_score = self.db.max_fight_score
        self.db.max_fight_score = self.db.fight_score
        -- 限时活动、冲榜活动，战力历史最高涨幅统计
        self.role:update_activity_data(CSConst.ActivityType.GrowthFightScore, self.db.max_fight_score - old_max_fight_score)
        self.role:update_rush_activity_data(CSConst.RushActivityType.ringleader, self.db.max_fight_score - old_max_fight_score)
    end
    --print("tianjiazhanli:"..self.db.fight_score);
    self.role:update_cross_role_rank("cross_fight_score_rank", self.db.fight_score)
    if not not_notify then
        self.role:send_client("s_update_base_info", {fight_score = new_score})
    end
    self.role:update_achievement(CSConst.AchievementType.FightScore, new_score)
    self.role:update_dynasty_role_info({fight_score = new_score})
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.FightScoreNum, new_score)
    self.role:update_role_rank("fight_score_rank", new_score)
    self.role:update_task(CSConst.TaskType.FightScore)
end

-- 修改主角形象
function role_base:modify_role_image(role_id)
    local old_role_id = self.db.role_id
    if old_role_id == role_id then return end
    local cost_data = excel_data.ParamData["modify_role_image_cost"]
    if not self.role:consume_item(cost_data.item_id, cost_data.count, g_reason.modify_role_image) then return end
    self.db.role_id = role_id
    self.role:send_client("s_update_base_info", {role_id = role_id})
    self.role:update_rank_role_info({role_id = role_id})
    self.role:update_dynasty_role_info({role_id = role_id})
    self.role:gaea_log("RoleImage", {oldId = old_role_id, newId = role_id})
    return true
end

-- 修改主角名字
function role_base:modify_role_name(name)
    if not IsStringBroken(name) then return end
    if self.db.name == name then return end

    if not CSFunction.check_player_name_legality(name) then return end
    --屏蔽字
    local name_utils = require("name_utils")
    local maskWord = name_utils.sdk_4399_check_name(name)
    print('=======修改名字屏蔽字==========' .. maskWord)
    if tostring(maskWord) ~= "{}" then
        return false,true,true
    end

    if name_utils.is_role_name_repeat(name) then
        return false, true
    end

    local cost_data = excel_data.ParamData["modify_role_name_cost"]
    if not self.role:consume_item(cost_data.item_id, cost_data.count, g_reason.modify_role_name) then
        return
    end
    if not name_utils.use_role_name(self.uuid, name) then
        self.role:add_item(cost_data.item_id, cost_data.count, g_reason.modify_role_name, true)
        return
    end
    local old_name = self.db.name
    name_utils.unuse_role_name(old_name)
    self.db.name = name
    self.role:gaea_log("RoleName", {oldName = old_name, newName = name})
    self:on_rename(name)
    return true
end

function role_base:on_rename()
    local name = self.db.name
    self.role:send_client("s_update_base_info", {name = name})
    --local title_wearing_id = self.role.title.wearing_id
    self.role:update_rank_role_info({name = name})
    --self.role:update_rank_role_info({title_wearing_id = "900090"})
    self.role:update_dynasty_role_info({name = name})
end

-- 修改主角旗帜
function role_base:modify_role_flag(flag_id)
    if not flag_id then return end
    if self.db.flag_id == flag_id then return end
    if not excel_data.FlagData[flag_id] then return end
    local cost_data = excel_data.ParamData["modify_role_flag_cost"]
    if self.db.flag_id then
        -- 第一次不需要消耗
        if not self.role:consume_item(cost_data.item_id, cost_data.count, g_reason.modify_role_flag) then return end
    end
    self.db.flag_id = flag_id
    self.role:send_client("s_update_base_info", {flag_id = flag_id})
    return true
end

-- 初始物品
function role_base:give_init_item()
    local init_item_list = excel_data.ParamData["init_item_list"].item_list
    for _, item_id in ipairs(init_item_list) do
        self.role:add_item(item_id, 1, g_reason.init_item)
    end
    self.role.action_point:on_add_init_lover()
end

-- 登出日志
function role_base:logout_log()
    -- 属性信息
    local attr_list = {}
    for name, value in pairs(self.db.attr_dict) do
        table.insert(attr_list, {name = name, value = value})
    end
    -- 阵容信息
    local lineup_list = {}
    for _, lineup_info in pairs(self.db.lineup_dict) do
        local equip_list = {}
        for part_index, item_guid in pairs(lineup_info.equip_dict) do
            table.insert(equip_list, {part_index = part_index, item_guid = item_guid})
        end
        table.insert(lineup_list, {
            lineup_id = lineup_info.lineup_id,
            pos_id = lineup_info.pos_id,
            hero_id = lineup_info.hero_id,
            equip_list = equip_list
        })
    end
    -- 背包信息
    local item_list = self.db.bag_item_list
    -- 英雄信息
    local hero_list = {}
    for _, hero_info in pairs(self.db.hero_dict) do
        local attr_list = {}
        for name, value in pairs(hero_info.attr_dict) do
            table.insert(attr_list, {name = name, value = value})
        end
        local spell_list = {}
        for spell_id, level in pairs(hero_info.spell_dict) do
            table.insert(spell_list, {spell_id = spell_id, level = level})
        end
        local fate_list = {}
        for fate_id in pairs(hero_info.fate_dict) do
            table.insert(fate_list, fate_id)
        end
        table.insert(hero_list, {
            hero_id = hero_info.hero_id,
            level = hero_info.level,
            score = hero_info.score,
            attr_list = attr_list,
            spell_list = spell_list,
            fate_list = fate_list,
            break_lv = hero_info.break_lv,
            star_lv = hero_info.star_lv,
            destiny_lv = hero_info.destiny_lv,
            destiny_exp = hero_info.destiny_exp
        })
    end
    -- 情人信息
    local lover_list = {}
    for _, lover_info in pairs(self.db.lover_dict) do
        local attr_list = {}
        for name, value in pairs(lover_info.attr_dict) do
            table.insert(attr_list, {name = name, value = value})
        end
        local spell_list = {}
        for spell_id, level in pairs(lover_info.spell_dict) do
            table.insert(spell_list, {spell_id = spell_id, level = level})
        end
        local fashion_list = {}
        for fashion_id in pairs(lover_info.fashion_dict) do
            table.insert(fashion_list, fashion_id)
        end
        table.insert(lover_list, {
            lover_id = lover_info.lover_id,
            level = lover_info.level,
            exp = lover_info.exp,
            grade = lover_info.grade,
            power_value = lover_info.power_value,
            children = lover_info.children,
            attr_list = attr_list,
            spell_list = spell_list,
            fashion_id = lover_info.fashion_id,
            fashion_list = fashion_list,
            star_lv = lover_info.star_lv
        })
    end
    self.role:gaea_log("RoleLogout", {roleData = {
        attr_list = attr_list,
        lineup_list = lineup_list,
        item_list = item_list,
        hero_list = hero_list,
        lover_list = lover_list
    }})
end

-- 设置语言
function role_base:set_language(language)
    self.db.language = language
    return true
end

-- 获取玩家基础信息
function role_base:get_player_base_info(uuid)
    if not uuid then return end
    if not cluster_utils.is_player_uuid_valid(uuid) then return end
    local base_info = cluster_utils.call_agent(nil, uuid, "lc_get_role_info")
    base_info.dynasty = base_info.dynasty_name
    return base_info
end

-- 评论设置
function role_base:comment_setting(not_comment)
    if self.db.not_comment == not_comment then return end
    self.db.not_comment = not_comment
    self.role:send_client("s_update_base_info", {not_comment = not_comment})
    return true
end

-- 保存评论
function role_base:save_comment(comment_id, star_num, content)
    if not comment_id or not star_num or not content then return end
    local comment_record = self.db.comment_record
    DB_LIST_INSERT(comment_record, {comment_id=comment_id, star_num=star_num, content=content})
    return true
end

return role_base