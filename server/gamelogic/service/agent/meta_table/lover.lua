local role_lover = DECLARE_MODULE("meta_table.lover")

local date = require("sys_utils.date")
local excel_data = require("excel_data")
local role_utils = require("role_utils")
local CSFunction = require("CSCommon.CSFunction")

local GIVE_TEN_ITEM = 10

function role_lover.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
        discuss_timer = nil,
        lover_list = {},
        train_timer_dict = {},
        shop_refresh_num_timer = nil,
        fondle_num = nil,
        fondle_lover_id = nil
    }
    return setmetatable(self, role_lover)
end

function role_lover:init_lover()
    local role_level = self.role:get_level()
    local level_data = excel_data.LevelData[role_level]
    local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.DateLoverNum)
    self.db.discuss_num = level_data.discuss_max_count + extra_num
    self.db.is_first_dote_lover = true
    self:init_lover_train()
    local lover_shop = self.db.lover_shop
    lover_shop.refresh_ts = date.time_second()
    local data = excel_data.ShopData["LoverShop"]
    lover_shop.free_refresh_num = data.free_refresh_num
    lover_shop.total_refresh_num = data.total_refresh_num
    self:_refresh_lover_shop()
end

function role_lover:daily_lover()
    self:daily_lover_train()
    local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.LovershopRefresh)
    local data = excel_data.ShopData["LoverShop"]
    local lover_shop = self.db.lover_shop
    lover_shop.total_refresh_num = data.total_refresh_num + extra_num
    self.role:send_client("s_update_lover_shop", lover_shop)
end

function role_lover:load_lover()
    local role_level = self.role:get_level()
    local level_data = excel_data.LevelData[role_level]
    local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.DateLoverNum)
    if self.db.discuss_num < level_data.discuss_max_count + extra_num then
        local now = date.time_second()
        local energy_cooldown = level_data.energy_cooldown
        local add_num = math.floor((now - self.db.discuss_ts) / energy_cooldown)
        local total_num = add_num + self.db.discuss_num
        if total_num < level_data.discuss_max_count + extra_num then
            -- 商谈次数未满，起恢复定时器
            self.db.discuss_num = total_num
            self.db.discuss_ts = self.db.discuss_ts + energy_cooldown * add_num
            local delay = energy_cooldown - (now - self.db.discuss_ts) % energy_cooldown
            self.discuss_timer = self.role:timer_loop(level_data.energy_cooldown, function()
                self:discuss_num_recover()
            end, delay)
        else
            self.db.discuss_num = level_data.discuss_max_count + extra_num
            self.db.discuss_ts = now
        end
    end

    self.lover_list = {}
    -- print(" db lover_dict :"..json.encode(self.db.lover_dict))
    for lover_id, lover_info in pairs(self.db.lover_dict) do
        table.insert(self.lover_list, lover_id)

        -- 品级给人物加属性
        -- print("lover_info :"..json.encode(lover_info))
        -- print("lover_info grade :"..json.encode(lover_info.grade))
        if lover_info.grade then
            local grade_data = excel_data.GradeData[lover_info.grade]
            -- print("grade_data :"..json.encode(grade_data))
            self.role:modify_attr(nil, grade_data.add_attr_dict, true)
        end
    end

    local lover_shop = self.db.lover_shop
    local data = excel_data.ShopData["LoverShop"]
    if lover_shop.free_refresh_num < data.free_refresh_num then
        local now = date.time_second()
        local recover_time = data.loop_refresh_time * CSConst.Time.Minute
        local add_num = math.floor((now - lover_shop.refresh_ts) / recover_time)
        local total_num = add_num + lover_shop.free_refresh_num
        if total_num < data.free_refresh_num then
            lover_shop.free_refresh_num = total_num
            lover_shop.refresh_ts = lover_shop.refresh_ts + recover_time * add_num
            local delay = recover_time - (now - lover_shop.refresh_ts) % recover_time
            self.shop_refresh_num_timer = self.role:timer_loop(recover_time, function()
                self:shop_refresh_num_recover()
            end, delay)
        else
            lover_shop.free_refresh_num = data.free_refresh_num
            lover_shop.refresh_ts = now
        end
    end
end

function role_lover:online_lover()
    self.role:send_client("s_online_lover", {
        all_lover = self.db.lover_dict,
        discuss_num = self.db.discuss_num,
        discuss_ts = self.db.discuss_ts
    })
    self.role:send_client("s_update_lover_shop", self.db.lover_shop)
    -- 情人培训
    self:online_lover_train()
end

