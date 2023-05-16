local date = require("sys_utils.date")
local excel_data = require("excel_data")

local bar = DECLARE_MODULE("meta_table.bar")

function bar.new(role)
    local self = {
        role = role,
        data = role.db.bar,
    }
    return setmetatable(self, bar)
end

-- 创建账号
function bar:on_init()
    self.role.db.bar = {
        hero_dict = {},
        lover_id = 0,
        lover_cnt = 0,
        hero_already_refresh_cnt = 0,
        hero_already_challenge_cnt = 0,
        hero_remaining_challenge_cnt = 0,
        lover_already_refresh_cnt = 0,
        lover_already_challenge_cnt = 0,
        lover_remaining_challenge_cnt = 0,
    }
    self.data = self.role.db.bar
end

-- 每日刷新
function bar:on_daily()
    self.data.hero_already_refresh_cnt = 0
    self.data.hero_already_challenge_cnt = 0
    self.data.lover_already_refresh_cnt = 0
    self.data.lover_already_challenge_cnt = 0
    if self.data.hero_remaining_challenge_cnt < excel_data.ParamData.bar_hero_free_challenge_times.f_value then
        self.data.hero_remaining_challenge_cnt = excel_data.ParamData.bar_hero_free_challenge_times.f_value
    end
    if self.data.lover_remaining_challenge_cnt < excel_data.ParamData.bar_lover_free_challenge_times.f_value then 
        self.data.lover_remaining_challenge_cnt = excel_data.ParamData.bar_lover_free_challenge_times.f_value
    end
    self.role:send_client("s_update_bar_count_data", {
        hero_already_refresh_cnt = self.data.hero_already_refresh_cnt,
        hero_already_challenge_cnt = self.data.hero_already_challenge_cnt,
        hero_remaining_challenge_cnt = self.data.hero_remaining_challenge_cnt,
        lover_already_refresh_cnt = self.data.lover_already_refresh_cnt,
        lover_already_challenge_cnt = self.data.lover_already_challenge_cnt,
        lover_remaining_challenge_cnt = self.data.lover_remaining_challenge_cnt,
    })
end

-- 每小时刷新
function bar:on_hourly(pre_hourly_ts)
    local hour_list = excel_data.ParamData.bar_refresh_time_list.tb_int
    local last_online_hour0 = date.get_hour_begin(pre_hourly_ts)
    local last_online_day0 = date.get_begin0(pre_hourly_ts)
    local curr_online_hour0 = date.get_hour_begin()
    local curr_online_day0 = date.get_begin0()
    if (curr_online_day0 - last_online_day0) // CSConst.Time.Day > 1 then
        self:refresh_hero(true)
        self:refresh_lover(true)
        self.role:send_client("s_update_bar_unit_data", {
            hero_dict = self.data.hero_dict,
            lover_id = self.data.lover_id,
            lover_cnt = self.data.lover_cnt,
        })
        return
    end
    for _, hour in ipairs(hour_list) do
        local last_should_refresh_ts = last_online_day0 + hour * CSConst.Time.Hour
        local curr_should_refresh_ts = curr_online_day0 + hour * CSConst.Time.Hour
        if (last_online_hour0 < last_should_refresh_ts and last_should_refresh_ts <= curr_online_hour0) or
           (last_online_hour0 < curr_should_refresh_ts and curr_should_refresh_ts <= curr_online_hour0)
        then
            self:refresh_hero(true)
            self:refresh_lover(true)
            self.role:send_client("s_update_bar_unit_data", {
                hero_dict = self.data.hero_dict,
                lover_id = self.data.lover_id,
                lover_cnt = self.data.lover_cnt,
            })
            return
        end
    end
end

-- 客户端上线
function bar:on_online()
    self.role:send_client("s_update_bar_unit_data", {
        hero_dict = self.data.hero_dict,
        lover_id = self.data.lover_id,
        lover_cnt = self.data.lover_cnt,
    })
    self.role:send_client("s_update_bar_count_data", {
        hero_already_refresh_cnt = self.data.hero_already_refresh_cnt,
        hero_already_challenge_cnt = self.data.hero_already_challenge_cnt,
        hero_remaining_challenge_cnt = self.data.hero_remaining_challenge_cnt,
        lover_already_refresh_cnt = self.data.lover_already_refresh_cnt,
        lover_already_challenge_cnt = self.data.lover_already_challenge_cnt,
        lover_remaining_challenge_cnt = self.data.lover_remaining_challenge_cnt,
    })
end

