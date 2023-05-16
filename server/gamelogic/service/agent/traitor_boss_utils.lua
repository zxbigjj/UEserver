local OfflineObjMgr = require("db.offline_db").OfflineObjMgr
local excel_data = require("excel_data")
local timer = require("timer")
local date = require("sys_utils.date")
local rank_utils = require("rank_utils")
local role_utils = require("role_utils")
local cluster_utils = require("msg_utils.cluster_utils")

local boss_utils = DECLARE_MODULE("traitor_boss_utils")
DECLARE_RUNNING_ATTR(boss_utils, "role_dict", {})
DECLARE_RUNNING_ATTR(boss_utils, "state_timer", nil)
DECLARE_RUNNING_ATTR(boss_utils, "revive_timer", nil)
DECLARE_RUNNING_ATTR(boss_utils, "challenge_num_timer", nil)
DECLARE_RUNNING_ATTR(boss_utils, "challenge_num_ts", nil)
DECLARE_RUNNING_ATTR(boss_utils, "record_list", {})

local CNAME = "TraitorBoss"
local _mgr = DECLARE_RUNNING_ATTR(boss_utils, "_mgr", nil, function()
    return OfflineObjMgr.new(require("schema_game")[CNAME])
end)

local BOSS_ID = "1"

function boss_utils.start()
    local data = _mgr:get(BOSS_ID)
    local now = date.time_second()
    local param_data = excel_data.ParamData
    local open_day = param_data["traitor_boss_open_day"].tb_int
    local open_time = param_data["traitor_boss_open_time"].tb_int
    local start_time = date.get_day_time(now, open_time[1])
    local close_time = date.get_day_time(now, open_time[2])
    local week_day = date.get_week_day(now)
    if data.is_open then
        if open_day[week_day] then
            if now < start_time then
                boss_utils.close()
                boss_utils.state_timer = timer.once(start_time - now, function()
                    boss_utils.state_timer = nil
                    boss_utils.open()
                end)
            elseif now >= close_time then
                boss_utils.close()
            else
                if data.revive_ts then
                    if now >= data.revive_ts then
                        boss_utils.revive()
                    else
                        boss_utils.revive_timer = timer.once(data.revive_ts - now, function()
                            boss_utils.revive_timer = nil
                            boss_utils.revive()
                        end)
                    end
                end
                boss_utils.state_timer = timer.once(close_time - now, function()
                    boss_utils.state_timer = nil
                    boss_utils.close()
                end)
                local challenge_recover_time = param_data["traitor_boss_challenge_recover_time"].f_value * CSConst.Time.Minute
                local delay = challenge_recover_time - (now - start_time)%challenge_recover_time
                boss_utils.challenge_num_ts = now + delay
                boss_utils.challenge_num_timer = timer.loop(challenge_recover_time, function()
                    boss_utils.challenge_num_recover()
                end, delay)
            end
        else
            boss_utils.close()
        end
    else
        if open_day[week_day] then
            if now < start_time then
                boss_utils.state_timer = timer.once(start_time - now, function()
                    boss_utils.state_timer = nil
                    boss_utils.open()
                end)
            elseif now < close_time then
                boss_utils.open()
            end
        end
    end
end

function boss_utils.daily_refresh()
    local data = _mgr:get(BOSS_ID)
    local now = date.time_second()
    local param_data = excel_data.ParamData
    local open_day = param_data["traitor_boss_open_day"].tb_int
    local open_time = param_data["traitor_boss_open_time"].tb_int
    local start_time = date.get_day_time(now, open_time[1])
    local week_day = date.get_week_day(now)
    if open_day[week_day] then
        if now < start_time and not boss_utils.state_timer then
            boss_utils.state_timer = timer.once(start_time - now, function()
                boss_utils.state_timer = nil
                boss_utils.open()
            end)
        end
    end
end

function boss_utils.save(data)
    _mgr:set(BOSS_ID, data)
end

function boss_utils.get_data()
    return _mgr:get(BOSS_ID)
end

-- 活动开启
function boss_utils.open()
    local data = _mgr:get(BOSS_ID)
    data.is_open = true
    data.challenge_recover_num = 0
    local param_data = excel_data.ParamData
    local level_param = param_data["traitor_boss_level_param"].f_value
    local new_level = data.boss_level - level_param
    new_level = new_level < 1 and 1 or new_level
    data.boss_level = new_level
    local boss_data = boss_utils.build_boss_info(new_level)
    data.max_hp = boss_data.max_hp
    data.hp_dict = boss_data.hp_dict
    boss_utils.save(data)

    local now = date.time_second()
    local open_time = param_data["traitor_boss_open_time"].tb_int
    local start_time = date.get_day_time(now, open_time[1])
    local close_time = date.get_day_time(now, open_time[2])
    boss_utils.state_timer = timer.once(close_time - now, function()
        boss_utils.state_timer = nil
        boss_utils.close()
    end)
    local challenge_recover_time = param_data["traitor_boss_challenge_recover_time"].f_value * CSConst.Time.Minute
    local delay = challenge_recover_time - (now - start_time)%challenge_recover_time
    boss_utils.challenge_num_ts = now + delay
    boss_utils.challenge_num_timer = timer.loop(challenge_recover_time, function()
        boss_utils.challenge_num_recover()
    end, delay)

    for _, uuid in pairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        if role then
            role.traitor:traitor_boss_open()
        end
    end
    cluster_utils.send_cross_traitor("ls_traitor_boss_open")
    cluster_utils.send_dynasty("ls_clear_traitor_honour")
    rank_utils.clear_rank_data("traitor_boss_honour_rank")
    rank_utils.clear_rank_data("traitor_boss_hurt_rank")
