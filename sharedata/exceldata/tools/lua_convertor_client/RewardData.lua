local M = {}
function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.reward_item_dict = {}
        for index, item_id in ipairs(v.reward_item_list) do
            if v.reward_item_dict[item_id] then
                error(" Id: " .. k .. " item_id repeat")
            else
                v.reward_item_dict[item_id] = v.reward_num_list[index]
            end
        end
        ret[k] = v
    end
    return ret
end
return M