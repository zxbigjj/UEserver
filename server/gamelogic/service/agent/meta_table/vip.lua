local role_vip = DECLARE_MODULE("meta_table.vip")
local date = require("sys_utils.date")
local excel_data = require("excel_data")

local PrivilegeType = {
    ExtraAddition = 1,
    NewFunc = 2,
}

function role_vip.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
    }
    return setmetatable(self, role_vip)
end

function role_vip:init()
    local sell_gift = self.db.vip.sell_gift
    for i = 1, excel_data.VipData.max_vip_level do
        sell_gift[i] = false
    end
    sell_gift[0] = true
end

function role_vip:online()
    self.role:send_client("s_update_vip_info", self:get_vip_info())
    self.role:send_client("s_update_vip_shop_info", self:get_vip_shop_info())
end

function role_vip:get_vip_info()
    local msg = {}
    local vip = self.db.vip
    msg.vip_level = vip.vip_level
    msg.vip_exp = vip.vip_exp
    msg.sell_gift = vip.sell_gift
    msg.daily_gift = vip.daily_gift
    return msg
end

function role_vip:get_vip_shop_info()
    local msg = {}
    local now_time = date.time_second()
    local wday = os.date("%w", now_time)
    if wday == 0 then wday = CSConst.DaysInWeek end
    local next_monday = CSConst.Time.Day * (CSConst.DaysInWeek - wday + 1) + now_time
    local diff_time = date.get_day_time(next_monday, 0)

    msg.shop_info = self.db.vip.vip_shop
    msg.diff_time = diff_time
    return msg
end

function role_vip:daily_reset()
    self.db.vip.daily_gift = true
    self.role:send_client("s_update_vip_info", self:get_vip_info())
end

function role_vip:weekly_reset()
    self.db.vip.vip_shop = {}
    self.role:send_client("s_update_vip_shop_info", self:get_vip_shop_info())
end

-- 更新vip等级经验
function role_vip:add_vip_exp(progress, reason)
    local vip = self.db.vip
    local old_level = vip.vip_level
    local exp_info = excel_data.VipData
    local old_exp = vip.vip_exp
    local new_exp = old_exp + progress
    for i = exp_info.max_vip_level, 0, -1 do
        if exp_info[i].total_exp <= new_exp then
            vip.vip_level = i
            break
        end
    end
    if new_exp < exp_info[1].total_exp then vip.vip_level = 0 end
    local new_level = vip.vip_level
    if old_level < new_level then
        self:vip_level_up(old_level, new_level)
    end
    vip.vip_exp = new_exp
    self.role:log("AddVIPExp", {add_exp=progress, old_exp=old_exp, new_exp=new_exp, reason=reason})
    self.role:send_client("s_update_vip_info", self:get_vip_info())
end

-- vip等级提升事件
function role_vip:vip_level_up(old_level, new_level)
    local vip_unlock_dict = excel_data.FuncUnlockData.vip_unlock_dict
    local id_list = {}
    for require_vip, lock_id_list in pairs(vip_unlock_dict) do
        if new_level >= require_vip then
            for _, lock_id in ipairs(lock_id_list) do
                table.insert(id_list, lock_id)
            end
        end
    end
    for i = old_level + 1, new_level do
        self.db.vip.sell_gift[i] = true
    end
    self.role:vip_level_trigger_check(id_list)
    self.role:vip_level_up_privilege_heroshop_num(old_level, new_level)
    self.role:vip_level_up_privilege_lovershop_num(old_level, new_level)
    self.role:vip_level_up_privilege_tower_num(old_level, new_level)
    self.role:vip_level_up_privilege_travel_num(old_level, new_level)
    self.role:vip_level_up_privilege_child_vitality_num(old_level, new_level)
    self.role:vip_level_up_privilege_stage(old_level, new_level)
    self.role:update_achievement(CSConst.AchievementType.Vip, new_level - old_level)
    self.role:update_rank_role_info({vip = new_level})
    self.role:update_dynasty_role_info({vip = new_level})
end

