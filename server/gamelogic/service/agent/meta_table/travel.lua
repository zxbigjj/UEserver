local role_travel = DECLARE_MODULE("meta_table.travel")

local excel_data = require("excel_data")
local date = require("sys_utils.date")
local drop_utils = require("drop_utils")

function role_travel.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
        strength_timer = nil,
        luck_timer = nil,
    }
    return setmetatable(self, role_travel)
end

function role_travel:init_travel()
    local travel = self.db.travel
    local ParamData = excel_data.ParamData
    local luck_value = ParamData["set_luck_recover_max_value"].f_value
    travel.luck.value = luck_value
    travel.luck.set_value = luck_value
    travel.luck.restore_num = 1
    local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.TravelNum)
    travel.strength_num = ParamData["travel_strength_num_limit"].f_value + extra_num
    local extra_assign_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.AssignTravelNum)
    travel.assign_travel_num = ParamData["assign_travel_max_count"].f_value + extra_assign_num
    self:unlock_tolvlup()
end

function role_travel:load_travel()
    local travel = self.db.travel
    local now = date.time_second()
    local param_data = excel_data.ParamData
    -- 体力恢复
    local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.TravelNum)
    local strength_num_limit = param_data["travel_strength_num_limit"].f_value + extra_num
    if travel.strength_num < strength_num_limit then
        local cd = param_data["travel_strength_num_restore_cd"].f_value
        local add_number = (now - travel.last_time) / cd
        local total_number = math.floor(add_number) + travel.strength_num
        if total_number < strength_num_limit then
            travel.strength_num = total_number
            travel.last_time = travel.last_time + cd * math.floor(add_number)
            local delay_time = cd - (now - travel.last_time) % cd
            self.strength_timer = self.role:timer_loop(cd, function ()
                self:strength_num_restore()
            end, delay_time)
         else
            travel.strength_num = strength_num_limit
            travel.last_time = now
        end
    end
    -- 运势恢复
    local luck = travel.luck
    local luck_recover_limit = param_data["set_luck_recover_max_value"].f_value
    if luck.value < luck_recover_limit then
        local cd = param_data["travel_luck_restore_cd"].f_value
        local add_number = (now - luck.restore_ts) / cd
        local total_number = math.floor(add_number) + luck.value
        if total_number < luck_recover_limit then
            luck.value = total_number
            luck.restore_ts = luck.restore_ts + cd * math.floor(add_number)
            local delay = cd - (now - luck.restore_ts) % cd
            self.luck_timer = self.role:timer_loop(cd, function()
                self:luck_value_restore()
            end, delay)
         else
            luck.value = luck_recover_limit
            luck.restore_ts = now
        end
    end
end

function role_travel:online_travel()
    local travel = self.db.travel
    self.role:send_client("s_update_travel_info", {
        luck = travel.luck,
        strength_num = travel.strength_num,
        last_time = travel.last_time,
        area_unlock_dict = travel.area_unlock_dict,
        assign_travel_num = travel.assign_travel_num,
        lover_meet = travel.lover_meet,
    })
end

-- 每日刷新指定出行的可用次数
function role_travel:daily_travel()
    local travel = self.db.travel
    travel.luck.restore_num = 1
    local extra_assign_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.AssignTravelNum)
    travel.assign_travel_num = excel_data.ParamData["assign_travel_max_count"].f_value + extra_assign_num
    self.role:send_client("s_update_travel_info", {assign_travel_num = travel.assign_travel_num})
end

-- 等级引起的地区可解锁
function role_travel:unlock_tolvlup()
    local role_level = self.role:get_level()
    local area_unlock_dict = self.db.travel.area_unlock_dict
    for i, v in ipairs(excel_data.TravelAreaData) do
        if v.unlock_level <= role_level and not area_unlock_dict[i] then
            if v.consume_item and v.consume_item_count then
                area_unlock_dict[i] = CSConst.CityUnlockStatus.No
            else
                area_unlock_dict[i] = CSConst.CityUnlockStatus.Yes
            end
        end
    end
    self.role:send_client("s_update_travel_info", {area_unlock_dict = area_unlock_dict})
