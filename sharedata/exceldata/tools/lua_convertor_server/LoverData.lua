
local M = {}

function M:convert(data)
    local ret = {}
    ret.lover_list = {}
    for k, v in pairs(data) do
        if v.fashion then
            v.fashion_dict = {}
            for _, fashion_id in ipairs(v.fashion) do
                v.fashion_dict[fashion_id] = true
            end
        end
        if v.sex == 2 then
            table.insert(ret.lover_list, k)
        end
        v.hero_dict = {}
        for _, hero_id in ipairs(v.hero) do
            v.hero_dict[hero_id] = true
        end
        ret[k] = v
    end
    return ret
end

return M