local excel_data = require("excel_data")
local timer = require("timer")
local date = require("sys_utils.date")
local cluster_utils = require("msg_utils.cluster_utils")
local CSFunction = require("CSCommon.CSFunction")
local fight_game = require("CSCommon.Fight.Game")
local fight_const = require("CSCommon.Fight.FConst")

local traitor_utils = DECLARE_MODULE("traitor_utils")
local TraitorCls = DECLARE_CLASS(traitor_utils, "TraitorCls")
DECLARE_RUNNING_ATTR(traitor_utils, "role_dict", {})
DECLARE_RUNNING_ATTR(traitor_utils, "pos_dict", {})
DECLARE_RUNNING_ATTR(traitor_utils, "is_open", nil)
DECLARE_RUNNING_ATTR(traitor_utils, "fight_ts", nil)
DECLARE_RUNNING_ATTR(traitor_utils, "fight_timer", nil)
DECLARE_RUNNING_ATTR(traitor_utils, "record_list", {})
DECLARE_RUNNING_ATTR(traitor_utils, "protect_timer_dict", {})

function traitor_utils.start()
    local now = date.time_second()
    local param_data = excel_data.ParamData
    local open_day = param_data["traitor_boss_open_day"].tb_int
    local open_time = param_data["traitor_boss_open_time"].tb_int
    local start_time = date.get_day_time(now, open_time[1])
    local close_time = date.get_day_time(now, open_time[2])
    local week_day = date.get_week_day(now)
    if open_day[week_day] then
        if now >= start_time and now < close_time then
            traitor_utils.open(true)
        end
    end
end

function traitor_utils.get_data()
    return _mgr:get(BOSS_ID)
end

-- 活动开始
function traitor_utils.open(is_start)
    if traitor_utils.is_open then return end
    traitor_utils.is_open = true
    for pos = 1, CSConst.CrossTraitorBossPosNum do
        traitor_utils.pos_dict[pos] = {}
    end
    local fight_time = excel_data.ParamData["cross_traitor_boss_loop_time"].f_value
    traitor_utils.fight_ts = date.time_second() + fight_time
    traitor_utils.fight_timer = timer.loop(fight_time, function()
        traitor_utils.fight()
    end)
    if not is_start then
        cluster_utils.send_cross_rank("ls_clear_rank_data", "cross_traitor_honour_rank")
        cluster_utils.send_cross_rank("ls_clear_rank_data", "cross_traitor_hurt_rank")
        cluster_utils.send_cross_dynasty("ls_clear_dynasty_rank", "cross_boss_honour_dynasty_rank")
    end
end

-- 活动结束
function traitor_utils.close()
    if not traitor_utils.is_open then return end
    traitor_utils.is_open = nil
    if traitor_utils.fight_timer then
        traitor_utils.fight_timer:cancel()
        traitor_utils.fight_timer = nil
    end
    traitor_utils.give_dynasty_rank_reward()
end

-- 更新叛军boss信息
function traitor_utils.update_traitor_info()
    if not traitor_utils.is_open then return end
    for uuid in pairs(traitor_utils.role_dict) do
        cluster_utils.send_agent(nil, uuid, "ls_update_cross_traitor_data", {
            pos_dict = traitor_utils.pos_dict,
            fight_ts = traitor_utils.fight_ts
        })
    end
end

-- 占领位置
function traitor_utils.occupy_pos(pos_id, role_info)
    if not traitor_utils.is_open then return end
    local uuid = role_info.uuid
    traitor_utils.role_dict[uuid] = true
    local pos_data = traitor_utils.pos_dict[pos_id]
    if not pos_data then return end
    local fight_data, is_win
    if pos_data.uuid then
        -- 该位置已有玩家
        if uuid == pos_data.uuid or pos_data.protect_ts then return end
        fight_data = {
            seed = math.random(1, g_const.Fight_Random_Num),
            own_fight_data = role_info.fight_data,
            enemy_fight_data = pos_data.fight_data,
            is_pvp = true
        }
        local game = fight_game.New(fight_data)
        is_win = game:GoToFight()
        if not is_win then
            return {fight_data = fight_data, is_win = is_win}
        end
    end
    -- 检查自己是否已占领位置
    for id, data in pairs(traitor_utils.pos_dict) do
        if data.uuid and data.uuid == uuid then
            traitor_utils.pos_dict[id] = {}
            break
        end
    end
    role_info.server_id = cluster_utils.get_server_id(uuid)
    traitor_utils.pos_dict[pos_id] = role_info
    local protect_ts = excel_data.ParamData["cross_traitor_boss_protect_time"].f_value
    role_info.protect_ts = date.time_second() + protect_ts
    if traitor_utils.protect_timer_dict[uuid] then
        traitor_utils.protect_timer_dict[uuid]:cancel()
    end
    traitor_utils.protect_timer_dict[uuid] = timer.once(protect_ts, function()
        traitor_utils.protect_timer_dict[uuid] = nil
        traitor_utils.update_role_protect_ts(pos_id)
    end)
    traitor_utils.update_traitor_info()
    return {fight_data = fight_data, is_win = is_win}
