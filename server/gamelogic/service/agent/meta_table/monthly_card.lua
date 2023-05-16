local date = require("sys_utils.date")
local excel_data = require("excel_data")

local monthly_card = DECLARE_MODULE("meta_table.monthly_card")

function monthly_card.new(role)
    local self = {
        role = role,
        data = role.db.monthly_card,
    }
    return setmetatable(self, monthly_card)
end

-- 每日刷新
function monthly_card:on_daily(last_daily_ts)
    local now_online_ts0 = date.get_begin0()
    local last_online_ts0 = date.get_begin0(last_daily_ts)
    local total_offline_days = (now_online_ts0 - last_online_ts0) // CSConst.Time.Day

    for card_id, card_info in pairs(self.data) do
        -- 检查是否过期
        local old_remaining_days = card_info.remaining_days
        if card_info.remaining_days then
            card_info.remaining_days = card_info.remaining_days - total_offline_days
            if card_info.remaining_days <= 0 then
                self.data[card_id] = nil
                self.role:send_client("s_notify_monthly_card_expired", {card_id = card_id})
            end
        end

        -- 计算补发次数
        local replacement_count
        if card_info.remaining_days and card_info.remaining_days <= 0 then
            replacement_count = card_info.is_received and (old_remaining_days - 1) or old_remaining_days
        else
            replacement_count = card_info.is_received and (total_offline_days - 1) or total_offline_days
        end

        -- 补发月卡奖励
        local card_exldata = excel_data.MonthlyCardData[card_id]
        local mail_id = CSConst.MailId.MonthlyCardReward
        local item_list = {{item_id = card_exldata.item_id, count = card_exldata.daily_item_num}}
        for i = 1, replacement_count do
            self.role:add_mail({mail_id = mail_id, item_list = item_list})
        end

        -- 重置领取状态
        card_info.is_received = false
    end

    if #self.data ~= 0 then
        self.role:send_client("s_update_monthly_card_data", {card_dict = self.data})
    end
end

-- 玩家上线
function monthly_card:on_online()
    self.role:send_client("s_update_monthly_card_data", {card_dict = self.data})
end

-- 购买月卡
function monthly_card:buy_card(card_id)
    card_id = tonumber(card_id)
    if not card_id or self.data[card_id] then        
        g_log:info("not card_id or self.data[card_id]")
        return 
    end
    local exldata = excel_data.MonthlyCardData[card_id]    
    if not exldata then
        g_log:info("not exldata")  
        return 
    end
    self.data[card_id] = {
        is_received = false,
        remaining_days = exldata.validity_period_day,
    }
    g_log:info("card_id:"..card_id..",add_vip_exp:"..exldata.add_vip_exp..",exldata.item_id:"..exldata.item_id..",exldata.add_item_num:"..exldata.add_item_num)
    self.role:add_vip_exp(exldata.add_vip_exp, g_reason.monthly_card_buy_reward)
    self.role:add_item(exldata.item_id, exldata.add_item_num, g_reason.monthly_card_buy_reward)
    self.role:send_client("s_update_monthly_card_data", {card_dict = {[card_id] = self.data[card_id]}})
    return true
end

-- 领取奖励
function monthly_card:receiving_reward(card_id)
    if not card_id or not self.data[card_id] or self.data[card_id].is_received then return end
    local exldata = excel_data.MonthlyCardData[card_id]
    if not exldata then return end
    self.data[card_id].is_received = true
    self.role:add_item(exldata.item_id, exldata.daily_item_num, g_reason.monthly_card_daily_reward)
    if self.data[card_id].remaining_days then
        if self.data[card_id].remaining_days <= 1 then
            -- 领完最后一次奖就算过期
            self.data[card_id] = nil
            self.role:send_client("s_notify_monthly_card_expired", {card_id = card_id})
        end
    end
    self.role:send_client("s_update_monthly_card_data", {card_dict = {[card_id] = {is_received = true}}})
    return true
end

return monthly_card