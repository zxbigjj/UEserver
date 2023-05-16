
local M = {}

function M:convert(data)
    local ret = {other_shop = {}, hero_shop = {}}
    for k, v in pairs(data) do
        if v.is_other then
            ret.other_shop[k] = v
        else
            ret.hero_shop[k] = v
        end
        local cost_item_list = {}
        for i, item_id in ipairs(v.cost_item_list) do
            local count = v.cost_item_value[i] * ((v.discount or 10)/10)
            count = math.ceil(count)
            table.insert(cost_item_list, {item_id = item_id, count = count})
        end
        v.cost_item_list = cost_item_list
        v.cost_item_value = nil
        ret[k] = v
    end
    return ret
end

return M