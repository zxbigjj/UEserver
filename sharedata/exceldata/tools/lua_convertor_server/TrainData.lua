
local M = {}

function M:convert(data)
    local ret = {}
    ret["layer_dict"] = {}
    for k, v in pairs(data) do
        if not ret["layer_dict"][v.layer] then
            ret["layer_dict"][v.layer] = {}
        end
        table.insert(ret["layer_dict"][v.layer], k)
        v.monster_level_list = v.monster_level or {}
        ret[k] = v
    end
    return ret
end

return M