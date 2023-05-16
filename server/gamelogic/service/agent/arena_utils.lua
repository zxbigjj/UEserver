local schema_game = require("schema_game")
local excel_data = require("excel_data")
local name_utils = require("name_utils")
local timer = require("timer")
local date = require("sys_utils.date")
local cache_utils = require("cache_utils")
local role_utils = require("role_utils")
local attr_utils = require("attr_utils")
local server_data = require("server_data")

local arena_utils = DECLARE_MODULE("arena_utils")
DECLARE_RUNNING_ATTR(arena_utils, "uuid2rank", {})
DECLARE_RUNNING_ATTR(arena_utils, "all_rank", {})
DECLARE_RUNNING_ATTR(arena_utils, "save_timer", nil)
DECLARE_RUNNING_ATTR(arena_utils, "change_dict", {})

local ROLE_LIST_LEN = 1000

function arena_utils.init()
    local role_data = excel_data.RoleLookData
    local role_list = {}

    for i = 1, CSConst.ArenaRobotNum do
        local role_id = math.random(#role_data)
        local name = name_utils.rand_role_name(role_data[role_id].sex)
        local uuid = tostring(i)
        table.insert(role_list, {
            uuid = uuid,
            role_id = role_id,
            rank = i,
            name = name,
            seed = i
        })
        name_utils.use_role_name(uuid, name)
        if #role_list == ROLE_LIST_LEN then
            local rank_start = arena_utils.get_rank_start(i)
            schema_game.ArenaRank:insert(rank_start, {rank_start = rank_start, role_list = role_list})
            role_list = {}
        end
    end
    if next(role_list) then
        local rank_start = arena_utils.get_rank_start(CSConst.ArenaRobotNum)
        schema_game.ArenaRank:insert(rank_start, {rank_start = rank_start, role_list = role_list})
    end

    server_data.set_server_core("last_arena_rank", CSConst.ArenaRobotNum)
end

function arena_utils.get_rank_start(rank)
    if rank%ROLE_LIST_LEN == 0 then
        return (math.floor(rank/ROLE_LIST_LEN)-1)*ROLE_LIST_LEN + 1
    else
        return math.floor(rank/ROLE_LIST_LEN)*ROLE_LIST_LEN + 1
    end
end

function arena_utils.start()
    for _, arena_data in ipairs(schema_game.ArenaRank:load_many()) do
        for _, role_data in ipairs(arena_data.role_list) do
            arena_utils.uuid2rank[role_data.uuid] = role_data.rank
        end
        arena_utils.all_rank[arena_data.rank_start] = arena_data.role_list
    end
    arena_utils.save_timer = timer.loop(600, function() arena_utils.save_all_rank() end, 600)
    -- local json = require("cjson")
    -- json.encode_sparse_array(true)
    -- print("all rank: " .. json.encode(arena_utils.all_rank))
end

function arena_utils.save_all_rank()
    for rank_start, role_list in pairs(arena_utils.all_rank) do
        if arena_utils.change_dict[rank_start] then
            schema_game.ArenaRank:set_field({rank_start = rank_start}, {role_list = role_list})
        end
    end
    arena_utils.change_dict = {}
end

function arena_utils.get_arena_config(rank)
    local arena_config = excel_data.ArenaData
    if not rank then
        return arena_config[#arena_config]
    end
    for _, config in ipairs(arena_config) do
        if rank >= config.rank_range[1] and rank <= config.rank_range[2] then
            return config
        end
    end
end

-- 获取竞技场排行前X名
function arena_utils.get_arena_front_rank(front_rank)
    local role_list = {}
    for rank = 1, front_rank do
        table.insert(role_list, arena_utils.get_arena_role_data(rank))
    end
    return role_list
end

-- 获取竞技场玩家数据
function arena_utils.get_arena_role_data(rank)
    local rank_data = arena_utils.get_arena_rank_data(rank)
    local role_data
    if tonumber(rank_data.uuid) > CSConst.ArenaRobotNum then
        role_data = arena_utils.build_arena_role_data(rank_data)
    else
        role_data = arena_utils.build_arena_robot_data(rank_data)
    end
    return role_data
end

-- 获取排名数据
function arena_utils.get_arena_rank_data(rank)
    local rank_start = arena_utils.get_rank_start(rank)
    local role_list = arena_utils.all_rank[rank_start]
    return role_list[rank-rank_start+1]
end

-- 构建竞技场需要的玩家数据
function arena_utils.build_arena_role_data(rank_data)
    local uuid = rank_data.uuid
    local role_data = {uuid = uuid, rank = rank_data.rank}
    local role = agent_utils.get_role(uuid)
    if role then
        role_data.level = role:get_level()
        role_data.role_id = role:get_role_id()
        role_data.name = role:get_name()
        role_data.vip = role:get_vip()
        role_data.fight_data = role:get_role_fight_data()
        role_data.fight_score = role:get_fight_score()
        role_data.title = role:get_title()
    else
        local role_info = cache_utils.get_role_info(uuid, {"level","name","role_id","fight_score","vip","lineup_dict","hero_dict", "title"})
        role_data.level = role_info.level
        role_data.role_id = role_info.role_id
        role_data.name = role_info.name
        role_data.vip = role_info.vip.vip_level
        role_data.fight_data = role_utils.get_role_fight_data(role_info.lineup_dict, role_info.hero_dict)
        role_data.fight_score = role_info.fight_score
        role_data.title = role_info.title.wearing_id
    end
    return role_data
end

-- 构建竞技场机器人数据
function arena_utils.build_arena_robot_data(rank_data)
    local config = arena_utils.get_arena_config(rank_data.rank)
    local rand = math.new_rand(rank_data.seed)
    local level = rand:random(config.robot_level[1], config.robot_level[2])
    local vip = rand:random(config.robot_vip[1], config.robot_vip[2])
    local hero_lineup = config.hero_lineup[rand:random(1, #config.hero_lineup)]
    local lineup_data = excel_data.RobotLineupData[hero_lineup]
    local fight_score = 0
    local fight_data = {}
    for i, v in ipairs(lineup_data.pos_list) do
        if v.robot_hero_id then
            local hero_level = rand:random(config.hero_level[1], config.hero_level[2])
            fight_data[i] = role_utils.build_robot_hero_data(v.robot_hero_id, hero_level)
            fight_score = fight_score + fight_data[i].score
        else
            fight_data[i] = {}
        end
    end
    return {
        uuid = rank_data.uuid,
        rank = rank_data.rank,
        role_id = rank_data.role_id,
        name = rank_data.name,
        level = level,
        vip = vip,
        fight_score = fight_score,
        fight_data = fight_data
    }
end

-- 获取排名间隔
local function get_rank_interval(rank, win_num)
    for i, v in ipairs(excel_data.ArenaIntervalData) do
        if rank >= v.rank_range[1] and rank <= v.rank_range[2] then
            return v.rank_interval
        end
    end
    return excel_data.ArenaWinNumData[win_num].rank_interval
end

-- 获取竞技场挑战玩家列表
function arena_utils.get_arena_role_list(role_data, win_num)
    local role_list = arena_utils.get_arena_front_rank(CSConst.ArenaTenRank)
    local temp_list = {}
    local self_rank = arena_utils.uuid2rank[role_data.uuid]
    if self_rank <= CSConst.ArenaFrontNum then
        return role_list
    end
    local rank = self_rank
    for i = 1, CSConst.ArenaFrontNum do
        local rank_interval = get_rank_interval(rank, win_num)
        local random_rank = math.random(rank - rank_interval, rank - 1)
        if random_rank <= CSConst.ArenaTenRank then break end
        table.insert(temp_list, arena_utils.get_arena_role_data(random_rank))
        rank = rank - rank_interval
    end
    if #temp_list > 0 then
        for i = #temp_list, 1, -1 do
            table.insert(role_list, temp_list[i])
        end
    end
    if self_rank > CSConst.ArenaTenRank then
        table.insert(role_list, role_data)
    end
    rank = self_rank
    local last_arena_rank = server_data.get_server_core("last_arena_rank")
    for i = 1, CSConst.ArenaBackNum do
        local rank_interval = get_rank_interval(rank, win_num)
        local random_rank = math.random(rank + 1, rank + rank_interval)
        if random_rank > CSConst.ArenaTenRank then
            if random_rank > last_arena_rank then break end
            table.insert(role_list, arena_utils.get_arena_role_data(random_rank))
        end
        rank = rank + rank_interval
    end
    return role_list
end

-- 获取竞技场排行榜
function arena_utils.get_arena_rank_list()
    return arena_utils.get_arena_front_rank(CSConst.ArenaRankLen)
end

-- 获取竞技场排名
function arena_utils.get_arena_rank(uuid)
    return arena_utils.uuid2rank[uuid]
end

-- 排名交换
function arena_utils.swap_arena_rank(self_uuid, fight_uuid)
    local self_rank = arena_utils.get_arena_rank(self_uuid)
    local fight_rank = arena_utils.get_arena_rank(fight_uuid)
    arena_utils.uuid2rank[self_uuid] = fight_rank
    arena_utils.uuid2rank[fight_uuid] = self_rank

    local fight_data = arena_utils.get_arena_rank_data(fight_rank)
    fight_data.rank = self_rank
    local rank_start = arena_utils.get_rank_start(self_rank)
    local role_list = arena_utils.all_rank[rank_start]
    role_list[self_rank - rank_start + 1] = fight_data
    arena_utils.change_dict[rank_start] = true

    local self_data = {uuid = self_uuid, rank = fight_rank}
    local rank_start = arena_utils.get_rank_start(fight_rank)
    local role_list = arena_utils.all_rank[rank_start]
    role_list[fight_rank - rank_start + 1] = self_data
    arena_utils.change_dict[rank_start] = true
end

-- 发放排名奖励
function arena_utils.give_rank_reward(last_give_ts)
    if last_give_ts == 0 then return end
    local rank_data = excel_data.TotalRankData[CSConst.RankId.Arena]
    local reward_time = date.get_begin0(last_give_ts) + rank_data.give_reward_time * CSConst.Time.Hour
    local now = date.time_second()
    if last_give_ts < reward_time and now >= reward_time then
        if not rank_data.reward_tier then return end
        local last_arena_rank = server_data.get_server_core("last_arena_rank")
        local role_dict = {}
        for rank = 1, last_arena_rank do
            local uuid = arena_utils.get_arena_rank_data(rank).uuid
            if tonumber(uuid) > CSConst.ArenaRobotNum then
                local reward_id = role_utils.get_rank_reward(rank_data, rank)
                if not reward_id then break end
                local item_list = excel_data.RewardData[reward_id].item_list
                role_dict[uuid] = {rank = rank, item_list = table.deep_copy(item_list)}
            end
        end

        local count = 0
        for uuid, data in pairs(role_dict) do
            agent_utils.add_mail(uuid, {
                mail_id = CSConst.MailId.Arena,
                mail_args = {rank = data.rank},
                item_list = data.item_list
            })
            count = count + 1
            if count == 10 then
                skynet.sleep(1)
                count = 0
            end
        end
    end
end

-- 设置竞技场初始排名
function arena_utils.set_arena_init_rank(uuid)
    local last_arena_rank = server_data.get_server_core("last_arena_rank")
    print("value: " .. last_arena_rank)
    last_arena_rank = tonumber(last_arena_rank)
    local last_rank = last_arena_rank + 1
    server_data.set_server_core("last_arena_rank", last_rank)
    arena_utils.uuid2rank[uuid] = last_rank

    local rank_start = arena_utils.get_rank_start(last_rank)
    local role_list = arena_utils.all_rank[rank_start]
    if not role_list then
        arena_utils.all_rank[rank_start] = {}
        role_list = arena_utils.all_rank[rank_start]
        schema_game.ArenaRank:insert(rank_start, {rank_start = rank_start, role_list = role_list})
    end
    table.insert(role_list, {uuid = uuid, rank = last_rank})
    arena_utils.change_dict[rank_start] = true
    return last_rank
end

return arena_utils
