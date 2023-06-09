local date = require("sys_utils.date")
local excel_data = require("excel_data")
local arena_utils = require("arena_utils")
local role_utils = require("role_utils")
local drop_utils = require("drop_utils")
local fight_game = require("CSCommon.Fight.Game")
local CSFunction = require("CSCommon.CSFunction")

local role_arena = DECLARE_MODULE("meta_table.arena")

local VICTORY_REWARD_NUM = 3

function role_arena.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
        vitality_timer = nil,
        fight_role_list = nil,
        victory_reward = nil,
        old_rank = nil
    }
    return setmetatable(self, role_arena)
end

function role_arena:init_arena()
    self.db.vitality = excel_data.ParamData["vitality_limit"].f_value
end

function role_arena:daily_arena()
    local arena_shop = self.db.arena.shop_dict
    for shop_id, data in pairs(excel_data.ArenaShopData) do
        if not data.forever_num then
            arena_shop[shop_id] = nil
        end
    end
    self.role:send_client("s_update_arena_info", {arena_shop = arena_shop})
end

function role_arena:load_arena()
    local now = date.time_second()
    local param_data = excel_data.ParamData
    local limit_value = param_data["vitality_limit"].f_value
    if self.db.vitality < limit_value then
        local recover_time = param_data["vitality_recover_time"].f_value * CSConst.Time.Minute
        local add_num = math.floor((now - self.db.vitality_ts) / recover_time)
        local total_num = add_num + self.db.vitality
        if total_num < limit_value then
            self.db.vitality = total_num
            self.db.vitality_ts = self.db.vitality_ts + recover_time * add_num
            local delay = recover_time - (now - self.db.vitality_ts) % recover_time
            self.vitality_timer = self.role:timer_loop(recover_time, function()
                self:vitality_recover()
            end, delay)
        else
            self.db.vitality = limit_value
            self.db.vitality_ts = now
        end
    end
end

function role_arena:online_arena()
    self.role:send_client("s_update_vitality", {vitality = self.db.vitality, vitality_ts = self.db.vitality_ts, taoxin_vitality = self.db.taoxin_vitality})
    local arena = self.db.arena
    self.role:send_client("s_update_arena_info", {
        arena_history_rank = arena.history_rank,
        arena_shop = arena.shop_dict
    })
end

-- 活力恢复
function role_arena:vitality_recover()
    local limit_value = excel_data.ParamData["vitality_limit"].f_value
    if self.db.vitality < limit_value then
        self.db.vitality = self.db.vitality + 1
        self.db.vitality_ts = date.time_second()
        self.role:send_client("s_update_vitality", {vitality = self.db.vitality, vitality_ts = self.db.vitality_ts , taoxin_vitality = self.db.taoxin_vitality})
    end
    if self.db.vitality >= limit_value then
        self.vitality_timer:cancel()
        self.vitality_timer = nil
    end
end

-- 改变活力
function role_arena:change_vitality(num, is_add)
    local param_data = excel_data.ParamData
    local limit_value = param_data["vitality_limit"].f_value
    if is_add then
        self.db.vitality = self.db.vitality + num
        local max_num = param_data["vitality_max_num"].f_value
        if self.db.vitality > max_num then
            self.db.vitality = max_num
        end
        if self.db.vitality >= limit_value and self.vitality_timer then
            self.vitality_timer:cancel()
            self.vitality_timer = nil
        end
    else
        if self.db.vitality < num then return end
        self.db.vitality = self.db.vitality - num
        if self.db.vitality < limit_value and not self.vitality_timer then
            self.db.vitality_ts = date.time_second()
            local recover_time = param_data["vitality_recover_time"].f_value * CSConst.Time.Minute
            self.vitality_timer = self.role:timer_loop(recover_time, function()
                self:vitality_recover()
            end)
        end
    end

    self.role:send_client("s_update_vitality", {vitality = self.db.vitality, vitality_ts = self.db.vitality_ts , taoxin_vitality = self.db.taoxin_vitality})
    return true
end

-- 改变桃心
function role_arena:change_taoxin(num, is_add)
    local param_data = excel_data.ParamData
    if is_add then
        self.db.taoxin_vitality = self.db.taoxin_vitality + num
        local max_num = param_data["vitality_max_num"].f_value
        if self.db.taoxin_vitality > max_num then
            self.db.taoxin_vitality = max_num
        end
    else
        if self.db.taoxin_vitality < num then return end
        self.db.taoxin_vitality = self.db.taoxin_vitality - num
    end
    self.role:send_client("s_update_vitality", {vitality = self.db.vitality, vitality_ts = self.db.vitality_ts , taoxin_vitality = self.db.taoxin_vitality})
    return true
