local role_hunt = DECLARE_MODULE("meta_table.hunt")

local excel_data = require("excel_data")
local date = require("sys_utils.date")
local hunt_utils = require("hunt_utils")
local rank_utils = require("rank_utils")
local drop_utils = require("drop_utils")

function role_hunt.new(role)
    local self = {
        role = role,
        db = role.db,
        uuid = role.uuid,
        hunt_check_ts = 0,
        hunt_recover_timer = nil,
        hunting_ground = nil
    }
    return setmetatable(self, role_hunt)
end

function role_hunt:init_hunt()
    self.db.hunt = {}
    local hunt = self.db.hunt
    hunt.hunt_num = excel_data.ParamData["hunt_rare_animal_num"].f_value
    hunt.add_hunt_num = 0
    self:unlock_hunt_ground(true)
end

function role_hunt:daily_hunt()
    local hunt = self.db.hunt
    hunt.add_hunt_num = 0
    hunt.hero_dict = {}
    for ground_id, ground_info in pairs(hunt.hunt_ground) do
        -- 每天重置猎场数据, 狩猎中的不重置
        if self.hunting_ground ~= ground_id then
            local data = excel_data.HuntGroundData[ground_id]
            ground_info.animal_num = 0
            ground_info.animal_hp = data.animal_hp[1]
            ground_info.arrow_num = data.arrow_num
            ground_info.hero_list = nil
        end
    end

    local hunt_shop = hunt.hunt_shop
    for shop_id, data in pairs(excel_data.HuntShopData) do
        if not data.forever_num then
            hunt_shop[shop_id] = nil
        end
    end

    self.role:send_client("s_update_hunt_data", {
        hunt_ground = hunt.hunt_ground,
        hero_dict = hunt.hero_dict,
        add_hunt_num = hunt.add_hunt_num,
        hunt_shop = hunt_shop
    })
    if not self.hunting_ground then
        hunt.curr_ground = nil
    end
    self.role:send_client("s_update_curr_ground", {curr_ground = hunt.curr_ground})
end

function role_hunt:online_hunt()
    local hunt = self.db.hunt
    local max_num = excel_data.ParamData["hunt_rare_animal_num"].f_value
    if hunt.hunt_num < max_num then
        local now = date.time_second()
        local cooldown = excel_data.ParamData["hunt_rare_animal_time"].f_value
        local add_num = math.floor((now - hunt.hunt_ts) / cooldown)
        local total_num = add_num + hunt.hunt_num
        if total_num < max_num then
            hunt.hunt_num = total_num
            hunt.hunt_ts = hunt.hunt_ts + cooldown * add_num
            if self.hunt_recover_timer then
                self.hunt_recover_timer:cancel()
            end
            local delay = cooldown - (now - hunt.hunt_ts) % cooldown
            self.hunt_recover_timer = self.role:timer_loop(cooldown, function()
                self:hunt_num_recover()
            end, delay)
        else
            hunt.hunt_num = max_num
            hunt.hunt_ts = now
        end
    end

    local tmp_log = {
        hunt_point = self.role:get_currency(CSConst.Virtual.HuntPoint),
        hunt_ground = hunt.hunt_ground,
        hunt_num = hunt.hunt_num,
        hunt_ts = hunt.hunt_ts,
        listen_animal = hunt.listen_animal,
        hero_dict = hunt.hero_dict,
        hunt_shop = hunt.hunt_shop,
        refresh_ts = self.db.last_hourly_ts,
        add_hunt_num = hunt.add_hunt_num
    }

--    print("-- hunt data: " .. json.encode(tmp_log))

    self.role:send_client("s_update_hunt_data", {
        hunt_point = self.role:get_currency(CSConst.Virtual.HuntPoint),
        hunt_ground = hunt.hunt_ground,
        hunt_num = hunt.hunt_num,
        hunt_ts = hunt.hunt_ts,
        listen_animal = hunt.listen_animal,
        hero_dict = hunt.hero_dict,
        hunt_shop = hunt.hunt_shop,
        refresh_ts = self.db.last_hourly_ts,
        add_hunt_num = hunt.add_hunt_num
    })
    self.role:send_client("s_update_curr_ground", {curr_ground = hunt.curr_ground})
end