-- 刷新酒吧英雄
function bar:refresh_hero(is_system_refresh)
    if not is_system_refresh then
        local bar_hero_refresh_basic_times = excel_data.ParamData.bar_hero_refresh_basic_times.f_value
        local bar_hero_refresh_extra_times = excel_data.VipData[self.role:get_vip()].bar_hero_refresh_extra_times
        if self.data.hero_already_refresh_cnt >= bar_hero_refresh_basic_times + bar_hero_refresh_extra_times then return end
        local refresh_price_list = excel_data.ParamData.bar_hero_refresh_price_list.tb_int
        local refresh_price = refresh_price_list[self.data.hero_already_refresh_cnt + 1] or refresh_price_list[#refresh_price_list]
        if not self.role:sub_currency(CSConst.Virtual.Diamond, refresh_price, g_reason.bar_refresh_hero_consume) then return end
        self.data.hero_already_refresh_cnt = self.data.hero_already_refresh_cnt + 1
    end

    self.data.hero_dict = {}
    local hero_dict = self.data.hero_dict
    local weight_table = excel_data.BarHeroData.weight_table
    local total_weight = excel_data.BarHeroData.total_weight
    local random_count = excel_data.ParamData.bar_hero_random_count.f_value
    while #hero_dict < random_count do
        local barhero_id = math.roll(weight_table, total_weight)
        local barhero_exldata = excel_data.BarHeroData[barhero_id]
        local hero_id = barhero_exldata.hero_id
        if not hero_dict[hero_id] then
            hero_dict[hero_id] = barhero_exldata.challenge_num
        end
    end

    if not is_system_refresh then
        self.role:send_client("s_update_bar_unit_data", {hero_dict = self.data.hero_dict})
        self.role:send_client("s_update_bar_count_data", {hero_already_refresh_cnt = self.data.hero_already_refresh_cnt})
        return true
    end
end

-- 刷新酒吧情人
function bar:refresh_lover(is_system_refresh)
    if not is_system_refresh then
        local bar_lover_refresh_basic_times = excel_data.ParamData.bar_lover_refresh_basic_times.f_value
        local bar_lover_refresh_extra_times = excel_data.VipData[self.role:get_vip()].bar_lover_refresh_extra_times
        if self.data.lover_already_refresh_cnt >= bar_lover_refresh_basic_times + bar_lover_refresh_extra_times then return end
        local refresh_price_list = excel_data.ParamData.bar_lover_refresh_price_list.tb_int
        local refresh_price = refresh_price_list[self.data.lover_already_refresh_cnt + 1] or refresh_price_list[#refresh_price_list]
        if not self.role:sub_currency(CSConst.Virtual.Diamond, refresh_price, g_reason.bar_refresh_lover_consume) then return end
        self.data.lover_already_refresh_cnt = self.data.lover_already_refresh_cnt + 1
    end

    local weight_table = excel_data.BarLoverData.weight_table
    local total_weight = excel_data.BarLoverData.total_weight
    local barlover_id = math.roll(weight_table, total_weight)
    local barlover_exldata = excel_data.BarLoverData[barlover_id]
    self.data.lover_id = barlover_exldata.lover_id
    self.data.lover_cnt = barlover_exldata.challenge_num

    if not is_system_refresh then
        self.role:send_client("s_update_bar_unit_data", {lover_id = self.data.lover_id, lover_cnt = self.data.lover_cnt})
        self.role:send_client("s_update_bar_count_data", {lover_already_refresh_cnt = self.data.lover_already_refresh_cnt})
        return true
    end
end

-- 检查是否可与英雄进行游戏
function bar:can_play_with_hero(hero_id)
    if not hero_id or not self.data.hero_dict[hero_id] then return end
    return self.data.hero_dict[hero_id] > 0 and self.data.hero_remaining_challenge_cnt > 0
end

-- 检查是否可与情人进行游戏
function bar:can_play_with_lover(lover_id)
    if not lover_id or self.data.lover_id ~= lover_id then return end
    return self.data.lover_cnt > 0 and self.data.lover_remaining_challenge_cnt > 0
end

-- 检查是否可进行酒吧游戏
function bar:can_play_game(hero_id, lover_id)
    if hero_id and lover_id then return end
    if not hero_id and not lover_id then return end
    if hero_id then return self:can_play_with_hero(hero_id) end
    if lover_id then return self:can_play_with_lover(lover_id) end
end

-- 挑战酒吧英雄
function bar:challenge_hero(hero_id, is_victory)
    if not self:can_play_with_hero(hero_id) then return end
    self.data.hero_dict[hero_id] = self.data.hero_dict[hero_id] - 1
    self.data.hero_remaining_challenge_cnt = self.data.hero_remaining_challenge_cnt - 1
    local item_dict = {} -- item_id => item_count
    local hero_exldata = excel_data.HeroData[hero_id]
    local fragment_id = hero_exldata.fragment_id
    local barhero_exldata = excel_data.BarHeroData[hero_id]
    if is_victory then
        -- 胜利
        if math.random() < barhero_exldata.victory_hero_ratio then
            -- 获得整个英雄
            local hero_item_id = excel_data.ItemData[fragment_id].hero
            if self.role:get_hero(hero_id) then
                -- 已有该英雄，分解
                local fragment_cnt = excel_data.ItemData[hero_item_id].fragment_count
                item_dict[fragment_id] = fragment_cnt
                self.role:add_item(fragment_id, fragment_cnt, g_reason.bar_challenge_hero_success_reward)
            else
                -- 没有该英雄，添加
                item_dict[hero_item_id] = 1
                self.role:add_hero(hero_id)
            end
        else
            -- 获得英雄碎片
            item_dict[fragment_id] = barhero_exldata.victory_frag_num
            self.role:add_item(fragment_id, barhero_exldata.victory_frag_num, g_reason.bar_challenge_hero_success_reward)
        end
    else
        -- 失败
        item_dict[fragment_id] = barhero_exldata.failure_frag_num
        self.role:add_item(fragment_id, barhero_exldata.failure_frag_num, g_reason.bar_challenge_hero_failure_reward)
    end
    return item_dict
end

-- 挑战酒吧情人
function bar:challenge_lover(lover_id, is_victory)
    if not self:can_play_with_lover(lover_id) then return end
    self.data.lover_cnt = self.data.lover_cnt - 1
    self.data.lover_remaining_challenge_cnt = self.data.lover_remaining_challenge_cnt - 1
    local item_dict = {} -- item_id => item_count
    local lover_exldata = excel_data.LoverData[lover_id]
    local fragment_id = lover_exldata.fragment_id
    local barlover_exldata = excel_data.BarLoverData[lover_id]
    if is_victory then
        -- 胜利
        if math.random() < barlover_exldata.victory_lover_ratio then
            -- 获得整个情人
            local lover_item_id = excel_data.ItemData[fragment_id].lover
            if self.role:get_lover(lover_id) then
                -- 已有该情人，分解
                local fragment_cnt = excel_data.ItemData[lover_item_id].fragment_count
                item_dict[fragment_id] = fragment_cnt
                self.role:add_item(fragment_id, fragment_cnt, g_reason.bar_challenge_lover_success_reward)
            else
                -- 没有该情人，添加
                item_dict[lover_item_id] = 1
                self.role:add_lover(lover_id)
            end
        else
            -- 获得情人碎片
            item_dict[fragment_id] = barlover_exldata.victory_frag_num
            self.role:add_item(fragment_id, barlover_exldata.victory_frag_num, g_reason.bar_challenge_lover_success_reward)
        end
    else
        -- 失败
        item_dict[fragment_id] = barlover_exldata.failure_frag_num
        self.role:add_item(fragment_id, barlover_exldata.failure_frag_num, g_reason.bar_challenge_lover_failure_reward)
    end
    return item_dict
end

-- 酒吧普通挑战
function bar:general_challenge(hero_id, lover_id, is_victory)
    if not self:can_play_game(hero_id, lover_id) then return end
    local item_dict
    if hero_id then
        -- 挑战英雄
        item_dict = self:challenge_hero(hero_id, is_victory)
        self.role:send_client("s_update_bar_unit_data", {hero_dict = self.data.hero_dict})
        self.role:send_client("s_update_bar_count_data", {hero_remaining_challenge_cnt = self.data.hero_remaining_challenge_cnt})
    else
        -- 挑战情人
        item_dict = self:challenge_lover(lover_id, is_victory)
        self.role:send_client("s_update_bar_unit_data", {lover_id = self.data.lover_id, lover_cnt = self.data.lover_cnt})
        self.role:send_client("s_update_bar_count_data", {lover_remaining_challenge_cnt = self.data.lover_remaining_challenge_cnt})
    end
    return {item_dict = item_dict}
end

-- 酒吧快速挑战
function bar:quick_challenge(hero_id, lover_id)
    if not self.role:check_function_is_unlocked(CSConst.FuncUnlockId.BarQuickChallenge) then return end
    if not self:can_play_game(hero_id, lover_id) then return end
    local total_item_dict = {}
    if hero_id then
        -- 挑战英雄
        local victory_ratio = excel_data.ParamData.bar_hero_quick_challenge_victory_ratio.f_value
        local hero_remaining_cnt = self.data.hero_dict[hero_id]
        local total_remaining_cnt = self.data.hero_remaining_challenge_cnt
        local available_remaining_cnt = hero_remaining_cnt > total_remaining_cnt and total_remaining_cnt or hero_remaining_cnt
        for i = 1, available_remaining_cnt do
            local item_dict = self:challenge_hero(hero_id, math.random() < victory_ratio)
            if not item_dict then break end
            table.dict_attr_add(total_item_dict, item_dict)
        end
        self.role:send_client("s_update_bar_unit_data", {hero_dict = self.data.hero_dict})
        self.role:send_client("s_update_bar_count_data", {hero_remaining_challenge_cnt = self.data.hero_remaining_challenge_cnt})
    else
        -- 挑战情人
        local victory_ratio = excel_data.ParamData.bar_lover_quick_challenge_victory_ratio.f_value
        local lover_remaining_cnt = self.data.lover_cnt
        local total_remaining_cnt = self.data.lover_remaining_challenge_cnt
        local available_remaining_cnt = lover_remaining_cnt > total_remaining_cnt and total_remaining_cnt or lover_remaining_cnt
        for i = 1, available_remaining_cnt do
            local item_dict = self:challenge_lover(lover_id, math.random() < victory_ratio)
            if not item_dict then break end
            table.dict_attr_add(total_item_dict, item_dict)
        end
        self.role:send_client("s_update_bar_unit_data", {lover_id = self.data.lover_id, lover_cnt = self.data.lover_cnt})
        self.role:send_client("s_update_bar_count_data", {lover_remaining_challenge_cnt = self.data.lover_remaining_challenge_cnt})
    end
    return {item_dict = total_item_dict}
end

-- 购买酒吧挑战次数
function bar:buy_challenge_count(bar_type, buy_count)
    if bar_type ~= CSConst.BarType.Hero and bar_type ~= CSConst.BarType.Lover then return end
    buy_count = buy_count or 1
    if buy_count <= 0 then return end
    if bar_type == CSConst.BarType.Hero then
        -- 购买英雄挑战次数
        local challenge_price_list = excel_data.ParamData.bar_hero_challenge_price_list.tb_int
        local actual_own_currency = self.role:get_currency(CSConst.Virtual.Diamond)
        local expect_sub_currency = 0 -- 将要消耗的钻石数
        local can_buy_count = 0 -- 实际能购买的次数
        for i = 1, buy_count do
            local challenge_price = challenge_price_list[self.data.hero_already_challenge_cnt + i] or challenge_price_list[#challenge_price_list]
            if expect_sub_currency + challenge_price > actual_own_currency then
                break
            else
                expect_sub_currency = expect_sub_currency + challenge_price
                can_buy_count = can_buy_count + 1
            end
        end
        if can_buy_count <= 0 then return end
        self.role:sub_currency(CSConst.Virtual.Diamond, expect_sub_currency, g_reason.bar_buy_hero_challenge_num_consume)
        self.data.hero_already_challenge_cnt = self.data.hero_already_challenge_cnt + can_buy_count
        self.data.hero_remaining_challenge_cnt = self.data.hero_remaining_challenge_cnt + can_buy_count
        self.role:send_client("s_update_bar_count_data", {
            hero_already_challenge_cnt = self.data.hero_already_challenge_cnt,
            hero_remaining_challenge_cnt = self.data.hero_remaining_challenge_cnt,
        })
    else
        -- 购买情人挑战次数
        local challenge_price_list = excel_data.ParamData.bar_lover_challenge_price_list.tb_int
        local actual_own_currency = self.role:get_currency(CSConst.Virtual.Diamond)
        local expect_sub_currency = 0 -- 将要消耗的钻石数
        local can_buy_count = 0 -- 实际能购买的次数
        for i = 1, buy_count do
            local challenge_price = challenge_price_list[self.data.lover_already_challenge_cnt + i] or challenge_price_list[#challenge_price_list]
            if expect_sub_currency + challenge_price > actual_own_currency then
                break
            else
                expect_sub_currency = expect_sub_currency + challenge_price
                can_buy_count = can_buy_count + 1
            end
        end
        if can_buy_count <= 0 then return end
        self.role:sub_currency(CSConst.Virtual.Diamond, expect_sub_currency, g_reason.bar_buy_lover_challenge_num_consume)
        self.data.lover_already_challenge_cnt = self.data.lover_already_challenge_cnt + can_buy_count
        self.data.lover_remaining_challenge_cnt = self.data.lover_remaining_challenge_cnt + can_buy_count
        self.role:send_client("s_update_bar_count_data", {
            lover_already_challenge_cnt = self.data.lover_already_challenge_cnt,
            lover_remaining_challenge_cnt = self.data.lover_remaining_challenge_cnt,
        })
    end
    return true
end

return bar
