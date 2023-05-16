
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        if v.dynasty_reward_list then
            local dynasty_reward_list = {}
            for i, item_id in ipairs(v.dynasty_reward_list) do
                table.insert(dynasty_reward_list, {item_id = item_id, count = v.dynasty_reward_value_list[i]})
            end
            v.dynasty_reward_list = dynasty_reward_list
            v.dynasty_reward_value_list = nil
        end
        if v.role_reward_list then
            local role_reward_list = {}
            for i, item_id in ipairs(v.role_reward_list) do
                table.insert(role_reward_list, {item_id = item_id, count = v.role_reward_value_list[i]})
            end
            v.role_reward_list = role_reward_list
            v.role_reward_value_list = nil
        end
        ret[k] = v
    end
    return ret
end

return M