local excel_data = require("excel_data")
local role_utils = require("role_utils")
local drop_utils = require("drop_utils")
local name_utils = require("name_utils")
local cache_utils = require("cache_utils")
local schema_game = require("schema_game")
local fight_game = require("CSCommon.Fight.Game")
local fight_const = require("CSCommon.Fight.FConst")

local role_treasure = DECLARE_MODULE("meta_table.treasure")

local PLAYER_NUM = 2
local GRAB_PLAYER_NUM = 5
local RANDOM_UUID_LEN = 10
local VICTORY_REWARD_NUM = 3
local GRAB_TREASURE_NUM = 5

function role_treasure.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
        grab_data = nil,
        victory_reward = nil
    }
    return setmetatable(self, role_treasure)
end

function role_treasure:init_treasure()
    local treasure_dict = self.db.treasure_dict
    local item_dict = excel_data.ParamData["grab_init_blue_treasure_list"].item_dict
    for item_id in pairs(item_dict) do
        treasure_dict[item_id] = {}
    end
end

function role_treasure:online_treasure()
    local treasure_dict = {}
    for item_id, fragment_dict in pairs(self.db.treasure_dict) do
        treasure_dict[item_id] = {fragment_dict = fragment_dict}
    end
    print('=====online_treasure======' .. json.encode(treasure_dict))
    self.role:send_client("s_online_grab_treasure", {treasure_dict = treasure_dict})
end

-- 添加宝物碎片
function role_treasure:add_treasure_fragment(item_id, count)
    local item_data = excel_data.ItemData[item_id]
    if not item_data then return end
    if item_data.sub_type ~= CSConst.ItemSubType.EquipmentFragment then return end
    local treasure_id = item_data.equipment
    if not treasure_id then return end
    if excel_data.ItemData[treasure_id].is_treasure then
        local treasure_dict = self.db.treasure_dict
        if not treasure_dict[treasure_id] then
            treasure_dict[treasure_id] = {}
        end
        local fragment_dict = treasure_dict[treasure_id]
        fragment_dict[item_id] = (fragment_dict[item_id] or 0) + count
        self.role:send_client("s_update_grab_treasure", {
            treasure_id = treasure_id,
            fragment_dict = fragment_dict
        })
        return true
    end
end

-- 检查是否是有效碎片
local function check_treasure_fragment(fragment_list, fragment_id)
    for _, id in ipairs(fragment_list) do
        if fragment_id == id then
            return true
        end
    end
end

-- 获取抢夺玩家列表
function role_treasure:get_grab_role_list(treasure_id, fragment_id)
    if not treasure_id or not fragment_id then return end
    local fragment_dict = self.db.treasure_dict[treasure_id]
    if not fragment_dict then return end
    local item_data = excel_data.ItemData[treasure_id]
    if not check_treasure_fragment(item_data.fragment_list, fragment_id) then return end

    local quality_data = excel_data.QualityData[item_data.quality]
    local role_list = {}
    self:build_grab_role_data(quality_data, role_list)
    self:build_grab_robot_data(quality_data, role_list)
    self.grab_data = {
        treasure_id = treasure_id,
        fragment_id = fragment_id,
        role_list = role_list
    }
    return {errcode = g_tips.ok, role_list = role_list}
end

-- 构建夺宝玩家数据
function role_treasure:build_grab_role_data(config, role_list)
    local role_level = self.role:get_level()
    local min_level = role_level + config.player_level_range[1]
    local max_level = role_level + config.player_level_range[2]
    local uuid_list = self:random_role(min_level, max_level)
    for _, uuid in ipairs(uuid_list) do
        local role_data = {uuid = uuid}
        local role = agent_utils.get_role(uuid)
        if role then
            role_data.level = role:get_level()
            role_data.name = role:get_name()
            role_data.fight_data = role:get_role_fight_data()
        else
            local role_info = cache_utils.get_role_info(uuid, {"level","name","lineup_dict","hero_dict"})
            role_data.level = role_info.level
            role_data.name = role_info.name
            role_data.fight_data = role_utils.get_role_fight_data(role_info.lineup_dict, role_info.hero_dict)
        end
        if role_data.fight_data then
            role_data.hero_list = {}
            for _, v in ipairs(role_data.fight_data) do
                if v.hero_id then
                    table.insert(role_data.hero_list, v.hero_id)
                end
            end
            table.insert(role_list, role_data)
        end
    end
end

