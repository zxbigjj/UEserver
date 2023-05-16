local date = require("sys_utils.date")
local rank_utils = require("rank_utils")
local role_utils = require("role_utils")

local fight_game = require("CSCommon.Fight.Game")
local fight_const = require("CSCommon.Fight.FConst")

local flash_event_utils = require("flash_event_utils")
local role_flash_event = DECLARE_MODULE("meta_table.flash_event")

--------------------------------------------

function role_flash_event.new(role)
    local self = {
        role = role,
        db = role.db
    }
    return setmetatable(self, role_flash_event)
end

------------------------------------------------------------
-- 世界boss
-- 恢复出战英雄，可以重新出战
function role_flash_event:recover_world_boss_hero(hero_id)
    if not hero_id then return end
    local world_boss = self.db.world_boss
    if not world_boss.hero_dict[hero_id] then return end
    local param_data = nil -- excel_data.ParamData["hero_hunt_recover_item"]
    if not self.role:consume_item(param_data.item_id, param_data.count, "恢复英雄") then -- g_reason.hunt_hero_recover) then
        return
    end
    world_boss.hero_dict[hero_id] = nil
    return true
end

-- 设置世界boss出战英雄
function role_flash_event:set_world_boss_hero(map_id, hero_list)
    if not map_id or not hero_list then return end
    local world_boss = self.db.world_boss
    if world_boss.curr_map then return end
    local world_boss_map = world_boss.world_boss_map[map_id]
    if not world_boss_map then return end
    if world_boss_map.hero_list then return end
    -- local data = nil       -- excel_data.HuntGroundData[map_id]

    for _, hero_id in ipairs(hero_list) do
        -- 检查hero_id是否合法，是否重复出战
        if not self.role:get_hero(hero_id) then return end
        if world_boss.hero_dict[hero_id] then return end
    end
    for _, hero_id in ipairs(hero_list) do
        world_boss.hero_dict[hero_id] = true
    end

    self:set_curr_map(map_id)
    world_boss_map.hero_list = hero_list
    -- world_boss_map.arrow_num = data.arrow_num
    self.role:send_client("", {
        world_boss_map = {[map_id] = world_boss_map},
        hero_dict = world_boss.hero_dict
    })

    return true
end

-- 行军
function role_flash_event:set_world_boss_hero_marching()

    -- return
end

-- 减少行军时间
function role_flash_event:decline_world_boss_hero_marching_time(hero_id)
    local param_data = nil
    if not self.role:consume_item(param_data.item_id, param_data.count, "减少行军时间") then -- g_reason.hunt_hero_recover) then
        return
    end
    return true
end

-- 挑战世界boss
function role_flash_event:challenge_world_boss()
    local own_fight_data = self.role:get_role_fight_data()
    if not own_fight_data then return end
    local world_boss = self.db.world_boss

    local boss_data = flash_event_utils.get_data()  -- 空方法
    if not boss_data.is_open then return end
    local old_boss_hp = 0
    for _, hp in pairs(boss_data.hp_dict) do
        old_boss_hp = old_boss_hp + hp
    end
    if old_boss_hp <= 0 then return {} end
    self.role:send_client("", {
        -- challenge_num = world_boss.challenge_num,
        -- challenge_num_ts = flash_event_utils.challenge_num_ts
    })

    -- 战斗
    local config = nil         -- excel_data.TraitorBossData[boss_data.boss_level]
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
    flash_event_utils.on_hurt(result.hp_dict, role_name, hurt)  -- 空方法
    if hurt > world_boss.max_hurt then
        -- 记录最高伤害
        world_boss.max_hurt = hurt
        self.role:update_role_rank("", world_boss.max_hurt)
        self.role:update_cross_role_rank("", world_boss.max_hurt)
    end
    -- 计算获得荣誉值
    -- local honour = math.floor(hurt/excel_data.ParamData[""].f_value)
    -- honour = honour < 1 and 1 or honour
    -- world_boss.honour = world_boss.honour + honour
    -- self.role:update_role_rank("", world_boss.honour)
    -- self.role:update_cross_role_rank("", world_boss.honour)
    -- self:add_dynasty_honour(honour)
    self:set_world_boss_reward_dict()
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
        flash_event_utils.set_record(record_data)   -- 空方法
    end
    local kill_reward
    if new_boss_hp <= 0 then
        -- 世界boss死亡
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
        flash_event_utils.set_record(record_data)
    end
    -- 判断奖励是否暴击
    local coin_count = nil  -- excel_data.ParamData[""].f_value
    local rate = math.random()
    local crit_id
    for i, v in ipairs() do     -- excel_data.TraitorBossCritData) do
        if rate < v.rate then
            coin_count = math.floor(coin_count * v.multiple)
            crit_id = i
            break
        end
        rate = rate - v.rate
    end
    table.insert(item_list, {item_id = CSConst.Virtual.TraitorCoin, count = coin_count})
    self.role.fight_reward = {item_list = item_list, reason = "世界boss奖励"}

    return {
        fight_data = fight_data,
        is_win = is_win,
        -- honour = honour,
        crit_id = crit_id,
        lucky_reward = lucky_reward,
        kill_reward = kill_reward,
    }
