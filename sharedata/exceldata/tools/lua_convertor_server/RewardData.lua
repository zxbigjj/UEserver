
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.item_list = {}
        v.item_dict = {}
        for i, item_id in ipairs(v.reward_item_list) do
            table.insert(v.item_list, {item_id = item_id, count = v.reward_num_list[i]})
            v.item_dict[item_id] = (v.item_dict[item_id] or 0) + v.reward_num_list[i]
        end
        ret[k] = v
    end
    return ret
end

return M