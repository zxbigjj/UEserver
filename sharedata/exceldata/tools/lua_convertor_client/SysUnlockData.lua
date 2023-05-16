local M = {}

function M:convert(data)
    local ret = {}
    ret["sys_unlock_list"] = {}
    local temp = {}
    for k,v in pairs(data) do
        temp[v.level] = temp[v.level] or {level = v.level, data = {}}
        table.insert(temp[v.level].data, v)
        ret[k] = v
    end
    for _, data in pairs(temp) do
        table.insert(ret["sys_unlock_list"], data)
    end
    table.sort(ret["sys_unlock_list"], function (data1, data2)
        return data1.level < data2.level
    end)
    return ret
end

return M