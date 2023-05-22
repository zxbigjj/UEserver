local date = require("sys_utils.date")
local excel_data = require("excel_data")
local recharge_activity_utils = require("recharge_activity_utils")

local recharge_draw = DECLARE_MODULE("meta_table.recharge_draw")

local BigAwardNum = 2
local TenDraw = 10
local SelfMaxAwardCount = 15

local AwardType = {
    Normal = 0,
    BigOne = 1,
    BigTwo = 2,
}

function recharge_draw.new(role)
    local self = {
        role = role,
        db = role.db,
        timer = nil, -- 免费次数定时器
    }
    return setmetatable(self, recharge_draw)
end

-- 加载
function recharge_draw:load()
    -- 获取可用的 activity_id（最多就一个）
    local activity_id = recharge_activity_utils.check_available_activity(CSConst.RechargeActivity.RechargeDraw)[1]
    if not activity_id then
        self.db.recharge_draw = {}
    else
        local db_activity_id = self.db.recharge_draw.activity_id
        if db_activity_id ~= activity_id then
            self.db.recharge_draw = {}
            self:init_activity(activity_id, true)
        end
        if recharge_activity_utils.is_ongoing_activity(activity_id) then
            self:start_free_draw_timer() -- 免费次数定时器
        end
    end
end

-- 上线
function recharge_draw:online()
    if self.db.recharge_draw.activity_id then
        self.role:send_client("s_update_recharge_draw_info", self:get_recharge_draw_info(true))
    end
end

-- 初始化活动数据
function recharge_draw:init_activity(activity_id, is_load_init)
    self.db.recharge_draw.activity_id = activity_id
    self:random_award(activity_id)
    self:init_big_award(activity_id)
    if is_load_init then return end
    self:start_free_draw_timer(true)
    self.role:send_client("s_update_recharge_draw_info", self:get_recharge_draw_info(true))
end

-- 活动结束回调(保留数据但不能抽奖)
function recharge_draw:stop_activity(activity_id)
    self.role:cancel_timer(self.timer)
end

-- 清理无效活动数据
function recharge_draw:clear_activity(activity_id)
    self.db.recharge_draw = {}
end

-- 获取充值抽奖信息
function recharge_draw:get_recharge_draw_info(show_shop)
    local msg = {}
    local draw_info = self.db.recharge_draw
    local award_list = table.deep_copy(draw_info.normal_award_list)
    table.insert(award_list, draw_info.big_award_list[AwardType.BigOne].award_id)
    table.insert(award_list, draw_info.big_award_list[AwardType.BigTwo].award_id)
    msg.activity_id = draw_info.activity_id
    msg.award_list = award_list
    msg.recharge_count = draw_info.recharge_count
    msg.draw_count = draw_info.free_num + draw_info.addition_num
    msg.self_award_list = draw_info.self_award_list
    if show_shop then msg.shop_dict = draw_info.shop_dict end
    return msg
end

