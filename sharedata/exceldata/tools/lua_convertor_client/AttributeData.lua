local M = {}

function M:convert(data)
    local ret = {}
    ret.city_income_attr_list = {}
    for k,v in pairs(data) do
        ret[k] = v
        if v.city_income_item and v.city_income_item_rate then
            table.insert(ret.city_income_attr_list, k)
        end
    end
    table.sort(ret.city_income_attr_list, function (k1, k2)
        return ret[k1].order > ret[k2].order
    end)
    return ret
end

return M