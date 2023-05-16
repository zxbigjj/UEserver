local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.item_list = {}
        for i = 1, #v.reward_item do
            table.insert(v.item_list, {item_id = v.reward_item[i], count = v.reward_num[i]})
        end
        ret[k] = v
    end
    return ret
end

return M