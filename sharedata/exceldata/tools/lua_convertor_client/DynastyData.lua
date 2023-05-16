
local M = {}

function M:convert(data)
    local ret = {}
    local last_lv_data
    for k, v in pairs(data) do
        v.total_exp = v.exp
        if last_lv_data then
            v.exp = v.exp - last_lv_data.total_exp
        end
        last_lv_data = v
        ret[k] = v
    end
    return ret
end

return M