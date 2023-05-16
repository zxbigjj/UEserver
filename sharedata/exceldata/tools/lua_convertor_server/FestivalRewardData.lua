local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.item_list = {}
        for i = 1, #v.reward_item_list do
            table.insert(v.item_list, {item_id = v.reward_item_list[i], count = v.reward_num_list[i]})
        end
        v.reward_item_dict = {}
        for i, reward_id in ipairs(v.reward_item_list) do
            v.reward_item_dict[reward_id] = v.reward_num_list[i]
        end
        ret[k] = v
    end
    return ret
end

return M