-- 随机一个情人id
function role_lover:get_random_lover()
    return self.lover_list[math.random(#self.lover_list)]
end

-- 商谈次数恢复
function role_lover:discuss_num_recover()
    local role_level = self.role:get_level()
    local level_data = excel_data.LevelData[role_level]
    local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.DateLoverNum)
    if self.db.discuss_num < level_data.discuss_max_count + extra_num then
        self.db.discuss_num = self.db.discuss_num + 1
        self.db.discuss_ts = date.time_second()
        self.role:send_client("s_update_discuss_data", {
            discuss_num = self.db.discuss_num,
            discuss_ts = self.db.discuss_ts
        })
    end
    -- 次数恢复到最大，取消定时器
    if self.db.discuss_num >= level_data.discuss_max_count + extra_num then
        self.discuss_timer:cancel()
        self.discuss_timer = nil
    end
end

-- 增加一个新情人
function role_lover:add_lover(lover_id)
    if not lover_id then return end
    local lover_data = excel_data.LoverData[lover_id]
    if not lover_data then return end
    local lover_dict = self.db.lover_dict
    if lover_dict[lover_id] then return end
    if lover_dict[lover_data.change_sex] then return end

    lover_dict[lover_id] = {lover_id = lover_id}
    local lover_info = lover_dict[lover_id]
    -- 属性初始化
    for i, attr_name in ipairs(lover_data.init_attr) do
        lover_info.attr_dict[attr_name] = lover_data.init_attr_value[1]
    end
    -- 时装初始化，男女都默认第一套
    lover_info.fashion_id = lover_data.fashion[1]

    lover_info.fashion_dict[lover_info.fashion_id] = true
    local other_lover = excel_data.LoverData[lover_data.change_sex]
    if other_lover then
        lover_info.other_fashion_dict[other_lover.fashion[1]] = true
    end
    -- 品级初始化，最低品级
    local grade = excel_data.GradeData[1].id
    lover_info.grade = grade
    lover_info.old_grade = grade
    -- 技能
    self:unlock_lover_spell(lover_info, true)

    table.insert(self.lover_list, lover_id)
    self.role:update_task(CSConst.TaskType.LoverNum)
    self.role:update_achievement(CSConst.AchievementType.LoverNum, 1)
    self.role:update_achievement(CSConst.AchievementType.LoverLevel, 1)
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.LoverGrade, 1)

    self.role:send_client("s_add_lover", {lover_info = lover_info})
    self.role:log("AddLover", {lover_info = lover_info})
end

-- 与情人商谈，增加势力值，有概率得到孩子
function role_lover:lover_discuss()
    if self.db.discuss_num <= 0 then return end
    if #self.db.lover_dict == 0 then return end
    self.db.discuss_num = self.db.discuss_num - 1
    local role_level = self.role:get_level()
    local level_data = excel_data.LevelData[role_level]
    local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.DateLoverNum)
    if self.db.discuss_num < level_data.discuss_max_count + extra_num then
        if not self.discuss_timer then
            -- 次数没满时，起恢复定时器
            self.db.discuss_ts = date.time_second()
            self.discuss_timer = self.role:timer_loop(level_data.energy_cooldown, function()
                self:discuss_num_recover()
            end)
        end
    end
    self.role:send_client("s_update_discuss_data", {
        discuss_num = self.db.discuss_num,
        discuss_ts = self.db.discuss_ts
    })

    -- 随机与一个情人商谈
    local index = math.random(#self.lover_list)
    local lover_id = self.lover_list[index]
    local lover_info = self.db.lover_dict[lover_id]
    local level_data = excel_data.LoverLevelData[lover_info.level]
    lover_info.power_value = lover_info.power_value + level_data.discuss_power_value
    local child_info = self:check_has_children(g_const.LoverHappyType.Flop, lover_id)
    self.fondle_lover_id = lover_id
    self.fondle_num = excel_data.ParamData["lover_fondle_num_limit"].f_value
    self.role:update_task(CSConst.TaskType.Discuss, {progress = 1})
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.RandomDoteLoverNum, 1)
    self.role:update_daily_active(CSConst.DailyActiveTaskType.RandomDoteLoverNum, 1)
    self.role:update_achievement(CSConst.AchievementType.Discuss, 1)
    self.role:update_festival_activity_data(CSConst.FestivalActivityType.appointment) -- 节日活动随机约会次数

    self.role:send_client("s_update_lover_info", {
        lover_id = lover_id,
        power_value = lover_info.power_value,
    })
    return {errcode = g_tips.ok, lover_id = lover_id, child_info = child_info, fondle_num = self.fondle_num}
end

-- 检查是否会得到孩子
function role_lover:check_has_children(type_id, lover_id)
    -- 有概率得到孩子
    local child_info = self.role:new_child(type_id, lover_id)
    if child_info then
        local lover_info = self.db.lover_dict[lover_id]
        lover_info.children = lover_info.children + 1
        self.role:send_client("s_update_lover_info", {
            lover_id = lover_id,
            children = lover_info.children
        })
    end
    return child_info
end

-- 恢复精力（使用物品增加商谈次数）
function role_lover:recover_energy(item_count)
    if not item_count then return end
    local item_id = excel_data.ParamData["lover_discuss_recover_item"].item_id
    if not self.role:consume_item(item_id, item_count, g_reason.lover_recover_energy) then
        return
    end

    local item_data = excel_data.ItemData[item_id]
    self.db.discuss_num = self.db.discuss_num + item_data.recover_count * item_count
    local role_level = self.role:get_level()
    local level_data = excel_data.LevelData[role_level]
    local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.DateLoverNum)
    if self.db.discuss_num >= level_data.discuss_max_count + extra_num and self.discuss_timer then
        self.discuss_timer:cancel()
        self.discuss_timer = nil
    end
    self.role:send_client("s_update_discuss_data", {
        discuss_num = self.db.discuss_num,
    })
    return true
