local M = {}

function M:convert(data)
    local ret = {}
    ret.force_guide = {}
    ret.func_guide = {}
    local force_guide = ret.force_guide
    local func_guide = ret.func_guide
    for k, v in pairs(data) do
        if v.type == 1 then
            if not force_guide[v.group_id] then force_guide[v.group_id] = {} end
            table.insert(force_guide[v.group_id], k)
        elseif v.type == 2 then
            if not func_guide[v.group_id] then func_guide[v.group_id] = {} end
            table.insert(func_guide[v.group_id], k)
        end
        ret[k] = v
    end

    for _, guide_id_list in pairs(force_guide) do
        table.sort(guide_id_list, function(id1, id2)
            return id1 < id2 
        end)
    end
    for _, guide_id_list in pairs(func_guide) do
        table.sort(guide_id_list, function(id1, id2)
            return id1 < id2 
        end)
    end
    return ret
end

return M