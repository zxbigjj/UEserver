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
    ret.guide_group_type = {}
    local guide_group_type = ret.guide_group_type
    for k, guide_id_list in pairs(guide_group_list) do
        table.sort(guide_id_list, function(id1, id2)
            return id1 < id2 
        end)
        guide_group_type[k] = ret[guide_id_list[1]].type
        if not guide_group_type[k] then
            error("guide group : " .. k .. " do not have type")
        end
    end
    return ret
end

return M