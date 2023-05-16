local M = {}
function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.stage_list = {}
        for i = 1, 3 do
            v.stage_list[i] = (v.id - 1) * 3 + i
        end
        ret[k] = v
    end
    return ret
end
return M