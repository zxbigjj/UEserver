
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        if v.first_reward_item and v.first_reward_item_count then
            v.first_reward_list = {}
            for index, item_id in ipairs(v.first_reward_item) do
                v.first_reward_list[index] = {
                    item_id =  item_id,
                    count = v.first_reward_item_count[index],
                }
            end
            v.first_reward_item = nil
            v.first_reward_item_count = nil
        end
        ret[k] = v
    end
    return ret
end

return M