
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.animal_num = #v.animal_hp
        ret[k] = v
    end
    return ret
end

return M