end

-- 解锁情人技能
function role_lover:unlock_lover_spell(db_lover, not_notify)
    local lover_data = excel_data.LoverData[db_lover.lover_id]
    local is_change
    for i, spell_id in pairs(lover_data.spell_list) do
        if not db_lover.spell_dict[spell_id]
            and db_lover.level >= lover_data.spell_unlock_lv[i] then
            -- 情人等级满足则解锁技能
            db_lover.spell_dict[spell_id] = 1
            self:spell_add_attr(db_lover.lover_id, spell_id)
            is_change = true
        end
    end
    if is_change and not not_notify then
        self.role:send_client("s_update_lover_info", {
            lover_id = db_lover.lover_id,
            spell_dict = db_lover.spell_dict
        })
    end
end

-- 提升情人技能，消耗势力值
function role_lover:upgrade_lover_spell(lover_id, spell_id)
    if not lover_id or not spell_id then return end
    local lover_info = self.db.lover_dict[lover_id]
    if not lover_info then return end
    local spell_level = lover_info.spell_dict[spell_id]
    if not spell_level then return end
    local spell_data = excel_data.LoverSpellData[spell_id]
    if spell_level >= spell_data.level_limit then return end
    local cost_power_value = spell_data.param_a * spell_level * spell_level + spell_data.param_b * spell_level + spell_data.param_c
    cost_power_value = math.ceil(cost_power_value)
    if lover_info.power_value < cost_power_value then return end

    lover_info.power_value = lover_info.power_value - cost_power_value
    local new_level = spell_level + 1
    lover_info.spell_dict[spell_id] = new_level
    self:spell_add_attr(lover_id, spell_id)

    self.role:send_client("s_update_lover_info", {
        lover_id = lover_id,
        spell_dict = lover_info.spell_dict,
        power_value = lover_info.power_value
    })
    return true
end

-- 情人技能增加英雄属性
function role_lover:spell_add_attr(lover_id, spell_id)
    local spell_data = excel_data.LoverSpellData[spell_id]
    local attr_dict = {}
    for i, attr_name in ipairs(spell_data.attr_list) do
        attr_dict[attr_name] = spell_data.attr_ratio[i]
    end
    if spell_data.is_all then
        local hero_dict = self.role:get_hero_dict()
        for hero_id in pairs(hero_dict) do
            self.role:modify_hero_attr(hero_id, nil, attr_dict, true)
        end
    else
        local lover_data = excel_data.LoverData[lover_id]
        for _, hero_id in ipairs(lover_data.hero) do
            self.role:modify_hero_attr(hero_id, nil, attr_dict, true)
        end
    end
    self.role:send_score_msg()
    return true
end

-- 赠送情人物品
function role_lover:give_lover_item(lover_id, item_id)
    if not lover_id or not item_id then return end
    local lover_info = self.db.lover_dict[lover_id]
    if not lover_info then return end
    local item_data = excel_data.ItemData[item_id]
    if not item_data then return end
    if item_data.add_exp then
        if lover_info.level >= #excel_data.LoverLevelData then return end
    end
    if item_data.sub_type ~= CSConst.ItemSubType.LoverStuff then return end
    if not self.role:consume_item(item_id, 1, g_reason.lover_give_item) then
        return
    end

    if item_data.add_exp then
        -- 加经验类物品
        self:add_lover_exp(lover_id, item_data.add_exp)
    elseif item_data.add_attr then
        -- 加属性类物品
        self:modify_lover_attr(lover_info, nil, {[item_data.add_attr] = item_data.attr_value})
    else
        error("lover item error")
    end
    return true
end

-- 赠送10次情人物品
function role_lover:give_ten_lover_item(lover_id, item_id)
    for i = 1, GIVE_TEN_ITEM do
        if not self:give_lover_item(lover_id, item_id) then break end
    end
    return true
end

-- 增加经验
function role_lover:add_lover_exp(lover_id, add_exp)
    if add_exp <= 0 then return end
    local lover_info = self.db.lover_dict[lover_id]
    if not lover_info then return end
    if lover_info.level >= #excel_data.LoverLevelData then return end
    lover_info.exp = lover_info.exp + add_exp
    self:check_lover_level_up(lover_info)
    self.role:send_client("s_update_lover_info", {
        lover_id = lover_id,
        exp = lover_info.exp
    })
    self.role:update_activity_data(CSConst.ActivityType.GrowthIntimacy, add_exp) -- 限时活动-情人经验统计
    self.role:update_rush_activity_data(CSConst.RushActivityType.intimacy, add_exp) -- 冲榜活动-情人亲密度涨幅
end

