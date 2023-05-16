
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.quality_dict = {}
        for index, quality in pairs(v.quality_list) do
            v.quality_dict[quality] = index
        end
        ret[k] = v
    end
    return ret
end

return M