local excel_data = require("excel_data")
local rank_utils = require("rank_utils")
local role_utils = require("role_utils")
local fight_game = require("CSCommon.Fight.Game")
local CSFunction = require("CSCommon.CSFunction")

local role_train = DECLARE_MODULE("meta_table.train")

local ADD_ATTR_NUM = 3

function role_train.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
    }
    return setmetatable(self, role_train)
end

function role_train:init_train()
    local train_war = self.db.train_war
    local init_fight_num = excel_data.ParamData["train_war_init_fight_num"].f_value
    train_war.fight_num = init_fight_num
end

function role_train:daily_train()
    local train = self.db.train
    train.reset_num = 0
    self.role:send_client("s_update_train_info", train)

    local train_war = self.db.train_war
    local init_fight_num = excel_data.ParamData["train_war_init_fight_num"].f_value
    train_war.fight_num = init_fight_num
    train_war.buy_fight_num = 0
    self.role:send_client("s_update_train_war_info", train_war)

    local train_shop = self.db.train_shop
    for shop_id, data in pairs(excel_data.TrainShopData) do
        if not data.forever_num then
            train_shop[shop_id] = nil
        end
    end
    self.role:send_client("s_update_train_shop", {train_shop = train_shop})
end

function role_train:online_train()
    local train = self.db.train
    self.role:send_client("s_update_train_info", train)
    self.role:send_client("s_update_train_shop", {train_shop = self.db.train_shop})

    local train_war = self.db.train_war
    self.role:send_client("s_update_train_war_info", train_war)
end

-- 获取试炼关卡奖励
local function get_train_stage_reward(reward_id, item_list)
    local reward_list = excel_data.RewardData[reward_id].item_list
    local reward_dict = {}
    -- 每个奖励都可能暴击增加数量
    for _, item in ipairs(reward_list) do
        local count = item.count
        local rate = math.random()
        local crit_id
        for i, v in ipairs(excel_data.TrainCritData) do
            if rate < v.rate then
                count = math.floor(count * v.multiple)
                crit_id = i
                break
            end
            rate = rate - v.rate
        end
        reward_dict[item.item_id] = {count = count, crit = crit_id}
        table.insert(item_list, {item_id = item.item_id, count = count})
    end
    return reward_dict
end