-- 随机本服玩家
function role_treasure:random_role(min_level, max_level)
    local uuid_list = {}
    -- 从在线玩家随机
    for _, uuid in pairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        local level = role:get_level()
        if level >= min_level and level <= max_level then
            if uuid ~= self.uuid then
                table.insert(uuid_list, uuid)
            end
        end
    end
    if #uuid_list >= RANDOM_UUID_LEN then
        return table.sample(uuid_list, PLAYER_NUM)
    end

    -- 从数据库随机
    uuid_list = {}
    for i = 1, 3 do
        local temp_list = {}
        local condition = string.format("random_num >= %d and level >= %d and level <= %d",
            math.random(1, g_const.Max_Random_Num),
            min_level,
            max_level
        )
        local data_list = schema_game.Role:load_many(condition, {"uuid"}, {random_num = 1}, PLAYER_NUM + 1)
        for _, data in ipairs(data_list) do
            if data.uuid ~= self.uuid then
                table.insert(temp_list, data.uuid)
                if #temp_list >= PLAYER_NUM then
                    return temp_list
                end
            end
        end
        if #temp_list > #uuid_list then
            uuid_list = temp_list
        end
    end
    return uuid_list
end

-- 获取机器人名字
local function get_robot_name(name_dict)
    local name_list = excel_data.RobotNameData[1].name
    while true do
        local name = name_list[math.random(1, #name_list)]
        if not name_dict[name] then
            name_dict[name] = true
            return name
        end
    end
end

-- 构建夺宝机器人数据
function role_treasure:build_grab_robot_data(config, role_list)
    local role_level = self.role:get_level()
    local min_level = role_level + config.robot_level_range[1]
    min_level = min_level > 0 and min_level or 1
    local max_level = role_level + config.robot_level_range[2]
    local name_dict = {}
    local robot_num = GRAB_PLAYER_NUM - #role_list
    for i = 1, robot_num do
        local name = get_robot_name(name_dict)
        local level = math.random(min_level, max_level)
        local hero_lineup = config.robot_hero_lineup[math.random(1, #config.robot_hero_lineup)]
        local lineup_data = excel_data.RobotLineupData[hero_lineup]
        local fight_data = {}
        local hero_list = {}
        for pos, v in ipairs(lineup_data.pos_list) do
            if v.robot_hero_id then
                fight_data[pos] = role_utils.build_robot_hero_data(v.robot_hero_id, level)
                table.insert(hero_list, fight_data[pos].hero_id)
            else
                fight_data[pos] = {}
            end
        end
        table.insert(role_list, {
            uuid = tostring(i),
            is_robot = true,
            level = level,
            name = name,
            hero_list = hero_list,
            fight_data = fight_data
        })
    end
end

-- 清除缓存数据
function role_treasure:clear_grab_role_list()
    self.grab_data = nil
end

-- 获取抢夺玩家数据
function role_treasure:get_fight_role(uuid)
    if not self.grab_data then return end
    for _, role_data in ipairs(self.grab_data.role_list) do
        if role_data.uuid == uuid then
            return role_data
        end
    end
end

-- 夺宝
function role_treasure:grab_treasure(fight_uuid)
    if not fight_uuid then return end
    local fight_role = self:get_fight_role(fight_uuid)
    if not fight_role then return end
    local own_fight_data = self.role:get_role_fight_data()
    if not own_fight_data then return end
    local param_data = excel_data.ParamData
    local cost_num = param_data["grab_treasure_cost_vitality"].f_value
    if not self.role:change_vitality(cost_num) then return end

    local fight_data = {
        seed = math.random(1, g_const.Fight_Random_Num),
        own_fight_data = own_fight_data,
        enemy_fight_data = fight_role.fight_data,
        is_pvp = true
    }
    local game = fight_game.New(fight_data)
    local is_win = game:GoToFight()
    local is_success
    local item_list = {}
    if is_win then
        -- 胜利
        local item_data = excel_data.ItemData[self.grab_data.treasure_id]
        local quality_data = excel_data.QualityData[item_data.quality]
        local rate = quality_data.player_rate
        if tonumber(fight_uuid) <= GRAB_PLAYER_NUM then
            rate = quality_data.robot_rate
        end
        if math.random() < rate then
            -- 成功抢夺碎片
            is_success = true
            table.insert(item_list, {item_id = self.grab_data.fragment_id, count = 1})
        end
        -- 胜利奖励
        local drop_id = param_data["grab_treasure_drop_id"].f_value
        local reward_list = drop_utils.roll_drop(drop_id)
        self.victory_reward = table.sample(reward_list, VICTORY_REWARD_NUM)
        self.role:update_daily_active(CSConst.DailyActiveTaskType.TreasureNum, 1)
    end
    -- 抢夺奖励（胜利和失败都有）
    local level_data = excel_data.LevelData[self.role:get_level()]
    local reward_dict = {}
    reward_dict[CSConst.Virtual.Exp] = level_data.vitality_to_exp * cost_num
    table.insert(item_list, {item_id = CSConst.Virtual.Exp, count = level_data.vitality_to_exp * cost_num})
    reward_dict[CSConst.Virtual.Money] = level_data.vitality_to_money * cost_num
    table.insert(item_list, {item_id = CSConst.Virtual.Money, count = level_data.vitality_to_money * cost_num})
    self.role.fight_reward = {item_list = item_list, reason = g_reason.grab_treasure}

    self.role:update_first_week_task(CSConst.FirstWeekTaskType.GrabNum, 1)
    self.role:update_task(CSConst.TaskType.GrabTreasure, {progress = 1})
    self.role:update_festival_activity_data(CSConst.FestivalActivityType.treasure, {add_value = 1}) -- 节日活动-夺宝次数
    return {
        errcode = g_tips.ok,
        fight_data = fight_data,
        is_win = is_win,
        is_success = is_success,
        reward_dict = reward_dict
    }
end

-- 选择夺宝胜利奖励（翻牌三选一）
function role_treasure:grab_treasure_select_reward(reward_index)
    if not reward_index or not self.victory_reward then return end
    local item = self.victory_reward[reward_index]
    if not item then return end
    local reward_list = self.victory_reward
    self.victory_reward = nil
    self.role:add_item(item.item_id, item.count, g_reason.grab_treasure_select_reward)

    return {errcode = g_tips.ok, reward_list = reward_list}
end

-- 夺宝5次
function role_treasure:grab_treasure_five_times(fight_uuid)
    if not fight_uuid then return end
    local fight_role = self:get_fight_role(fight_uuid)
    if not fight_role or not fight_role.is_robot then return end

    local item_data = excel_data.ItemData[self.grab_data.treasure_id]
    local quality_data = excel_data.QualityData[item_data.quality]
    local rate = quality_data.robot_rate
    local level_data = excel_data.LevelData[self.role:get_level()]
    local param_data = excel_data.ParamData
    local cost_num = param_data["grab_treasure_cost_vitality"].f_value
    local reward_dict = {}
    reward_dict[CSConst.Virtual.Exp] = level_data.vitality_to_exp * cost_num
    reward_dict[CSConst.Virtual.Money] = level_data.vitality_to_money * cost_num
    local drop_id = param_data["grab_treasure_drop_id"].f_value
    local reward_list = drop_utils.roll_drop(drop_id)
    local result = {}
    local item_dict = {}
    for i = 1, GRAB_TREASURE_NUM do
        if not self.role:change_vitality(cost_num) then break end
        local item = reward_list[math.random(#reward_list)]
        item_dict[item.item_id] = (item_dict[item.item_id] or 0) + item.count
        local is_success
        if math.random() < rate then
            is_success = true
            self.role:add_item(self.grab_data.fragment_id, 1, g_reason.grab_treasure)
        end
        table.insert(result, {
            is_success = is_success,
            reward_dict = reward_dict,
            random_reward = {[item.item_id] = item.count}
        })
        -- 成功抢夺则停止
        if is_success then
            self.role:update_daily_active(CSConst.DailyActiveTaskType.TreasureNum, 1)
            break
        end
    end
    local count = #result
    if count == 0 then return end
    for k, v in pairs(reward_dict) do
        item_dict[k] = (item_dict[k] or 0) + v * count
    end
    self.role:add_item_dict(item_dict, g_reason.grab_treasure)
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.GrabNum, count)
    self.role:update_task(CSConst.TaskType.GrabTreasure, {progress = count})
    self.role:update_festival_activity_data(CSConst.FestivalActivityType.treasure, {add_value = count}) -- 节日活动-夺宝次数
    return {errcode = g_tips.ok, result = result}
end

-- 快速夺宝
function role_treasure:quick_grab_treasure(treasure_id, auto_use_item)
    if not treasure_id then return end
    local param_data = excel_data.ParamData
    local open_level = param_data["quick_grab_treasure_open_level"].f_value
    if self.role:get_level() < open_level then return end
    local fragment_dict = self.db.treasure_dict[treasure_id]
    if not fragment_dict then return end
    local item_data = excel_data.ItemData[treasure_id]
    local quality_data = excel_data.QualityData[item_data.quality]
    local rate = quality_data.robot_rate
    local item_id = param_data["vitality_item_id"].item_id
    local has_item_count = self.role:get_item_count(item_id)
    local cost_num = param_data["grab_treasure_cost_vitality"].f_value
    local drop_id = param_data["grab_treasure_drop_id"].f_value
    local reward_list = drop_utils.roll_drop(drop_id)
    local grab_count = 0
    local cost_item_count = 0
    local random_reward = {}
    local item_dict = {}
    for _, fragment_id in ipairs(item_data.fragment_list) do
        if not fragment_dict[fragment_id] then
            while true do
                if not self.role:change_vitality(cost_num) then
                    if not auto_use_item then break end
                    if cost_item_count >= has_item_count then break end
                    if not self.role:consume_item(item_id, 1, g_reason.grab_treasure) then break end
                    cost_item_count = cost_item_count + 1
                    if not self.role:change_vitality(cost_num) then break end
                end
                grab_count = grab_count + 1
                -- 随机奖励
                local item = reward_list[math.random(#reward_list)]
                random_reward[item.item_id] = (random_reward[item.item_id] or 0) + item.count
                item_dict[item.item_id] = (item_dict[item.item_id] or 0) + item.count
                if math.random() < rate then
                    self.role:add_item(fragment_id, 1, g_reason.grab_treasure)
                    self.role:update_daily_active(CSConst.DailyActiveTaskType.TreasureNum, 1)
                    break
                end
            end
        end
    end
    if grab_count == 0 then return end

    -- 固定奖励
    local reward_dict = {}
    local level_data = excel_data.LevelData[self.role:get_level()]
    local count = level_data.vitality_to_exp * cost_num * grab_count
    reward_dict[CSConst.Virtual.Exp] = count
    item_dict[CSConst.Virtual.Exp] = (item_dict[CSConst.Virtual.Exp] or 0) + count
    count = level_data.vitality_to_money * cost_num * grab_count
    reward_dict[CSConst.Virtual.Money] = count
    item_dict[CSConst.Virtual.Money] = (item_dict[CSConst.Virtual.Money] or 0) + count
    self.role:add_item_dict(item_dict, g_reason.grab_treasure)
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.GrabNum, grab_count)
    self.role:update_task(CSConst.TaskType.GrabTreasure, {progress = grab_count})
    self.role:update_festival_activity_data(CSConst.FestivalActivityType.treasure, {add_value = grab_count}) -- 节日活动-夺宝次数

    return {
        errcode = g_tips.ok,
        reward_dict = reward_dict,
        random_reward = random_reward,
        grab_count = grab_count,
        cost_item_count = cost_item_count
    }
end

-- 宝物合成
function role_treasure:treasure_compose(treasure_id, compose_count)
    if not treasure_id or not compose_count then return end
    local fragment_dict = self.db.treasure_dict[treasure_id]
    if not fragment_dict then return end

    local item_data = excel_data.ItemData[treasure_id]
    local temp_dict = {}
    for _, fragment_id in ipairs(item_data.fragment_list) do
        if not fragment_dict[fragment_id] then return end
        if fragment_dict[fragment_id] < compose_count then return end
        temp_dict[fragment_id] = fragment_dict[fragment_id] - compose_count
        temp_dict[fragment_id] = temp_dict[fragment_id] ~= 0 and temp_dict[fragment_id] or nil
    end
    if not next(temp_dict) then
        local init_treasure = excel_data.ParamData["grab_init_blue_treasure_list"].item_dict
        if not init_treasure[treasure_id] then
            temp_dict = nil
        end
    end
    self.db.treasure_dict[treasure_id] = temp_dict
    self.role:add_item(treasure_id, compose_count, g_reason.treasure_compose)
    self.role:update_task(CSConst.TaskType.TreasureCompose, {progress = compose_count})
    self.role:update_daily_active(CSConst.DailyActiveTaskType.ComposeTreasure, compose_count)

    self.role:send_client("s_update_grab_treasure", {
        treasure_id = treasure_id,
        fragment_dict = temp_dict
    })
    return true
end

-- 宝物熔炼
function role_treasure:treasure_smelt(guid_list, treasure_id)
    print("---------- start to smelt------------" .. treasure_id)
    if not guid_list or not treasure_id then return print("reason: 1") end
    local treasure_data = excel_data.ItemData[treasure_id]
    if not treasure_data or not treasure_data.fragment_list then return print("reason: 2") end
    local fragment_id = treasure_data.fragment_list[1]
    if not fragment_id then return print("reason: 3") end
    local item_list = {}
    for _, item_guid in ipairs(guid_list) do
        local item = self.role:get_bag_item(item_guid)
        if not item then return print("reason: 4") end
        -- 培养过的不能熔炼
        if item.refine_lv > 0 or item.strengthen_exp > 0 or item.strengthen_lv > 1 then return print("reason: 5") end
        local item_data = excel_data.ItemData[item.item_id]
        if not item_data.is_treasure or not item_data.part_index then return print("reason: 6") end
        if treasure_data.quality ~= item_data.quality + 1 then return print("reason: 7") end
        table.insert(item_list, {guid = item_guid, count = 1})
    end

    local count = #guid_list
    if count == 0 then return end
    local treasure_smelt_cost = excel_data.ParamData["treasure_smelt_cost"]
    table.insert(item_list, {item_id = treasure_smelt_cost.item_id, count = treasure_smelt_cost.count * count})
    if not self.role:consume_item_list(item_list, g_reason.treasure_smelt) then return print("reason: 8") end
    self.role:add_item(fragment_id, count, g_reason.treasure_smelt)
    return true
end

return role_treasure
