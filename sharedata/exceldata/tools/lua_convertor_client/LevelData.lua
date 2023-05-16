local M = {}

function M:convert(data)
    local ret = {}
    local level_list = {}
    for k,v in pairs(data) do
        ret[k] = v
        table.insert(level_list, v)
    end
    table.sort(level_list, function (level1, level2)
        return level1.level < level2.level
    end)
    for i, data in ipairs(level_list) do
        if i == 1 then
            ret[i]["total_exp"] = 0
        else
            ret[i]["total_exp"] = ret[i - 1].total_exp + ret[i - 1].exp
        end
    end
    return ret
end

return M