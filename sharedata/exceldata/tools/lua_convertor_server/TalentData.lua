
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        if v.attr_list then
            v.attr_dict = {}
            for i, attr_name in ipairs(v.attr_list) do
                v.attr_dict[attr_name] = (v.attr_dict[attr_name] or 0) + v.attr_value_list[i]
            end
        end
        if v.extra_attr_list then
            v.extra_attr_dict = {}
            for i, attr_name in ipairs(v.extra_attr_list) do
                v.extra_attr_dict[attr_name] = (v.extra_attr_dict[attr_name] or 0) + v.extra_attr_value_list[i]
            end
        end
        ret[k] = v
    end
    return ret
end

return M