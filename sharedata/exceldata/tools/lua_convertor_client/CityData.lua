local M = {}

function M:convert(data)
    local ret = {}
    ret.country_dict = {}
    local country_dict = ret.country_dict
    for k,v in pairs(data) do
        ret[k] = v
        if v.country_id then
            if not country_dict[v.country_id] then
                country_dict[v.country_id] = {}
            end
            table.insert(country_dict[v.country_id], v.id)
        end
    end
    for k, city_list in pairs(country_dict) do
        table.sort(city_list, function (id1, id2)
            return id1 < id2
        end)
    end
    return ret
end

return M