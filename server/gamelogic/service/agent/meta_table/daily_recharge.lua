local date = require("sys_utils.date")
local excel_data = require("excel_data")

local daily_recharge = DECLARE_MODULE("meta_table.daily_recharge")

function daily_recharge.new(role)
    local self = {
        role = role,
        db   = role.db,
        data = role.db.daily_recharge,
    }
    return setmetatable(self, daily_recharge)
end

-- 每日刷新
function daily_recharge:daily(gm_today0)
    -- 获取当前正在进行的活动 id,data
    local today0 = gm_today0 or date.get_begin0()
    local cur_id, cur_data
    for id, data in pairs(excel_data.DailyRechargeData) do
        if data.start_ts <= today0 and today0 < data.stop_ts then
            cur_id, cur_data = id, data
            break
        end
    end

    -- 如果没有进行中的活动，则清除数据
    if not cur_id then
        self.db.daily_recharge = nil
        self.data = self.db.daily_recharge
        self:send()
        return
    end

    -- 判断今天是活动进行的第几天, 1..7
    local cur_day = math.floor((today0 - cur_data.start_ts) / CSConst.Time.Day + 1)
    if not self.data or self.data.id ~= cur_id then
        -- 初始化
        self.db.daily_recharge = {
            id = cur_id,
            cur_day = cur_day,
            total_recharge_days = 0,
            reward_dict = {[cur_data.luxury_reward] = CSConst.RewardState.unpick},
        }
        self.data = self.db.daily_recharge
        for _, reward_id in ipairs(cur_data.reward_list) do
            self.data.reward_dict[reward_id] = CSConst.RewardState.unpick
        end
    else
        -- 更新
        self.data.cur_day = cur_day
    end
    self:send(self.data)
end

-- 上线通知
function daily_recharge:online()
    if self.data then self:send(self.data) end
end

-- 发送数据
function daily_recharge:send(data)
    print("-*-----* daily recharge send *-----*-")
    self.role:send_client("s_update_daily_recharge_data", data or {})
end

-- 领取奖励
function daily_recharge:receiving_reward(reward_id)
    if not reward_id or not self.data or not self.data.reward_dict[reward_id] then return end
    if self.data.reward_dict[reward_id] ~= CSConst.RewardState.pick then return end
    self.data.reward_dict[reward_id] = CSConst.RewardState.picked
    self.role:add_item_list(excel_data.RewardData[reward_id].item_list, g_reason.daily_recharge_reward)
    self:send({reward_dict = {[reward_id] = self.data.reward_dict[reward_id]}})
    return true
end

-- 充值事件
function daily_recharge:on_recharge_event(recharge_id)
    if not self.data then return end
    local id, cur_day = self.data.id, self.data.cur_day
    local exldata = excel_data.DailyRechargeData[id]
    if recharge_id ~= exldata.recharge_list[cur_day] then return end
    local reward_id = exldata.reward_list[cur_day]
    if self.data.reward_dict[reward_id] ~= CSConst.RewardState.unpick then return end
    self.data.reward_dict[reward_id] = CSConst.RewardState.pick
    self.data.total_recharge_days = self.data.total_recharge_days + 1
    if self.data.total_recharge_days == exldata.recharge_days then
        self.data.reward_dict[exldata.luxury_reward] = CSConst.RewardState.pick
        self:send({
            total_recharge_days = self.data.total_recharge_days, 
            reward_dict = {
                [reward_id] = self.data.reward_dict[reward_id],
                [exldata.luxury_reward] = self.data.reward_dict[exldata.luxury_reward],
            },
        })
    else
        self:send({
            total_recharge_days = self.data.total_recharge_days, 
            reward_dict = {
                [reward_id] = self.data.reward_dict[reward_id],
            },
        })
    end
end

return daily_recharge