-- 检查情人是否能升级
function role_lover:check_lover_level_up(db_lover)
    if db_lover.level >= #excel_data.LoverLevelData then return end
    if db_lover.exp < excel_data.LoverLevelData[db_lover.level + 1].exp then return end

    local new_level = db_lover.level + 1
    db_lover.level = new_level
    self:on_lover_level_up(db_lover)
    self:check_lover_level_up(db_lover)
    if new_level == db_lover.level then
        self.role:party_update_lover_level(db_lover.lover_id, db_lover.level)
        self.role:send_client("s_update_lover_info", {
            lover_id = db_lover.lover_id,
            level = db_lover.level
        })
    end
end

function role_lover:on_lover_level_up(db_lover)
    self:unlock_lover_spell(db_lover)
    self.role:update_task(CSConst.TaskType.LoverLevel)
    self.role:update_achievement(CSConst.AchievementType.LoverLevel, 1)
end

-- 修改情人属性
function role_lover:modify_lover_attr(db_lover, old_attr_dict, new_attr_dict)
    local attr_diff_dict = role_utils.get_attr_dict_diff(old_attr_dict, new_attr_dict)
    if not attr_diff_dict then return end
    attr_diff_dict = g_const.StLoverAttr(attr_diff_dict)

    local attr_dict = db_lover.attr_dict
    for attr_name, value in pairs(attr_diff_dict) do
        attr_dict[attr_name] = attr_dict[attr_name] + value
        if attr_dict[attr_name] < 0 then
            error("modify lover attr error: "..attr_name.."="..attr_dict[attr_name])
        end
    end

    self.role:send_client("s_update_lover_info", {
        lover_id = db_lover.lover_id,
        attr_dict = attr_dict
    })
end

-- 宠爱情人，增加情人经验和势力值，有概率得到孩子
function role_lover:dote_lover(lover_id)
    if not lover_id then return end
    local lover_info = self.db.lover_dict[lover_id]
    if not lover_info then return end
    local level_data = excel_data.LoverLevelData[lover_info.level]
    if not self.role:consume_item(level_data.cost_item, level_data.cost_num, g_reason.lover_dote) then
        return
    end

    lover_info.power_value = lover_info.power_value + level_data.dote_power_value
    self:add_lover_exp(lover_id, level_data.dote_exp)
    local child_info
    if self.db.is_first_dote_lover then
        -- 第一次宠爱不生孩子
        self.db.is_first_dote_lover = nil
    else
        child_info = self:check_has_children(g_const.LoverHappyType.Dote, lover_id)
    end
    self.role:send_client("s_update_lover_info", {
        lover_id = lover_id,
        power_value = lover_info.power_value,
    })
    self.fondle_lover_id = lover_id
    self.fondle_num = excel_data.ParamData["lover_fondle_num_limit"].f_value
    self.role:update_daily_active(CSConst.DailyActiveTaskType.DoteLoverNum, 1)
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.DoteLoverNum, 1)
    self.role:update_task(CSConst.TaskType.Dote, {progress = 1})
    self.role:update_achievement(CSConst.AchievementType.Dote, 1)
    self.role:update_festival_activity_data(CSConst.FestivalActivityType.pettingLover) -- 节日活动宠爱次数
    return {errcode = g_tips.ok, child_info = child_info, fondle_num = self.fondle_num}
end

-- 解锁情人时装
function role_lover:unlock_lover_fashion(lover_id, fashion_id)
    -- print("unlock_lover_fashion step 8")
    -- print("lover_id :"..lover_id)
    -- print("unlock_fashion :"..tostring(fashion_id))
    if not lover_id or not fashion_id then return end
    -- print("unlock_lover_fashion step 9")
    local fashion_data = excel_data.ItemData[fashion_id]
    -- print("unlock_lover_fashion step 10")
    if not fashion_data then return end
    local lover_info = self.db.lover_dict[lover_id]
    -- print("unlock_lover_fashion step 11"..lover_id)
    if not lover_info then return end
    -- print("unlock_lover_fashion step 12")
    local lover_data = excel_data.LoverData[lover_id]
    -- print("unlock_lover_fashion step 13")
    local fashion_dict = lover_info.fashion_dict
    -- print("fashion_dict :"..json.encode(fashion_dict))
    --if fashion_data.sex ~= lover_data.sex then
    --    print("unlock_lover_fashion step 1")
    --    -- 表示另一个性别的时装
    --    if not excel_data.LoverData[lover_data.change_sex].fashion_dict[fashion_id] then
    --        print("unlock_lover_fashion step 2")
    --        -- 不在可穿列表
    --        return
    --    end
    --    print("unlock_lover_fashion step 3")
    --    fashion_dict = lover_info.other_fashion_dict
    --else
        -- print("unlock_lover_fashion step 4")
        if not lover_data.fashion_dict[fashion_id] then
            -- print("unlock_lover_fashion step 5")
            return
        end
    --end
    -- print("unlock_lover_fashion step 6")
    if fashion_dict[fashion_id] then return end
    -- print("unlock_lover_fashion step 7")
    fashion_dict[fashion_id] = true
    if fashion_data.attr_dict then
        self:modify_lover_attr(lover_info, nil, fashion_data.attr_dict)
    end

    local msg = {lover_id = lover_id}
    --if fashion_data.sex ~= lover_data.sex then
    --    msg.other_fashion_dict = fashion_dict
    --else
        msg.fashion_dict = fashion_dict
    --end
    self.role:send_client("s_update_lover_info", msg)
    -- print("unlock_lover_fashion msg : "..json.encode(msg))
    return true
