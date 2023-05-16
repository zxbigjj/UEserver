local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.item_list = {{item_id = v.sell_item_id, count = v.sell_item_num}}
        ret[k] = v
    end
    return ret
end

return M