end

-- 活动结束
function boss_utils.close()
    local data = _mgr:get(BOSS_ID)
    data.is_open = nil
    boss_utils.save(data)
    if boss_utils.revive_timer then
        boss_utils.revive_timer:cancel()
        boss_utils.revive_timer = nil
    end
    if boss_utils.challenge_num_timer then
        boss_utils.challenge_num_timer:cancel()
        boss_utils.challenge_num_timer = nil
    end

    for _, uuid in pairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        if role then
            role.traitor:traitor_boss_close()
        end
    end
    boss_utils.give_rank_reward()
    cluster_utils.send_cross_traitor("ls_traitor_boss_close")
end

-- 挑战次数恢复
function boss_utils.challenge_num_recover()
    local data = _mgr:get(BOSS_ID)
    data.challenge_recover_num = data.challenge_recover_num + 1
    boss_utils.save(data)
    local challenge_recover_time = excel_data.ParamData["traitor_boss_challenge_recover_time"].f_value * CSConst.Time.Minute
    boss_utils.challenge_num_ts = date.time_second() + challenge_recover_time

    for _, uuid in pairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        if role then
            role.traitor:challenge_num_recover()
        end
    end
end

-- 构建叛军boss数据
function boss_utils.build_boss_info(boss_level)
    local boss_data = excel_data.TraitorBossData[boss_level]
    local fight_data = role_utils.get_monster_fight_data(boss_data.monster_group_id, boss_data.monster_level)
    local hp_dict = {}
    local max_hp = 0
    for pos, data in ipairs(fight_data) do
        if data.fight_attr_dict then
            hp_dict[pos] = data.fight_attr_dict["max_hp"]
            max_hp = max_hp + hp_dict[pos]
        end
    end
    return {hp_dict = hp_dict, max_hp = max_hp}
end

function boss_utils.add_role(uuid)
    boss_utils.role_dict[uuid] = true
end

function boss_utils.delete_role(uuid)
    boss_utils.role_dict[uuid] = nil
end

-- boss受到伤害
function boss_utils.on_hurt(hp_dict, role_name, hurt)
    local data = _mgr:get(BOSS_ID)
    data.hp_dict = hp_dict
    local boss_hp = 0
    for _, hp in pairs(data.hp_dict) do
        boss_hp = boss_hp + hp
    end
    if boss_hp <= 0 then
        boss_utils.death(role_name)
    end
    for uuid in pairs(boss_utils.role_dict) do
        local role = agent_utils.get_role(uuid)
        if role then
            role.traitor:update_traitor_boss_info(role_name, hurt)
        end
    end
end

-- boss死亡
function boss_utils.death(role_name)
    local data = _mgr:get(BOSS_ID)
    local new_level = data.boss_level + 1
    if excel_data.TraitorBossData[new_level] then
        data.boss_level = new_level
    end
    data.hp_dict = {}
    data.killed_role = role_name
    local now = date.time_second()
    local refresh_time = excel_data.ParamData["traitor_boss_refresh_time"].tb_int
    local revive_ts = math.random(refresh_time[1] - refresh_time[2], refresh_time[1] + refresh_time[2])
    data.revive_ts = now + revive_ts
    boss_utils.save(data)
    boss_utils.revive_timer = timer.once(revive_ts, function()
        boss_utils.revive_timer = nil
        boss_utils.revive()
    end)

    for _, uuid in pairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        if role then
            role.traitor:set_traitor_boss_reward_dict(data.boss_level)
        end
    end
end

-- boss复活
function boss_utils.revive()
    local data = _mgr:get(BOSS_ID)
    local boss_data = boss_utils.build_boss_info(data.boss_level)
    data.max_hp = boss_data.max_hp
    data.hp_dict = boss_data.hp_dict
    data.killed_role = nil
    data.revive_ts = nil
    boss_utils.save(data)

    for uuid in pairs(boss_utils.role_dict) do
        local role = agent_utils.get_role(uuid)
        if role then
            role.traitor:traitor_boss_revive()
        end
    end
end

function boss_utils.set_record(record_data)
    local record_num = excel_data.ParamData["traitor_boss_record_num"].f_value
    if #boss_utils.record_list >= record_num then
        table.remove(boss_utils.record_list, 1)
    end
    table.insert(boss_utils.record_list, record_data)
end

-- 发放奖励
function boss_utils.give_rank_reward()
    boss_utils.give_dynasty_rank_reward()
    boss_utils.give_honour_rank_reward()
    boss_utils.give_hurt_rank_reward()
end

function boss_utils.give_dynasty_rank_reward()
    local dynasty_list = cluster_utils.call_dynasty("lc_get_rank_dynasty_list", "traitor_boss_honour_dynasty_rank")
    if not dynasty_list or not next(dynasty_list) then return end
    for _, data in ipairs(excel_data.DynastyHonourRankData) do
        for rank = data.rank_range[1], data.rank_range[2] do
            local dynasty_data = dynasty_list[rank]
            if dynasty_data then
                local item_list = excel_data.RewardData[data.reward_id].item_list
                cluster_utils.send_dynasty(
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

function boss_utils.give_honour_rank_reward()
    rank_utils.give_rank_reward("traitor_boss_honour_rank")
end

function boss_utils.give_hurt_rank_reward()
    rank_utils.give_rank_reward("traitor_boss_hurt_rank")
end

return boss_utils