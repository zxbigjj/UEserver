local role_salon = DECLARE_MODULE("meta_table.salon")
local excel_data = require("excel_data")
local date = require("sys_utils.date")
local cluster_utils = require("msg_utils.cluster_utils")

function role_salon.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db
    }
    return setmetatable(self, role_salon)
end

function role_salon:online_salon()
    local salon_db = self.db.salon
    self.role:send_client("s_update_salon_info",{
        salon_dict = salon_db.salon_dict,
        old_salon_dict = salon_db.old_salon_dict,
        attr_point_count = salon_db.attr_point_count,
        attr_point_buy_num = salon_db.attr_point_buy_num,
    })
    self.role:send_client("s_update_salon_shop", {
        salon_shop = salon_db.shop_dict,
        refresh_ts = self.db.last_hourly_ts
    })
end

function role_salon:daily_salon()
    local salon_db = self.db.salon
    local len = #salon_db.salon_dict
    if len > 0 then
        for i = 1, len do
            local data = table.deep_copy(salon_db.salon_dict[i])
            salon_db.salon_dict[i] = nil
            salon_db.old_salon_dict[i] = data
            if data.integral then
                -- 奖励未领取不清空
                salon_db.salon_dict[i] = {
                    integral = data.integral,
                    lover_id = data.lover_id,
                    rank = data.rank
                }
            end
        end
    end
    self:lover_compute()
    salon_db.attr_point_count = salon_db.attr_point_count_limit
    salon_db.attr_point_buy_num = 0
    self.role:send_client("s_update_salon_info",{
        salon_dict = salon_db.salon_dict,
        old_salon_dict = salon_db.old_salon_dict,
        attr_point_count = salon_db.attr_point_count,
        attr_point_buy_num = salon_db.attr_point_buy_num,
    })
end