-- 狩猎历史积分排行
function role_hunt:get_hunt_rank()
    local rank_info = rank_utils.get_rank_list("hunt_rank", self.uuid)
    rank_info.self_rank_score = self.db.hunt.history_point
    return rank_info
end

-- 狩猎积分兑换
function role_hunt:hunt_point_exchange(shop_id, shop_num)
    if not shop_id then return end
    shop_num = shop_num or 1
    if shop_num < 1 then return end
    local data = excel_data.HuntShopData[shop_id]
    if not data then return end
    local hunt_shop = self.db.hunt.hunt_shop
    local new_num = hunt_shop[shop_id] + shop_num
    if data.forever_num and new_num > data.forever_num then return end
    if data.daily_num and new_num > data.daily_num then return end

    local item_list = {}
    for i, item_id in ipairs(data.cost_item_list) do
        local count = math.floor(data.cost_item_value[i] * (data.discount or CSConst.DefaultDiscount) * 0.1)
        count = count == 0 and 1 or count
        table.insert(item_list, {item_id = item_id, count = count * shop_num})
    end
    if not self.role:consume_item_list(item_list, g_reason.hunt_point_exchange) then return end
    hunt_shop[shop_id] = new_num
    local item_count = data.item_count * shop_num
    self.role:add_item(data.item_id, item_count, g_reason.hunt_point_exchange)
    self.role:send_client("s_update_hunt_data", {hunt_shop = hunt_shop})
    self.role:gaea_log("ShopConsume", {
        itemId = data.item_id,
        itemCount = item_count,
        consume = item_list
    })
    return true
end

-- 增加狩猎积分
function role_hunt:add_hunt_point(hunt_point)
    local hunt = self.db.hunt
    hunt.history_point = hunt.history_point + hunt_point
    self.role:update_role_rank("hunt_rank", hunt.history_point)
    self.role:update_cross_role_rank("cross_hunt_rank", hunt.history_point)
    self.role:update_rush_activity_item_data(CSConst.Virtual.HuntPoint, hunt_point) -- 冲榜活动-狩猎积分涨幅
end
--------------------------- 猎场狩猎 -----------------------------------
-- 解锁猎场
function role_hunt:unlock_hunt_ground(not_notify)
    local role_level = self.role:get_level()
    local hunt = self.db.hunt
    local hunt_ground = hunt.hunt_ground
    local ret = {}
    local is_change
    for ground_id, ground_data in pairs(excel_data.HuntGroundData) do
        if not hunt_ground[ground_id] and role_level >= ground_data.open_level then
            is_change = true
            hunt_ground[ground_id] = {
                ground_id = ground_id,
                animal_num = 0,
                animal_hp = ground_data.animal_hp[1],
                arrow_num = ground_data.arrow_num,
                first_reward = false,
            }
            ret[ground_id] = hunt_ground[ground_id]
        end
    end

    if is_change and not not_notify then
        self.role:send_client("s_update_hunt_data", {hunt_ground = ret})
    end

    if not hunt.listen_animal and role_level >= excel_data.RareAnimalData[1].open_level then
        hunt.listen_animal = 1
        self.role:send_client("s_update_hunt_data", {listen_animal = hunt.listen_animal})
    end
end

-- 设置狩猎出战英雄
function role_hunt:set_hunt_hero(ground_id, hero_list)
    if not ground_id or not hero_list then return end
    local hunt = self.db.hunt
    if hunt.curr_ground then return end
    local hunt_ground = hunt.hunt_ground[ground_id]
    if not hunt_ground then return end
    if hunt_ground.hero_list then return end
    local data = excel_data.HuntGroundData[ground_id]
    if hunt_ground.animal_num >= data.animal_num then return end
    for _, hero_id in ipairs(hero_list) do
        -- 检查hero_id是否合法，是否重复出战
        if not self.role:get_hero(hero_id) then return end
        if hunt.hero_dict[hero_id] then return end
    end

    for _, hero_id in ipairs(hero_list) do
        hunt.hero_dict[hero_id] = true
    end
    self:set_curr_ground(ground_id)
    hunt_ground.hero_list = hero_list
    hunt_ground.arrow_num = data.arrow_num
    self.role:send_client("s_update_hunt_data", {
        hunt_ground = {[ground_id] = hunt_ground},
        hero_dict = hunt.hero_dict
    })

    return true
end

