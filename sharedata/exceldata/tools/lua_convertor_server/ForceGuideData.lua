local M = {}

function M:convert(data)
    local ret = {}
    ret.guide_group_list = {}
    local guide_group_list = ret.guide_group_list
    for k, v in pairs(data) do
        if not guide_group_list[v.group_id] then guide_group_list[v.group_id] = {} end
        table.insert(guide_group_list[v.group_id], k)
        ret[k] = v
    end
    for _, guide_id_list in pairs(guide_group_list) do
        table.sort(guide_id_list, function(id1, id2)
            return id1 < id2 
        end)
    end
    ret.group_id_to_guide_type = {}
    local group_id_to_guide_type = ret.group_id_to_guide_type
    for id, exldata in pairs(data) do
        if exldata.type then
            group_id_to_guide_type[exldata.group_id] = exldata.type
        end
    end
    return ret
end

return M