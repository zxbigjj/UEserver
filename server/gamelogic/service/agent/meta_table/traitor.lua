local date = require("sys_utils.date")
local timer = require("timer")
local excel_data = require("excel_data")
local traitor_utils = require("traitor_utils")
local role_utils = require("role_utils")
local fight_game = require("CSCommon.Fight.Game")
local fight_const = require("CSCommon.Fight.FConst")
local rank_utils = require("rank_utils")
local boss_utils = require("traitor_boss_utils")
local cluster_utils = require("msg_utils.cluster_utils")

local role_traitor = DECLARE_MODULE("meta_table.traitor")

function role_traitor.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
        recover_timer = nil,
        cross_boss_button = nil,
        cooling_ts = nil,
        cooling_timer = nil,
        is_enter_cross = nil
    }
    return setmetatable(self, role_traitor)
end

function role_traitor:init_traitor()
    local traitor = self.db.traitor
    traitor.challenge_ticket = excel_data.ParamData["traitor_challenge_ticket_limit"].f_value
    traitor.challenge_ts = 0
end

function role_traitor:daily_traitor()
    local traitor = self.db.traitor
    traitor.feats = 0
    traitor.feats_reward = {}
    traitor.total_hurt = 0
    for shop_id, data in pairs(excel_data.TraitorShopData) do
        if data.daily_num then
            traitor.shop_dict[shop_id] = nil
        end
    end

    self.role:send_client("s_update_traitor_info", {
        feats = traitor.feats,
        feats_reward = traitor.feats_reward,
        shop_dict = traitor.shop_dict
    })
end

function role_traitor:load_traitor()
    local traitor = self.db.traitor
    local param_data = excel_data.ParamData
    local max_num = param_data["traitor_challenge_ticket_limit"].f_value
    if traitor.challenge_ticket < max_num then
        local now = date.time_second()
        local recover_time = param_data["traitor_ticket_recover_time"].f_value * CSConst.Time.Hour
        local add_num = math.floor((now - traitor.challenge_ts) / recover_time)
        local total_num = add_num + traitor.challenge_ticket
        if total_num < max_num then
            traitor.challenge_ticket = total_num
            traitor.challenge_ts = traitor.challenge_ts + recover_time * add_num
            local delay = recover_time - (now - traitor.challenge_ts) % recover_time
            self.recover_timer = self.role:timer_loop(recover_time, function()
                self:challenge_ticket_recover()
            end, delay)
        else
            traitor.challenge_ticket = max_num
            traitor.challenge_ts = now
        end
    end
    self:load_traitor_boss()
end

-- 挑战卷恢复
function role_traitor:challenge_ticket_recover()
    local traitor = self.db.traitor
    local max_num = excel_data.ParamData["traitor_challenge_ticket_limit"].f_value
    if traitor.challenge_ticket < max_num then
        traitor.challenge_ticket = traitor.challenge_ticket + 1
        traitor.challenge_ts = date.time_second()
        self.role:send_client("s_update_traitor_info", {challenge_ticket = traitor.challenge_ticket})
    end
    -- 次数恢复到最大，取消定时器
    if traitor.challenge_ticket >= max_num then
        self.recover_timer:cancel()
        self.recover_timer = nil
    end
end

function role_traitor:online_traitor()
    local traitor_info
    local traitor_cls = traitor_utils.get_traitor_cls(self.uuid)
    if traitor_cls then
        traitor_info = traitor_cls:get_traitor_info()
    end
    local traitor = self.db.traitor
    self.role:send_client("s_update_traitor_info", {
        traitor_info = traitor_info,
        challenge_ticket = traitor.challenge_ticket,
        feats = traitor.feats,
        feats_reward = traitor.feats_reward,
        shop_dict = traitor.shop_dict,
        auto_kill = traitor.auto_kill,
        total_hurt = traitor.total_hurt,
    })
end

