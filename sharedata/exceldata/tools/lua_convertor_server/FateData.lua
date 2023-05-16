
local M = {}

function M:convert(data)
    local ret = {}
    ret.hero_dict = {}
    for k, v in pairs(data) do
        -- ret.hero_dict[v.hero_id] = ret.hero_dict[v.hero_id] or {}
        -- table.insert(ret.hero_dict[v.hero_id], k)
        ret[k] = v
    end
    return ret
end

return M