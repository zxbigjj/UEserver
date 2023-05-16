local M = {}

function M:convert(data)
    local ret = {}
    ret["challenge_map_list"] = {}
    for k, v in pairs(data) do
        table.insert(ret["challenge_map_list"], v)
    end
    table.sort(ret["challenge_map_list"], function (map1, map2)
        return map2.id > map1.id
    end)
    return ret
end

return M