function role_salon:hourly_salon(pre_hourly_ts)
    local now = date.time_second()
    if now - pre_hourly_ts >= CSConst.Time.Day then
        return self:refresh_salon_shop(true)
    end
    local now_date = os.date("*t", now)
    local pre_date = os.date("*t", pre_hourly_ts)
    local shop_data = excel_data.ShopData["SalonShop"]
    if pre_date.day < now_date.day then
        if pre_date.hour < shop_data.refresh_time[#shop_data.refresh_time]
            or now_date.hour >= shop_data.refresh_time[1] then
            return self:refresh_salon_shop(true)
        end
    else
        for i, refresh_hour in ipairs(shop_data.refresh_time) do
            if pre_date.hour < refresh_hour and now_date.hour >= refresh_hour then
                return self:refresh_salon_shop(true)
            end
        end
    end
end

-- 情人相关计算
function role_salon:lover_compute()
    local unlock_num = 0
    local GradeData = excel_data.GradeData
    local attr_point_count = 0
    local salon_db = self.db.salon
    local lover_dict = self.db.lover_dict
    for lover_id, lover_info in pairs(lover_dict) do
        if lover_info.grade then
            if lover_info.grade > 1 then
                local grade_config = GradeData[lover_info.grade]
                attr_point_count = attr_point_count + grade_config.salon_attr_point
                unlock_num = unlock_num + 1
                if excel_data.SalonAreaData[unlock_num] then
                    salon_db.salon_dict[unlock_num] = salon_db.salon_dict[unlock_num] or {}
                end
            end
        end
    end
    -- 沙龙积分点数量上限改变后，计算与原始数量上限的差值，累加在可用积分点上
    if not salon_db.attr_point_count_limit then
        salon_db.attr_point_count_limit = attr_point_count
    elseif salon_db.attr_point_count_limit < attr_point_count then
        salon_db.attr_point_count = salon_db.attr_point_count + (attr_point_count - salon_db.attr_point_count_limit)
        salon_db.attr_point_count_limit = attr_point_count
    end
    self.role:send_client("s_update_salon_info",{
        salon_dict = salon_db.salon_dict,
        attr_point_count = salon_db.attr_point_count,
    })
end

-- 派遣情人
function role_salon:dispatch_lover(salon_id, lover_id, attr_point_dict)
    local salon_config = excel_data.SalonAreaData[salon_id]
    if not salon_config then return end
    local delay_seconds = date.get_day_time(nil, salon_config.start_time) - date.time_second()
    if delay_seconds < 0 then return end
    local salon = self.db.salon
    if not salon.salon_dict[salon_id] then return end
    if salon.salon_dict[salon_id].lover_id or salon.salon_dict[salon_id].integral then return end
    local lover_info = self.db.lover_dict[lover_id]
    if not lover_info or lover_info.grade <= 1 then return end

    local attr_point = 0
    if attr_point_dict then
        attr_point_dict = g_const.StLoverAttr(attr_point_dict)
        for name, value in pairs(attr_point_dict) do
            attr_point = attr_point + value
        end
        if salon.attr_point_count - attr_point < 0 then return end
    end

    local role_info = self.role:get_role_info()
    role_info.attr_point_dict = attr_point_dict or {}
    role_info.lover = {
        lover_id = lover_info.lover_id,
        level = lover_info.level,
        grade = lover_info.grade,
        attr_dict = lover_info.attr_dict,
    }
    local results = cluster_utils.call_cross_salon("lc_add_role", {salon_id = salon_id, role_info = role_info})
    if not results then return end

    if attr_point > 0 then
        salon.attr_point_count = salon.attr_point_count - attr_point
        salon.salon_dict[salon_id].attr_point_dict = table.deep_copy(attr_point_dict)
    end
    salon.salon_dict[salon_id].lover_id = lover_id
    self.role:send_client("s_update_salon_info",{
        salon_dict = {[salon_id] = salon.salon_dict[salon_id]},
        attr_point_count = salon.attr_point_count,
    })
    return true
end

-- 购买属性加成点
function role_salon:buy_attr_point()
    local salon_db = self.db.salon
    local by_num_limit = excel_data.ParamData["salon_buy_attr_point_num_limit"].f_value
    if salon_db.attr_point_buy_num >= by_num_limit then return end
    local sub_config = excel_data.ParamData["salon_buy_attr_point_item"]
    if not self.role:consume_item(sub_config.item_id, sub_config.count) then return end
    local count = excel_data.ParamData["salon_buy_attr_point_count"].f_value
    salon_db.attr_point_count = salon_db.attr_point_count + count
    salon_db.attr_point_buy_num = salon_db.attr_point_buy_num + 1
    self.role:send_client("s_update_salon_info",{
        attr_point_count = salon_db.attr_point_count,
        attr_point_buy_num = salon_db.attr_point_buy_num,
    })
    return true
end

-- 接收pvp结果
function role_salon:receive_pvp_results(pvp_info)
    local salon_info = self.db.salon.salon_dict[pvp_info.salon_id]
    if not salon_info then return end
    salon_info.rank = pvp_info.rank
    salon_info.integral = CSConst.Salon.PvPIntegral[salon_info.rank]
    salon_info.pvp_id = pvp_info.pvp_id
    self.role:send_client("s_update_salon_info",{salon_dict = {[pvp_info.salon_id] = salon_info}})
end

--领取积分
function role_salon:receive_integral(salon_id)
    local salon = self.db.salon
    local salon_info = salon.salon_dict[salon_id]
    if not salon_info or not salon_info.integral then return end
    local item_id = excel_data.ParamData["salon_integral"].item_id
    salon.history_integral = salon.history_integral + salon_info.integral
    self.role:add_item(item_id, salon_info.integral)
    self.role:update_cross_role_rank("salon_rank", salon.history_integral)
    salon_info.integral = nil
    if not salon_info.pvp_id then
        salon_info.lover_id = nil
        salon_info.rank = nil
    end
    self.role:send_client("s_update_salon_info",{
        salon_dict = {[salon_id] = salon_info},
    })
    return true
end

-- 获取pvp记录
function role_salon:get_pvp_record(day, salon_id, pvp_id)
    if day ~= CSConst.Salon.Today and day ~= CSConst.Salon.Yesterday then return end
    if salon_id < 1 or salon_id > #excel_data.SalonAreaData then return end
    local pvp_info = cluster_utils.call_cross_salon("lc_get_salon_pvp_record",{
        day = day, salon_id = salon_id, pvp_id = pvp_id})
    if not pvp_info then return end
    return {errcode = g_tips.ok, pvp_info = pvp_info}
end

-- 获取沙龙积分排行榜
function role_salon:get_rank()
    local rank_info = cluster_utils.call_cross_rank("lc_get_rank_list", "salon_rank", self.uuid)
    rank_info.self_rank_score = self.db.salon.history_integral
    return rank_info
end

-- 购买物品（只能买一次）
function role_salon:buy_salon_shop_item(shop_id)
    if not shop_id then return end
    local data = excel_data.SalonShopData[shop_id]
    if not data then return end
    local shop_dict = self.db.salon.shop_dict
    if not shop_dict[shop_id] or shop_dict[shop_id] >= 1 then return end

    if not self.role:consume_item_list(data.cost_item_list, g_reason.salon_shop) then return end
    shop_dict[shop_id] = shop_dict[shop_id] + 1
    self.role:add_item(data.item_id, data.item_count, g_reason.salon_shop)
    self.role:send_client("s_update_salon_shop", {salon_shop = shop_dict, refresh_ts = self.db.last_hourly_ts})
    self.role:gaea_log("ShopConsume", {
        itemId = data.item_id,
        itemCount = data.item_count,
        consume = data.cost_item_list
    })
    return true
end

-- 刷新商店（重置购买次数）
function role_salon:refresh_salon_shop(is_auto_refresh)
    local shop_data = excel_data.ShopData["SalonShop"]
    if not is_auto_refresh then
        if not self.role:consume_item(shop_data.refresh_item, shop_data.refresh_price, g_reason.refresh_salon_shop) then return end
    end
    local salon_db = self.db.salon
    salon_db.shop_dict = {}
    local weight_table = {}
    for key, data in pairs(excel_data.SalonShopData) do
        weight_table[key] = data.weight
    end
    for i = 1, shop_data.refresh_item_num do
        local shop_id = math.roll(weight_table)
        salon_db.shop_dict[shop_id] = 0
        weight_table[shop_id] = nil
    end
    self.role:send_client("s_update_salon_shop", {salon_shop = salon_db.shop_dict, refresh_ts = self.db.last_hourly_ts})
    return true
end

return role_salon