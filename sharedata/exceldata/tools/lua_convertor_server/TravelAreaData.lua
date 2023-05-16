
local M = {}

function M:convert(data)
    local ret = {}
    ret.drop_list = {}
    for k, v in pairs(data) do
        if v.area_drop then
            table.insert(ret.drop_list, v.area_drop)
        end
        ret[k] = v
    end
    return ret
end

return M