end

-- 更换情人时装
function role_lover:change_lover_fashion(lover_id, fashion_id)
    -- print("lover_id :"..lover_id)
    -- print("fashion_id :"..fashion_id)
    if not lover_id or not fashion_id then return end
    local lover_info = self.db.lover_dict[lover_id]
    -- print("lover_info :"..json.encode(lover_info))
    if not lover_info then return end
    -- print("step 1")
    local  old_fashion_id = lover_info.fashion_id
    if lover_info.fashion_id == fashion_id then return end
    -- print("step 2")
    if not lover_info.fashion_dict[fashion_id] then return end
    -- print("step 3")
    lover_info.fashion_id = fashion_id

    local old_attr_dict
    if  old_fashion_id then
        local fashion_data_old = excel_data.ItemData[old_fashion_id]
        old_attr_dict = fashion_data_old.attr_dict
    end

    local new_attr_dict
    if fashion_id then
        local fashion_data_new = excel_data.ItemData[lover_info.fashion_id]
        new_attr_dict = fashion_data_new.attr_dict
    end
    -- print("new_attr_dict :"..json.encode(new_attr_dict))
    -- print("old_attr_dict :"..json.encode(old_attr_dict))

    local lover_data = excel_data.LoverData[lover_id]
    for _, hero_id in ipairs(lover_data.hero) do
        self.role:modify_hero_attr(hero_id, old_attr_dict, new_attr_dict, true)
    end


    self.role:send_client("s_update_lover_info", {
        lover_id = lover_id,
        fashion_id = lover_info.fashion_id
    })
    return true
end

-- 男女切换
function role_lover:change_lover_sex(lover_id)
    -- TODO：该功能暂时去掉
    -- if not lover_id then return end
    -- local lover_info = self.db.lover_dict[lover_id]
    -- if not lover_info then return end
    -- local lover_data = excel_data.LoverData[lover_id]
    -- local new_id = lover_data.change_sex
    -- if not new_id then return end

    -- local new_lover = table.deep_copy(lover_info)
    -- new_lover.lover_id = new_id
    -- new_lover.fashion_dict, new_lover.other_fashion_dict = new_lover.other_fashion_dict, new_lover.fashion_dict
    -- new_lover.fashion_id = excel_data.LoverData[new_id].fashion[1]
    -- self.db.lover_dict[lover_id] = nil
    -- self.db.lover_dict[new_id] = new_lover

    -- table.delete(self.lover_list, lover_id)
    -- table.insert(self.lover_list, new_id)

    -- return new_lover
end

-- 改变情人品级，有升有降
function role_lover:change_lover_grade(lover_id, grade)
    if not lover_id then return end
    local lover_info = self.db.lover_dict[lover_id]
    if not lover_info then return end
    local old_grade = lover_info.grade
    if old_grade == grade then return end
    -- 不能跨品级提升
    if grade - old_grade > 1 or grade - old_grade < -1 then return end
    local grade_data = excel_data.GradeData[grade]
    if not grade_data then return end
    if lover_info.level < grade_data.level_limit then return end
    local grade_lover_num = self:get_grade_lover_num(grade)
    if grade_data.max_count > 0 and grade_lover_num >= grade_data.max_count then
        -- 该品级人数已满
        return
    end
    local all_attr = 0
    for _, v in pairs(lover_info.attr_dict) do
        all_attr = all_attr + v
    end
    if all_attr < grade_data.attr_sum_limit then
        -- 总属性值不满足
        return
    end
    if grade > lover_info.grade then
        local item_id = grade_data.promote_item_id
        local cost_num = grade_data.promote_item_count
        if not self.role:consume_item(item_id, cost_num, g_reason.change_lover_grade) then
            return
        end
    end
    lover_info.old_grade = lover_info.grade
    lover_info.grade = grade

    local old_data = excel_data.GradeData[lover_info.old_grade]
    self.role:modify_attr(old_data.add_attr_dict, grade_data.add_attr_dict, true)
    self.role:salon_lover_compute()
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.LoverGrade, grade)
    self.role:update_task(CSConst.TaskType.LoverGrade)
    self.role:guide_event_trigger_check(CSConst.GuideEventTriggerType.GetFirstBeauty) -- 第一个美人

    self.role:send_client("s_update_lover_info", {
        lover_id = lover_id,
        old_grade = lover_info.old_grade,
        grade = lover_info.grade
    })
    return true
end

-- 获取某品级的情人数
function role_lover:get_grade_lover_num(grade)
    local count = 0
    local lover_dict = self.db.lover_dict
    for _, lover_info in pairs(lover_dict) do
        if lover_info.grade == grade then
            count = count + 1
        end
    end
    return count
