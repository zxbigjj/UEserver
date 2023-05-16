
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.consume_item_list = {}
        for i, item_id in ipairs(v.cost_item_list) do
            v.consume_item_list[i] = {
                item_id = item_id,
                count = v.cost_item_count_list[i],
            }
        end
        v.cost_item_list = nil
        v.cost_item_count_list = nil
        ret[k] = v
    end
    return ret
end

return M