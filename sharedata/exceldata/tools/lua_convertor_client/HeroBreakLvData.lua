local M = {}

function M:convert(data)
    local ret = {}
    ret["break_lv_list"] = {}
    for k,v in pairs(data) do
        table.insert(ret["break_lv_list"], v)
        ret[k] = v
    end
    table.sort(ret["break_lv_list"], function (data1, data2)
        return data1.id < data2.id
    end)
    return ret
end

return M