end

-- 情人升星
function role_lover:upgrade_lover_star_lv(lover_id)
    if not lover_id then return end
    local lover_info = self.db.lover_dict[lover_id]
    if not lover_info then return end
    local old_star_lv = lover_info.star_lv
    local max_level = excel_data.ParamData["lover_star_lv_limit"].f_value
    if old_star_lv >= max_level then return end

    local new_star_lv = old_star_lv + 1
    local item_dict = CSFunction.get_lover_star_cost(lover_id, new_star_lv)
    if not self.role:consume_item_dict(item_dict, g_reason.upgrade_lover_star_lv) then return end
    lover_info.star_lv = new_star_lv
    local old_attr_dict = CSFunction.get_lover_star_attr(lover_id, old_star_lv)
    local new_attr_dict = CSFunction.get_lover_star_attr(lover_id, new_star_lv)
    -- print("new_attr_dict :"..json.encode(new_attr_dict))
    -- print("old_attr_dict :"..json.encode(old_attr_dict))
    local lover_data = excel_data.LoverData[lover_id]
    for _, hero_id in ipairs(lover_data.hero) do
        self.role:modify_hero_attr(hero_id, old_attr_dict, new_attr_dict, true)
    end
    self.role:send_score_msg()

    local fashion_unlock_lv = lover_data.fashion_unlock_lv
    local fashion = lover_data.fashion

    -- print("fashion_unlock_lv :"..json.encode(fashion_unlock_lv))
    -- print("fashion :"..json.encode(fashion))

    for index , start in ipairs(fashion_unlock_lv) do
        if start > 0 and start == lover_info.star_lv  then
            if fashion[index+1] then
                -- print("lover_id :"..lover_id)
                self:unlock_lover_fashion(lover_id,fashion[index+1])
            end
        end
    end

    self.role:send_client("s_update_lover_info", {
        lover_id = lover_id,
        star_lv = lover_info.star_lv
    })
    self.role:log("LoverStarLvUp", {lover_id = lover_id, old_star_lv = old_star_lv, new_star_lv = new_star_lv})
    return true
end

--查询情人信息
function role_lover:query_lover_info(lover_id)
    -- print("query_lover_info lover_id :"..lover_id)
    if not lover_id then return end
    local lover_info = self.db.lover_dict[lover_id]
    if not lover_info then return end
    -- print("query_lover_info lover_info :"..json.encode(lover_info))
    return {errcode = g_tips.ok, fashion_id = lover_info.fashion_id}
end

function role_lover:shop_refresh_num_recover()
    local lover_shop = self.db.lover_shop
    local data = excel_data.ShopData["LoverShop"]
    if lover_shop.free_refresh_num < data.free_refresh_num then
        lover_shop.free_refresh_num = lover_shop.free_refresh_num + 1
        lover_shop.refresh_ts = date.time_second()
        self.role:send_client("s_update_lover_shop", lover_shop)
    end
    if lover_shop.free_refresh_num >= data.free_refresh_num then
        self.shop_refresh_num_timer:cancel()
        self.shop_refresh_num_timer = nil
    end
end

-- 刷新情人商店
function role_lover:refresh_lover_shop()
    local lover_shop = self.db.lover_shop
    local data = excel_data.ShopData["LoverShop"]
    if lover_shop.total_refresh_num <= 0 then return end
    if lover_shop.free_refresh_num > 0 then
        lover_shop.free_refresh_num = lover_shop.free_refresh_num - 1
        if lover_shop.free_refresh_num < data.free_refresh_num then
            if not self.shop_refresh_num_timer then
                lover_shop.refresh_ts = date.time_second()
                local recover_time = data.loop_refresh_time * CSConst.Time.Minute
                self.shop_refresh_num_timer = self.role:timer_loop(recover_time, function()
                    self:shop_refresh_num_recover()
                end)
            end
        end
    else
        if not self.role:consume_item(data.refresh_item, data.refresh_price, g_reason.refresh_lover_shop) then return end
    end
    lover_shop.total_refresh_num = lover_shop.total_refresh_num - 1
    self:_refresh_lover_shop()
    self.role:send_client("s_update_lover_shop", lover_shop)
    return true
end

function role_lover:_refresh_lover_shop()
    local lover_shop = self.db.lover_shop
    lover_shop.shop_dict = {}
    local role_level = self.role:get_level()
    local weight_table = {}
    for key, v in pairs(excel_data.LoverShopData) do
        if v.open_level and role_level >= v.open_level then
            weight_table[key] = v.weight
        end
    end
    local data = excel_data.ShopData["LoverShop"]
    for i = 1, data.refresh_item_num do
        local shop_id = math.roll(weight_table)
        lover_shop.shop_dict[shop_id] = 0
        weight_table[shop_id] = nil
    end
end