end

-- 获取竞技场信息
function role_arena:get_arena_info()
    if not self.role:check_lineup_has_hero() then return end
    local arena = self.db.arena
    if not arena.history_rank then
        -- 第一次进入竞技场，初始化排名为最大排名+1
        arena.history_rank = arena_utils.set_arena_init_rank(self.uuid)
        self.role:send_client("s_update_arena_info", {arena_history_rank = arena.history_rank})
    end
    local self_rank = arena_utils.get_arena_rank(self.uuid)
    local role_data = {
        uuid = self.uuid,
        rank = self_rank,
        role_id = self.role:get_role_id(),
        name = self.role:get_name(),
        level = self.role:get_level(),
        vip = self.role:get_vip(),
        fight_score = self.role:get_fight_score(),
        title = self.role:get_title(),
    }
    self.fight_role_list = arena_utils.get_arena_role_list(role_data, arena.win_num)
    self.old_rank = self_rank
    return {
        role_list = self.fight_role_list,
        self_rank = self_rank
    }
end

-- 获取挑战玩家数据
function role_arena:get_arena_fight_role(uuid)
    if not self.fight_role_list then return end
    for _, role_data in ipairs(self.fight_role_list) do
        if role_data.uuid == uuid then
            return role_data
        end
    end
end

-- 挑战玩家
function role_arena:arena_challenge(fight_uuid)
    if not fight_uuid then return end
    if fight_uuid == self.uuid then return end
    local fight_role = self:get_arena_fight_role(fight_uuid)
    if not fight_role then return end
    local self_rank = arena_utils.get_arena_rank(self.uuid)
    if fight_role.rank ~= arena_utils.get_arena_rank(fight_uuid)
        or self.old_rank ~= self_rank then
        return {errcode = g_tips.ok, rank_change = true}
    end
    -- 前10名玩家要入榜前20才能挑战
    if fight_role.rank <= CSConst.ArenaTenRank then
        if self_rank > CSConst.ArenaChallengeLimit then return end
    end
    local own_fight_data = self.role:get_role_fight_data()
    if not own_fight_data then return end
    local cost_num = excel_data.ParamData["arena_cost_vitality"].f_value
    if not self:change_vitality(cost_num) then return end

    local fight_data = {
        seed = math.random(1, g_const.Fight_Random_Num),
        own_fight_data = own_fight_data,
        enemy_fight_data = fight_role.fight_data,
        is_pvp = true
    }
    local game = fight_game.New(fight_data)
    local is_win = game:GoToFight()
    local new_rank, rank_reward
    local item_list = {}
    local arena_config = arena_utils.get_arena_config(fight_role.rank)
    local arena = self.db.arena
    if is_win then
        -- 胜利
        if fight_role.rank < self_rank then
            -- 排名交换
            arena_utils.swap_arena_rank(self.uuid, fight_role.uuid)
            local old_rank = arena.history_rank
            if fight_role.rank < old_rank then
                -- 记录最高排名
                new_rank = fight_role.rank
                arena.history_rank = new_rank
                self.role:send_client("s_update_arena_info", {arena_history_rank = new_rank})
                local reward_num = 0
                local config = arena_utils.get_arena_config(old_rank)
                for i = config.id, 1, -1 do
                    local data = excel_data.ArenaData[i]
                    if new_rank <= data.rank_range[2] and new_rank >= data.rank_range[1] then
                        reward_num = reward_num + data.new_rank_reward * (old_rank - new_rank)
                        break
                    else
                        reward_num = reward_num + data.new_rank_reward * (old_rank - data.rank_range[1])
                        old_rank = data.rank_range[1]
                    end
                end
                -- 最高排名突破奖励
                if reward_num > 0 then
                    rank_reward = {[CSConst.Virtual.Diamond] = reward_num}
                    table.insert(item_list, {item_id = CSConst.Virtual.Diamond, count = reward_num})
                end
            end
            if excel_data.ArenaWinNumData[arena.win_num + 1] then
                -- 记录连胜次数, 战胜排名比自己高的才计数
                arena.win_num = arena.win_num + 1
            end
        end
        -- 胜利奖励
        local reward_list = drop_utils.roll_drop(arena_config.drop_id)
        self.victory_reward = table.sample(reward_list, VICTORY_REWARD_NUM)
        local reward_data = excel_data.RewardData[arena_config.victory_reward]
        table.extend(item_list, reward_data.item_list)

        self.role:update_daily_active(CSConst.DailyActiveTaskType.ArenaNum, 1)
        self.role:update_festival_activity_data(CSConst.FestivalActivityType.arena) -- 竞技场挑战胜利 (节日活动)
    else
        -- 清除连胜次数
        arena.win_num = 0
        local reward_data = excel_data.RewardData[arena_config.fail_reward]
        table.extend(item_list, reward_data.item_list)
    end
    -- 活力值奖励
    local level_data = excel_data.LevelData[self.role:get_level()]
    table.insert(item_list, {item_id = CSConst.Virtual.Exp, count = level_data.vitality_to_exp * cost_num})
    table.insert(item_list, {item_id = CSConst.Virtual.Money, count = level_data.vitality_to_money * cost_num})
    self.role.fight_reward = {item_list = item_list, reason = g_reason.arena_challenge}
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.ArenaNum, 1)
    self.role:update_task(CSConst.TaskType.ArenaNum, {progress = 1})

    return {
        errcode = g_tips.ok,
        fight_data = fight_data,
        is_win = is_win,
        new_rank = new_rank,
        reward_dict = CSFunction.item_list_to_dict(item_list),
        rank_reward = rank_reward
    }
