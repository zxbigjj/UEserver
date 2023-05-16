local role_stage = DECLARE_MODULE("meta_table.stage")

local excel_data = require("excel_data")
local date = require("sys_utils.date")
local attr_utils = require("attr_utils")
local drop_utils = require("drop_utils")
local fight_game = require("CSCommon.Fight.Game")
local fight_const = require("CSCommon.Fight.FConst")
local role_utils = require("role_utils")

function role_stage.new(role)
    local self = {
        role = role,
        urs = role.urs,
        uuid = role.uuid,
        db = role.db,
        action_point_timer = nil,
        city_resource_timer = nil,
    }
    return setmetatable(self, role_stage)
end

function role_stage:init_stage()
    local stage_data = excel_data.StageData[1]
    self.db.stage = {
        curr_stage = 1,
        curr_part = 1,
        action_point = excel_data.ParamData["stage_action_point_limit"].f_value,
        fight_stage_ts = date.time_second(),
    }
    local stage = self.db.stage
    stage.stage_dict[stage.curr_stage] = {first_reward = false, state = CSConst.Stage.State.New}
    if not stage_data.is_boss then
        stage.remain_enemy = stage_data.enemy_num[1]
    end
end

-- 每天刷新
function role_stage:daily_stage()
    local stage_dict = self.db.stage.stage_dict
    -- 刷新boss关卡的通关次数和重置次数
    for _, stage_info in pairs(stage_dict) do
        stage_info.victory_num = 0
        stage_info.reset_num = 0
    end
    self.role:send_client("s_update_stage_info", {stage_dict = stage_dict})
end

function role_stage:load_stage()
    local stage = self.db.stage
    local now = date.time_second()
    local param_data = excel_data.ParamData
    local limit_point = param_data["stage_action_point_limit"].f_value
    if stage.action_point < limit_point then
        local recover_time = param_data["action_point_recover_time"].f_value * CSConst.Time.Minute
        local add_num = math.floor((now - stage.fight_stage_ts) / recover_time)
        local total_num = add_num + stage.action_point
        if total_num < limit_point then
            -- 行动点未满，起恢复定时器
            stage.action_point = total_num
            stage.fight_stage_ts = stage.fight_stage_ts + recover_time * add_num
            local delay = recover_time - (now - stage.fight_stage_ts) % recover_time
            self.action_point_timer = self.role:timer_loop(recover_time, function()
                self:action_point_recover()
            end, delay)
        else
            stage.action_point = limit_point
            stage.fight_stage_ts = now
        end
    end

    if not stage.city_resource_ts then return end
    if not self:check_resource_is_limit() then
        local output_time = param_data["city_resource_output_time"].f_value * CSConst.Time.Minute
        local output_num = math.floor((now - stage.city_resource_ts) / output_time)
        if output_num > 0 then
            self:city_resource_output(output_num)
        end
        if not self:check_resource_is_limit() then
            -- 资源没有达到上限则起定时器
            stage.city_resource_ts = stage.city_resource_ts + output_time * output_num
            local delay = output_time - (now - stage.city_resource_ts) % output_time
            self.city_resource_timer = self.role:timer_loop(output_time, function()
                self:city_resource_output()
            end, delay)
        else
            stage.city_resource_ts = now
        end
    end
end

function role_stage:online_stage()
    local stage = self.db.stage
    self.role:send_client("s_update_stage_info", {
        curr_stage = stage.curr_stage,
        curr_part = stage.curr_part,
        remain_enemy = stage.remain_enemy,
        stage_dict = stage.stage_dict
    })
    self.role:send_client("s_update_city_info", {
        city_dict = stage.city_dict,
        resource_dict = stage.resource_dict
    })
    self.role:send_client("s_update_country_info", {country_dict = stage.country_dict})
    self.role:send_client("s_update_action_point", {action_point = stage.action_point, action_point_ts = stage.fight_stage_ts})
end

