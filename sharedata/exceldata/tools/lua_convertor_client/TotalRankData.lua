local M = {}

local max_guide_type = 4
function M:convert(data)
    local ret = {}

    ret.group_list = {}
    local group_list = ret.group_list
    ret.sort_group_id_list = {}
    local sort_group_id_list = ret.sort_group_id_list
    local guide_type
    for k, v in pairs(data) do
        if not group_list[v.group_id] then
            table.insert(sort_group_id_list, v.group_id)
            group_list[v.group_id] = {}
        end
        table.insert(group_list[v.group_id], k)
        ret[k] = v
    end
    for _, guide_id_list in pairs(group_list) do
        table.sort(guide_id_list, function(id1, id2)
            return id1 < id2 
        end)
    end
    table.sort(sort_group_id_list, function (group_id1, group_id2)
        return ret[group_list[group_id1][1]].sort < ret[group_list[group_id2][1]].sort
    end)

    return ret
end

return M
