local MOD = DECLARE_MODULE("gift_key_utils")

local ExcelData = require("excel_data")
local Date = require("sys_utils.date")
local timer = require("timer")
local cluster_utils = require("msg_utils.cluster_utils")

DECLARE_RUNNING_ATTR(MOD, "close_dict", {})
DECLARE_RUNNING_ATTR(MOD, "_timer", nil, function()
    return timer.loop(60, function() MOD.query_close_dict() end, 1)
end)

function MOD.query_close_dict()
    MOD.close_dict = cluster_utils.call_world('lc_query_gift_key_close_dict')
end

function MOD.is_close(channel)
    return MOD.close_dict[channel] and true or false
end

function MOD.use_gift_key(role, key)
    key = string.lower(key)
    local prefix = string.sub(key, 1, 3)
    role.db.yw_gift_key = role.db.yw_gift_key or {}

    for _, used_key in ipairs(role.db.yw_gift_key) do
        if string.sub(used_key, 1, 3) == prefix then
            return false, g_tips.gift_key_same
        end
    end

    local ok, data = cluster_utils.call_world("lc_use_gift_key", key)
    if not ok then
        return false, data
    end

    table.insert(role.db.yw_gift_key, key)
    role:add_item_list(data, g_reason.gift_key)
    return true, data
end

return MOD