-- 城市资源产出，只有被占领的城市才会有资源产出
function role_stage:city_resource_output(output_num)
    local stage = self.db.stage
    if not output_num then
        stage.city_resource_ts = date.time_second()
    end
    output_num = output_num or 1
    local output_time = excel_data.ParamData["city_resource_output_time"].f_value * CSConst.Time.Minute
    local resource_limit_dict = self:get_resource_limit()
    local resource_dict = stage.resource_dict
    local city_dict = stage.city_dict
    for city_id, city in pairs(city_dict) do
        if city.is_occupied then
            local extra_output = self:get_resource_extra_output(city_id, city.manager_type, city.manager_id)
            local city_data = excel_data.CityData[city_id]
            for i, item_id in ipairs(city_data.item_list) do
                local value = (city_data.item_value_list[i] + (extra_output[item_id] or 0)) / CSConst.Time.Hour
                value = value * output_time * output_num
                value = math.floor(value)
                resource_dict[item_id] = (resource_dict[item_id] or 0) + value
                if resource_dict[item_id] > resource_limit_dict[item_id] then
                    -- 资源上限为所有城市上限之和
                    resource_dict[item_id] = resource_limit_dict[item_id]
                end
            end
        end
    end
    self.role:send_client("s_update_city_info", {resource_dict = resource_dict})

    if self:check_resource_is_limit() then
        -- 所有资源达到上限取消定时器
        if self.city_resource_timer then
            self.city_resource_timer:cancel()
            self.city_resource_timer = nil
        end
    end
end

-- 获取城市资源额外产出
function role_stage:get_resource_extra_output(city_id, manager_type, manager_id)
    if not manager_type then return {} end
    local attr_dict
    if manager_type == CSConst.CityManager.Hero then
        attr_dict = self.role:get_hero(manager_id).attr_dict
    elseif manager_type == CSConst.CityManager.Child then
        attr_dict = self.role:get_marry_attr(manager_id)
    end
    local attr_to_item = {}
    for attr, v in pairs(excel_data.AttributeData) do
        if v.city_income_item then
            attr_to_item[attr] = {item_id = v.city_income_item, rate = v.city_income_item_rate}
        end
    end
    local extra_output = {}
    for attr, v in pairs(attr_to_item) do
        extra_output[v.item_id] = math.floor((attr_dict[attr] or 0 ) * v.rate)
    end
    return extra_output
end

-- 获取占领城市资源上限
function role_stage:get_resource_limit()
    local resource_limit = {}
    local city_dict = self.db.stage.city_dict
    local vip = self.role:get_vip()
    local rate = excel_data.ParamData["default_city_income_limit_rate"].f_value + excel_data.VipData[vip].city_income_limit
    for city_id, city in pairs(city_dict) do
        if city.is_occupied then
            local extra_output = self:get_resource_extra_output(city_id, city.manager_type, city.manager_id)
            local city_data = excel_data.CityData[city_id]
            for i, item_id in ipairs(city_data.item_list) do
                resource_limit[item_id] = (resource_limit[item_id] or 0) + (city_data.item_value_list[i] + (extra_output[item_id] or 0))* rate
                resource_limit[item_id] = math.floor(resource_limit[item_id])
            end
        end
    end
    return resource_limit
end

-- 检查资源是否达到上限
function role_stage:check_resource_is_limit()
    local resource_dict = self.db.stage.resource_dict
    if #resource_dict == 0 then return end
    local resource_limit_dict = self:get_resource_limit()
    for item_id, value in pairs(resource_dict) do
        if value < resource_limit_dict[item_id] then
            return
        end
    end
    return true
end

-- 行动点恢复
function role_stage:action_point_recover()
    local stage = self.db.stage
    local limit_point = excel_data.ParamData["stage_action_point_limit"].f_value
    if stage.action_point < limit_point then
        stage.action_point = stage.action_point + 1
        stage.fight_stage_ts = date.time_second()
        self.role:send_client("s_update_action_point", {
            action_point = stage.action_point,
            action_point_ts = stage.fight_stage_ts
        })
    end
    -- 次数恢复到最大，取消定时器
    if stage.action_point >= limit_point then
        self.action_point_timer:cancel()
        self.action_point_timer = nil
    end
