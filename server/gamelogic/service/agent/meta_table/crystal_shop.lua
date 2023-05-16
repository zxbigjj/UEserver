local crystal_shop = DECLARE_MODULE("meta_table.crystal_shop")
local date = require("sys_utils.date")
local excel_data = require("excel_data")

local Daily_Sell_Count = 6

function crystal_shop.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
        refresh_timer = nil,
    }
    return setmetatable(self, crystal_shop)
end

function crystal_shop:load()
    local shop_data = self.db.crystal_shop
    local now = date.time_second()
    local shop_info = excel_data.ShopData["CrystalShop"]
    for i = #shop_info.refresh_time, 1, -1 do
        local last_refresh_ts =  date.get_day_time(now, shop_info.refresh_time[i])
        if last_refresh_ts < now and shop_data.refresh_shop_ts < last_refresh_ts then
            self:reset_daily_sell_shop()
            break
        end
    end
    self:set_refresh_timer()
end

function crystal_shop:online()
    self:send_shop_info()
end

function crystal_shop:send_shop_info()
    local msg = {}
    local crystal_shop = self.db.crystal_shop
    msg.daily_item = crystal_shop.daily_item
    msg.week_item = crystal_shop.week_item
    self.role:send_client("s_update_crystal_shop_info", msg)
end

function crystal_shop:weekly_reset()
    local shop_data = excel_data.CrystalShopData
    self.db.crystal_shop.week_item = {}
    local week_item = self.db.crystal_shop.week_item
    for k, v in ipairs(excel_data.CrystalShopData) do
        if v.week_limit_num ~= nil then
            week_item[k] = 0
        end
    end
    self:send_shop_info()
end

-- 设置计时器
function crystal_shop:set_refresh_timer()
    local crystal_shop = self.db.crystal_shop
    local shop_data = excel_data.ShopData["CrystalShop"]
    local now = date.time_second()
    for i, refresh_hour in ipairs(shop_data.refresh_time) do
        local refresh_ts = date.get_day_time(now, refresh_hour)
        if now < refresh_ts then
            self.refresh_timer = self.role:timer_once(refresh_ts - now, function()
                self.refresh_timer = nil
                self:reset_daily_sell_shop()
            end)
            break
        end
    end
    if not self.refresh_timer then
        local refresh_ts = date.get_day_time(now, shop_data.refresh_time[1]) + CSConst.Time.Day
        self.refresh_timer = self.role:timer_once(refresh_ts - now, function()
            self.refresh_timer = nil
            self:reset_daily_sell_shop()
        end)
    end
end

-- 重置每日优惠商品
function crystal_shop:reset_daily_sell_shop()
    local shop_item = self:random_daily_sell()
    local crystal_shop = self.db.crystal_shop
    crystal_shop.daily_item = {}
    local daily_item = crystal_shop.daily_item
    for _, id in ipairs(shop_item) do
        daily_item[id] = 0
    end

    self:set_refresh_timer()
    local now = date.time_second()
    crystal_shop.refresh_shop_ts = now
    self:send_shop_info()
end
-- 随机每日特惠商品
function crystal_shop:random_daily_sell()
    local id_list = {}
    local real_id_list = {}
    for k, v in ipairs(excel_data.CrystalShopData) do
        if v.week_limit_num == nil and self:can_buy_item(v) then
            table.insert(id_list, k)
        end
    end
    if #id_list < Daily_Sell_Count then return end
    for i = 1, Daily_Sell_Count do
        local random_id = math.random(1,#id_list)
        real_id_list[i] = id_list[random_id]
        table.remove(id_list, random_id)
    end
    return real_id_list
end

function crystal_shop:can_buy_item(item_data)
    local level = self.role:get_level()
    local vip = self.role:get_vip()
    for k = #item_data.item_count, 1, -1 do
        if level >= item_data.require_level[k] or vip >= item_data.require_vip[k] then
            return item_data.item_count[k]
        end
    end
    return nil
end

-- 购买水晶商店物品
function crystal_shop:buy_crystal_shop_item(shop_id, shop_num)
    if not shop_id or not shop_num then return end
    local crystal_shop = self.db.crystal_shop
    local shop = nil
    if crystal_shop.daily_item[shop_id] then shop = crystal_shop.daily_item end
    if crystal_shop.week_item[shop_id] then shop = crystal_shop.week_item end
    if not shop then return end
    local sell_data = excel_data.CrystalShopData[shop_id]
    local limit_num = sell_data.week_limit_num or 1
    local new_num = shop[shop_id] + shop_num
    if new_num > limit_num then return end
    local consume_dict = {}
    local reason = g_reason.crystal_shop_buy_item
    for k, cost_id in ipairs(sell_data.cost_item_list) do
        consume_dict[cost_id] = sell_data.cost_item_value[k] * shop_num
    end
    local count = nil
    local level = self.role:get_level()
    local vip = self.role:get_vip()
    for i = #sell_data.item_count, 1, -1 do
        if level >= sell_data.require_level[i] or vip >= sell_data.require_vip[i] then
            count = sell_data.item_count[i]
            break
        end
    end
    if not count then return end
    shop[shop_id] = new_num
    if not self.role:consume_item_dict(consume_dict, reason) then
        shop[shop_id] = new_num - shop_num
        return
    end
    self.role:add_item(sell_data.item_id, count * shop_num, reason)
    self:send_shop_info()

    local consume_list = {}
    for item_id, count in pairs(consume_dict) do
        table.insert(consume_list, {item_id = item_id, count = count})
    end
    self.role:gaea_log("ShopConsume", {
        itemId = sell_data.item_id,
        itemCount = count * shop_num,
        consume = consume_list,
    })
    return true
end

return crystal_shop