-- 添加叛军
function role_traitor:add_traitor(is_auto_kill)
    local traitor = self.db.traitor
    if traitor_utils.get_traitor_cls(self.uuid) then return end
    local traitor_id
    local role_level = self.role:get_level()
    for id, data in pairs(excel_data.TraitorData) do
        if role_level >= data.level_range[1] and role_level <= data.level_range[2] then
            traitor_id = id
            break
        end
    end
    local traitor_data = excel_data.TraitorData[traitor_id]
    local fight_data = role_utils.get_monster_fight_data(traitor_data.monster_group_id, traitor_data.monster_level)
    local index = math.random(1, #traitor_data.quality_list)
    local hp_dict = {}
    local max_hp = 0
    for pos, data in ipairs(fight_data) do
        if data.fight_attr_dict then
            hp_dict[pos] = data.fight_attr_dict["max_hp"] * traitor_data.hp_rate[index] * traitor.traitor_level
            max_hp = max_hp + hp_dict[pos]
        end
    end
    local traitor_cls = traitor_utils.add_traitor({
        traitor_guid = self.uuid,                  -- guid == uuid(每个人只能拥有一个叛军)
        role_name = self.role:get_name(),
        traitor_id = traitor_id,
        traitor_level = traitor.traitor_level,
        quality = traitor_data.quality_list[index],
        max_hp = max_hp,
        hp_dict = hp_dict,
    })

    if is_auto_kill then
        self:auto_kill_traitor()
    end
    return traitor_cls:get_traitor_info()
end

-- 使用物品增加挑战次数
function role_traitor:add_challenge_ticket(item_count)
    if not item_count then return end
    local item_id = excel_data.ParamData["traitor_challenge_recover_item"].item_id
    local item_data = excel_data.ItemData[item_id]
    if not item_data then return end
    if not self.role:consume_item(item_id, item_count, g_reason.add_traitor_ticket) then
        return
    end

    local add_num = item_data.recover_count * item_count
    self:change_challenge_ticket(add_num, true)
    return true
end

function role_traitor:change_challenge_ticket(num, is_add)
    local traitor = self.db.traitor
    local param_data = excel_data.ParamData
    local max_num = excel_data.ParamData["traitor_challenge_ticket_limit"].f_value
    if is_add then
        traitor.challenge_ticket = traitor.challenge_ticket + num
        if traitor.challenge_ticket >= max_num and self.recover_timer then
            self.recover_timer:cancel()
            self.recover_timer = nil
        end
    else
        if traitor.challenge_ticket < num then return end
        traitor.challenge_ticket = traitor.challenge_ticket - num
        if traitor.challenge_ticket < max_num and not self.recover_timer then
            traitor.challenge_ts = date.time_second()
            local recover_time = param_data["traitor_ticket_recover_time"].f_value * CSConst.Time.Minute
            self.recover_timer = self.role:timer_loop(recover_time, function()
                self:challenge_ticket_recover()
            end)
        end
    end
    self.role:send_client("s_update_traitor_info", {challenge_ticket = traitor.challenge_ticket})
    return true
end

-- 检查是否在某时间段内
local function check_in_time_range(begin_hour, end_hour)
    local now = date.time_second()
    local begin_ts = date.get_day_time(now, begin_hour)
    local end_ts = date.get_day_time(now, end_hour)
    if now >= begin_ts and now <= end_ts then
        return true
    end
end

-- 挑战叛军
function role_traitor:challenge_traitor(traitor_guid, attack_type, is_auto_kill)
    if not traitor_guid then return end
    if attack_type ~= CSConst.TraitorAttackType.One and attack_type ~= CSConst.TraitorAttackType.Two then return end
    local own_fight_data = self.role:get_role_fight_data()
    if not own_fight_data then return end
    local traitor_cls = traitor_utils.get_traitor_cls(traitor_guid)
    if not traitor_cls then
        return false, CSConst.TraitorTips.HasDeath
    end
    local traitor_info = traitor_cls:get_traitor_info()
    local traitor_hp = 0
    for _, hp in pairs(traitor_info.hp_dict) do
        traitor_hp = traitor_hp + hp
    end
    if traitor_hp <= 0 then return end
    local param_data = excel_data.ParamData
    local cost_ticket_num, attack_ratio
    if attack_type == CSConst.TraitorAttackType.One then
        -- 普通攻击
        cost_ticket_num = param_data["traitor_challenge_cost"].f_value
        attack_ratio = 1
    elseif attack_type == CSConst.TraitorAttackType.Two then
        -- 全力一击，攻击翻倍，消耗翻倍
        cost_ticket_num = param_data["traitor_challenge_double_cost"].f_value
        local halve_cost_time = param_data["traitor_challenge_halve_cost"].tb_int
        if check_in_time_range(halve_cost_time[1], halve_cost_time[2]) then
            -- 固定时间段内，消耗减半
            cost_ticket_num = math.floor(cost_ticket_num * CSConst.TraitorCostHalf)
            cost_ticket_num = cost_ticket_num < 1 and 1 or cost_ticket_num
        end
        attack_ratio = param_data["traitor_challenge_attack_ratio"].f_value
    end
    local traitor = self.db.traitor
    if is_auto_kill then
        -- 自动击杀
        if traitor.challenge_ticket < cost_ticket_num then
            if traitor.auto_kill.is_cost then
                -- 自动消耗物品
                local item_id = param_data["traitor_challenge_recover_item"].item_id
                local item_data = excel_data.ItemData[item_id]
                local item_count = (cost_ticket_num - traitor.challenge_ticket)/item_data.recover_count
                self:add_challenge_ticket(math.ceil(item_count))
            else
                if traitor.auto_kill.is_share then
                    -- 自动分享
                    self:share_traitor()
                end
                return
            end
        end
    end
    if not self:change_challenge_ticket(cost_ticket_num) then return end

    local traitor_data = excel_data.TraitorData[traitor_info.traitor_id]
    local enemy_fight_data = role_utils.get_monster_fight_data(traitor_data.monster_group_id, traitor_data.monster_level)
    local index = traitor_data.quality_dict[traitor_info.quality]
    for i, data in ipairs(enemy_fight_data) do
        if data.fight_attr_dict then
            data.fight_attr_dict["max_hp"] = data.fight_attr_dict["max_hp"] * traitor_data.hp_rate[index] * traitor_info.traitor_level
            data.fight_attr_dict["hp"] = traitor_info.hp_dict[i]
        end
    end
    for i, data in ipairs(own_fight_data) do
        if data.hero_id then
            -- 计算攻击力
            local hero = self.role:get_hero(data.hero_id)
            local break_ratio = param_data["traitor_hero_break_attack_ratio"].f_value
            break_ratio = (hero.break_lv - 1) * break_ratio
            break_ratio = break_ratio < 1 and 1 or break_ratio
            data.fight_attr_dict["att"] = data.fight_attr_dict["att"] * attack_ratio * break_ratio
        end
    end
    local fight_data = {
        seed = math.random(1, g_const.Fight_Random_Num),
        own_fight_data = own_fight_data,
        enemy_fight_data = enemy_fight_data,
    }
    local game = fight_game.New(fight_data)
    local is_win = game:GoToFight()
    local result = game:GetFightResultInfo(fight_const.Side.Enemy)
    -- 更新叛军信息
    traitor_info.hp_dict = result.hp_dict
    traitor_cls:save()
    local role = agent_utils.get_role(traitor_info.traitor_guid)
    if role then
        role:send_client("s_update_traitor_info", {traitor_info = traitor_info})
    end
    -- 计算伤害
    local new_traitor_hp = 0
    for _, hp in pairs(traitor_info.hp_dict) do
        new_traitor_hp = new_traitor_hp + hp
    end
    local hurt = traitor_hp - new_traitor_hp
    local item_list = {}
    if new_traitor_hp <= 0 then
        traitor_cls:delete(true)
        local kill_reward = traitor_data.kill_reward[index]
        table.insert(item_list, {item_id = CSConst.Virtual.Diamond, count = kill_reward})
        self.role:update_achievement(CSConst.AchievementType.TraitorKill, 1)
    end
    local value = cost_ticket_num * param_data["traitor_ticket_add_coin"].f_value
    table.insert(item_list, {item_id = CSConst.Virtual.TraitorCoin, count = value})
    if is_auto_kill then
        self.role:add_item_list(item_list, g_reason.traitor_challenge)
    else
        self.role.fight_reward = {item_list = item_list, reason = g_reason.traitor_challenge}
    end
    local feats = hurt / param_data["traitor_feats_ratio"].f_value
    local double_feats_time = param_data["traitor_challenge_double_reward"].tb_int
    if check_in_time_range(double_feats_time[1], double_feats_time[2]) then
        -- 固定时间段内，功勋奖励翻倍
        feats = feats * CSConst.TraitorRewardDouble
    end
    feats = math.floor(feats)
    feats = feats < 1 and 1 or feats
    traitor.feats = traitor.feats + feats
    traitor.total_hurt = traitor.total_hurt + hurt
    self.role:send_client("s_update_traitor_info", {feats = traitor.feats, total_hurt = traitor.total_hurt})
    local old_feats_rank = rank_utils.get_role_rank("traitor_feats_rank", self.uuid)
    local old_hurt_rank = rank_utils.get_role_rank("traitor_hurt_rank", self.uuid)
    self.role:update_role_rank("traitor_feats_rank", traitor.feats)
    self.role:update_cross_role_rank("cross_traitor_feats_rank", traitor.feats)
    self.role:update_role_rank("traitor_hurt_rank", traitor.total_hurt)
    self.role:update_cross_role_rank("cross_traitor_hurt_rank", traitor.total_hurt)
    local new_feats_rank = rank_utils.get_role_rank("traitor_feats_rank", self.uuid)
    local new_hurt_rank = rank_utils.get_role_rank("traitor_hurt_rank", self.uuid)
    if hurt > traitor.max_hurt then
        traitor.max_hurt = hurt
        self.role:update_role_rank("traitor_max_hurt_rank", traitor.max_hurt)
        self.role:update_cross_role_rank("cross_traitor_max_hurt_rank", traitor.max_hurt)
    end
    self.role:update_daily_active(CSConst.DailyActiveTaskType.ChallengeTraitor, 1)
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.TraitorDamage, hurt)
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.TraitorFeats, feats)
    self.role:update_festival_activity_data(CSConst.FestivalActivityType.traitor) -- 节日活动 挑战叛军次数

    return {
        fight_data = fight_data,
        is_win = is_win,
        traitor_info = traitor_info,
        hurt = hurt,
        feats = feats,
        traitor_coin = value,
        old_hurt_rank = old_hurt_rank,
        new_hurt_rank = new_hurt_rank,
        old_feats_rank = old_feats_rank,
        new_feats_rank = new_feats_rank
    }