end

function role_stage:use_action_point_item(item_count)
    if not item_count then return end
    local param_data = excel_data.ParamData
    local item_id = param_data["stage_action_point_item"].item_id
    local item_data = excel_data.ItemData[item_id]
    local add_num = item_data.recover_count * item_count
    local max_num = param_data["stage_action_point_max_num"].f_value
    if self.db.stage.action_point + add_num > max_num then return end
    if not self.role:consume_item(item_id, item_count, g_reason.add_action_point) then
        return
    end
    self:change_action_point(add_num, true)
    return true
end

-- 改变行动点
function role_stage:change_action_point(num, is_add)
    local stage = self.db.stage
    local param_data = excel_data.ParamData
    local limit_point = param_data["stage_action_point_limit"].f_value
    if is_add then
        stage.action_point = stage.action_point + num
        local max_num = param_data["stage_action_point_max_num"].f_value
        if stage.action_point > max_num then
            stage.action_point = max_num
        end
        if stage.action_point >= limit_point and self.action_point_timer then
            self.action_point_timer:cancel()
            self.action_point_timer = nil
        end
    else
        if stage.action_point < num then return end
        stage.action_point = stage.action_point - num
        if stage.action_point < limit_point and not self.action_point_timer then
            stage.fight_stage_ts = date.time_second()
            local recover_time = param_data["action_point_recover_time"].f_value * CSConst.Time.Minute
            self.action_point_timer = self.role:timer_loop(recover_time, function()
                self:action_point_recover()
            end)
        end
        self.role:update_activity_data(CSConst.ActivityType.ConsumptionStamina, num) -- 限时活动-行动点消耗统计
    end

    self.role:send_client("s_update_action_point", {action_point = stage.action_point, action_point_ts = stage.fight_stage_ts})
    return true
end

function role_stage:enter_stage(stage_id)
    if not stage_id then return end
    local stage = self.db.stage
    local stage_info = stage.stage_dict[stage_id]
    if not stage_info then return end
    if stage_info.state == CSConst.Stage.State.New then
        stage_info.state = CSConst.Stage.State.UnPass
        self.role:send_client("s_update_stage_info", {stage_dict = {[stage.curr_stage] = stage_info}})
    end
    return true
end