end

-- 玩家消耗物品解锁地区
function role_travel:area_unlock(area_id)
    local area_config = excel_data.TravelAreaData[area_id]
    local area_unlock_dict = self.db.travel.area_unlock_dict
    if not area_unlock_dict[area_id] or area_unlock_dict[area_id] ~= CSConst.ConfirmStatus.No then return end
    if not self.role:consume_item(area_config.consume_item, area_config.consume_item_count) then return end
    area_unlock_dict[area_id] = CSConst.CityUnlockStatus.Yes
    self.role:send_client("s_update_travel_info", {area_unlock_dict = {[area_id] = area_unlock_dict[area_id]}})
    return true
end

-- 随机出行
function role_travel:random_travel()
    local travel = self.db.travel
    local area_unlock_dict = travel.area_unlock_dict
    local drop_list = {}
    if travel.strength_num <= 0 or travel.luck.value <= 0 then return end

    local area_drop_list =  excel_data.TravelAreaData.drop_list
    local unlock_num = 0
    for i, v in pairs(area_unlock_dict) do
        if v == CSConst.ConfirmStatus.Yes then
            drop_list[i] = area_drop_list[i]
            unlock_num = unlock_num + 1
        elseif v == CSConst.ConfirmStatus.No then
            drop_list[i] = 0
        end
    end
    if unlock_num <= 0 then return end
    -- 首先掉落出area_id
    local area_id = math.roll(drop_list)
    local travel_config = excel_data.TravelAreaData[area_id]
    travel.strength_num = travel.strength_num - travel_config.strength_consume
    travel.luck.value = travel.luck.value - excel_data.ParamData["travel_luck_consume"].f_value
    self:strength_refresh()
    self:luck_automatic_restore()

    local event_id = self:get_event_id(travel_config, true)
    local result = self:event_handles(event_id)
    self.role:update_achievement(CSConst.AchievementType.TravelNum, 1)
    self.role:update_daily_active(CSConst.DailyActiveTaskType.TravelNum, 1)
    self.role:update_task(CSConst.TaskType.RandomTravel, {progress = 1})
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.TravelNum, 1)
    self.role:update_festival_activity_data(CSConst.FestivalActivityType.travel) -- 节日活动随机出行

    return {errcode = g_tips.ok,
        area_id = area_id,
        event_id = event_id,
        meet_id = result.meet_id,
        item_id = result.item_id,
        count = result.count,
    }
end

function role_travel:get_event_id(travel_config, is_random_travel)
    local luck_value = self.db.travel.luck.value
    local data
    for _, v in pairs(excel_data.LuckDescData) do
        if luck_value >= v.value_range[1] and luck_value <= v.value_range[2] then
            data = v
            break
        end
    end
    local weight_table = {}
    local total_weight = 0
    for i, luck_type in ipairs(travel_config.luck_type_list) do
        local weight
        if luck_type == CSConst.TravelLuckType.Weight_1 then
            if is_random_travel then
                weight = travel_config.rand_event_drop_list[i] * (1 + data.weight_1)
            else
                weight = travel_config.assign_event_drop_list[i] * (1 + data.weight_1)
            end
        elseif luck_type == CSConst.TravelLuckType.Weight_2 then
            if is_random_travel then
                weight = travel_config.rand_event_drop_list[i] * (1 + data.weight_2)
            else
                weight = travel_config.assign_event_drop_list[i] * (1 + data.weight_2)
            end
        else
            if is_random_travel then
                weight = travel_config.rand_event_drop_list[i]
            else
                weight = travel_config.assign_event_drop_list[i]
            end
        end
        if weight > 0 then
            weight_table[i] = weight
            total_weight = total_weight + weight_table[i]
        end
    end
    local event_index = math.roll(weight_table, total_weight)
    return travel_config.event_list[event_index]