-- 购买物品（只能买一次）
function role_lover:buy_lover_shop_item(shop_id)
    local lover_shop = self.db.lover_shop
    if not shop_id then return end
    local data = excel_data.LoverShopData[shop_id]
    if not data then return end
    if not lover_shop.shop_dict[shop_id] or lover_shop.shop_dict[shop_id] >= 1 then return end
    if not self.role:consume_item_list(data.cost_item_list, g_reason.lover_shop) then return end
    lover_shop.shop_dict[shop_id] = lover_shop.shop_dict[shop_id] + 1
    self.role:add_item(data.item_id, data.item_count, g_reason.lover_shop)
    self.role:send_client("s_update_lover_shop", lover_shop)
    self.role:gaea_log("ShopConsume", {
        itemId = data.item_id,
        itemCount = data.item_count,
        consume = data.cost_item_list
    })
    return true
end

-- 一键消耗所有体力，商谈情人
function role_lover:total_lover_discuss()
    local lover_list = {}
    local child_dict = {}
    for i = 1, self.db.discuss_num do
        local ret = self:lover_discuss()
        if not ret then break end
        table.insert(lover_list, ret.lover_id)
        if ret.child_info then
            child_dict[ret.lover_id] = ret.child_info
        end
    end
    return {errcode = g_tips.ok, lover_list = lover_list, child_dict = child_dict}
end

-- 爱抚情人
function role_lover:fondle_lover()
    if not self.fondle_num or self.fondle_num == 0 then return end
    self.fondle_num = self.fondle_num - 1
    local lover_id = self.fondle_lover_id
    local param_data = excel_data.ParamData
    local param1 = param_data["lover_fondle_power_value_param1"].f_value
    local param2 = param_data["lover_fondle_power_value_param2"].f_value
    local param3 = param_data["lover_fondle_power_value_param3"].f_value
    local lover_info = self.db.lover_dict[lover_id]
    local power_value = math.floor((lover_info.level + param1) * param2 / param3)
    power_value = power_value < 1 and 1 or power_value
    lover_info.power_value = lover_info.power_value + power_value
    self.role:send_client("s_update_lover_info", {
        lover_id = lover_id,
        power_value = lover_info.power_value,
    })
    return {errcode = g_tips.ok, power_value = power_value, fondle_num = self.fondle_num}
end
--------------------------- lover train star -----------------------------------
-- 随机情人培训事件
local function random_lover_train_event(event_dict)
    local event_list = {}
    -- 筛选可以随机的事件
    for event_id, event_data in pairs(excel_data.TrainEventData) do
        if not event_dict[event_id] then
            table.insert(event_list, event_id)
        end
    end
    if not next(event_list) then return end
    local index = math.random(#event_list)
    return event_list[index]
end

-- 初始化培训事件
function role_lover:init_lover_train()
    self.db.lover_train = {}
    local lover_train = self.db.lover_train
    lover_train.grid_num = excel_data.ParamData["lover_train_init_grid"].f_value
    lover_train.quicken_num = excel_data.ParamData["lover_event_quicken_num"].f_value
    local event_dict = lover_train.event_dict
    for i=1, lover_train.grid_num do
        local event_id = random_lover_train_event(event_dict)
        if event_id then
            event_dict[event_id] = {event_id = event_id}
        end
    end
end

-- 每天刷新培训加速次数
function role_lover:daily_lover_train()
    local lover_train = self.db.lover_train
    lover_train.quicken_num = excel_data.ParamData["lover_event_quicken_num"].f_value
    self.role:send_client("s_update_lover_train_info", {quicken_num = lover_train.quicken_num})
end

function role_lover:online_lover_train()
    local event_dict = self.db.lover_train.event_dict
    for event_id, event_info in pairs(event_dict) do
        if event_info.lover_id and not event_info.is_finish then
            -- 没有完成的事件，上线时判断是否完成了
            local now = date.time_second()
            local train_time = excel_data.ParamData["lover_train_time"].f_value * CSConst.Time.Minute
            if now - event_info.train_ts < train_time then
                if self.train_timer_dict[event_id] then
                    self.train_timer_dict[event_id]:cancel()
                end
                local delay = train_time - (now - event_info.train_ts)
                self.train_timer_dict[event_id] = self.role:timer_once(delay, function ()
                    self:lover_train_finish(event_id)
                end)
            else
                event_info.is_finish = true
            end
        end
    end

    self.role:send_client("s_update_lover_train_info", self.db.lover_train)
end

-- 培训结束
function role_lover:lover_train_finish(event_id)
    self.train_timer_dict[event_id] = nil
    local event_info = self.db.lover_train.event_dict[event_id]
    if not event_info then return end
    event_info.is_finish = true
    self.role:send_client("s_lover_train_finish", {event_id = event_id})
end

-- 判断情人是否正在培训
function role_lover:is_lover_training(lover_id)
    local event_dict = self.db.lover_train.event_dict
    for event_id, event_info in pairs(event_dict) do
        if event_info.lover_id == lover_id then
            return true
        end
    end
end

-- 情人培训
function role_lover:lover_train(lover_id, event_id)
    if not lover_id or not event_id then return end
    if not self.db.lover_dict[lover_id] then return end
    if self:is_lover_training(lover_id) then return end
    local event_dict = self.db.lover_train.event_dict
    local event_info = event_dict[event_id]
    if not event_info or event_info.lover_id then return end

    event_info.lover_id = lover_id
    event_info.train_ts = date.time_second()
    local delay = excel_data.ParamData["lover_train_time"].f_value * CSConst.Time.Minute
    self.train_timer_dict[event_id] = self.role:timer_once(delay, function ()
        self:lover_train_finish(event_id)
    end)
    self.role:send_client("s_update_lover_train_info", {event_dict = event_dict})
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.LoverTrain, 1)
    self.role:update_daily_active(CSConst.DailyActiveTaskType.TrainLoverNum, 1)
    self.role:update_festival_activity_data(CSConst.FestivalActivityType.loverTraining) -- 节日活动情人培训
    return true
