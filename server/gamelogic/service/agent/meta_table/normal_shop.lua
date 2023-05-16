local normal_shop = DECLARE_MODULE("meta_table.normal_shop")
local date = require("sys_utils.date")
local excel_data = require("excel_data")

function normal_shop.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
    }
    return setmetatable(self, normal_shop)
end

function normal_shop:online()
    self.role:send_client("s_update_normal_shop_info", {shop_info = self.db.normal_shop})
end

function normal_shop:daily_reset()
    local shop_info = self.db.normal_shop
    local shop_data = excel_data.NormalShopData
    for id in pairs(shop_info) do
        if shop_data[id].gift_limit_num == nil then
            shop_info[id] = nil
        end
    end
    self.role:send_client("s_update_normal_shop_info", {shop_info = self.db.normal_shop})
end

-- 购买商城物品
function normal_shop:buy_normal_shop_item(shop_id, shop_num)
    if not shop_id or not shop_num or shop_num <= 0 then return end
    local shop_info = self.db.normal_shop
    local shop_data = excel_data.NormalShopData[shop_id]
    if not shop_data then return end
    if not shop_info[shop_id] then shop_info[shop_id] = 0 end
    local old_num = shop_info[shop_id]
    if not shop_data.gift_limit_num then
        -- 普通商品
        local level = self.role:get_vip() + 1
        local new_num = shop_info[shop_id] + shop_num
        if shop_data.vip_buy_num then
            local max_buy_num = shop_data.vip_buy_num[level]
            if max_buy_num <= 0 then return end
            if new_num > max_buy_num then return end
        end
        local discount_index = 1
        local cal = 0
        local price_dict = {}
        for k, cost_id in ipairs(shop_data.cost_item_list) do
            price_dict[cost_id] = 0
        end
        for i = 1, new_num do
            cal = cal + 1
            local discount = nil
            if shop_data.discount_num[discount_index] and cal > shop_data.discount_num[discount_index] then
                cal = 1
                discount_index = discount_index + 1
                discount = shop_data.discount[discount_index] or 1
            else
                discount = shop_data.discount[discount_index] or 1
            end
            if i > old_num then
                for k, cost_id in ipairs(shop_data.cost_item_list) do
                    local price = price_dict[cost_id]
                    price = price + discount * shop_data.cost_item_value[k]
                    price_dict[cost_id] = math.ceil(price)
                end
            end
        end

        local reason = g_reason.normal_shop_buy_item
        shop_info[shop_id] = new_num
        if self.role:consume_item_dict(price_dict, reason) then
            self.role:add_item(shop_data.item_id, shop_data.item_count * shop_num, reason)
        else
            shop_info[shop_id] = old_num
            return false
        end

        local consume_list = {}
        for item_id, count in pairs(price_dict) do
            table.insert(consume_list, {item_id = item_id, count = count})
        end
        self.role:gaea_log("ShopConsume", {
            itemId = shop_data.item_id,
            itemCount = shop_data.item_count * shop_num,
            consume = consume_list,
        })
    else
        -- VIP礼包商品
        local vip_level = self.role:get_vip()
        local new_num = shop_info[shop_id] + shop_num
        if vip_level < shop_data.vip_require_level then return end
        if shop_info[shop_id] >= shop_data.gift_limit_num then return end
        local new_num = shop_info[shop_id] + shop_num
        if new_num > shop_data.gift_limit_num then return end
        local price_dict = {}
        for k, cost_id in ipairs(shop_data.cost_item_list) do
            price_dict[cost_id] = shop_data.cost_item_value[k] * shop_num
        end
        local reason = g_reason.normal_shop_buy_vip_gift
        shop_info[shop_id] = new_num
        if self.role:consume_item_dict(price_dict, reason) then
            self.role:add_item(shop_data.item_id, shop_data.item_count * shop_num, reason)
        else
            shop_info[shop_id] = old_num
            return false
        end

        local consume_list = {}
        for item_id, count in pairs(price_dict) do
            table.insert(consume_list, {item_id = item_id, count = count})
        end
        self.role:gaea_log("ShopConsume", {
            itemId = shop_data.item_id,
            itemCount = shop_data.item_count * shop_num,
            consume = consume_list,
        })
    end
    self.role:update_daily_active(CSConst.DailyActiveTaskType.BuyEnergyNum, shop_num, shop_data.item_id)
    self.role:update_daily_active(CSConst.DailyActiveTaskType.BuyVitalityNum, shop_num, shop_data.item_id)
    self.role:send_client("s_update_normal_shop_info", {shop_info = self.db.normal_shop})
    return true
end

return normal_shop