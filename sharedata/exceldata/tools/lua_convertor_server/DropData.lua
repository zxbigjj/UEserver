
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        local group = ret[v.group_id]
        if not group then
            ret[v.group_id] = {}
            group = ret[v.group_id]
        end
        group[k] = v
    end
    return ret
end

return M