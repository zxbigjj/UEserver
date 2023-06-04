local daily_gift_package_activities_utils = require("daily_gift_package_activities_utils")

local daily_gift_package_activities = DECLARE_MODULE("meta_table.daily_gift_package_activities")

function daily_gift_package_activities.new(role)
    print("---- daily_gift_package_activities new  ====".. role.uuid)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db
    }
    print("---- daily_gift_package_activities new  ====".. role.uuid)
    return setmetatable(self, daily_gift_package_activities)
end

function daily_gift_package_activities:get_all_gift_info(role)
    print("daily_gift_package_activities get_all_gift_info start===")
    print("daily_gift_package_activities role uuid==="..role.uuid)
    print("daily_gift_package_activities self uuid==="..self.role.uuid)
    --daily_gift_package_activities_utils.send_reward(role , 1)
    return daily_gift_package_activities_utils.get_all_gift_info(role);
end

-- 购买成功发送礼物
function daily_gift_package_activities:send_gift_reward(role , id)
    daily_gift_package_activities_utils.send_reward(role , id)
end

-- 零点更新每日礼包
function daily_gift_package_activities:daily_gift(role)
    local daily_gift_package = daily_gift_package_activities_utils.get_daily_gift(role);
    print( "---- 每日礼包 --- " .. json.encode(daily_gift_package))
    role:send_client("s_update_daily_gift", daily_gift_package)
end

function daily_gift_package_activities:daily_zero_gift(role , id)
    return  daily_gift_package_activities_utils.daily_zero_gift(self.role , id)
end

return daily_gift_package_activities