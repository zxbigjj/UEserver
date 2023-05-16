
local M = {}

function M:convert(data)
    local ret = {}
    local exp = 0
    for k, v in ipairs(data) do
        v.exp = v.total_exp - exp
        exp = v.total_exp
        ret[k] = v
    end
    return ret
end

return M