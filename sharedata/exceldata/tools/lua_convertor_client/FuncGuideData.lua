local M = {}

local max_guide_type = 4
function M:convert(data)
    local ret = {}

    ret.func_guide = {}
    local force_guide = ret.force_guide
    local func_guide = ret.func_guide
    local guide_type
    for k, v in pairs(data) do
        if not func_guide[v.group_id] then func_guide[v.group_id] = {} end
        table.insert(func_guide[v.group_id], k)
        guide_type = v.guide_type
        if not guide_type then error(" no guide_type gudie_id: ", k) end
        if guide_type < 1 or guide_type > max_guide_type then error("guide_type out of range gudie_id: ", k) end
        ret[k] = v
    end
    for _, guide_id_list in pairs(func_guide) do
        table.sort(guide_id_list, function(id1, id2)
            return id1 < id2 
        end)
    end

    return ret
end

return M