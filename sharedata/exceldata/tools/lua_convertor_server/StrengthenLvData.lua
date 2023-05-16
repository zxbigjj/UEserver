
local M = {}

function M:convert(data)
    local ret = {}
    local total_exp = {0,0,0,0,0}
    for k, v in ipairs(data) do
        for i = 1, 5 do
            local exp = v["exp_q"..i]
            v["exp_q"..i] = total_exp[i]
            total_exp[i] = total_exp[i] + exp
        end
        ret[k] = v
    end
    return ret
end

return M