local json = require("cjson")
local date = require("sys_utils.date")
local schema_game = require("schema_game")
local hero_activities_utils = require("hero_activities_utils")

local role_activities = DECLARE_MODULE("meta_table.hero_activities")
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
    -- self:send_ongoing_hero_activities()
    self:set_activities_timer()
end

------------------------------------    timer
function role_activities:set_activities_timer()
    local now = date.time_second()
    local res = hero_activities_utils.get_ongoing_hero_activities(self.role)
    self.role:send_client("s_update_ongoing_hero_activities", res)

    for _, hero_activity_data in pairs(res.activity_list) do
        self:timer_loop_hero_activity(
            hero_activity_data.id,
            hero_activity_data.refresh_interval * 60,
            hero_activity_data.end_ts - now
        )
    end
end

function role_activities:timer_loop_hero_activity(id, duration_seconds, delay_time)
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
        self:send_ongoing_hero_activities()
    end, delay_time)
end

------------------------------------    common
-- 发送正在进行的礼包活动
function role_activities:send_ongoing_hero_activities()
    local result = hero_activities_utils.get_ongoing_hero_activities(self.role)
    self.role:send_client("s_update_ongoing_hero_activities", result)
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
    schema_game.HeroActivitiesDealInfo:delete_many({ uuid = self.uuid })
end

-- 删除礼包
function role_activities:delete_activity(activity_id)
    self:clear_activities_timer(activity_id)
    self:send_ongoing_hero_activities()
end

------------------------------------    get
-- 获取正在进行的英雄礼包
function role_activities:get_ongoing_hero_activities()
    return hero_activities_utils.get_ongoing_hero_activities(self.role)
end

return role_activities
