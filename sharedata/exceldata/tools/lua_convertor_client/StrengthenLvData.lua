local M = {}

function M:convert(data)
    local ret = {}
    for k,v in pairs(data) do
        ret[k] = v
    end
    for level, data in ipairs(ret) do
        data.total_exp_q1 = level == 1 and 0 or ret[level - 1].total_exp_q1 + ret[level - 1].exp_q1
        data.total_exp_q2 = level == 1 and 0 or ret[level - 1].total_exp_q2 + ret[level - 1].exp_q2
        data.total_exp_q3 = level == 1 and 0 or ret[level - 1].total_exp_q3 + ret[level - 1].exp_q3
        data.total_exp_q4 = level == 1 and 0 or ret[level - 1].total_exp_q4 + ret[level - 1].exp_q4
        data.total_exp_q5 = level == 1 and 0 or ret[level - 1].total_exp_q5 + ret[level - 1].exp_q5
    end
    return ret
end

return M