end

-- 获取首通奖励
function role_flash_event:get_world_boss_first_reward(map_id)
    if not map_id then return end
    local data = nil   -- excel_data.HuntGroundData[map_id]
    -- if not data then return end
    local world_boss_map = self.db.world_boss.world_boss_map[map_id]
    if not world_boss_map then return end
    if not world_boss_map.first_reward then return end
    world_boss_map.first_reward = nil

    self.role:add_item_list(data.first_pass_award_list, "世界BOSS首通奖励")
    self.role:send_client("", {world_boss_map = {[map_id] = world_boss_map}})
    return true
end

------------------------------------------------------------
-- 设置当前狩猎场
function role_flash_event:set_curr_map(curr_map)
    if self.db.world_boss.curr_map == curr_map then return end
    self.db.world_boss.curr_map = curr_map
    self.role:send_client("", {curr_map = curr_map})
end

-- 设置世界boss奖励状态
function role_flash_event:set_world_boss_reward_dict(boss_level)
    local world_boss = self.db.world_boss
    for id, data in pairs() do -- excel_data.TraitorBossRewardData) do
        -- if (data.require_honour and world_boss.honour >= data.require_honour)
        --     or (boss_level and data.require_boss_level and boss_level >= data.require_boss_level) then
        --     if world_boss.reward_dict[id] == false then
        --         world_boss.reward_dict[id] = true
        --     end
        -- end
    end
end

-- 获取世界boss数据
function role_flash_event:get_world_boss_data()
    -- flash_event_utils.add_role(self.uuid)
    -- local world_boss = self.db.world_boss
    -- local honour_rank_info = rank_utils.get_rank_list("world_boss_honour_rank", self.uuid)
    -- local three_honour_rank = {}
    -- for i= 1, CSConst.TraitorBossThreeRank do
    --     local rank_info = honour_rank_info.rank_list[i]
    --     if not rank_info then break end
    --     table.insert(three_honour_rank, rank_info)
    -- end
    -- local max_hurt_rank = rank_utils.get_role_rank("", self.uuid)
    -- local dynasty_id = self.role:get_dynasty_id()
    -- local dynasty_rank = dynasty_id and cluster_utils.call_dynasty("lc_get_dynasty_rank_index", "world_boss_honour_dynasty_rank", dynasty_id)
    -- local cross_boss_button = CSConst.TraitorBossButton.Ok
    -- local param_data = nil      -- excel_data.ParamData
    -- local server_day = param_data["cross_world_boss_server_time"].f_value
    -- if agent_utils.get_server_day() < server_day then
    --     cross_boss_button = CSConst.TraitorBossButton.ServerDay
    -- end
    -- local fight_score = param_data["cross_world_boss_fight_score"].f_value
    -- local hurt = param_data["cross_world_boss_hurt"].f_value
    -- if self.db.max_fight_score < fight_score and world_boss.max_hurt < hurt then
    --     cross_boss_button = CSConst.TraitorBossButton.FightScoreHurt
    -- end
    -- self.cross_boss_button = cross_boss_button
    -- local boss_data = flash_event_utils.get_data()
    -- return {
    --     is_open = boss_data.is_open,
    --     honour = world_boss.honour,
    --     honour_rank = honour_rank_info.self_rank,
    --     max_hurt = world_boss.max_hurt,
    --     max_hurt_rank = max_hurt_rank,
    --     dynasty_rank = dynasty_rank,
    --     boss_level = boss_data.boss_level,
    --     three_honour_rank = three_honour_rank,
    --     max_hp = boss_data.max_hp,
    --     hp_dict = boss_data.hp_dict,
    --     challenge_num = world_boss.challenge_num,
    --     challenge_num_ts = flash_event_utils.challenge_num_ts,
    --     buy_challenge_num = world_boss.buy_challenge_num,
    --     revive_ts = boss_data.revive_ts,
    --     cross_boss_button = self.cross_boss_button,
    --     reward_dict = world_boss.reward_dict,
    --     killed_role = boss_data.killed_role
    -- }
end


return role_flash_event