end

-- 删除叛军
function role_traitor:delete_traitor(reward_list, no_notify)
    local is_kill = reward_list and true or false
    if not no_notify then
        self.role:send_client("s_delete_traitor", {is_kill = is_kill})
    end
    if is_kill then
        -- 叛军每次被击杀等级都会提升一级
        local traitor = self.db.traitor
        traitor.traitor_level = traitor.traitor_level + 1
        -- 发现叛军奖励
        agent_utils.add_mail(self.uuid, {mail_id=CSConst.MailId.TraitorDiscover, item_list=reward_list})
    end
end

-- 分享叛军（分享后，所有好友可以挑战）
function role_traitor:share_traitor()
    local traitor_cls = traitor_utils.get_traitor_cls(self.uuid)
    if not traitor_cls or traitor_cls:is_share() then return end
    traitor_cls:share()
    self.role:send_client("s_update_traitor_info", {traitor_info = traitor_cls:get_traitor_info()})
    self.role:update_daily_active(CSConst.DailyActiveTaskType.ShareTraitor, 1)
    return true
end

function role_traitor:get_traitor_info(traitor_guid)
    if not traitor_guid then return end
    local traitor_cls = traitor_utils.get_traitor_cls(traitor_guid)
    local traitor_info = traitor_cls and traitor_cls:get_traitor_info()
    return {traitor_info = traitor_info}
