
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        local cost_item_list = {}
        for i, item_id in ipairs(v.cost_item_list) do
            table.insert(cost_item_list, {item_id = item_id, count = v.cost_item_value[i]})
        end
        v.cost_item_list = cost_item_list
        v.cost_item_value = nil
        ret[k] = v
    end
    return ret
end

return M