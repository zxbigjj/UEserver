local M = {}

function M:convert(data)
    local ret = {}
    ret["power_list"] = {}
    for k,v in pairs(data) do
        ret[k] = v
        table.insert(ret["power_list"], v)
    end
    table.sort(ret["power_list"], function (power1, power2)
        return power1.id < power2.id
    end)
    return ret
end

return M