-- 普通关卡
function role_stage:stage_fight()
    local stage = self.db.stage
    local stage_data = excel_data.StageData[stage.curr_stage]
    if not stage_data then return end
    if stage.action_point < stage_data.cost_action_point then return end
    if stage_data.is_boss then return end
    local stage_info = stage.stage_dict[stage.curr_stage]
    if stage_info.state == CSConst.Stage.State.New then
        stage_info.state = CSConst.Stage.State.UnPass
        self.role:send_client("s_update_stage_info", {stage_dict = {[stage.curr_stage] = stage_info}})
    end
    local self_fight = self.role:get_attr_value("fight")
    local self_num = self.role:get_currency(CSConst.Virtual.Soldier)
    local enemy_fight = stage_data.enemy_military[stage.curr_part]
    local enemy_num = stage.remain_enemy
    local is_win, self_cost, enemy_cost, item_list
    if self_num / enemy_fight >= enemy_num / self_fight then
        -- 胜利
        is_win = true
        self_cost = enemy_num / self_fight * enemy_fight
        self_cost = math.ceil(self_cost)
        if self_cost > self_num then
            self_cost = self_num
        end
        self.role:consume_item(CSConst.Virtual.Soldier, self_cost, g_reason.stage_fight)
        enemy_cost = enemy_num

        -- 判断当前小节是否为关卡的最后一节
        local stage_dict
        if stage.curr_part >= #stage_data.enemy_num then
            self:change_action_point(stage_data.cost_action_point)
            stage_info.state = CSConst.Stage.State.FirstPass
            stage_info.first_reward = true
            stage_dict = {[stage.curr_stage] = stage_info}
            stage.curr_stage = stage.curr_stage + 1
            stage.curr_part = 1
            local new_data = excel_data.StageData[stage.curr_stage]
            if new_data and not new_data.is_boss then
                stage.remain_enemy = new_data.enemy_num[stage.curr_part]
            else
                stage.remain_enemy = nil
            end
            stage.stage_dict[stage.curr_stage] = {first_reward = false, state = CSConst.Stage.State.New}
            stage_dict[stage.curr_stage] = stage.stage_dict[stage.curr_stage]
            self.role:stage_to_criminal()

            -- 最后小节才给奖励
            item_list = {}
            local level_data = excel_data.LevelData[self.role:get_level()]
            table.insert(item_list, {item_id = CSConst.Virtual.Exp, count = level_data.action_point_to_exp * stage_data.cost_action_point})
            table.insert(item_list, {item_id = CSConst.Virtual.Money, count = level_data.action_point_to_money * stage_data.cost_action_point})
            if stage_data.stage_drop then
                table.extend(item_list, drop_utils.roll_drop(stage_data.stage_drop))
            end
            self.role.fight_reward = {item_list = item_list, reason = g_reason.stage_reward}
            self.role:update_daily_active(CSConst.DailyActiveTaskType.StageNum, 1)
            self:on_new_stage(stage.curr_stage)
        else
            stage.curr_part = stage.curr_part + 1
            stage.remain_enemy = stage_data.enemy_num[stage.curr_part]
        end

        self.role:send_client("s_update_stage_info", {
            curr_stage = stage.curr_stage,
            remain_enemy = stage.remain_enemy,
            curr_part = stage.curr_part,
            stage_dict = stage_dict
        })
    else
        -- 失败
        enemy_cost = self_num / enemy_fight * self_fight
        local remain_enemy = enemy_num - math.ceil(enemy_cost)
        if remain_enemy <= 0 then
            remain_enemy = 1
        end
        self.role:consume_item(CSConst.Virtual.Soldier, self_num, g_reason.stage_fight)
        self_cost = self_num
        stage.remain_enemy = remain_enemy
        self.role:send_client("s_update_stage_info", {remain_enemy = stage.remain_enemy})
    end

    return {
        errcode = g_tips.ok,
        is_win = is_win,
        self_cost = self_cost,
        enemy_cost = enemy_cost,
        item_list = item_list
    }
end

