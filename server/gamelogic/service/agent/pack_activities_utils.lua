local json = require("cjson")
local timer = require("timer")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local schema_game = require("schema_game")
local cluster_utils = require("msg_utils.cluster_utils")

local pack_activities_utils = DECLARE_MODULE("pack_activities_utils")
-- local ActivityClass = DECLARE_CLASS(pack_activities_utils, "ActivityClass")
local lover_activities_dict = DECLARE_RUNNING_ATTR(pack_activities_utils, "lover_activities_dict", {})
local lover_activities_timer = DECLARE_RUNNING_ATTR(pack_activities_utils, "lover_activities_timer", {})
local hero_activities_dict = DECLARE_RUNNING_ATTR(pack_activities_utils, "hero_activities_dict", {})
local hero_activities_timer = DECLARE_RUNNING_ATTR(pack_activities_utils, "hero_activities_timer", {})
--------------------------------------------------------------  start、shutdown

function pack_activities_utils.start()      -- 开机加载
    print("=====================")
    print("pack_activities_utils start to load")
    print("=====================")
    pack_activities_utils.load()
end

-- function pack_activities_utils.shutdown()
--     -- todo  好像并不需要
-- end

function pack_activities_utils.load()       -- 装载
    local lover_activities_list = schema_game.LoverActivities:load_many()
    for _, lover_activity in pairs(lover_activities_list) do
        lover_activities_dict[lover_activity] = lover_activity
    end
    local hero_activities_list = schema_game.HeroActivities:load_many()
    for _, hero_activity in pairs(hero_activities_list) do
        hero_activities_dict[hero_activity] = hero_activity
    end
end

--------------------------------------------------------------  Class
-- 构造 activity_obj
-- function ActivityClass.new(data, activity_type)     -- 1.情人   2.英雄
--     local self = setmetatable({}, ActivityClass)
--     self.id = data.id
--     self.price = data.price
--     self.discount = data.discount
--     self.activity_name_fir = data.activity_name_fir
--     self.activity_name_sec = data.activity_name_sec
--     self.item_list = data.item_list
--     self.icon = data.icon
--     self.end_ts = data.end_ts
--     self.refresh_interval = data.refresh_interval

--     if activity_type == 1 then
--         self.lover_id = data.lover_id
--         self.lover_type = data.lover_type
--         lover_activities_dict[self.id] = self
--     else
--         self.hero_id = data.hero_id
--         self.hero_type = data.hero_type
--         hero_activities_dict[self.id] = self
--     end
--     return self
-- end

--------------------------------------------------------------  methods
function pack_activities_utils.add_pack_activity(data, activity_type)
    if activity_type == 1 then -- 1.情人   2.英雄
        lover_activities_dict[data.id] = data
    elseif activity_type == 2 then
        hero_activities_dict[data.id] = data
    end
end

function pack_activities_utils.get_ongoing_lover_activities()
    for activity_id, activity_info in ipairs(lover_activities_dict) do
        -- todo
    end
end

function pack_activities_utils.get_ongoing_hero_activities()
    for activity_id, activity_info in ipairs(hero_activities_dict) do
        -- todo
    end
end


return pack_activities_utils
