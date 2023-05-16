local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        if v.lover_id then
            ret[v.lover_id] = ret[v.lover_id] or {}
            ret[v.lover_id].meet_list = ret[v.lover_id].meet_list or {}
            table.insert(ret[v.lover_id].meet_list, k)
            v.meet_index = #ret[v.lover_id].meet_list
            ret[v.lover_id][k] = v
        end
    end
    return ret
end

return M