-- boss关卡
function role_stage:boss_stage_fight(stage_id)
    local stage = self.db.stage
    if not stage_id or stage_id > stage.curr_stage then return end
    local stage_data = excel_data.StageData[stage_id]
    if not stage_data or not stage_data.is_boss then return end
    local boss_stage = stage.stage_dict[stage_id]
    if not boss_stage then return end
    if boss_stage.victory_num >= stage_data.victory_num then return end
    if stage.action_point < stage_data.cost_action_point then return end
    local own_fight_data = self.role:get_role_fight_data()
    if not own_fight_data then return end
    if boss_stage.state == CSConst.Stage.State.New then
        boss_stage.state = CSConst.Stage.State.UnPass
    end

    local item_list
    local traitor_info
    local fight_data = {
        seed = math.random(1, g_const.Fight_Random_Num),
        victory_id = stage_data.victory_id,
        own_fight_data = own_fight_data,
        enemy_fight_data = role_utils.get_monster_fight_data(stage_data.monster_group_id, stage_data.monster_level)
    }
    local game = fight_game.New(fight_data)
    local is_win = game:GoToFight()
    if is_win then
        -- 胜利
        if stage_id == stage.curr_stage then
            -- 第一次通关
            boss_stage.state = CSConst.Stage.State.FirstPass
            boss_stage.first_reward = true
            stage.curr_stage = stage.curr_stage + 1
            local new_data = excel_data.StageData[stage.curr_stage]
            if new_data and not new_data.is_boss then
                stage.remain_enemy = new_data.enemy_num[stage.curr_part]
            end
            stage.stage_dict[stage.curr_stage] = {first_reward = false, state = CSConst.Stage.State.New}
            self.role:send_client("s_update_stage_info", {
                stage_dict = {[stage.curr_stage] = stage.stage_dict[stage.curr_stage]}
            })
            self.role:stage_to_criminal()
            self:on_new_stage(stage.curr_stage)
        else
            boss_stage.state = CSConst.Stage.State.Pass
        end

        -- 胜利才扣除行动点，失败不扣
        self:change_action_point(stage_data.cost_action_point)
        boss_stage.victory_num = boss_stage.victory_num + 1
        local result = game:GetFightResultInfo(fight_const.Side.Own)
        local star_num = role_utils.get_boss_stage_star_num(stage_data.victory_id, result)
        if not boss_stage.star_num or star_num > boss_stage.star_num then
            -- 记录最高星星评分
            local add_star_num = star_num - (boss_stage.star_num or 0)
            self:add_city_star_num(stage_data.city_id, add_star_num)
            boss_stage.star_num = star_num
            self.role:update_achievement(CSConst.AchievementType.StageStar, add_star_num)
        end

        -- 消耗行动点奖励
        item_list = {}
        local level_data = excel_data.LevelData[self.role:get_level()]
        table.insert(item_list, {item_id = CSConst.Virtual.Exp, count = level_data.action_point_to_exp * stage_data.cost_action_point})
        table.insert(item_list, {item_id = CSConst.Virtual.Money, count = level_data.action_point_to_money * stage_data.cost_action_point})
        -- 通关奖励
        if stage_data.stage_drop then
            table.extend(item_list, drop_utils.roll_drop(stage_data.stage_drop))
        end
        self.role.fight_reward = {item_list = item_list, reason = g_reason.stage_reward}
        traitor_info = self:check_traitor(stage_data.cost_action_point)
        self.role:update_daily_active(CSConst.DailyActiveTaskType.StageNum, 1)
        self.role:update_festival_activity_data(CSConst.FestivalActivityType.stage) -- 节日活动-攻略关卡boss
    end
    self.role:send_client("s_update_stage_info", {
        curr_stage = stage.curr_stage,
        remain_enemy = stage.remain_enemy,
        stage_dict = {[stage_id] = boss_stage}
    })

    return {
        errcode = g_tips.ok,
        fight_data = fight_data,
        is_win = is_win,
        item_list = item_list,
        traitor_info = traitor_info
    }
end

-- 检查是否出现叛军
function role_stage:check_traitor(cost_action_point, is_auto_kill)
    local level_limit = excel_data.FuncUnlockData[CSConst.FuncUnlockId.Traitor].level or 1
    local appear_ratio = excel_data.ParamData["traitor_appear_ratio"].f_value
    if self.role:get_level() >= level_limit and math.random() < cost_action_point/appear_ratio then
        return self.role:add_traitor(is_auto_kill)
    end
end

-- 扫荡boss关卡
function role_stage:sweep_boss_stage(stage_id, is_first)
    local stage = self.db.stage
    if not stage_id or stage_id > stage.curr_stage then return end
    local stage_data = excel_data.StageData[stage_id]
    if not stage_data or not stage_data.is_boss then return end
    local boss_stage = stage.stage_dict[stage_id]
    if boss_stage.victory_num >= stage_data.victory_num then return end
    -- 评价满星才能扫荡
    if boss_stage.star_num < CSConst.Stage.MaxStar then return end
    if not self:change_action_point(stage_data.cost_action_point) then return end

    boss_stage.state = CSConst.Stage.State.Pass
    boss_stage.victory_num = boss_stage.victory_num + 1
    local item_list = {}
    local level_data = excel_data.LevelData[self.role:get_level()]
    table.insert(item_list, {item_id = CSConst.Virtual.Exp, count = level_data.action_point_to_exp * stage_data.cost_action_point})
    table.insert(item_list, {item_id = CSConst.Virtual.Money, count = level_data.action_point_to_money * stage_data.cost_action_point})
    table.extend(item_list, drop_utils.roll_drop(stage_data.stage_drop))
    self.role:add_item_list(item_list, g_reason.stage_reward)
    local traitor_info = self:check_traitor(stage_data.cost_action_point, not is_first)
    self.role:update_daily_active(CSConst.DailyActiveTaskType.StageNum, 1)
    self.role:update_festival_activity_data(CSConst.FestivalActivityType.stage) -- 节日活动-攻略关卡boss

    self.role:send_client("s_update_stage_info", {stage_dict = {[stage_id] = boss_stage}})
    return {
        errcode = g_tips.ok,
        item_list = item_list,
        traitor_info = traitor_info
    }
