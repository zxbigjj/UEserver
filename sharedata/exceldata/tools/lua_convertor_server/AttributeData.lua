
local M = {}

function M:convert(data)
    for k, v in pairs(data) do
        if v.other_add_role_attr then
            v.is_role_attr = true
            data[v.pct_attr].is_role_attr = true
        end
    end
    return data
end

return M