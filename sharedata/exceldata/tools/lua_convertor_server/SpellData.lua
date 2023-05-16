
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        local count = 0
        for _, hit_info in ipairs(v.hit_tb) do
            count = count + hit_info.hurt_rate * 100
        end
        if count ~= 100 then
            error("hurt_rate 相加要等于一，SpellData，spell_id ".. k)
        end
        if v.modify_attr then
            v.modify_attr_dict = {}
            for _, attr_info in ipairs(v.modify_attr) do
                v.modify_attr_dict[attr_info.attr_name] = attr_info.attr_value
            end
        end
        ret[k] = v
    end
    return ret
end

return M