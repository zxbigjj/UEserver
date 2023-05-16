
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        if v.attr_list then
            v.attr_dict = {}
            for i, attr_name in pairs(v.attr_list) do
                v.attr_dict[attr_name] = v.attr_value_list[i]
            end
        end
        ret[k] = v
    end
    return ret
end

return M