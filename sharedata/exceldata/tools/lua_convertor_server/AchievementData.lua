
local M = {}

function M:convert(data)
    local ret = {}
    ret["achievement_dict"] = {}
    for k, v in pairs(data) do
        ret["achievement_dict"][v.achievement_type] = ret["achievement_dict"][v.achievement_type] or {}
        ret["achievement_dict"][v.achievement_type][v.finish_order] = k
        ret[k] = v
    end
    return ret
end

return M