end

-- 获取叛军列表（好友分享的叛军）
function role_traitor:get_traitor_list()
    local traitor_list = {}
    local friend_dict = self.role:get_friend_dict()
    for uuid in pairs(friend_dict) do
        local traitor_cls = traitor_utils.get_traitor_cls(uuid)
        if traitor_cls and traitor_cls:is_share() then
            table.insert(traitor_list, traitor_cls:get_traitor_info())
        end
    end
    return {traitor_list = traitor_list}
end

-- 自动击杀叛军设置
function role_traitor:set_auto_kill_traitor(quality_dict, is_share, is_cost)
    if not quality_dict then return end
    local auto_kill = self.db.traitor.auto_kill
    auto_kill.quality_dict = quality_dict
    auto_kill.is_share = is_share
    auto_kill.is_cost = is_cost
    self.role:send_client("s_update_traitor_info", {auto_kill = auto_kill})
    return true
end

-- 自动击杀叛军
function role_traitor:auto_kill_traitor()
    local auto_kill = self.db.traitor.auto_kill
    local traitor_cls = traitor_utils.get_traitor_cls(self.uuid)
    if not traitor_cls then return end
    local traitor_info = traitor_cls:get_traitor_info()
    local attack_type = auto_kill.quality_dict[traitor_info.quality]
    if not attack_type then return end
    for i = 1, 100 do
        if not self:challenge_traitor(self.uuid, attack_type, true) then return end
    end
end

-- 领取功勋奖励
function role_traitor:get_feats_reward(reward_id)
    local traitor = self.db.traitor
    local feats_reward = traitor.feats_reward
    local item_dict = {}
    if reward_id then
        local data = excel_data.TraitorRewardData[reward_id]
        if traitor.feats < data.require_feats then return end
        feats_reward[reward_id] = true
        item_dict[data.item_id] = data.item_count
    else
        for index, data in ipairs(excel_data.TraitorRewardData) do
            if traitor.feats < data.require_feats then break end
            if not feats_reward[index] then
                feats_reward[index] = true
                item_dict[data.item_id] = (item_dict[data.item_id] or 0) + data.item_count
            end
        end
    end
    if next(item_dict) then
        self.role:add_item_dict(item_dict, g_reason.traitor_feats_reward)
        self.role:send_client("s_update_traitor_info", {feats_reward = feats_reward})
    end
    return {reward_dict = item_dict}
end


-- 购买叛军商店物品
function role_traitor:buy_shop_item(shop_id, shop_num)
    if not shop_id or not shop_num then return end
    local data = excel_data.TraitorShopData[shop_id]
    if not data then return end
    local shop_dict = self.db.traitor.shop_dict
    local new_num = shop_dict[shop_id] + shop_num
    if data.forever_num and new_num > data.forever_num then return end
    if data.daily_num and new_num > data.daily_num then return end

    local item_list = {}
    for i, item_id in ipairs(data.cost_item_list) do
        local count = math.floor(data.cost_item_value[i] * (data.discount or CSConst.DefaultDiscount) * 0.1)
        count = count == 0 and 1 or count
        table.insert(item_list, {item_id = item_id, count = count * shop_num})
    end
    if not self.role:consume_item_list(item_list, g_reason.traitor_shop) then return end
    shop_dict[shop_id] = new_num
    local item_count = data.item_count * shop_num
    self.role:add_item(data.item_id, item_count, g_reason.traitor_shop)
    self.role:send_client("s_update_traitor_info", {shop_dict = shop_dict})
    self.role:gaea_log("ShopConsume", {
        itemId = data.item_id,
        itemCount = item_count,
        consume = item_list
    })
    return true
end
-------------------------------------- 叛军boss----------------------------------------
function role_traitor:load_traitor_boss()
    local traitor_boss = self.db.traitor_boss
    local boss_data = boss_utils.get_data()
    if boss_data.is_open then
        if not traitor_boss.is_open then
            self:traitor_boss_open()
        else
            -- 检查挑战次数
            if boss_data.challenge_recover_num > traitor_boss.challenge_recover_num then
                local add_num = boss_data.challenge_recover_num - traitor_boss.challenge_recover_num
                traitor_boss.challenge_num = traitor_boss.challenge_num + add_num
                traitor_boss.challenge_recover_num = boss_data.challenge_recover_num
            end
        end
    else
        if traitor_boss.is_open then
            self:traitor_boss_close()
        end
    end
    self:set_traitor_boss_reward_dict(boss_data.boss_level - 1)
