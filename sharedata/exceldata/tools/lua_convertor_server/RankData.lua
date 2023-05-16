
local M = {}

function M:convert(data)
    local ret = {role_rank = {}, dynasty_rank = {}}
    for k, v in pairs(data) do
        if v.is_dynasty_rank then
            ret.dynasty_rank[k] = v
        else
            ret.role_rank[k] = v
        end
        ret[k] = v
    end
    return ret
end

return M