-- 设置当前狩猎场
function role_hunt:set_curr_ground(curr_ground)
    if self.db.hunt.curr_ground == curr_ground then
        return
    end
    self.db.hunt.curr_ground = curr_ground
    self.role:send_client("s_update_curr_ground", {curr_ground = curr_ground})
end

-- 狩猎野兽
function role_hunt:hunt_ground_animal(ground_id, shoot_result)
    if not ground_id then return end
    local hunt = self.db.hunt
    if hunt.curr_ground and hunt.curr_ground ~= ground_id then return end
    local hunt_ground = hunt.hunt_ground[ground_id]
    if not hunt_ground or not hunt_ground.hero_list then return end
    if hunt_ground.arrow_num <= 0 then return end
    local data = excel_data.HuntGroundData[ground_id]
    if hunt_ground.animal_num >= data.animal_num then return end
    local now = date.time_second()
    if now - self.hunt_check_ts < CSConst.Hunt.Cooldown - 1 then
        -- 射箭时间间隔检查，容错1秒
        return
    end

    self.hunt_check_ts = now
    hunt_ground.arrow_num = hunt_ground.arrow_num - 1
    -- 伤害等于所有出战英雄战力总和
    local hurt = self:get_hero_list_score(hunt_ground.hero_list)
    if shoot_result == CSConst.ShootResult.Crit then
        -- 暴击
        hurt = hurt * CSConst.Hunt.Crit
    elseif shoot_result == CSConst.ShootResult.Miss then
        -- 未命中
        hurt = 0
    end
    hurt = math.floor(hurt)
    hunt_ground.animal_hp = hunt_ground.animal_hp - hurt
    if hunt_ground.animal_hp <= 0 then
        -- 猎物被击杀
        hunt_ground.animal_num = hunt_ground.animal_num + 1
        hunt_ground.animal_hp = data.animal_hp[hunt_ground.animal_num + 1] or 0
        local item_list = drop_utils.roll_drop(data.drop_id)
        self.role:add_item_list(item_list, g_reason.kill_ground_animal)
        self.role:send_client("s_hunt_ground_kill_reward", {ground_id = ground_id, item_list = item_list})

        if hunt_ground.animal_num >= data.animal_num then
            -- 猎场猎物全部被击杀
            hunt_ground.hero_list = nil
            self:set_curr_ground(nil)
            if hunt_ground.first_reward == false then
                -- 设置首通奖励领取状态
                hunt_ground.first_reward = true
            end
            self.role:update_first_week_task(CSConst.FirstWeekTaskType.PassHuntStage, 1)
            self.role:update_task(CSConst.TaskType.HuntGround, {progress = 1})
        end
    end
    -- 弓箭数为0，狩猎失败
    if hunt_ground.animal_num < data.animal_num and hunt_ground.arrow_num <= 0 then
        hunt_ground.hero_list = nil
        self:set_curr_ground(nil)
    end

    self.role:send_client("s_update_hunt_data", {hunt_ground = {[ground_id] = hunt_ground}})
    return {
        errcode = g_tips.ok,
        hurt = hurt,
    }
end

-- 获取出战英雄战力
function role_hunt:get_hero_list_score(hero_list)
    local total_score = 0
    for _, hero_id in ipairs(hero_list) do
        local hero = self.role:get_hero(hero_id)
        total_score = total_score + hero.score
    end
    return total_score
end

-- 放弃当前狩猎的猎场，进行新猎场狩猎
function role_hunt:give_up_hunt_ground()
    local hunt = self.db.hunt
    if not hunt.curr_ground then return end

    local data = excel_data.HuntGroundData[hunt.curr_ground]
    local hunt_ground = hunt.hunt_ground[hunt.curr_ground]
    hunt_ground.hero_list = nil
    self:set_curr_ground(nil)

    return {
        errcode = g_tips.ok,
        old_ground = hunt_ground
    }
end

-- 恢复出战英雄，可以重新出战
function role_hunt:hunt_hero_recover(hero_id)
    if not hero_id then return end
    local hunt = self.db.hunt
    if not hunt.hero_dict[hero_id] then return end
    local param_data = excel_data.ParamData["hero_hunt_recover_item"]
    if not self.role:consume_item(param_data.item_id, param_data.count, g_reason.hunt_hero_recover) then
        return
    end
    hunt.hero_dict[hero_id] = nil
    return true