end

-- 情人培训加速，花钱可以立即完成
function role_lover:lover_train_quicken(event_id)
    if not event_id then return end
    local lover_train = self.db.lover_train
    if lover_train.quicken_num <= 0 then return end
    local event_info = lover_train.event_dict[event_id]
    if not event_info or not event_info.lover_id then return end
    if event_info.is_finish then return end

    local cost_item = excel_data.ParamData["lover_quicken_cost_item"].item_id
    -- 消耗数量为剩余分钟数
    local train_time = excel_data.ParamData["lover_train_time"].f_value * CSConst.Time.Minute
    local cost_num = (event_info.train_ts + train_time - date.time_second()) / CSConst.Time.Minute
    cost_num = math.ceil(cost_num)
    if not self.role:consume_item(cost_item, cost_num, g_reason.lover_train_quicken) then
        return
    end

    lover_train.quicken_num = lover_train.quicken_num - 1
    self.train_timer_dict[event_id]:cancel()
    self:lover_train_finish(event_id)

    return true
end

-- 情人培训完成，需要手动领取奖励
function role_lover:get_lover_train_reward(event_id)
    if not event_id then return end
    local event_dict = self.db.lover_train.event_dict
    local event_info = event_dict[event_id]
    if not event_info or not event_info.is_finish then return end

    -- 完成培训，给情人加属性
    local event_data = excel_data.TrainEventData[event_id]
    local lover_info = self.db.lover_dict[event_info.lover_id]
    self:modify_lover_attr(lover_info, nil, event_data.attr_dict)
    event_dict[event_id] = nil
    -- 完成一个培训事件立即随机增加一个
    local new_event_id = random_lover_train_event(event_dict)
    if new_event_id then
        event_dict[new_event_id] = {event_id = new_event_id}
    end
    self.role:send_client("s_update_lover_train_info", {event_dict = event_dict})

    return true
end

-- 解锁情人培训事件格子
function role_lover:lover_unlock_event_grid()
    local lover_train = self.db.lover_train
    local grid_index = lover_train.grid_num + 1
    local grid_data = excel_data.EventGridData[grid_index]
    if not grid_data then return end
    if grid_data.cost_value and not self.role:consume_item(grid_data.cost_name, grid_data.cost_value, g_reason.lover_train_unlocak) then
        return
    end

    lover_train.grid_num = lover_train.grid_num + 1
    -- 增加一个格子立即随机增加一个培训事件
    local event_dict = lover_train.event_dict
    local event_id = random_lover_train_event(event_dict)
    if event_id then
        event_dict[event_id] = {event_id = event_id}
    end
    self.role:send_client("s_update_lover_train_info", {
        event_dict = event_dict,
        grid_num = lover_train.grid_num
    })

    return true
end
--------------------------- lover train end -----------------------------------

-- vip升级获得额外商店刷新次数次数
function role_lover:vip_level_up_privilege_lovershop_num(old_level, new_level)
    local old_level_info = excel_data.VipData[old_level]
    local new_level_info = excel_data.VipData[new_level]
    local lock_info = excel_data.VIPPrivilegeData
    local lock_name = lock_info[CSConst.VipPrivilege.LovershopRefresh].vip_data_name
    local extra_num = new_level_info[lock_name]
    if old_level > 0 then extra_num = extra_num - old_level_info[lock_name] end
    local lover_shop = self.db.lover_shop
    lover_shop.total_refresh_num = lover_shop.total_refresh_num + extra_num
    self.role:send_client("s_update_lover_shop", lover_shop)

    local role_level = self.role:get_level()
    local level_data = excel_data.LevelData[role_level]
    local extra_num = self.role:get_vip_privilege_num(CSConst.VipPrivilege.DateLoverNum)
    if self.db.discuss_num < level_data.discuss_max_count + extra_num and not self.discuss_timer then
        self.db.discuss_ts = date.time_second()
        self.discuss_timer = self.role:timer_loop(level_data.energy_cooldown, function()
            self:discuss_num_recover()
        end)
        self.role:send_client("s_update_discuss_data", {
            discuss_num = self.db.discuss_num,
            discuss_ts = self.db.discuss_ts
        })
    end
end

return role_lover