end

function role_travel:strength_refresh()
    local travel = self.db.travel
    local now = date.time_second()
    local param_data = excel_data.ParamData
    local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.TravelNum)
    local strength_num_limit = param_data["travel_strength_num_limit"].f_value + extra_num
    if travel.strength_num < strength_num_limit and not self.strength_timer then
        travel.last_time = now
        local cd = param_data["travel_strength_num_restore_cd"].f_value
        self.strength_timer = self.role:timer_loop(cd, function ()
            self:strength_num_restore()
        end)
    end
    local luck = travel.luck
    local luck_recover_limit = param_data["set_luck_recover_max_value"].f_value
    if luck.value < luck_recover_limit and not self.luck_timer then
        luck.restore_ts = now
        local cd = param_data["travel_luck_restore_cd"].f_value
        self.luck_timer = self.role:timer_loop(cd, function()
            self:luck_value_restore()
        end)
    end

    self.role:send_client("s_update_travel_info", {
        luck = travel.luck,
        strength_num = travel.strength_num,
        last_time = travel.last_time,
        assign_travel_num = travel.assign_travel_num,
    })
end

function role_travel:strength_num_restore()
    local travel = self.db.travel
    local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.TravelNum)
    local strength_num_limit = excel_data.ParamData["travel_strength_num_limit"].f_value + extra_num
    if travel.strength_num < strength_num_limit then
        travel.strength_num = travel.strength_num + 1
        travel.last_time = date.time_second()
        self.role:send_client("s_update_travel_info", {strength_num = travel.strength_num, last_time = travel.last_time})
    end
    if travel.strength_num >= strength_num_limit then
        self.strength_timer:cancel()
        self.strength_timer = nil
    end
end

-- 指定地区出行，事件随机
function role_travel:assign_travel(area_id)
    local travel = self.db.travel
    local area_unlock_dict = travel.area_unlock_dict
    if not area_unlock_dict[area_id] then return end
    if area_unlock_dict[area_id] ~= CSConst.ConfirmStatus.Yes then return end
    if travel.luck.value <= 0 then return end
    local travel_config = excel_data.TravelAreaData[area_id]
    local item_id = travel_config.assign_consume_item
    local count = travel_config.assign_consume_item_count
    if not self.role:consume_item(item_id, count) then return end

    travel.luck.value = travel.luck.value - excel_data.ParamData["travel_luck_consume"].f_value
    travel.strength_num = travel.strength_num - travel_config.strength_consume
    travel.assign_travel_num = travel.assign_travel_num - travel_config.strength_consume
    self:strength_refresh()
    self:luck_automatic_restore()

    local event_id = self:get_event_id(travel_config)
    local result = self:event_handles(event_id)
    self.role:update_achievement(CSConst.AchievementType.TravelNum, 1)
    self.role:update_daily_active(CSConst.DailyActiveTaskType.TravelNum, 1)
    self.role:update_task(CSConst.TaskType.AssignTravel, {progress = 1})
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.TravelNum, 1)

    return {errcode = g_tips.ok,
        event_id = event_id,
        meet_id = result.meet_id,
        item_id = result.item_id,
        count = result.count,
    }
end

-- 随机事件处理
function role_travel:event_handles(event_id)
    local event_config = excel_data.TravelEventData[event_id]
    if event_config.lover_id then
        if event_config.reward_id then
            self:earn_reward(event_config.reward_id)
        end
        local lover = self.role:get_lover(event_config.lover_id)
        -- 情人存在，直接加情人亲密经验
        if lover then
            local area_unlock_dict = self.db.travel.area_unlock_dict
            local area_num = 0
            for _, v in pairs(area_unlock_dict) do
                if v == CSConst.ConfirmStatus.Yes then
                    area_num = area_num + 1
                end
            end
            local count = math.floor(area_num * event_config.add_lover_exp_ratio)
            if count > 0 then
                self.role:add_lover_exp(lover.lover_id, count)
            end
            return {item_id = excel_data.ParamData["lover_exp"].item_id, count = count}
        else
            -- 情人不存在，增加邂逅相遇记录
            return self:lover_meet(event_config.lover_id)
        end
    else
        return self:earn_reward(event_config.reward_id)
    end