-- 获取vip特权次数
function role_vip:get_vip_privilege_num(privilege_id)
    if not privilege_id then return end
    local vip_level = self.db.vip.vip_level
    local level_info = excel_data.VipData[vip_level]
    local lock_info = excel_data.VIPPrivilegeData
    if lock_info[privilege_id].type ~= PrivilegeType.ExtraAddition then return end
    local lock_name = lock_info[privilege_id].vip_data_name
    return level_info[lock_name] or 0
end

-- 领取vip每日礼包
function role_vip:recive_daily_gift()
    local vip_level = self.db.vip.vip_level
    local vip_data = excel_data.VipData
    if vip_level < 0 or vip_level > vip_data.max_vip_level then return end
    if self.db.vip.daily_gift ~= true then return end
    local gift_id = vip_data[vip_level].free_gift
    if not gift_id then return end
    local reason = g_reason.vip_daily_gift
    self.db.vip.daily_gift = false
    self.role:add_item(gift_id, 1, reason)
    self.role:send_client("s_update_vip_info", self:get_vip_info())
    return true
end

-- 购买vip特惠礼包
function role_vip:buy_sell_gift(buy_id)
    local vip_level = self.db.vip.vip_level
    if vip_level < buy_id then return end
    local vip_data = excel_data.VipData
    if vip_level < 0 or vip_level > vip_data.max_vip_level then return end
    if self.db.vip.sell_gift[buy_id] ~= true then return end
    local gift_info = vip_data[buy_id]
    if not gift_info.gift then return end
    local reason = g_reason.vip_sell_gift
    if self.role:consume_item(gift_info.consume_item_id, gift_info.gift_price, reason) then
        self.db.vip.sell_gift[buy_id] = nil
        self.role:add_item(gift_info.gift, 1, reason)
    else
        return false
    end
    self.role:send_client("s_update_vip_info", self:get_vip_info())

    self.role:gaea_log("ShopConsume", {
        itemId = gift_info.gift,
        itemCount = 1,
        consume = {item_id = gift_info.consume_item_id, count = gift_info.gift_price},
    })
    return true
end

-- 领取vip礼包
function role_vip:get_vip_gift()
    local gift_dict = self.db.vip.gift_dict
    local item_dict = {} -- item_id => item_count
    local VipData = excel_data.VipData
    local RewardData = excel_data.RewardData
    for level = 1, self.db.vip.vip_level do
        if not gift_dict[level] then
            gift_dict[level] = true
            local reward_id = VipData[level].gift
            if reward_id then
                table.dict_attr_add(item_dict, RewardData[reward_id].item_dict)
            end
        end
    end
    if next(item_dict) then
        self.role:add_item_dict(item_dict, g_reason.vip_level_gift, true)
    end
    return true
end

-- 购买vip商城物品
function role_vip:buy_vip_shop_item(shop_id, shop_num)
    if not shop_id or not shop_num or shop_num <= 0 then return end
    local vip_info = self.db.vip
    local vip_level = vip_info.vip_level + 1
    local shop_info = excel_data.VIPShopData[shop_id]
    if not shop_info then return end
    if not vip_info.vip_shop[shop_id] then vip_info.vip_shop[shop_id] = 0 end
    local new_num = vip_info.vip_shop[shop_id] + shop_num
    if not shop_info.buy_num[vip_level] or new_num > shop_info.buy_num[vip_level] then return end
    vip_info.vip_shop[shop_id] = new_num
    local consume_dict = {}
    for k, cost_id in ipairs(shop_info.cost_item_list) do
        consume_dict[cost_id] = shop_info.cost_item_value[k] * shop_info.discount[vip_level] * shop_num
    end
    local reason = g_reason.vip_shop_buy_item
    if self.role:consume_item_dict(consume_dict, reason) then
        self.role:add_item(shop_info.item_id, shop_info.item_count * shop_num, reason)
    else
        vip_info.vip_shop[shop_id] = new_num - shop_num
        return false
    end
    self.role:send_client("s_update_vip_shop_info", self:get_vip_shop_info())

    local consume_list = {}
    for item_id, count in pairs(consume_dict) do
        table.insert(consume_list, {item_id = item_id, count = count})
    end
    self.role:gaea_log("ShopConsume", {
        itemId = shop_info.item_id,
        itemCount = shop_info.item_count * shop_num,
        consume = consume_list,
    })
    return true
end

return role_vip