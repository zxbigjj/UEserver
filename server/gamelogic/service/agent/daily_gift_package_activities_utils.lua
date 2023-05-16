local excel_data = require("excel_data")
local schema_game = require("schema_game")
local date = require "sys_utils.date"
local json = require("json")

local cur_date = date.format_day_time(nil)
--每日礼包
local daily_gift_package_activities_utils = DECLARE_MODULE("daily_gift_package_activities_utils")

--获取当前的每日礼包信息
function daily_gift_package_activities_utils.get_all_gift_info(role)
    print("====get_all_gift_info start ====")

    --获取玩家今天购买每日礼包的全部记录
    local get_day_gift_info = schema_game.DailyGiftPackage:load_many({reward_date = cur_date , user_id = role.uuid , reset_cycle = 1})

    -- 获取玩家 没有礼包的购买记录
    local get_week_gift_info = schema_game.DailyGiftPackage:get_db_client():query("select * from t_dailygiftpackage where user_id = "..tostring(role.uuid) .. " and reset_cycle = 7 and reward_date >= '" .. tostring(date.get_week_start_time()).."' and reward_date <'"..tostring(date.get_week_end_time()).."'")

    -- 获取玩家终身礼包的购买激励
    local get_forever_gift_info = schema_game.DailyGiftPackage:load_many({user_id = role.uuid , reset_cycle = 36500})

    local result = {}

    for  id, activities_info in pairs(excel_data.DailyGiftData) do
        print("====get_all_gift_info id ===="..id)
        print("====get_all_gift_info  activities_info ===="..json.encode(activities_info))
        local residue_count = activities_info.limit_num;
        print("====get_all_gift_info residue_count ===="..residue_count)
        if activities_info.reset_cycle == 1  then
            print("====enter  get_day_gift_info===="..json.encode(get_day_gift_info))
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
        print("====get_all_gift_info  activities_info result ===="..json.encode(result))
    end
    return {
        detail_gift_package_list = result ,
        day_residue_time = date.get_residue_seconds_to_tomorrow(),
        week_residue_time = date.get_week_last_time()
    }
end

--充值减少礼包次数
function daily_gift_package_activities_utils.purchase_info(role , id)

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
    local gift_package_infos =  schema_game.DailyGiftPackage:load_many({id = id , user_id = role.uuid , reward_date = cur_date})
    return gift_package_infos
end

function daily_gift_package_activities_utils.send_reward(role , id)
    local result = daily_gift_package_activities_utils.purchase_info(role , id)
    if result ~= "ok" then
        return nil
    end
    local excel_info = daily_gift_package_activities_utils.get_excel_info_by_id(tonumber(id))
    print("====excel_info==="..json.encode(excel_info))
    local reward_dict = {}
    for k, v in ipairs(excel_info.item_id) do
        reward_dict[v] = excel_info.item_count[k]
    end

    local reason = g_reason.gift_package
    print("====reward_dict==="..json.encode(reward_dict))
    role:add_item_dict(reward_dict, reason)

    -- 更新客户端每日礼包
    local daily_gift_package = daily_gift_package_activities_utils.get_all_gift_info(role);
    role:send_client("s_update_daily_gift", daily_gift_package)
end

function daily_gift_package_activities_utils.daily_zero_gift(role , id)
    print("daily_zero_gift id"..id)
    local result = daily_gift_package_activities_utils.purchase_info(role , id)
    if result ~= "ok" then
        return nil
    end
    local excel_info = daily_gift_package_activities_utils.get_excel_info_by_id(id)
    print("====excel_info==="..json.encode(excel_info))
    local reward_dict = {}
    for k, v in ipairs(excel_info.item_id) do
        reward_dict[v] = excel_info.item_count[k]
    end

    local reason = g_reason.gift_package
    print("====reward_dict==="..json.encode(reward_dict))
    role:add_item_dict(reward_dict, reason)

    return daily_gift_package_activities_utils.get_all_gift_info(role)
end

return daily_gift_package_activities_utils