end

-- 情人邂逅相遇
function role_travel:lover_meet(lover_id)
    local travel = self.db.travel
    if not travel.lover_meet[lover_id] then
        travel.lover_meet[lover_id] = {
            meet_id = 0,
            meet_num = 0,
        }
    end

    local lover_meet = travel.lover_meet[lover_id]
    local lover_meet_config = excel_data.LoverMeetData[lover_id]
    if lover_meet.meet_num < 1 then
        lover_meet.meet_id = lover_meet_config.meet_list[1]
    end
    local meet_config = lover_meet_config[lover_meet.meet_id]
    if meet_config.drop then
        local rand = math.random()
        if rand < meet_config.drop or meet_config.count <= (lover_meet.meet_num - meet_config.meet_index + 1) then
        -- 掉落成功，获得情人。 掉落次数超过此值，直接给与。
            lover_meet.meet_id = lover_meet_config.meet_list[(meet_config.meet_index + 1)]
            self.role:add_lover(lover_id)
        end
    else
        if lover_meet.meet_num > 0 then
            lover_meet.meet_id = lover_meet_config.meet_list[(meet_config.meet_index + 1)]
        end
    end
    lover_meet.meet_num = lover_meet.meet_num + 1
    self.role:send_client("s_update_travel_info", {lover_meet = {[lover_id] = lover_meet}})
    return {meet_id = lover_meet.meet_id}
end

-- 获取奖励，引用总部大厅情报奖励
function role_travel:earn_reward(reward_id)
    local reward_config = excel_data.InfoRewardData[reward_id]
    if not reward_config then return end
    local item_id, count
    if reward_config.item_id then
        item_id = reward_config.item_id
        if reward_config.attr_name and reward_config.reward_float_ratio_limit then
            local ratio_limit = reward_config.reward_float_ratio_limit
            local attr_value = self.role:get_attr_value(reward_config.attr_name)
            local min_value = math.floor(attr_value * ratio_limit[1])
            local max_value = math.floor(attr_value * ratio_limit[2])
            count = reward_config.base_value + math.random(min_value, max_value)
        else
            count = excel_data.LevelData[self.role:get_level()].info_exp
        end
    elseif reward_config.drop_id then
        local item_list = drop_utils.roll_drop(reward_config.drop_id)
        item_id = item_list[1].item_id
        count = item_list[1].count
    end
    if count > 0 then
        self.role:add_item(item_id, count, g_reason.travel_reward)
    else
        local item_count = self.role:get_item_count(item_id)
        item_count = (-count > item_count) and item_count or -count
        if item_count > 0 then
            self.role:consume_item(item_id, item_count, g_reason.travel_reward)
        end
    end
    return {item_id = item_id, count = count}
end

function role_travel:use_item()
    local travel = self.db.travel
    local item_config = excel_data.ParamData["travel_strength_num_restore_item"]
    local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.TravelNum)
    local strength_num_limit = excel_data.ParamData["travel_strength_num_limit"].f_value + extra_num
    if travel.strength_num >= strength_num_limit then return end
    if not self.role:consume_item(item_config.item_id, item_config.count) then return end
    travel.strength_num = travel.strength_num + excel_data.ItemData[item_config.item_id].recover_count
    if travel.strength_num >= strength_num_limit and self.strength_timer then
        self.strength_timer:cancel()
        self.strength_timer = nil
    end
    self.role:send_client("s_update_travel_info", {strength_num = travel.strength_num})
    return true
end