end

-- 重置boss关卡
function role_stage:reset_boss_stage(stage_id)
    if not stage_id then return end
    local boss_stage = self.db.stage.stage_dict[stage_id]
    if not boss_stage then return end
    local stage_data = excel_data.StageData[stage_id]
    -- 通关次数用完后才能重置
    if boss_stage.victory_num < stage_data.victory_num then return end
    local extra_reset_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.StageResetNum)
    if boss_stage.reset_num >= stage_data.reset_num + extra_reset_num then return end
    local reset_data = excel_data.StageResetData
    local data = reset_data[boss_stage.reset_num + 1]
    if not data then
        data = reset_data[#reset_data]
    end
    if not self.role:consume_item(data.cost_item, data.cost_num, g_reason.reset_stage) then
        return
    end

    boss_stage.reset_num = boss_stage.reset_num + 1
    boss_stage.victory_num = 0
    self.role:send_client("s_update_stage_info", {
        stage_dict = {[stage_id] = boss_stage}
    })
    return true
end

-- 获取关卡首通奖励
function role_stage:get_stage_first_reward(stage_id, item_list)
    if not stage_id then return end
    local stage_info = self.db.stage.stage_dict[stage_id]
    if not stage_info or not stage_info.first_reward then return end
    local stage_data = excel_data.StageData[stage_id]
    if not stage_data.reward_list then return end

    stage_info.first_reward = nil
    self.role:add_item_list(stage_data.reward_list, g_reason.stage_reward)
    if item_list then
        table.extend(item_list, stage_data.reward_list)
    end

    self.role:send_client("s_update_stage_info", {
        stage_dict = {[stage_id] = stage_info}
    })
    return true
end
-------------------------------城市 国家-------------------------------------
-- 增加城市评分星星数量
function role_stage:add_city_star_num(city_id, star_num)
    local stage = self.db.stage
    local city = stage.city_dict[city_id]
    if not city then
        stage.city_dict[city_id] = {}
        city = stage.city_dict[city_id]
        local city_data = excel_data.CityData[city_id]
        for i in ipairs(city_data.star_num_list) do
            city.reward_dict[i] = false
        end
    end
    city.star_num = city.star_num + star_num
    self:set_city_star_reward(city_id)

    local city_info = excel_data.StageData["city_dict"][city_id]
    if stage.curr_stage > city_info.last_stage
        and city.star_num >= #city_info.boss_stage_list * CSConst.Stage.MaxStar then
        -- 该城市全部满星通关，则算被占领
        city.is_occupied = true
        if not stage.city_resource_ts then
            -- 城市被占领了，每隔一段时间会有资源产出，所有城市共用一个定时器
            stage.city_resource_ts = date.time_second()
        end
        self:set_city_resource_timer()

        local city_data = excel_data.CityData[city_id]
        self:add_occupy_city_num(city_data.country_id)
    end
    self.role:send_client("s_update_city_info", {city_dict = {[city_id] = city}})

    self.role:update_task(CSConst.TaskType.StageStar, {progress = star_num})
    --跨服星星排行榜
    self.role:update_cross_role_rank("cross_stage_start_rank", self:get_stage_star())
    self.role:update_role_rank("stage_star_rank", self:get_stage_star())
end

-- 设置城市星星奖励领取状态
function role_stage:set_city_star_reward(city_id)
    local city = self.db.stage.city_dict[city_id]
    if not city then return end
    local reward_dict = city.reward_dict
    local city_data = excel_data.CityData[city_id]
    local has_change
    for i, star_num in ipairs(city_data.star_num_list) do
        if reward_dict[i] == false and city.star_num >= star_num then
            has_change = true
            reward_dict[i] = true
        end
    end

    if has_change then
        self.role:send_client("s_update_city_info", {city_dict = {[city_id] = city}})
    end
end

-- 获取城市星星评分奖励
function role_stage:get_city_star_reward(city_id, reward_index, item_list)
    if not city_id or not reward_index then return end
    local city = self.db.stage.city_dict[city_id]
    if not city then return end
    local reward_dict = city.reward_dict
    if not reward_dict[reward_index] then return end

    reward_dict[reward_index] = nil
    local city_data = excel_data.CityData[city_id]
    local reward_data = excel_data.RewardData[city_data.reward_list[reward_index]]
    self.role:add_item_list(reward_data.item_list, g_reason.city_star_reward)
    if item_list then
        table.extend(item_list, reward_data.item_list)
    end

    self.role:send_client("s_update_city_info", {city_dict = {[city_id] = city}})
    return true
end

-- 获取城市所有未领奖励（包括关卡首通奖励和星星评分奖励）
function role_stage:get_city_all_reward(city_id)
    local city_info = excel_data.StageData["city_dict"][city_id]
    if not city_info then return end

    local item_list = {}
    for _, stage_id in ipairs(city_info.boss_stage_list) do
        self:get_stage_first_reward(stage_id, item_list)
    end
    local city = self.db.stage.city_dict[city_id]
    if not city then return end
    for index in pairs(city.reward_dict) do
        self:get_city_star_reward(city_id, index, item_list)
    end

    return item_list
end

-- 获取所有城市的未领奖励
function role_stage:get_all_city_reward()
    local city_dict = self.db.stage.city_dict
    local item_list = {}
    for city_id in pairs(city_dict) do
        local list = self:get_city_all_reward(city_id)
        table.extend(item_list, list)
    end
    return item_list
end

-- 获取管理城市
function role_stage:get_manage_city(manager_type, manager_id)
    if not manager_type or not manager_id then return end
    local city_dict = self.db.stage.city_dict
    for city_id, city in pairs(city_dict) do
        if city.manager_type == manager_type
            and city.manager_id == manager_id then
            return city_id
        end
    end
end

-- 派遣孩子或者英雄管理城市（会加成城市占领资源产出）
function role_stage:manage_city(city_id, manager_type, manager_id)
    if not city_id then return end
    if not manager_type or not manager_id then return end
    local stage = self.db.stage
    local city = stage.city_dict[city_id]
    if not city or not city.is_occupied then return end

    if manager_type == CSConst.CityManager.Hero then
        local hero = self.role:get_hero(manager_id)
        if not hero then return end
    elseif manager_type == CSConst.CityManager.Child then
        local child = self.role:get_child(manager_id)
        if not child then return end
        -- 结了婚的孩子才能管理城市
        if child.child_status ~= CSConst.ChildStatus.Married then return end
    end
    local old_city
    local old_city_id = self:get_manage_city(manager_type, manager_id)
    if old_city_id then
        old_city = stage.city_dict[old_city_id]
    end
    local city_dict = {}
    if old_city then
        -- 管理有旧的城市，则交换
        old_city.manager_type = city.manager_type
        old_city.manager_id = city.manager_id
        city_dict[old_city_id] = old_city
    end
    city.manager_type = manager_type
    city.manager_id = manager_id
    city_dict[city_id] = city
    self.role:send_client("s_update_city_info", {city_dict = city_dict})
    self.role:update_task(CSConst.TaskType.ManageCity)
    self:set_city_resource_timer()

    return true
end

-- 获取城市占领资源
function role_stage:get_city_resource()
    local stage = self.db.stage
    local resource_dict = stage.resource_dict
    if #resource_dict == 0 then return end

    self.role:add_item_dict(resource_dict, g_reason.city_resource)
    stage.resource_dict = {}
    self.role:send_client("s_update_city_info", {resource_dict = stage.resource_dict})

    if not self.city_resource_timer then
        stage.city_resource_ts = date.time_second()
        local output_time = excel_data.ParamData["city_resource_output_time"].f_value * CSConst.Time.Minute
        self.city_resource_timer = self.role:timer_loop(output_time, function()
            self:city_resource_output()
        end)
    end
    return true
end

-- 增加国家占有城市数
function role_stage:add_occupy_city_num(country_id)
    local stage = self.db.stage
    local country = stage.country_dict[country_id]
    if not country then
        stage.country_dict[country_id] = {}
        country = stage.country_dict[country_id]
        local country_data = excel_data.CountryData[country_id]
        if country_data.occupy_pct_list then
            for i in ipairs(country_data.occupy_pct_list) do
                country.reward_dict[i] = false
            end
        end
    end

    country.occupy_city_num = country.occupy_city_num + 1
    self:set_country_occupy_reward(country_id)
    self.role:send_client("s_update_country_info", {country_dict = {[country_id] = country}})
end

-- 设置国家城市占有度奖励领取状态
function role_stage:set_country_occupy_reward(country_id)
    local country = self.db.stage.country_dict[country_id]
    if not country then return end
    local reward_dict = country.reward_dict
    local country_data = excel_data.CountryData[country_id]
    if not country_data.occupy_pct_list then return end
    local total_city_num = #excel_data.CityData["country_dict"][country_id].city_list
    local has_change
    for i, occupy_pct in ipairs(country_data.occupy_pct_list) do
        if reward_dict[i] == false and country.occupy_city_num / total_city_num >= occupy_pct then
            has_change = true
            reward_dict[i] = true
        end
    end
    if has_change then
        self.role:send_client("s_update_country_info", {country_dict = {[country_id] = country}})
    end
end

-- 获取国家城市占有度奖励
function role_stage:get_country_occupy_reward(country_id, reward_index)
    if not country_id or not reward_index then return end
    local country = self.db.stage.country_dict[country_id]
    if not country then return end
    local reward_dict = country.reward_dict
    if not reward_dict[reward_index] then return end

    reward_dict[reward_index] = nil
    local country_data = excel_data.CountryData[country_id]
    local reward_data = excel_data.RewardData[country_data.reward_list[reward_index]]
    self.role:add_item_list(reward_data.item_list, g_reason.country_occupy_reward)

    self.role:send_client("s_update_country_info", {country_dict = {[country_id] = country}})
    return true
end

-- 通关后触发事件
function role_stage:on_new_stage(stage_id)
    self.role:update_task(CSConst.TaskType.Stage)
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.PassCityNum, self.db.stage.curr_stage)
    self.role:update_rush_activity_data(CSConst.RushActivityType.checkpoint, 1) -- 冲榜活动-累计通关数
    self.role:update_achievement(CSConst.AchievementType.Stage, 1)
    self.role:guide_event_trigger_check(excel_data.StageData[stage_id - 1].trigger_event_id) -- 关卡事件
    local stage_data = excel_data.StageData[stage_id]
end

-- 获取管辖城市个数
function role_stage:get_manage_city_count()
    local city_dict = self.db.stage.city_dict
    local count = 0
    for _, city_info in pairs(city_dict) do
        if city_info.manager_id then
            count = count + 1
        end
    end
    return count
end

-- 获取关卡星数
function role_stage:get_stage_star()
    local city_dict = self.db.stage.city_dict
    local num = 0
    for _, city_info in pairs(city_dict) do
        num = num + city_info.star_num
    end
    return num
end

-- 启动资源恢复定时器
function role_stage:set_city_resource_timer()
    local stage = self.db.stage
    if not stage.city_resource_ts then return end
    if self:check_resource_is_limit() or self.city_resource_timer then return end
    stage.city_resource_ts = date.time_second()
    local output_time = excel_data.ParamData["city_resource_output_time"].f_value * CSConst.Time.Minute
    self.city_resource_timer = self.role:timer_loop(output_time, function()
        self:city_resource_output()
    end)
end

-- vip升级触发
function role_stage:vip_level_up_privilege_stage(old_level, new_level)
    self:set_city_resource_timer()
end

return role_stage