end

-- 获取首通奖励
function role_hunt:get_first_reward(ground_id)
    if not ground_id then return end
    local data = excel_data.HuntGroundData[ground_id]
    if not data then return end
    local hunt_ground = self.db.hunt.hunt_ground[ground_id]
    if not hunt_ground then return end
    if not hunt_ground.first_reward then return end

    hunt_ground.first_reward = nil
    self.role:add_item_list(data.first_pass_award_list, g_reason.hunt_ground_first_reward)

    self.role:send_client("s_update_hunt_data", {hunt_ground = {[ground_id] = hunt_ground}})
    return true
end

function role_hunt:start_hunt_ground()
    local hunt = self.db.hunt
    self.hunting_ground = hunt.curr_ground
end

function role_hunt:end_hunt_ground()
    self.hunting_ground = nil
end
--------------------------- 珍兽狩猎 -----------------------------------
-- 狩猎珍兽次数恢复
function role_hunt:hunt_num_recover()
    local hunt = self.db.hunt
    local max_num = excel_data.ParamData["hunt_rare_animal_num"].f_value
    if hunt.hunt_num < max_num then
        hunt.hunt_num = hunt.hunt_num + 1
        hunt.hunt_ts = date.time_second()
        self.role:send_client("s_update_hunt_data", {
            hunt_num = hunt.hunt_num,
            hunt_ts = hunt.hunt_ts,
        })
    end
    -- 次数恢复到最大，取消定时器
    if hunt.hunt_num >= max_num then
        self.hunt_recover_timer:cancel()
        self.hunt_recover_timer = nil
    end
end

-- 增加狩猎次数
function role_hunt:add_hunt_num()
    local hunt = self.db.hunt
    local default_num = excel_data.ParamData["buy_rare_animal_num"].f_value
    local vip = self.role:get_vip()
    local max_buy_num = excel_data.VipData[vip].buy_rare_animal_num
    local new_add_num = hunt.add_hunt_num + 1
    if new_add_num > default_num + max_buy_num then return end
    local num_data = excel_data.AddRareAnimalData
    local data = num_data[new_add_num]
    if not data then
        data = num_data[#num_data]
    end
    if not self.role:consume_item(data.cost_item, data.cost_num, g_reason.add_hunt_num) then
        return
    end

    hunt.hunt_num = hunt.hunt_num + 1
    hunt.add_hunt_num = hunt.add_hunt_num + 1
    local max_num = excel_data.ParamData["hunt_rare_animal_num"].f_value
    if hunt.hunt_num >= max_num and self.hunt_recover_timer then
        self.hunt_recover_timer:cancel()
        self.hunt_recover_timer = nil
    end
    self.role:send_client("s_update_hunt_data", {
        hunt_num = hunt.hunt_num,
        hunt_ts = hunt.hunt_ts,
        add_hunt_num = hunt.add_hunt_num
    })
    return true
end

-- 获取所有珍兽的数据
function role_hunt:get_all_rare_animal_data()
    local rare_animal = {}
    local role_level = self.role:get_level()
    for animal_id, animal in pairs(hunt_utils.animal_dict) do
        if role_level >= excel_data.RareAnimalData[animal_id].open_level then
            local hunt_role = animal:get_hunt_role(self.uuid)
            table.insert(rare_animal, {
                animal_id = animal.id,
                animal_hp = animal.percent_hp,
                join_num = animal:get_join_num(),
                is_start = hunt_role and true,
                kill_ts = animal.kill_ts,
                revive_ts = animal.revive_ts,
            })
        end
    end
    return rare_animal
end

-- 开始狩猎珍兽
function role_hunt:start_hunt_rare_animal(animal_id)
    if not animal_id then return end
    local data = excel_data.RareAnimalData[animal_id]
    if not data or data.open_level > self.role:get_level() then return end
    local hunt = self.db.hunt
    if hunt.hunt_num <= 0 then return end
    local animal = hunt_utils.get_animal_cls(animal_id)
    if not animal then return end
    if animal:is_death() then return end
    if animal:get_hunt_role(self.uuid) then return end

    local role_data = {
        uuid = self.uuid,
        name = self.role:get_name(),
        level = self.role:get_level(),
        role_id = self.role:get_role_id(),
        vip = self.role:get_vip(),
    }
    animal:hunt_star(role_data)
    hunt.hunt_num = hunt.hunt_num - 1
    local max_num = excel_data.ParamData["hunt_rare_animal_num"].f_value
    if hunt.hunt_num < max_num then
        if not self.hunt_recover_timer then
            -- 次数未满起恢复定时器
            hunt.hunt_ts = date.time_second()
            local delay = excel_data.ParamData["hunt_rare_animal_time"].f_value * 60
            self.hunt_recover_timer = self.role:timer_loop(delay, function()
                self:hunt_num_recover()
            end)
        end
    end
    self.role:update_task(CSConst.TaskType.HuntNum, {progress = 1})

    self.role:send_client("s_update_hunt_data", {
        hunt_num = hunt.hunt_num,
        hunt_ts = hunt.hunt_ts,
    })
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.HuntRareAnimal, 1)
    self.role:update_daily_active(CSConst.DailyActiveTaskType.HuntRareAnimalNum, 1)
    return true