-- 运势自动恢复设置
function role_travel:luck_restore_set(set_value, set_item_id)
    local travel = self.db.travel
    if set_item_id then
        local item_config = excel_data.ItemData[set_item_id]
        if not excel_data.LuckData[set_item_id] then return end
        if not item_config then return end
        travel.luck.set_item_id = set_item_id
        if set_value then
            local luck_limit = excel_data.ParamData["travel_luck_limit"].f_value
            if set_value < 0 or set_value > luck_limit then return end
            travel.luck.set_value = set_value
        end
    else
        travel.luck.set_item_id = nil
        travel.luck.set_value = nil
    end
    self.role:send_client("s_update_travel_info", {luck = travel.luck})
    self:luck_automatic_restore()
    return true
end

-- 运势自动恢复
function role_travel:luck_automatic_restore()
    local travel = self.db.travel
    if not travel.luck.set_item_id then return end
    if not travel.luck.set_value then return end
    if travel.luck.value >= travel.luck.set_value then return end
    while self:luck_restore(travel.luck.set_item_id) do
        local travel = self.db.travel
        if travel.luck.value >= travel.luck.set_value then
            break
        end
    end
end

-- 运势手动恢复
function role_travel:luck_restore(item_id)
    local luck = self.db.travel.luck
    local luck_max_limit
    if item_id == CSConst.Virtual.Diamond then
        luck_max_limit = excel_data.ParamData["travel_luck_limit"].f_value
    else
        luck_max_limit = excel_data.ParamData["set_luck_recover_max_value"].f_value
    end
    print("luck value :" .. luck.value)
    print("luck_max_limit :" .. luck_max_limit)
    if luck.value >= luck_max_limit then
        return
    end
    local luck_config = excel_data.LuckData[item_id]
    if not luck_config then return end
    local count_index = luck.restore_num
    local len = #luck_config.consume_item_count_list
    if count_index > len then
        count_index = len
    end
    local count = luck_config.consume_item_count_list[count_index]
    if not self.role:consume_item(item_id, count) then return end
    luck.value = luck.value + luck_config.add_luck
    luck.restore_num = count_index + 1
    local luck_recover_limit = excel_data.ParamData["set_luck_recover_max_value"].f_value
    if luck.value >= luck_recover_limit and self.luck_timer then
        self.luck_timer:cancel()
        self.luck_timer = nil
    end
    if luck.value > luck_max_limit then
        luck.value = luck_max_limit
    end
    self.role:send_client("s_update_travel_info", {luck = luck})
    return true
end

-- vip升级获得额外定向出行次数
function role_travel:vip_level_up_privilege_travel_num(old_level, new_level)
    local old_level_info = excel_data.VipData[old_level]
    local new_level_info = excel_data.VipData[new_level]
    local lock_info = excel_data.VIPPrivilegeData
    local lock_name = lock_info[CSConst.VipPrivilege.AssignTravelNum].vip_data_name
    local extra_num = new_level_info[lock_name]
    if old_level > 0 then extra_num = extra_num - old_level_info[lock_name] end
    local travel = self.db.travel
    travel.assign_travel_num = travel.assign_travel_num + extra_num
    self:strength_refresh()
    self.role:send_client("s_update_travel_info", {
        strength_num = travel.strength_num,
        assign_travel_num = travel.assign_travel_num,
    })
end
-- 一键随机出行
function role_travel:total_random_travel()
    local travel_info = {}
    for i = 1, self.db.travel.strength_num do
        local ret = self:random_travel()
        if not ret then break end
        ret.errcode = nil
        table.insert(travel_info, ret)
    end
    return {errcode = g_tips.ok, travel_info = travel_info}
end

function role_travel:luck_value_restore()
    local luck = self.db.travel.luck
    local limit_value = excel_data.ParamData["set_luck_recover_max_value"].f_value
    if luck.value < limit_value then
        luck.value = luck.value + 1
        luck.restore_ts = date.time_second()
        self.role:send_client("s_update_travel_info", {luck = luck})
    end
    if luck.value >= limit_value then
        self.luck_timer:cancel()
        self.luck_timer = nil
    end
end

return role_travel