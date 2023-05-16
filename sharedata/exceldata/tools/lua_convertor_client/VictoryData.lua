local M = {}
function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.str_list = {}
        if v.remian_hp then
            for i, val in ipairs(v.remian_hp) do
                v.str_list[i] = string.format(v.str_format, v.remian_hp[i] * 100)
            end
        elseif v.death_num then
            for i, val in ipairs(v.death_num) do
                v.str_list[i] = string.format(v.str_format, v.death_num[i])
            end
        elseif v.round_num then
            for i, val in ipairs(v.round_num) do
                v.str_list[i] = string.format(v.str_format, v.round_num[i])
            end
        else
            for i = 1, 3 do
                v.str_list[i] = v.str_format
            end
        end
        ret[k] = v
    end
    return ret
end
return M