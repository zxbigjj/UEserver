local excel_data = require("excel_data")
local schema_game = require("schema_game")
local date = require "sys_utils.date"
local json = require("json")

--每日礼包
local daily_gift_package_activities_utils = DECLARE_MODULE("daily_gift_package_activities_utils")

--获取当前的每日礼包信息
function daily_gift_package_activities_utils.get_all_gift_info(role)
    local cur_date = date.format_day_time(nil)
   
    --获取玩家今天购买每日礼包的全部记录
    local get_day_gift_info = schema_game.DailyGiftPackage:load_many({reward_date = cur_date , user_id = role.uuid , reset_cycle = 1})
    -- 获取玩家 没有礼包的购买记录
    local get_week_gift_info = schema_game.DailyGiftPackage:get_db_client():query("select * from t_dailygiftpackage where user_id = "..tostring(role.uuid) .. " and reset_cycle = 7 and reward_date >= '" .. tostring(date.get_week_start_time()).."' and reward_date <'"..tostring(date.get_week_end_time()).."'")

    -- 获取玩家终身礼包的购买激励
    local get_forever_gift_info = schema_game.DailyGiftPackage:load_many({user_id = role.uuid , reset_cycle = 36500})

    local result = {}

    for  id, activities_info in pairs(excel_data.DailyGiftData) do
        local residue_count = activities_info.limit_num;
        if activities_info.reset_cycle == 1  then
            for _, info in pairs(get_day_gift_info) do
                if info.reward_id == activities_info.id then
                    residue_count = residue_count - 1
                end
            end
        elseif activities_info.reset_cycle == 7 then

            for _, info in pairs(get_week_gift_info) do
                if info.reward_id == activities_info.id then
                    residue_count = residue_count - 1
                end
            end

        elseif activities_info.reset_cycle == 36500 then
            for _, info in pairs(get_forever_gift_info) do
                if info.reward_id == activities_info.id then
                    residue_count = residue_count - 1
                end
            end
        end
        table.insert(result , {
            id = id ,
            uuid = role.uuid ,
            residue_count= residue_count
        })
    end
    return {
        detail_gift_package_list = result ,
        day_residue_time = date.get_residue_seconds_to_tomorrow(),
        week_residue_time = date.get_week_last_time()
    }
end

function daily_gift_package_activities_utils.get_daily_gift(role)
    local now_ts = date.time_second()
    local one_day = 24*3600
    local one_week = 7 * one_day
    local result = {}
    for  id, activities_info in pairs(excel_data.DailyGiftData) do
        local residue_count = activities_info.limit_num;
        table.insert(result , {
            id = id ,
            uuid = role.uuid ,
            residue_count= residue_count
        })
    end
    return {
        detail_gift_package_list = result ,
        day_residue_time = now_ts + one_day,
        week_residue_time = now_ts + one_week
    }
end

--充值减少礼包次数
function daily_gift_package_activities_utils.purchase_info(role , id)

    local cur_date = date.format_day_time(nil)

    local excel_info = daily_gift_package_activities_utils.get_excel_info_by_id(tonumber(id))
    if  excel_info == nil then
        error "throw an error 没有这个礼包"
        return nil
    end
    local new_gift_package_info = {
        user_id =  role.uuid,
        reward_id = tonumber(id) ,
        reward_date = cur_date,
        reset_cycle = excel_info.reset_cycle
    }
    schema_game.DailyGiftPackage:insert(nil , new_gift_package_info)
    return "ok"
end

function daily_gift_package_activities_utils.get_excel_info_by_id(gift_id)
    for id, activities_info in pairs(excel_data.DailyGiftData) do
        if(id == gift_id ) then
            return activities_info
        end
    end
    return nil;
end

function daily_gift_package_activities_utils.get_gift_package_info_by_id(role , id)
    local cur_date = date.format_day_time(nil)
    local gift_package_infos =  schema_game.DailyGiftPackage:load_many({id = id , user_id = role.uuid , reward_date = cur_date})
    return gift_package_infos
end

function daily_gift_package_activities_utils.send_reward(role , id)
    local result = daily_gift_package_activities_utils.purchase_info(role , id)
    if result ~= "ok" then
        return nil
    end
    local excel_info = daily_gift_package_activities_utils.get_excel_info_by_id(tonumber(id))
    local reward_dict = {}
    for k, v in ipairs(excel_info.item_id) do
        reward_dict[v] = excel_info.item_count[k]
    end

    local reason = g_reason.gift_package
    role:add_item_dict(reward_dict, reason)

    -- 更新客户端每日礼包
    local daily_gift_package = daily_gift_package_activities_utils.get_all_gift_info(role);
    print("daily_gift_package_activities_utils send_reward daily_gift_package :"..daily_gift_package)
    role:send_client("s_update_daily_gift", daily_gift_package)
end

function daily_gift_package_activities_utils.daily_zero_gift(role , id)
    local get_last_times = daily_gift_package_activities_utils.get_last_times(role , id)
    if get_last_times == -1 then
        return nil
    end
    local result = daily_gift_package_activities_utils.purchase_info(role , id)
    if result ~= "ok" then
        return nil
    end
    local excel_info = daily_gift_package_activities_utils.get_excel_info_by_id(id)
    local reward_dict = {}
    for k, v in ipairs(excel_info.item_id) do
        reward_dict[v] = excel_info.item_count[k]
    end

    local reason = g_reason.gift_package
    role:add_item_dict(reward_dict, reason)

    return daily_gift_package_activities_utils.get_all_gift_info(role)
end

function daily_gift_package_activities_utils.get_last_times( role , id)
    local cur_date = date.format_day_time(nil)
    local excel_info = daily_gift_package_activities_utils.get_excel_info_by_id(id)
    if excel_info.reset_cycle == 1 then
        local get_day_gift_info = schema_game.DailyGiftPackage:load_many({reward_date = cur_date , user_id = role.uuid , reward_id = id})
        if #get_day_gift_info >= excel_info.limit_num then
            return -1
        end
        return excel_info.limit_num - #get_day_gift_info
    end

    if excel_info.reset_cycle == 7 then
        local get_week_gift_info = schema_game.DailyGiftPackage:get_db_client():query("select * from t_dailygiftpackage where user_id = "..tostring(role.uuid) .. " and reward_id = ".. id .." and reset_cycle = 7 and reward_date >= '" .. tostring(date.get_week_start_time()).."' and reward_date <'"..tostring(date.get_week_end_time()).."'")

        if #get_week_gift_info >= excel_info.limit_num then
            return -1
        end
        return excel_info.limit_num - #get_week_gift_info
    end

    if excel_info.reset_cycle == 36500 then
        -- 获取玩家终身礼包的购买激励
        local get_forever_gift_info = schema_game.DailyGiftPackage:load_many({user_id = role.uuid , reset_cycle = 36500 , reward_id = id})
        if #get_forever_gift_info >= excel_info.limit_num then
            return -1
        end
        return excel_info.limit_num - #get_forever_gift_info
    end

end

return daily_gift_package_activities_utils