-- 随机普通奖品
function recharge_draw:random_award(activity_id)
    local award_list = {}
    local id_list = {
        [AwardType.Normal] = {},
        [AwardType.BigOne] = {},
        [AwardType.BigTwo] = {},
    }
    for id, data in ipairs(excel_data.RechargeDrawData) do
        if data.activity_id == activity_id then
            table.insert(id_list[data.award_type], id)
        end
    end
    local normal_award_num = excel_data.ParamData.normal_reward_count.f_value
    for i = 1, normal_award_num do
        local random_id = math.random(1, #id_list[AwardType.Normal])
        table.insert(award_list, id_list[AwardType.Normal][random_id])
        table.remove(id_list[AwardType.Normal], random_id)
    end
    local draw_info = self.db.recharge_draw
    if not draw_info.big_award_list[AwardType.BigOne] then draw_info.big_award_list[AwardType.BigOne] = {} end
    if not draw_info.big_award_list[AwardType.BigTwo] then draw_info.big_award_list[AwardType.BigTwo] = {} end
    draw_info.big_award_list[AwardType.BigOne].award_id = id_list[AwardType.BigOne][math.random(1, #id_list[AwardType.BigOne])]
    draw_info.big_award_list[AwardType.BigTwo].award_id = id_list[AwardType.BigTwo][math.random(1, #id_list[AwardType.BigTwo])]
    draw_info.normal_award_list = award_list
end

-- 初始化大奖位奖品
function recharge_draw:init_big_award(activity_id)
    local award_data = excel_data.RechargeDrawData
    local big_award_list = self.db.recharge_draw.big_award_list
    for id, data in pairs(award_data) do
        if data.activity_id == activity_id and data.award_type ~= AwardType.Normal then
            local new_reach_list = self:get_award_reach_list(id)
            if not big_award_list[data.award_type] then big_award_list[data.award_type] = {} end
            if not big_award_list[data.award_type].draw_num then
                local draw_num = math.random(1, data.award_pre_turn) - 1
                big_award_list[data.award_type] = { award_id=id, draw_num=draw_num, reach_list=new_reach_list }
            else
                big_award_list[data.award_type].award_id = id
                big_award_list[data.award_type].reach_list = new_reach_list
            end
        end
    end
end

-- 设置新的大奖中奖轮
function recharge_draw:get_award_reach_list(award_id)
    local award_data = excel_data.RechargeDrawData
    local new_reach_list = {}
    for i = 1, award_data[award_id].award_turn do
        local new_num = math.random(1, award_data[award_id].award_turn) + award_data[award_id].award_pre_turn
        if not table.contains(new_reach_list, new_num) then
            table.insert(new_reach_list, new_num)
        end
        if #new_reach_list >= award_data[award_id].award_num then break end
    end
    return new_reach_list
end

-- 免费次数计时器
function recharge_draw:start_free_draw_timer(is_init_activity)
    local dbdata = self.db.recharge_draw
    local duration_sec = excel_data.ParamData.free_draw_refresh.f_value
    if is_init_activity then
        self.timer = self.role:timer_loop(duration_sec, function() self:add_free_draw_count() end, 0)
    else
        local now_ts = date.time_second()
        local last_refresh_ts = dbdata.last_refresh
        if not last_refresh_ts then
            local activity_obj = recharge_activity_utils.started_activity_dict[dbdata.activity_id]
            last_refresh_ts = activity_obj.start_time
            dbdata.last_refresh = last_refresh_ts
            dbdata.free_num = dbdata.free_num + 1
        end

        --陈永帅：处理转盘最大数量20230519
        local max_free_num = excel_data.ParamData.max_free_draw.f_value
        local add_count = (now_ts - last_refresh_ts) // duration_sec
        if add_count >= max_free_num then
            add_count = max_free_num
        end

        dbdata.free_num = dbdata.free_num + add_count
        local delay_sec = (last_refresh_ts + duration_sec * (add_count + 1)) - now_ts
        self.timer = self.role:timer_loop(duration_sec, function() self:add_free_draw_count() end, delay_sec)
    end
end

-- 给与免费抽奖次数
function recharge_draw:add_free_draw_count()
    print("-- add free draw count uuid: " .. self.role.uuid)
    local max_free_num = excel_data.ParamData.max_free_draw.f_value
    local draw_info = self.db.recharge_draw
    if  draw_info.free_num >= max_free_num then
        draw_info.free_num = max_free_num
    else
        draw_info.free_num = draw_info.free_num + 1
    end
    draw_info.last_refresh = date.time_second()
    print("-- count is: " .. draw_info.free_num + draw_info.addition_num)
    self.role:send_client("s_update_recharge_draw_info", {draw_count = draw_info.free_num + draw_info.addition_num})
end

-- 抽奖
function recharge_draw:do_draw(activity_id, is_ten_draw)
    if not recharge_activity_utils.is_ongoing_activity(activity_id) then return end
    local draw_info = self.db.recharge_draw
    if not activity_id or activity_id ~= draw_info.activity_id then return end
    local award_list = {}
    local real_draw_time = draw_info.free_num + draw_info.addition_num
    if real_draw_time < 1 then return end
    if not is_ten_draw then
        -- 单抽
        real_draw_time = 1
        if draw_info.free_num > 0 then
            table.extend(award_list, self:free_draw(activity_id, 1))
        else
            table.extend(award_list, self:addition_draw(activity_id, 1))
        end
    else
        -- 十连抽
        if real_draw_time >= TenDraw then real_draw_time = TenDraw end
        if draw_info.free_num >= real_draw_time then
            table.extend(award_list, self:free_draw(activity_id, real_draw_time))
        else
            local addition_draw_times = real_draw_time - draw_info.free_num
            table.extend(award_list, self:free_draw(activity_id, draw_info.free_num))
            table.extend(award_list, self:addition_draw(activity_id, addition_draw_times))
        end
    end
    self:random_award(activity_id)
    self:insert_player_award(award_list)
    local award_dict = {}
    local award_data = excel_data.RechargeDrawData
    for _, id in ipairs(award_list) do
        award_dict[award_data[id].item_id] = award_data[id].item_count
    end
    local ratio = excel_data.ParamData["draw_to_integral_ratio"].f_value
    award_dict[CSConst.Virtual.RechargeDrawIntegral] = math.floor(real_draw_time * ratio)
    self.role:add_item_dict(award_dict, g_reason.recharge_draw_reward)
    self.role:send_client("s_update_recharge_draw_info", self:get_recharge_draw_info())
    return {errcode = g_tips.ok, award_list = award_list}
end

-- 免费抽奖次数抽奖
function recharge_draw:free_draw(activity_id, draw_times)
    if draw_times <= 0 then return {} end
    local award_data = excel_data.RechargeDrawData
    local draw_info = self.db.recharge_draw
    local award_list = {}

    local weight_table = {}
    local total_weight = 0
    for _, id in ipairs(draw_info.normal_award_list) do
        total_weight = total_weight + award_data[id].weight
        weight_table[id] = award_data[id].weight
    end

    for i = 1, draw_times do
        local picked = false
        -- 先检查是否抽大奖
        for award_type, data in ipairs(draw_info.big_award_list) do
            data.draw_num = data.draw_num + 1
            for k, reach_num in ipairs(data.reach_list) do
                if data.draw_num >= reach_num then
                    picked = true
                    table.insert(award_list, data.award_id)
                    table.remove(data.reach_list, k)
                    if #data.reach_list <= 0 then
                        data.draw_num = 0
                        data.reach_list = self:get_award_reach_list(data.award_id)
                    end
                    break
                end
            end
            if picked then break end
        end
        -- 再抽取普通奖
        if not picked then
            table.insert(award_list, math.roll(weight_table, total_weight))
        end
    end
    draw_info.free_num = draw_info.free_num - draw_times
    return award_list
end

-- 充值抽奖次数抽奖
function recharge_draw:addition_draw(activity_id, draw_times)
    if draw_times <= 0 then return {} end
    local award_data = excel_data.RechargeDrawData
    local draw_info = self.db.recharge_draw
    local award_list = {}

    local weight_table = {}
    for k, v in ipairs(draw_info.normal_award_list) do
        if award_data[v].activity_id == activity_id then
            weight_table[v] = award_data[v].weight
        end
    end
    local big_one_id = draw_info.big_award_list[AwardType.BigOne].award_id
    local big_two_id = draw_info.big_award_list[AwardType.BigTwo].award_id
    weight_table[big_one_id] = award_data[big_one_id].weight
    weight_table[big_two_id] = award_data[big_one_id].weight

    draw_info.addition_num = draw_info.addition_num - draw_times
    for i = 1, draw_times do
        table.insert(award_list, math.roll(weight_table))
    end
    return award_list
end

-- 向utils和自身中奖记录中，插入中奖信息
function recharge_draw:insert_player_award(award_list)
    local award_data = excel_data.RechargeDrawData
    local draw_info = self.db.recharge_draw
    local now_time = date.time_second()
    for _, id in ipairs(award_list) do
        if award_data[id].is_show_award == true then
            local award_info = {}
            award_info.user_name = self.role:get_name()
            award_info.award_id = id
            award_info.time = now_time
            recharge_activity_utils.insert_player_award(draw_info.activity_id, award_info)
        end
        table.insert(draw_info.self_award_list, 1, {award_id=id, time=now_time})
        if #draw_info.self_award_list > SelfMaxAwardCount then
            table.remove(draw_info.self_award_list)
        end
    end
end

-- 充值增加额外抽奖次数
function recharge_draw:get_addition_draw_num(recharge_count)
    local draw_info = self.db.recharge_draw
    if not recharge_activity_utils.can_receive_activity(draw_info.activity_id) then return end
    local draw_info = self.db.recharge_draw
    if not draw_info.activity_id then return end
    local activity_data = excel_data.RechargeActivityData[draw_info.activity_id]
    local max_loop = recharge_count
    for i = 1, max_loop do
        local diff_index = #activity_data.draw_diff_count
        for k = #activity_data.draw_diff_count, 1, -1 do
            if draw_info.recharge_count >= activity_data.recharge_count_list[k] then
                diff_index = k
                draw_info.recharge_count = draw_info.recharge_count + activity_data.draw_diff_count[k]
                recharge_count = recharge_count - activity_data.draw_diff_count[k]
                draw_info.addition_num = draw_info.addition_num + 1
                break
            end
        end
        if recharge_count < 0 then
            draw_info.addition_num = draw_info.addition_num - 1
            draw_info.recharge_count = draw_info.recharge_count + recharge_count
            break
        end
    end
    self.role:send_client("s_update_recharge_draw_info", {
        draw_count = draw_info.free_num + draw_info.addition_num,
        recharge_count = draw_info.recharge_count,
    })
end

-- 积分购买商城物品
function recharge_draw:buy_integral_shop(shop_id, shop_num)
    if not shop_id or not shop_num then return end
    local draw_info = self.db.recharge_draw
    if not recharge_activity_utils.can_receive_activity(draw_info.activity_id) then return end
    local item_data = excel_data.DrawShopData[shop_id]
    if item_data.activity_id ~= draw_info.activity_id then return end
    local old_num = draw_info.shop_dict[shop_id] or 0
    local new_num = old_num + shop_num
    if item_data.forever_num and new_num > item_data.forever_num then return end
    local consume_dict = {}
    for k, v in ipairs(item_data.cost_item_list) do
        consume_dict[v] = item_data.cost_item_value[k] * shop_num
    end
    draw_info.shop_dict[shop_id] = new_num
    if self.role:consume_item_dict(consume_dict, g_reason.buy_recharge_draw_shop) then
        self.role:add_item(item_data.item_id, item_data.item_count * shop_num, g_reason.buy_recharge_draw_shop)
    else
        draw_info.shop_dict[shop_id] = old_num
        return
    end
    self.role:send_client("s_update_recharge_draw_info", {shop_dict = draw_info.shop_dict})

    local consume_list = {}
    for item_id, count in pairs(consume_dict) do
        table.insert(consume_list, {item_id = item_id, count = count})
    end
    self.role:gaea_log("ShopConsume", {
        itemId = item_data.item_id,
        itemCount = item_data.item_count * shop_num,
        consume = consume_list,
    })
    return true
end

return recharge_draw