end

-- 更新占位保护时间
function traitor_utils.update_role_protect_ts(pos_id)
    local role_info = traitor_utils.pos_dict[pos_id]
    if not role_info.uuid then return end
    role_info.protect_ts = nil
    traitor_utils.update_traitor_info()
end

-- 与跨服叛军boss发生战斗
function traitor_utils.fight()
    if not traitor_utils.is_open then return end
    traitor_utils.record_list = {}
    local fight_time = excel_data.ParamData["cross_traitor_boss_loop_time"].f_value
    traitor_utils.fight_ts = date.time_second() + fight_time
    local boss_data = excel_data.CrossTraitorBossData[1]
    local enemy_fight_data = CSFunction.get_fight_data_by_group_id(boss_data.monster_group_id, boss_data.monster_level)
    local kick_pos_dict = {}
    for pos, data in pairs(traitor_utils.pos_dict) do
        if data.uuid then
            local fight_data = {
                seed = math.random(1, g_const.Fight_Random_Num),
                own_fight_data = data.fight_data,
                enemy_fight_data = enemy_fight_data,
            }
            local game = fight_game.New(fight_data)
            local is_win = game:GoToFight()
            local ret = game:GetFightResultInfo(fight_const.Side.Enemy)
            local hurt = ret.total_hp - ret.remain_hp
            local item_id = CSConst.Virtual.Diamond
            local item_count = boss_data.boss_reward
            local challenge_num = cluster_utils.call_agent(nil, data.uuid, "lc_update_cross_traitor_fight", {
                fight_data = fight_data,
                is_win = is_win,
                hurt = hurt,
                item_id = item_id,
                item_count = item_count
            })
            if challenge_num then
                local record_data = {
                    time = date.time_second(),
                    role_name = data.role_name,
                    hurt = hurt,
                    item_id = item_id,
                    item_count = item_count,
                    server_id = data.server_id
                }
                traitor_utils.set_record(record_data)
                if challenge_num <= 0 then
                    kick_pos_dict[pos] = true
                end
            end
        end
    end
    for pos in pairs(kick_pos_dict) do
        traitor_utils.pos_dict[pos] = {}
    end
    traitor_utils.update_traitor_info()
end

-- 保存战斗记录
function traitor_utils.set_record(record_data)
    table.insert(traitor_utils.record_list, record_data)
end

function traitor_utils.get_traitor_record()
    return traitor_utils.record_list
end

function traitor_utils.enter_traitor(uuid)
    traitor_utils.role_dict[uuid] = true
end

function traitor_utils.quit_traitor(uuid)
    traitor_utils.role_dict[uuid] = nil
    local is_change
    for id, data in pairs(traitor_utils.pos_dict) do
        if data.uuid and data.uuid == uuid then
            traitor_utils.pos_dict[id] = {}
            is_change = true
            break
        end
    end
    if is_change then
        traitor_utils.update_traitor_info()
    end
end

function traitor_utils.get_traitor_data(uuid)
    if not traitor_utils.is_open then return end
    traitor_utils.role_dict[uuid] = true
    return {
        fight_ts = traitor_utils.fight_ts,
        pos_dict = traitor_utils.pos_dict,
    }
end

function traitor_utils.send_dynasty(cmd, dynasty_id, ...)
    local server_id = cluster_utils.get_server_id_by_dynasty(dynasty_id)
    local node_name = require("launch_utils").get_service_node_name('.dynasty', server_id)
    cluster_utils.lua_send(node_name, '.dynasty', cmd, dynasty_id, ...)
end

-- 发放王朝排行奖励
function traitor_utils.give_dynasty_rank_reward()
    local dynasty_list = cluster_utils.call_cross_dynasty("lc_get_rank_dynasty_list", "cross_boss_honour_dynasty_rank")
    if not dynasty_list or not next(dynasty_list) then return end
    for _, data in ipairs(excel_data.DynastyHonourRankData) do
        for rank = data.rank_range[1], data.rank_range[2] do
            local dynasty_data = dynasty_list[rank]
            if dynasty_data then
                local item_list = excel_data.RewardData[data.cross_reward_id].item_list
                traitor_utils.send_dynasty(
                    "ls_give_dynasty_rank_reward",
                    dynasty_data.dynasty_id,
                    CSConst.MailId.TraitorBossDynastyRank,
                    {rank = rank},
                    item_list
                )
            end
        end
    end
end

return traitor_utils