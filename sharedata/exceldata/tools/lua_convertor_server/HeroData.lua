
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        if v.spell then
            v.spell_dict = {}
            for _, spell_id in ipairs(v.spell) do
                v.spell_dict[spell_id] = 1
            end
        end
        ret[k] = v
    end
    return ret
end

return M