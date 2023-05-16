
local M = {}

function M:convert(data)
    local ret = {}
    ret["country_dict"] = {}
    for k, v in pairs(data) do
        if not ret["country_dict"][v.country_id] then
            ret["country_dict"][v.country_id] = {city_list = {},  last_city = 0}
        end
        table.insert(ret["country_dict"][v.country_id].city_list, k)
        if k > ret["country_dict"][v.country_id].last_city then
            ret["country_dict"][v.country_id].last_city = k
        end
        ret[k] = v
    end
    for _, v in pairs(ret["country_dict"]) do
        table.sort(v.city_list, function (a, b) return a < b end)
    end
    return ret
end

return M