end

-- 选择挑战胜利奖励（翻牌三选一）
function role_arena:arena_select_reward(reward_index)
    if not reward_index or not self.victory_reward then return end
    local item = self.victory_reward[reward_index]
    if not item then return end
    local reward_list = self.victory_reward
    self.victory_reward = nil
    self.role:add_item(item.item_id, item.count, g_reason.arena_select_reward)

    return {errcode = g_tips.ok, reward_list = reward_list}
end

-- 快速挑战（只能挑战比自己排名低的，必胜）
function role_arena:arena_quick_challenge(fight_uuid, challenge_count, auto_use_item)
    if not fight_uuid or not challenge_count then return end
    local fight_role = self:get_arena_fight_role(fight_uuid)
    if not fight_role then return end
    local self_rank = arena_utils.get_arena_rank(self.uuid)
    if fight_role.rank <= self_rank then return end
    local cost_num = excel_data.ParamData["arena_cost_vitality"].f_value
    local item_id = excel_data.ParamData["vitality_item_id"].item_id
    local item_count = self.role:get_item_count(item_id)
    local item_data = excel_data.ItemData[item_id]
    local arena_config = arena_utils.get_arena_config(fight_role.rank)
    local reward_list = drop_utils.roll_drop(arena_config.drop_id)
    local reward_data = excel_data.RewardData[arena_config.victory_reward]
    local old_level = self.role:get_level()
    local cost_item_count = 0
    local real_challenge_count = 0
    local random_reward = {}
    local reward_dict = {}
    for i = 1, challenge_count do
        if self.db.vitality < cost_num then
            if not auto_use_item then break end
            local need_item_count = (cost_num - self.db.vitality)/item_data.recover_count
            need_item_count = math.ceil(need_item_count)
            if not self.role:consume_item(item_id, need_item_count, g_reason.arena_quick_challenge) then break end
            self:change_vitality(need_item_count * item_data.recover_count, true)
            cost_item_count = cost_item_count + need_item_count
        end
        self:change_vitality(cost_num)
        real_challenge_count = real_challenge_count + 1
        local item_dict = {}
        -- 翻牌奖励
        local item = reward_list[math.random(#reward_list)]
        random_reward[item.item_id] = (random_reward[item.item_id] or 0) + item.count
        item_dict[item.item_id] = (item_dict[item.item_id] or 0) + item.count
        -- 固定奖励
        for _, v in ipairs(reward_data.item_list) do
            reward_dict[v.item_id] = (reward_dict[v.item_id] or 0) + v.count
            item_dict[v.item_id] = (item_dict[v.item_id] or 0) + v.count
        end
        -- 活力值奖励
        local level_data = excel_data.LevelData[old_level]
        local count = level_data.vitality_to_exp * cost_num
        reward_dict[CSConst.Virtual.Exp] = (reward_dict[CSConst.Virtual.Exp] or 0) + count
        item_dict[CSConst.Virtual.Exp] = (item_dict[CSConst.Virtual.Exp] or 0) + count
        count = level_data.vitality_to_money * cost_num
        reward_dict[CSConst.Virtual.Money] = (reward_dict[CSConst.Virtual.Money] or 0) + count
        item_dict[CSConst.Virtual.Money] = (item_dict[CSConst.Virtual.Money] or 0) + count
        self.role:add_item_dict(item_dict, g_reason.arena_quick_challenge, true)
        if old_level ~= self.role:get_level() then break end
    end
    if real_challenge_count <= 0 then
        return {errcode = g_tips.ok, real_challenge_count = real_challenge_count}
    end
    for k, v in pairs(random_reward) do
        self.role:send_client("s_notify_add_item", {item_id = k, count = v})
    end
    for k, v in pairs(reward_dict) do
        self.role:send_client("s_notify_add_item", {item_id = k, count = v})
    end
    self.role:update_daily_active(CSConst.DailyActiveTaskType.ArenaNum, real_challenge_count)
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.ArenaNum, real_challenge_count)
    self.role:update_task(CSConst.TaskType.ArenaNum, {progress = real_challenge_count})
    self.role:update_festival_activity_data(CSConst.FestivalActivityType.arena, {add_value = real_challenge_count}) -- 竞技场挑战胜利 (节日活动)

    return {
        errcode = g_tips.ok,
        cost_item_count = cost_item_count,
        random_reward = random_reward,
        reward_dict = reward_dict,
        real_challenge_count = real_challenge_count
    }
end

-- 获取竞技场排行榜
function role_arena:get_arena_rank_list()
    local rank_list = arena_utils.get_arena_rank_list()
    for _, v in ipairs(rank_list) do
        v.rank_score = v.fight_score
        if tonumber(v.uuid) > CSConst.ArenaRobotNum then
            v.dynasty_name = agent_utils.get_dynasty_name(v.uuid)
        end
    end
    return {
        rank_list = rank_list,
        self_rank = arena_utils.get_arena_rank(self.uuid),
        self_rank_score = self.role:get_fight_score()
    }
end

-- 清除缓存数据
function role_arena:clear_arena_info()
    self.fight_role_list = nil
    self.old_rank = nil
end

-- 使用活力物品
function role_arena:use_vitality_item(item_count)
    if not item_count then return end
    local param_data = excel_data.ParamData
    local item_id = param_data["vitality_item_id"].item_id
    local item_data = excel_data.ItemData[item_id]
    local add_num = item_data.recover_count * item_count
    local max_num = param_data["vitality_max_num"].f_value
    if self.db.vitality + add_num > max_num then return end
    if not self.role:consume_item(item_id, item_count, g_reason.use_vitality_item) then
        return
    end
    self:change_vitality(add_num, true)
    return true
end

-- 购买竞技场商店物品
function role_arena:arena_buy_shop_item(shop_id, shop_num)
    if not shop_id or not shop_num then return end
    if shop_num < 1 then return end
    local data = excel_data.ArenaShopData[shop_id]
    if not data then return end
    local arena = self.db.arena
    if data.rank_limit then
        if not arena.history_rank then return end
        if arena.history_rank > data.rank_limit then return end
    end
    local arena_shop = arena.shop_dict
    local new_num = arena_shop[shop_id] + shop_num
    if data.forever_num and new_num > data.forever_num then return end
    if data.daily_num and new_num > data.daily_num then return end

    local item_list = {}
    for i, item_id in ipairs(data.cost_item_list) do
        local count = math.floor(data.cost_item_value[i] * (data.discount or CSConst.DefaultDiscount) * 0.1)
        count = count == 0 and 1 or count
        table.insert(item_list, {item_id = item_id, count = count * shop_num})
    end
    if not self.role:consume_item_list(item_list, g_reason.arena_shop) then return end
    arena_shop[shop_id] = new_num
    local item_count = data.item_count * shop_num
    self.role:add_item(data.item_id, item_count, g_reason.arena_shop)
    self.role:send_client("s_update_arena_info", {arena_shop = arena_shop})
    self.role:gaea_log("ShopConsume", {
        itemId = data.item_id,
        itemCount = item_count,
        consume = item_list
    })
    return true
end

return role_arena