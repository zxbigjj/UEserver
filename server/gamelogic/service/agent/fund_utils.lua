local server_data = require("server_data")
local agent_utils = require("agent_utils")

local fund_utils = DECLARE_MODULE("fund_utils")

-- 购买人数
local total_count = DECLARE_RUNNING_ATTR(fund_utils, "total_count", 0)

-- 启动时加载数据
function fund_utils.start()
    total_count = server_data.get_server_core("openservice_fund_cnt")
end

-- 关闭时保存数据
function fund_utils.shutdown()
    server_data.set_server_core("openservice_fund_cnt", total_count)
end

-- 获取购买总人数
function fund_utils.get_count()
    return total_count
end

-- 购买总人数加一
function fund_utils.add_count(self_uuid, add_count)
    add_count = add_count or 1
    total_count = total_count + add_count
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        -- 当前购买的玩家不通知
        if uuid ~= self_uuid then
            local role = agent_utils.get_role(uuid)
            role.fund:notify_count_added()
        end
    end
end

return fund_utils