end

-- 叛军boss活动开始
function role_traitor:traitor_boss_open()
    local traitor_boss = self.db.traitor_boss
    traitor_boss.is_open = true
    traitor_boss.challenge_recover_num = 0
    traitor_boss.challenge_num = excel_data.ParamData["traitor_boss_init_challenge_num"].f_value
    traitor_boss.buy_challenge_num = 0
    traitor_boss.honour = 0
    traitor_boss.max_hurt = 0
    traitor_boss.reward_dict = {}
    for id in pairs(excel_data.TraitorBossRewardData) do
        traitor_boss.reward_dict[id] = false
    end
    self.role:send_client("s_traitor_boss_open", {})
end

-- 叛军boss活动结束
function role_traitor:traitor_boss_close()
    local traitor_boss = self.db.traitor_boss
    traitor_boss.is_open = nil
    traitor_boss.challenge_num = 0
    self.role:send_client("s_traitor_boss_close", {})
end

-- 更新叛军boss信息
function role_traitor:update_traitor_boss_info(role_name, role_hurt)
    local boss_data = boss_utils.get_data()
    self.role:send_client("s_update_traitor_boss_info", {
        boss_level = boss_data.boss_level,
        max_hp = boss_data.max_hp,
        hp_dict = boss_data.hp_dict,
        revive_ts = boss_data.revive_ts,
        role_name = role_name,
        role_hurt = role_hurt,
        killed_role = boss_data.killed_role
    })
end

-- 叛军boss复活
function role_traitor:traitor_boss_revive()
    local boss_data = boss_utils.get_data()
    self.role:send_client("s_traitor_boss_revive", {
        boss_level = boss_data.boss_level,
        max_hp = boss_data.max_hp,
        hp_dict = boss_data.hp_dict
    })
end

-- 挑战次数恢复
function role_traitor:challenge_num_recover()
    local traitor_boss = self.db.traitor_boss
    traitor_boss.challenge_recover_num = traitor_boss.challenge_recover_num + 1
    traitor_boss.challenge_num = traitor_boss.challenge_num + 1
    self.role:send_client("s_update_traitor_boss_challenge_num", {
        challenge_num = traitor_boss.challenge_num,
        challenge_num_ts = boss_utils.challenge_num_ts
    })
end

-- 获取叛军boss数据
function role_traitor:get_traitor_boss_data()
    boss_utils.add_role(self.uuid)
    local traitor_boss = self.db.traitor_boss
    local honour_rank_info = rank_utils.get_rank_list("traitor_boss_honour_rank", self.uuid)
    local three_honour_rank = {}
    for i= 1, CSConst.TraitorBossThreeRank do
        local rank_info = honour_rank_info.rank_list[i]
        if not rank_info then break end
        table.insert(three_honour_rank, rank_info)
    end
    local max_hurt_rank = rank_utils.get_role_rank("traitor_boss_hurt_rank", self.uuid)
    local dynasty_id = self.role:get_dynasty_id()
    local dynasty_rank = dynasty_id and cluster_utils.call_dynasty("lc_get_dynasty_rank_index", "traitor_boss_honour_dynasty_rank", dynasty_id)
    local cross_boss_button = CSConst.TraitorBossButton.Ok
    local param_data = excel_data.ParamData
    local server_day = param_data["cross_traitor_boss_server_time"].f_value
    if agent_utils.get_server_day() < server_day then
        cross_boss_button = CSConst.TraitorBossButton.ServerDay
    end
    local fight_score = param_data["cross_traitor_boss_fight_score"].f_value
    local hurt = param_data["cross_traitor_boss_hurt"].f_value
    if self.db.max_fight_score < fight_score and traitor_boss.max_hurt < hurt then
        cross_boss_button = CSConst.TraitorBossButton.FightScoreHurt
    end
    self.cross_boss_button = cross_boss_button
    local boss_data = boss_utils.get_data()
    return {
        is_open = boss_data.is_open,
        honour = traitor_boss.honour,
        honour_rank = honour_rank_info.self_rank,
        max_hurt = traitor_boss.max_hurt,
        max_hurt_rank = max_hurt_rank,
        dynasty_rank = dynasty_rank,
        boss_level = boss_data.boss_level,
        three_honour_rank = three_honour_rank,
        max_hp = boss_data.max_hp,
        hp_dict = boss_data.hp_dict,
        challenge_num = traitor_boss.challenge_num,
        challenge_num_ts = boss_utils.challenge_num_ts,
        buy_challenge_num = traitor_boss.buy_challenge_num,
        revive_ts = boss_data.revive_ts,
        cross_boss_button = self.cross_boss_button,
        reward_dict = traitor_boss.reward_dict,
        killed_role = boss_data.killed_role
    }
end

-- 进入叛军boss界面
function role_traitor:enter_traitor_boss()
    boss_utils.add_role(self.uuid)
end

-- 退出叛军boss界面
function role_traitor:quit_traitor_boss()
    boss_utils.delete_role(self.uuid)
end

