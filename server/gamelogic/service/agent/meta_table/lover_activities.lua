local json = require("cjson")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local schema_game = require("schema_game")
local lover_activities_utils = require("lover_activities_utils")

local role_activities = DECLARE_MODULE("meta_table.lover_activities")
-------------------------------------------------------------------------------
function role_activities.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
        activity_timer = {}
    }
    return setmetatable(self, role_activities)
end

------------------------------------    online
function role_activities:online()
    -- self:send_ongoing_lover_activities()
    self:set_activities_timer()
end

------------------------------------    timer
function role_activities:set_activities_timer()
    local now = date.time_second()
    local res = lover_activities_utils.get_ongoing_lover_activities(self.role)
    self.role:send_client("s_update_ongoing_lover_activities", res)

    for _, lover_activity_data in pairs(res.activity_list) do
        self:timer_loop_lover_activity(
            lover_activity_data.id,
            lover_activity_data.refresh_interval * 60,
            lover_activity_data.end_ts - now
        )
    end
end

function role_activities:timer_loop_lover_activity(id, duration_seconds, delay_time)
    if duration_seconds <= 0 then return end
    if self.activity_timer[id] then
        self.activity_timer[id]:cancel()
        self.activity_timer[id] = nil
    end
    -- print("id, duration_seconds, delay_time")
    -- print(id, duration_seconds, delay_time)
    self.activity_timer[id] = self.role:timer_loop(duration_seconds, function()
        self:clear_activities_deal_info()
        if not self.role:is_online() then
            self.activity_timer[id]:cancel()
            self.activity_timer[id] = nil
            return
        end
        self:send_ongoing_lover_activities()
    end, delay_time)
end

------------------------------------    common
-- 发送正在进行的礼包活动
function role_activities:send_ongoing_lover_activities()
    local result = lover_activities_utils.get_ongoing_lover_activities(self.role)
    self.role:send_client("s_update_ongoing_lover_activities", result)
end

-- 清除礼包定时
function role_activities:clear_activities_timer(activity_id)
    if self.activity_timer[activity_id] then
        self.activity_timer[activity_id]:cancel()
        self.activity_timer[activity_id] = nil
    end
end

-- 清除礼包购买记录
function role_activities:clear_activities_deal_info()
    schema_game.LoverActivitiesDealInfo:delete_many({uuid = self.uuid})
end

-- 删除礼包
function role_activities:delete_activity(activity_id)
    self:clear_activities_timer(activity_id)
    self:send_ongoing_lover_activities()
end

------------------------------------    get
-- 获取已经购买的情人视频
function role_activities:get_purchased_lover_videos()
    return lover_activities_utils.get_purchased_lover_videos(self.role)
end

-- 获取正在进行的情人礼包
function role_activities:get_ongoing_lover_activities()
    return lover_activities_utils.get_ongoing_lover_activities(self.role)
end

-- 领取视频奖励
function role_activities:get_lover_video_reward(lover_video_id)
    -- print("== lover_video_id: " .. lover_video_id)
    local item_list = {}
    local gift_item_list = excel_data.LoverPortrait[lover_video_id].gift_item_list
    local gift_num_list = excel_data.LoverPortrait[lover_video_id].gift_num_list
    local role_deal_info_list = schema_game.RolePurchasedLoverActivities:load_many({
        uuid = self.uuid, lover_type = 0,
    })

    if not next(gift_item_list) then return false end

    for index, value in pairs(gift_item_list) do
        table.insert(item_list, { item_id = value, count = gift_num_list[index] })
    end
    for index, deal_info in pairs(role_deal_info_list) do
        if deal_info.lover_id == lover_video_id and deal_info.reward_status == 0 then
            self.role:add_item_list(item_list, g_reason.lover_activity_video_reward)
            -- self.role:send_client("s_update_lover_video_reward", { reward_list = item_list })
            schema_game.RolePurchasedLoverActivities:set_field({id = deal_info.id}, {
                reward_status = 1
            })
            return true
        end
    end
    return false
end

return role_activities
