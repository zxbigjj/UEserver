
local M = {}

function M:convert(data)
    local ret = {}
    local total_exp = {0,0,0,0,0}
    for k in ipairs(data) do
        if k > 0 then
            v = data[k - 1]
            for i = 1, 5 do
                local exp = v["exp_q"..i]
                v["exp_q"..i] = total_exp[i]
                total_exp[i] = total_exp[i] + exp
            end
            ret[k-1] = v
        end
        if not data[k + 1] then
            v = data[k]
            for i = 1, 5 do
                v["exp_q"..i] = total_exp[i]
            end
            ret[k] = v
        end
    end
    return ret
end

return M