-- 挑战叛军boss
function role_traitor:challenge_traitor_boss()
    local own_fight_data = self.role:get_role_fight_data()
    if not own_fight_data then return end
    local traitor_boss = self.db.traitor_boss
    if traitor_boss.challenge_num <= 0 then return end
    local boss_data = boss_utils.get_data()
    if not boss_data.is_open then return end
    local old_boss_hp = 0
    for _, hp in pairs(boss_data.hp_dict) do
        old_boss_hp = old_boss_hp + hp
    end
    if old_boss_hp <= 0 then return {} end

    traitor_boss.challenge_num = traitor_boss.challenge_num - 1
    self.role:send_client("s_update_traitor_boss_challenge_num", {
        challenge_num = traitor_boss.challenge_num,
        challenge_num_ts = boss_utils.challenge_num_ts
    })
    local config = excel_data.TraitorBossData[boss_data.boss_level]
    local enemy_fight_data = role_utils.get_monster_fight_data(config.monster_group_id, config.monster_level)
    for pos, data in ipairs(enemy_fight_data) do
        if data.fight_attr_dict then
            data.fight_attr_dict["hp"] = boss_data.hp_dict[pos]
        end
    end
    local fight_data = {
        seed = math.random(1, g_const.Fight_Random_Num),
        own_fight_data = own_fight_data,
        enemy_fight_data = enemy_fight_data,
    }
    local game = fight_game.New(fight_data)
    local is_win = game:GoToFight()
    local result = game:GetFightResultInfo(fight_const.Side.Enemy)
    local new_boss_hp = 0
    for _, hp in pairs(result.hp_dict) do
        new_boss_hp = new_boss_hp + hp
    end
    local hurt = old_boss_hp - new_boss_hp
    local role_name = self.role:get_name()
    boss_utils.on_hurt(result.hp_dict, role_name, hurt)
    if hurt > traitor_boss.max_hurt then
        -- 记录最高伤害
        traitor_boss.max_hurt = hurt
        self.role:update_role_rank("traitor_boss_hurt_rank", traitor_boss.max_hurt)
        self.role:update_cross_role_rank("cross_traitor_hurt_rank", traitor_boss.max_hurt)
    end
    -- 计算获得荣誉值
    local honour = math.floor(hurt/excel_data.ParamData["traitor_boss_honour_param"].f_value)
    honour = honour < 1 and 1 or honour
    traitor_boss.honour = traitor_boss.honour + honour
    self.role:update_role_rank("traitor_boss_honour_rank", traitor_boss.honour)
    self.role:update_cross_role_rank("cross_traitor_honour_rank", traitor_boss.honour)
    self:add_dynasty_honour(honour)
    self:set_traitor_boss_reward_dict()
    local item_list = {}
    local lucky_reward
    if config.lucky_hp >= new_boss_hp and config.lucky_hp <= old_boss_hp then
        -- 幸运一击
        local item_id = CSConst.Virtual.Diamond
        local item_count = config.lucky_reward
        lucky_reward = {[item_id] = item_count}
        table.insert(item_list, {item_id = item_id, count = item_count})
        local record_data = {
            boss_level = boss_data.boss_level,
            time = date.time_second(),
            role_name = role_name,
            item_id = item_id,
            item_count = item_count,
            is_lucky = true
        }
        boss_utils.set_record(record_data)
    end
    local kill_reward
    if new_boss_hp <= 0 then
        -- 叛军boss死亡
        local index = math.random(1, #config.kill_reward)
        local item_id = config.kill_reward[index]
        local item_count = config.kill_reward_num[index]
        kill_reward = {[item_id] = item_count}
        table.insert(item_list, {item_id = item_id, count = item_count})
        local record_data = {
            boss_level = boss_data.boss_level,
            time = date.time_second(),
            role_name = role_name,
            item_id = item_id,
            item_count = item_count
        }
        boss_utils.set_record(record_data)
    end
    -- 判断奖励是否暴击
    local coin_count = excel_data.ParamData["traitor_boss_add_coin"].f_value
    local rate = math.random()
    local crit_id
    for i, v in ipairs(excel_data.TraitorBossCritData) do
        if rate < v.rate then
            coin_count = math.floor(coin_count * v.multiple)
            crit_id = i
            break
        end
        rate = rate - v.rate
    end
    table.insert(item_list, {item_id = CSConst.Virtual.TraitorCoin, count = coin_count})
    self.role.fight_reward = {item_list = item_list, reason = g_reason.traitor_boss_challenge}

    return {
        fight_data = fight_data,
        is_win = is_win,
        honour = honour,
        crit_id = crit_id,
        lucky_reward = lucky_reward,
        kill_reward = kill_reward
    }
end

-- 加入王朝时，要同步荣誉值
function role_traitor:add_dynasty_honour(honour)
    local dynasty_id = self.role:get_dynasty_id()
    if not dynasty_id then return end
    local boss_data = boss_utils.get_data()
    if not boss_data.is_open then return end
    honour = honour or self.db.traitor_boss.honour
    cluster_utils.send_dynasty("ls_update_traitor_honour", self.uuid, honour)
end

-- 退出王朝时，要同步荣誉值
function role_traitor:delete_dynasty_honour()
    local dynasty_id = self.role:get_dynasty_id()
    if not dynasty_id then return end
    local boss_data = boss_utils.get_data()
    if not boss_data.is_open then return end
    local honour = self.db.traitor_boss.honour
    cluster_utils.send_dynasty("ls_update_traitor_honour", self.uuid, -honour)
end

-- 设置叛军boss奖励状态
function role_traitor:set_traitor_boss_reward_dict(boss_level)
    local traitor_boss = self.db.traitor_boss
    for id, data in pairs(excel_data.TraitorBossRewardData) do
        if (data.require_honour and traitor_boss.honour >= data.require_honour)
            or (boss_level and data.require_boss_level and boss_level >= data.require_boss_level) then
            if traitor_boss.reward_dict[id] == false then
                traitor_boss.reward_dict[id] = true
            end
        end
    end
end

-- 领取叛军boss奖励
function role_traitor:get_traitor_boss_reward(reward_id)
    local reward_dict = self.db.traitor_boss.reward_dict
    local reward_id_list = {}
    if not reward_id then
        -- 领取所有奖励
        for id, v in pairs(reward_dict) do
            if v == true then
                table.insert(reward_id_list, id)
            end
        end
    else
        if not reward_dict[reward_id] then return end
        table.insert(reward_id_list, reward_id)
    end
    local item_dict = {}
    for _, id in ipairs(reward_id_list) do
        reward_dict[id] = nil
        local data = excel_data.TraitorBossRewardData[id]
        local reward_data = excel_data.RewardData[data.reward_id]
        for item_id, count in pairs(reward_data.item_dict) do
            item_dict[item_id] = (item_dict[item_id] or 0) + count
        end
    end
    self.role:add_item_dict(item_dict, g_reason.traitor_boss_reward)
    return {reward_dict = reward_dict, item_dict = item_dict}
end

-- 购买挑战次数
function role_traitor:buy_traitor_boss_challenge_num(buy_num)
    if not buy_num or buy_num < 1 then return end
    local traitor_boss = self.db.traitor_boss
    local buy_challenge_num = traitor_boss.buy_challenge_num
    local vip = self.role:get_vip()
    local max_buy_num = excel_data.VipData[vip].tratior_challenge_buy_time
    if buy_challenge_num + buy_num > max_buy_num then return end

    local item_dict = {}
    local num_data = excel_data.TraitorBossCNData
    for i = buy_challenge_num + 1, buy_challenge_num + buy_num do
        local data = num_data[i]
        if not data then
            data = num_data[#num_data]
        end
        item_dict[data.cost_item] = (item_dict[data.cost_item] or 0) + data.cost_num
    end
    if not self.role:consume_item_dict(item_dict, g_reason.traitor_boss_buy_num) then return end
    traitor_boss.challenge_num = traitor_boss.challenge_num + buy_num
    traitor_boss.buy_challenge_num = buy_challenge_num + buy_num
    return {challenge_num = traitor_boss.challenge_num, buy_challenge_num = traitor_boss.buy_challenge_num}
end

-- 获取叛军boss攻打记录
function role_traitor:get_traitor_boss_record()
    return {
        boss_record = boss_utils.record_list,
        cross_boss_record = cluster_utils.call_cross_traitor("lc_get_traitor_record")
    }
end

-- 获取跨服叛军boss数据
function role_traitor:get_cross_traitor_boss_data()
    if self.cross_boss_button ~= CSConst.TraitorBossButton.Ok then return end
    local traitor_boss = self.db.traitor_boss
    if not traitor_boss.is_open then return end
    local boss_data = cluster_utils.call_cross_traitor("lc_get_traitor_data", self.uuid)
    if not boss_data then return end
    return {
        fight_ts = boss_data.fight_ts,
        pos_dict = boss_data.pos_dict,
        cooling_ts = self.cooling_ts
    }
end

-- 进入跨服叛军boss界面
function role_traitor:enter_cross_traitor_boss()
    cluster_utils.send_cross_traitor("ls_enter_traitor", self.uuid)
    self.is_enter_cross = true
end

-- 退出跨服叛军boss界面
function role_traitor:quit_cross_traitor_boss()
    if not self.is_enter_cross then return end
    cluster_utils.send_cross_traitor("ls_quit_traitor", self.uuid)
    self.is_enter_cross = nil
end

-- 占领跨服叛军boss位置
function role_traitor:cross_traitor_boss_occupy_pos(pos_id)
    if not pos_id then return end
    local fight_data = self.role:get_role_fight_data()
    if not fight_data then return end
    local traitor_boss = self.db.traitor_boss
    if not traitor_boss.is_open then return end
    if traitor_boss.challenge_num <= 0 then return end
    if self.cooling_ts then return end
    local role_info = {
        uuid = self.uuid,
        role_id = self.role:get_role_id(),
        role_name = self.role:get_name(),
        fight_score = self.role:get_fight_score(),
        fight_data = fight_data
    }
    local ret = cluster_utils.call_cross_traitor("lc_occupy_pos", pos_id, role_info)
    if not ret then return end
    if ret.fight_data then
        local cooling_ts = excel_data.ParamData["cross_traitor_boss_cooling_time"].f_value
        self.cooling_ts = date.time_second() + cooling_ts
        self.cooling_timer = timer.once(cooling_ts, function()
            self.cooling_timer = nil
            self:update_cooling_ts()
        end)
        self.role:send_client("s_update_cross_cooling_ts", {cooling_ts = self.cooling_ts})
    end
    return ret
end

-- 更新挑战冷却时间
function role_traitor:update_cooling_ts()
    self.cooling_ts = nil
    self.role:send_client("s_update_cross_cooling_ts", {cooling_ts = self.cooling_ts})
end

-- 更新跨服叛军boss信息
function role_traitor:update_cross_traitor_info(info)
    self.role:send_client("s_update_cross_traitor_info", info)
end

-- 挑战跨服叛军boss（时间到自动挑战）
function role_traitor:update_cross_traitor_fight(data)
    local traitor_boss = self.db.traitor_boss
    traitor_boss.challenge_num = traitor_boss.challenge_num - 1
    self.role:send_client("s_update_traitor_boss_challenge_num", {
        challenge_num = traitor_boss.challenge_num,
        challenge_num_ts = boss_utils.challenge_num_ts
    })
    if data.hurt > traitor_boss.max_hurt then
        traitor_boss.max_hurt = data.hurt
        self.role:update_role_rank("traitor_boss_hurt_rank", traitor_boss.max_hurt)
        self.role:update_cross_role_rank("cross_traitor_hurt_rank", traitor_boss.max_hurt)
    end
    local honour = math.floor(data.hurt/excel_data.ParamData["cross_traitor_boss_honour_param"].f_value)
    honour = honour < 1 and 1 or honour
    traitor_boss.honour = traitor_boss.honour + honour
    self.role:update_role_rank("traitor_boss_honour_rank", traitor_boss.honour)
    self.role:update_cross_role_rank("cross_traitor_honour_rank", traitor_boss.honour)
    self:add_dynasty_honour(honour)
    self:set_traitor_boss_reward_dict()
    local coin_count = excel_data.ParamData["traitor_boss_add_coin"].f_value
    local rate = math.random()
    local crit_id
    for i, v in ipairs(excel_data.TraitorBossCritData) do
        if rate < v.rate then
            coin_count = math.floor(coin_count * v.multiple)
            crit_id = i
            break
        end
        rate = rate - v.rate
    end
    local reward_dict = {
        [CSConst.Virtual.TraitorCoin] = coin_count,
        [data.item_id] = data.item_count
    }
    self.role:add_item_dict(reward_dict, g_reason.cross_traitor_boss_reward)

    self.role:send_client("s_cross_traitor_boss_fight", {
        fight_data = data.fight_data,
        is_win = data.is_win,
        honour = honour,
        crit_id = crit_id,
        reward_dict = reward_dict
    })
    return traitor_boss.challenge_num
end

------------------------------------------------------  rank
-- 获取功勋排行榜
function role_traitor:get_feats_rank()
    local rank_info = rank_utils.get_rank_list("traitor_feats_rank", self.uuid)
    rank_info.self_rank_score = self.db.traitor.feats
    return rank_info
end

function role_traitor:get_cross_feats_rank()
    local rank_info = cluster_utils.call_cross_rank("lc_get_rank_list", "cross_traitor_feats_rank", self.uuid)
    rank_info.self_rank_score = self.db.traitor.feats
    return rank_info
end

-- 获取伤害排行榜
function role_traitor:get_hurt_rank()
    local rank_info = rank_utils.get_rank_list("traitor_hurt_rank", self.uuid)
    rank_info.self_rank_score = self.db.traitor.total_hurt
    return rank_info
end

function role_traitor:get_cross_hurt_rank()
    local rank_info = cluster_utils.call_cross_rank("lc_get_rank_list", "cross_traitor_hurt_rank", self.uuid)
    rank_info.self_rank_score = self.db.traitor.total_hurt
    return rank_info
end

-- 获取最大伤害排行榜
function role_traitor:get_traitor_max_hurt_rank()
    local rank_info = rank_utils.get_rank_list("traitor_max_hurt_rank", self.uuid)
    rank_info.self_rank_score = self.db.traitor.max_hurt
    return rank_info
end

function role_traitor:get_cross_max_hurt_rank()
    local rank_info = cluster_utils.call_cross_rank("lc_get_rank_list", "cross_traitor_max_hurt_rank", self.uuid)
    rank_info.self_rank_score = self.db.traitor.max_hurt
    return rank_info
end

-- 获取王朝荣誉排行榜
function role_traitor:get_traitor_boss_dynasty_rank(is_cross)
    local dynasty_id = self.role:get_dynasty_id()
    if is_cross then
        return cluster_utils.call_cross_dynasty("lc_get_dynasty_rank_list", "cross_boss_honour_dynasty_rank", dynasty_id)
    else
        return cluster_utils.call_dynasty("lc_get_dynasty_rank_list", "traitor_boss_honour_dynasty_rank", dynasty_id)
    end
end

return role_traitor