end

-- 获取单个珍兽的数据
function role_hunt:get_rare_animal_data(animal_id)
    if not animal_id then return end
    local animal = hunt_utils.get_animal_cls(animal_id)
    if not animal then return end
    local hunt_role = animal:get_hunt_role(self.uuid)
    local msg = {
        animal_id = animal.id,
        animal_hp = animal.percent_hp,
        inspire_num = hunt_role and hunt_role.inspire_num or 0,
        hurt_rank = animal.hurt_rank,
        self_rank = hunt_role and hunt_role.rank,
        self_hurt = hunt_role and hunt_role.hurt
    }
    return {errcode = g_tips.ok, rare_animal = msg}
end

-- 狩猎珍兽，进行攻击
function role_hunt:hunt_rare_animal(animal_id, shoot_result)
    if not animal_id then return end
    local animal = hunt_utils.get_animal_cls(animal_id)
    if not animal then return end
    if animal:is_death() then
        return {errcode = g_tips.ok, hurt = 0}
    end
    local hunt_role = animal:get_hunt_role(self.uuid)
    if not hunt_role then return end
    local now = date.time_second()
    if now - self.hunt_check_ts < CSConst.Hunt.Cooldown - 1 then
        -- 射箭时间间隔检查，容错1秒
        return
    end

    self.hunt_check_ts = now
    if shoot_result == CSConst.ShootResult.Miss then
        -- 未命中
        return g_tips.ok_resp
    end
    -- 伤害为所有英雄的战力之和
    local hurt = self.role:get_all_hero_score()
    -- 鼓舞一次伤害百分比增加
    local add_rate = excel_data.ParamData["rare_animal_inspire_add_rate"].f_value
    hurt = hurt * (1 + hunt_role.inspire_num * add_rate)
    if shoot_result == CSConst.ShootResult.Crit then
        hurt = hurt * CSConst.Hunt.Crit
    end
    hurt = math.floor(hurt)
    animal:on_hunt(self.uuid, hurt)

    return {errcode = g_tips.ok, hurt = hurt}
end

-- 狩猎鼓舞，会增加狩猎伤害
function role_hunt:hunt_inspire(animal_id)
    if not animal_id then return end
    local animal = hunt_utils.get_animal_cls(animal_id)
    if not animal then return end
    local hunt_role = animal:get_hunt_role(self.uuid)
    if not hunt_role then return end
    local new_num = hunt_role.inspire_num + 1
    local data = excel_data.HuntInspireData[new_num]
    if not data then return end

    if not self.role:consume_item(data.cost_item, data.cost_num, g_reason.hunt_inspire) then
        return
    end
    hunt_role.inspire_num = new_num

    return true
end

-- 监视珍兽，复活时会提前通知
function role_hunt:listen_rare_animal(animal_id)
    -- if not animal_id then return false end
    -- print("--- animal id: "..animal_id)
    local hunt = self.db.hunt
    if hunt.listen_animal == animal_id then return true end
    if animal_id then
        local data = excel_data.RareAnimalData[animal_id]
        if not data then return end
        if data.open_level > self.role:get_level() then return end
    end

    hunt.listen_animal = animal_id
    self.role:send_client("s_update_hunt_data", {listen_animal = hunt.listen_animal})
    return true
end

return role_hunt
