
local M = {}

function M:convert(data)
    local ret = {}
    local total_exp = 0
    local max_level = 0
    for k, v in pairs(data) do
        local exp = v.exp
        v.exp = total_exp
        total_exp = total_exp + exp
        ret[k] = v
        max_level = max_level + 1
    end
    ret["max_level"] = max_level
    return ret
end

return M