local M = {}

function M:convert(data)
    local ret = {}
    ret["bag_sort_type_list"] = {}
    for k,v in pairs(data) do
        ret[k] = v
        if v.sub_type_list then
            table.insert(ret["bag_sort_type_list"], v)
        end
    end
    table.sort(ret["bag_sort_type_list"], function (type1, type2)
        return type1.id < type2.id
    end)
    return ret
end

return M