-- 随机三条加成属性
local function get_add_attr_id_list()
    local add_attr_id_list = {}
    local id_list = excel_data.TrainAttrData["id_list"]
    for i = 1, ADD_ATTR_NUM do
        local id = id_list[i][math.random(1, #id_list[i])]
        add_attr_id_list[i] = id
    end
    return add_attr_id_list
end

-- 获取试炼层奖励
function role_train:get_train_layer_reward(layer_id, item_list)
    local train = self.db.train
    local layer_reward
    local layer_data = excel_data.TrainLayerData[layer_id]
    local layer_star_num = 0
    for _, num in ipairs(train.layer_star_num_list) do
        layer_star_num = layer_star_num + num
    end
    for i, star_num in ipairs(layer_data.star_num_list) do
        -- 根据每层获得的星数给奖励
        if layer_star_num < star_num then break end
        layer_reward = layer_data.reward_list[i]
    end
    local reward_list = excel_data.RewardData[layer_reward].item_list
    for _, item in ipairs(reward_list) do
        table.insert(item_list, {item_id = item.item_id, count = item.count})
    end
    -- 通关每一层可以获得额外属性加成（三选一）
    if layer_id ~= #excel_data.TrainLayerData then
        train.add_attr_id_list = get_add_attr_id_list()
    end
    return layer_reward
end

-- 挑战试炼关卡
function role_train:train_challenge_stage(difficulty)
    if not difficulty then return end
    local train = self.db.train
    if train.is_fail or #train.add_attr_id_list > 0 then return end
    local train_data = excel_data.TrainData[train.curr_stage]
    if not train_data then return end
    if difficulty <= 0 or difficulty > #train_data.difficulty_list then return end
    local own_fight_data = self.role:get_role_fight_data()
    if not own_fight_data then return end

    self:train_add_attr(own_fight_data)
    local monster_group_id = train_data.monster_group_list[difficulty]
    local monster_level = train_data.monster_level_list[difficulty]
    local fight_data = {
        seed = math.random(1, g_const.Fight_Random_Num),
        victory_id = train_data.victory_id,
        own_fight_data = own_fight_data,
        enemy_fight_data = role_utils.get_monster_fight_data(monster_group_id, monster_level)
    }
    local json = require("cjson")
    json.encode_sparse_array(true)
    print("======= own fight data: "..json.encode(fight_data.own_fight_data))
    print("======= monster fight data: "..json.encode(fight_data.enemy_fight_data))
    local game = fight_game.New(fight_data)
    local is_win = game:GoToFight()
    local reward_dict, layer_reward
    if is_win then
        -- 胜利
        local item_list = {}
        reward_dict, layer_reward = self:train_challenge_victory(train, difficulty, item_list)
        self.role.fight_reward = {item_list = item_list, reason = g_reason.train_challenge}
    else
        train.is_fail = true
    end

    self.role:send_client("s_update_train_info", train)
    return {
        errcode = g_tips.ok,
        fight_data = fight_data,
        is_win = is_win,
        reward_dict = reward_dict,
        layer_reward = layer_reward
    }
end

-- 试炼挑战胜利
function role_train:train_challenge_victory(db_train, difficulty, item_list, auto_select)
    local train_data = excel_data.TrainData[db_train.curr_stage]
    if difficulty == #train_data.difficulty_list then
        -- 记录最大难度通关的最高关卡
        if db_train.curr_stage > db_train.max_stage then
            db_train.max_stage = db_train.curr_stage
        end
    end
    local add_star_num = train_data.star_num_list[difficulty]
    db_train.curr_star_num = db_train.curr_star_num + add_star_num
    if db_train.curr_star_num > db_train.history_star_num then
        -- 记录最高星数
        local add_progress = db_train.curr_star_num - db_train.history_star_num
        db_train.history_star_num = db_train.curr_star_num
        self.role:update_role_rank("train_rank", db_train.history_star_num)
        self.role:update_cross_role_rank("cross_train_rank",db_train.history_star_num)--陈永帅
        self.role:update_task(CSConst.TaskType.TrainStar, {progress = add_progress})
        self.role:update_achievement(CSConst.AchievementType.TrainStar, add_progress)
    end
    db_train.can_use_star_num = db_train.can_use_star_num + add_star_num
    table.insert(db_train.layer_star_num_list, add_star_num)
    -- 通关奖励
    local reward_id = train_data.reward_list[difficulty]
    local reward_dict = get_train_stage_reward(reward_id, item_list)
    -- 每层奖励（每层最后一关才给）
    local layer_reward
    local stage_list = excel_data.TrainData["layer_dict"][train_data.layer]
    if stage_list[#stage_list] == db_train.curr_stage then
        layer_reward = self:get_train_layer_reward(train_data.layer, item_list)
        if auto_select then
            self:train_select_add_attr(nil, auto_select)
        end
    end
    db_train.curr_stage = db_train.curr_stage + 1
    self:check_open_train_war(db_train.curr_stage)
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.TrainStarNum, add_star_num)

    return reward_dict, layer_reward
end

-- 给上阵英雄加成属性（只在试炼玩法生效）
function role_train:train_add_attr(own_fight_data)
    local train = self.db.train
    if #train.add_attr_dict == 0 then return end
    for _, data in ipairs(own_fight_data) do
        if data.fight_attr_dict then
            for attr_name, value in pairs(train.add_attr_dict) do
                data.fight_attr_dict[attr_name] = (data.fight_attr_dict[attr_name] or 0) + value
            end
        end
    end
end

-- 选择加成属性
function role_train:train_select_add_attr(index, auto_select)
    local train = self.db.train
    if #train.add_attr_id_list == 0 then return end
    local data
    if auto_select then
        -- 自动选择最高加成
        for _, id in ipairs(train.add_attr_id_list) do
            data = excel_data.TrainAttrData[id]
            if train.can_use_star_num <= data.cost_star then break end
        end
    else
        if not index then return end
        local add_attr_id = train.add_attr_id_list[index]
        if not add_attr_id then return end
        data = excel_data.TrainAttrData[add_attr_id]
        if train.can_use_star_num < data.cost_star then return end
    end

    train.add_attr_id_list = {}
    train.layer_star_num_list = {}
    train.can_use_star_num = train.can_use_star_num - data.cost_star
    train.add_attr_dict[data.attr_name] = (train.add_attr_dict[data.attr_name] or 0) + data.attr_value

    if not auto_select then
        self.role:send_client("s_update_train_info", train)
    end
    return true
end

-- 快速挑战（按最高难度通关本层所有关卡）
function role_train:train_quick_challenge()
    local train = self.db.train
    if train.is_fail or #train.add_attr_id_list > 0 then return end
    local excel_train = excel_data.TrainData
    local train_data = excel_train[train.curr_stage]
    if not train_data then return end
    local stage_list = excel_train["layer_dict"][train_data.layer]
    local last_stage = excel_train[stage_list[#stage_list]]
    local fight_score = self.role:get_fight_score()
    -- 需要战力大于最后一关最高难度的推荐战力
    if fight_score < last_stage.score_list[#last_stage.score_list] then return end

    local result = {}
    local item_list = {}
    local reward_dict, layer_reward
    for i, stage_id in ipairs(stage_list) do
        if stage_id >= train.curr_stage then
            local difficulty = #train_data.difficulty_list
            reward_dict, layer_reward = self:train_challenge_victory(train, difficulty, item_list)
            table.insert(result, {stage_id = stage_id, reward_dict = reward_dict})
            reward_dict = nil
        end
    end
    local item_dict = CSFunction.item_list_to_dict(item_list)
    self.role:add_item_dict(item_dict, g_reason.train_quick_challenge)

    self.role:send_client("s_update_train_info", train)
    return {
        errcode = g_tips.ok,
        result = result,
        layer_reward = layer_reward
    }
end

-- 重置试炼关卡（回到第一层第一关）
function role_train:train_reset_stage()
    local train = self.db.train
    local reset_data = excel_data.TrainResetData[train.reset_num + 1]
    if not reset_data then return end
    if reset_data.cost_num > 0 then
        if not self.role:consume_item(reset_data.cost_item, reset_data.cost_num, g_reason.train_reset_stage) then return end
    end

    train.reset_num = train.reset_num + 1
    train.curr_stage = 1
    train.curr_star_num = 0
    train.can_use_star_num = 0
    train.layer_star_num_list = {}
    train.add_attr_dict = {}
    train.add_attr_id_list = {}
    train.has_buy_treasure = false
    train.is_fail = false

    self.role:send_client("s_update_train_info", train)
    self.role:update_daily_active(CSConst.DailyActiveTaskType.ResetTrialNum, 1)
    return true
end

-- 扫荡试炼关卡
function role_train:train_sweep_stage()
    local train = self.db.train
    if train.is_fail or #train.add_attr_id_list > 0 then return end
    if train.curr_stage > train.max_stage then return end

    local item_list = {}
    -- 扫荡到曾经通关的最高难度的最高关卡数
    local min_stage = train.curr_stage
    for i = min_stage, train.max_stage do
        local train_data = excel_data.TrainData[train.curr_stage]
        local difficulty = #train_data.difficulty_list
        self:train_challenge_victory(train, difficulty, item_list, true)
    end
    local item_dict = CSFunction.item_list_to_dict(item_list)
    self.role:add_item_dict(item_dict, g_reason.train_sweep)

    self.role:send_client("s_update_train_info", train)
    return {
        errcode = g_tips.ok,
        reward_list = item_list
    }
end

-- 购买秘宝
function role_train:train_buy_treasure()
    local train = self.db.train
    if train.has_buy_treasure then return end

    local data
    for _, v in ipairs(excel_data.TrainItemData) do
        data = v
        if train.curr_star_num <= v.star_num then break end
    end
    if not self.role:consume_item(data.cost_item, data.current_price, g_reason.train_buy_treasure) then return end
    train.has_buy_treasure = true
    self.role:add_item(data.item_id, data.item_count, g_reason.train_buy_treasure)

    self.role:send_client("s_update_train_info", train)
    return true
end

-- 获取试炼排行榜
function role_train:train_get_rank()
    local rank_info = rank_utils.get_rank_list("train_rank", self.uuid)
    rank_info.self_rank_score = self.db.train.history_star_num
    return rank_info
end

-- 检查是否开启新的试炼副本
function role_train:check_open_train_war(curr_stage)
    local train_war = self.db.train_war
    local war_data = excel_data.TrainWarData
    local max_war = #war_data
    if train_war.max_war >= max_war then return end
    local war = train_war.max_war + 1
    local has_change
    -- 试炼关卡到达一定关卡数就会开启试炼副本
    for i = war, max_war do
        if curr_stage <= war_data[i].open_stage then break end
        train_war.max_war = i
        has_change = true
    end
    if has_change then
        self.role:send_client("s_update_train_war_info", train_war)
    end
end

-- 挑战试炼副本
function role_train:train_war_challenge(war_id)
    if not war_id then return end
    local train_war = self.db.train_war
    if war_id > train_war.curr_war + 1 then return end
    if war_id > train_war.max_war then return end
    if train_war.fight_num <= 0 then return end
    local war_data = excel_data.TrainWarData[war_id]
    if not war_data then return end
    local own_fight_data = self.role:get_role_fight_data()
    if not own_fight_data then return end

    local fight_data = {
        seed = math.random(1, g_const.Fight_Random_Num),
        own_fight_data = own_fight_data,
        enemy_fight_data = role_utils.get_monster_fight_data(war_data.monster_group, war_data.monster_level)
    }
    local game = fight_game.New(fight_data)
    local is_win = game:GoToFight()
    local is_first
    if is_win then
        -- 胜利
        train_war.fight_num = train_war.fight_num - 1
        local item_list = {{item_id = war_data.reward_id, count = war_data.reward_count}}
        if war_id == train_war.curr_war + 1 then
            -- 首通
            is_first = true
            train_war.curr_war = train_war.curr_war + 1
            table.insert(item_list, {item_id = war_data.first_reward_id, count = war_data.first_reward_count})
        end
        self.role.fight_reward = {item_list = item_list, reason = g_reason.train_war_challenge}
        self.role:update_festival_activity_data(CSConst.FestivalActivityType.train) -- 试炼精英挑战 胜利次数统计 (节日活动)
    end

    self.role:send_client("s_update_train_war_info", train_war)
    return {
        errcode = g_tips.ok,
        fight_data = fight_data,
        is_win = is_win,
        is_first = is_first
    }
end

-- 购买试炼副本挑战次数
function role_train:train_war_buy_fight_num(num)
    if not num then return end
    local train_war = self.db.train_war
    local buy_fight_num = train_war.buy_fight_num
    local vip = self.role:get_vip()
    local max_buy_num = excel_data.VipData[vip].train_challenge_buy_time
    if buy_fight_num + num > max_buy_num then return end

    local item_dict = {}
    local num_data = excel_data.TrainWarNumData
    for i = buy_fight_num + 1, buy_fight_num + num do
        local data = num_data[i]
        if not data then
            data = num_data[#num_data]
        end
        item_dict[data.cost_item] = (item_dict[data.cost_item] or 0) + data.cost_num
    end
    if not self.role:consume_item_dict(item_dict, g_reason.train_war_buy_fight_num) then return end
    train_war.buy_fight_num = buy_fight_num + num
    train_war.fight_num = train_war.fight_num + num
    self.role:send_client("s_update_train_war_info", train_war)
    return true
end

-- 购买试炼商店物品
function role_train:train_buy_shop_item(shop_id, shop_num)
    if not shop_id or not shop_num then return end
    if shop_num < 1 then return end
    local data = excel_data.TrainShopData[shop_id]
    if not data then return end
    local train = self.db.train
    if data.star_num and train.history_star_num < data.star_num then return end
    local train_shop = self.db.train_shop
    local new_num = train_shop[shop_id] + shop_num
    if data.forever_num and new_num > data.forever_num then return end
    if data.daily_num and new_num > data.daily_num then return end

    local item_list = {}
    for i, item_id in ipairs(data.cost_item_list) do
        local count = math.floor(data.cost_item_value[i] * (data.discount or CSConst.DefaultDiscount) * 0.1)
        count = count == 0 and 1 or count
        table.insert(item_list, {item_id = item_id, count = count * shop_num})
    end
    if not self.role:consume_item_list(item_list, g_reason.train_shop) then return end
    train_shop[shop_id] = new_num
    local item_count = data.item_count * shop_num
    self.role:add_item(data.item_id, item_count, g_reason.train_shop)
    self.role:send_client("s_update_train_shop", {train_shop = train_shop})
    self.role:gaea_log("ShopConsume", {
        itemId = data.item_id,
        itemCount = item_count,
        consume = item_list
    })
    return true
end

return role_train