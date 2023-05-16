local M = {}

function M:convert(data)
    local ret = {}
    ret["destiny_lv_list"] = {}
    for k,v in pairs(data) do
        table.insert(ret["destiny_lv_list"], v)
        ret[k] = v
    end
    table.sort(ret["destiny_lv_list"], function (data1, data2)
        return data1.level < data2.level
    end)
    return ret
end

return M