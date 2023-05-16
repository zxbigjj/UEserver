
local M = {}

function M:convert(data)
    local ret = {}
    local total_exp = 0
    for k, v in ipairs(data) do
        local exp = v.exp
        v.exp = total_exp
        total_exp = total_exp + exp
        ret[k] = v
    end
    return ret
end

return M