local schema_game = require("schema_game")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local timer = require("timer")
local json = require("cjson")
local cluster_utils = require("msg_utils.cluster_utils")

local lover_activities_utils = DECLARE_MODULE("lover_activities_utils")

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
-- 获取已经购买的情人视频
function lover_activities_utils.get_purchased_lover_videos(role)
    local own_lover_videos = {}
    local impersonal_lover_videos = {}
    local total_lover_videos = {}
    local role_purchased_lover_activities = schema_game.RolePurchasedLoverActivities:load_many({
        uuid = role.uuid, lover_type = 0,
    })
    for lover_video_id, lover_video_info in pairs(excel_data.LoverPortrait) do
        if not lover_video_info then break end
        table.insert(total_lover_videos, { video_id = lover_video_id,
            lover_id = lover_video_info.unit_id,
            video_name = lover_video_info.name,
            video_status = 0, reward_status = 0
        })
    end
    for _, lover_activity in pairs(role_purchased_lover_activities) do
        if not lover_activity then break end
        for _, video_info in pairs(total_lover_videos) do
            if not video_info then break end
            if video_info.video_id == lover_activity.lover_id then
                video_info.video_status = 1
                video_info.reward_status = lover_activity.reward_status
                break
            end
        end
    end
    for _, value in pairs(total_lover_videos) do
        if not value then break end
        if value.video_status == 1 then table.insert(own_lover_videos, value)
        else table.insert(impersonal_lover_videos, value) end
    end

    local lover_videos_res = {
        total_num = #total_lover_videos,
        purchased_num = #own_lover_videos,
        own_lover_videos = own_lover_videos,
        impersonal_lover_videos = impersonal_lover_videos,
    }
    json.encode_sparse_array(true)
    -- print("===== lover_videos_res: "..json.encode(lover_videos_res))
    -- return lover_videos_res
    return {}
end

-- 获得正在进行的礼包活动
function lover_activities_utils.get_ongoing_lover_activities(role)
    local now = date.time_second()
    print("get_ongoing_lover_activities time"..json.encode(os.date("%Y-%m-%d %H:%M:%S", math.floor(now))))
    local activity_list = {}
    local lover_activities = schema_game.LoverActivities:load_many({status = "activate"})
    local role_purchased_lover_activities = schema_game.RolePurchasedLoverActivities:load_many({uuid = role.uuid})
    local role_deal_lover_activities = schema_game.LoverActivitiesDealInfo:load_many({uuid = role.uuid})
    local photo_table = {}
    local video_table = {}

    for _, value in pairs(lover_activities) do
        if not value then break end
        if value.lover_type == 0 then
            table.insert(video_table, value)
        else
            table.insert(photo_table, value)
        end
    end

    -- print("========== all lover activities : ".. json.encode(lover_activities))

    -- while #activity_list <= 7 do
    -- end

    for index = 1, 7 do
        local lover_activity = lover_activities[index]
        if not lover_activity then break end

        -- print("======== lover "..json.encode(lover_activity))

        if now >= lover_activity.end_ts then
            local next_refresh_time = lover_activity.end_ts
            while next_refresh_time <= now do --刷新时间,分
                next_refresh_time = next_refresh_time + (60 * lover_activity.refresh_interval)
            end
            schema_game.LoverActivities:set_field({ id = lover_activity.id }, { end_ts = next_refresh_time })

            lover_activity.end_ts = next_refresh_time
        end
        lover_activity.purchase_status = 0
        for _, value in pairs(role_purchased_lover_activities) do   -- 以前购买过
            if not value then break end
            if value.lover_id == lover_activity.lover_id then lover_activity.purchase_status = 1 break end
        end
        for _, deal_activity in pairs(role_deal_lover_activities) do   -- 活动内购买过
            if not deal_activity then break end
            if deal_activity.lover_activity_id == lover_activity.id then lover_activity = nil break end
        end
        table.insert(activity_list, lover_activity)
    end

    local lover_activities_res = {activity_list = activity_list}
    -- print("====== lover_activities_res: "..json.encode(lover_activities_res))
    return lover_activities_res
end

------------------------------------------------    method
-- 购买礼包
function lover_activities_utils.buy_ongoing_lover_activities(args)  -- 2022年4月18日, 需要改一下
    local role_info = schema_game.LoverActivitiesDealInfo:load_many({uuid = args.uuid, lover_activity_id = args.id})
    local lover_activities_info = schema_game.LoverActivities:load(tonumber(args.id))
    if not lover_activities_info then return false, "活动ID错误" end

    local deal_info = {
        uuid = tonumber(args.uuid), lover_activity_id = tonumber(args.id),
        deal_count = 1, deal_time = date.time_second(),
    }
    local purchase_info = {
        uuid = tostring(args.uuid), activity_id = tonumber(args.id),
        lover_id = lover_activities_info.lover_id, lover_type = lover_activities_info.lover_type,
    }

    if next(role_info) == nil then  -- 没买过
        schema_game.LoverActivitiesDealInfo:insert(nil, deal_info)
        schema_game.RolePurchasedLoverActivities:insert(nil, purchase_info)
        return true, {
            uuid = tonumber(args.uuid), lover_activity_id = tonumber(args.id),
            deal_count = 1, purchase_count = 1, deal_time = date.time_second()
        }
    else
        return false, "超过购买次数"
    end
end

return lover_activities_utils
