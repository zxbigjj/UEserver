local schema_game = require("schema_game")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local timer = require("timer")
local json = require("cjson")
local cluster_utils = require("msg_utils.cluster_utils")

local hero_activities_utils = DECLARE_MODULE("hero_activities_utils")

------------------------------------------------    common
local function random_table(_table, _num)
    local _result = {}
    local _index = 1
    local _num = _num or #_table
    while #_table ~= 0 do
        local ran = math.random(0, #_table)
        if _table[ran] ~= nil then
            _result[_index] = _table[ran]
            table.remove(_table, ran)
            _index = _index + 1
            if _index > _num then break end
        end
    end
    return _result
end

------------------------------------------------    get
-- 获得正在进行的礼包活动
function hero_activities_utils.get_ongoing_hero_activities(role)
    -- print('======'..role.uuid)
    local now = date.time_second()
    local activity_list = {}
    local hero_activities = schema_game.HeroActivities:load_many({ status = "activate" })
    local role_deal_hero_activities = schema_game.HeroActivitiesDealInfo:load_many({ uuid = role.uuid })
    local role_purchased_hero_activities = schema_game.RolePurchasedHeroActivities:load_many({ uuid = role.uuid })
    -- print("========== role_purchased_hero_activities : " .. json.encode(role_purchased_hero_activities))
    -- print("========== all hero activities : " .. json.encode(hero_activities))

    for index = 1, 7 do
        local hero_activity = hero_activities[index]
        if not hero_activity then break end

        -- print("======== hero " .. json.encode(hero_activity))

        if now >= hero_activity.end_ts then
            local next_refresh_time = hero_activity.end_ts
            while next_refresh_time <= now do --刷新时间,分
                next_refresh_time = next_refresh_time + (60 * hero_activity.refresh_interval)
            end
            schema_game.HeroActivities:set_field({ id = hero_activity.id }, { end_ts = next_refresh_time })

            hero_activity.end_ts = next_refresh_time
        end
        hero_activity.purchase_status = 0
        for _, value in pairs(role_purchased_hero_activities) do -- 以前购买过
            if not value then break end
            if value.hero_id == hero_activity.hero_id then hero_activity.purchase_status = 1 break end
        end
        for _, deal_activity in pairs(role_deal_hero_activities) do -- 活动内购买过
            if not deal_activity then break end
            if deal_activity.hero_activity_id == hero_activity.id then hero_activity = nil break end
        end
        table.insert(activity_list, hero_activity)
    end

    local hero_activities_res = { activity_list = activity_list }
    -- print("====== hero_activities_res: " .. json.encode(hero_activities_res))
    return hero_activities_res
end

------------------------------------------------    method
-- 购买礼包
function hero_activities_utils.buy_ongoing_hero_activities(args) -- 2022年4月18日, 需要改一下
    local role_info = schema_game.HeroActivitiesDealInfo:load_many({uuid = args.uuid, hero_activity_id = args.id})
    local deal_info = {
        uuid = tonumber(args.uuid), hero_activity_id = tonumber(args.id),
        deal_count = 1, deal_time = date.time_second(),
    }

    if next(role_info) == nil then -- 没买过
        schema_game.HeroActivitiesDealInfo:insert(nil, deal_info)
        return true, {
            uuid = tonumber(args.uuid), hero_activity_id = tonumber(args.id),
            deal_count = 1, purchase_count = 1, deal_time = date.time_second()
        }
    else
        return false, "超过购买次数"
    end
end

return hero_activities_utils
