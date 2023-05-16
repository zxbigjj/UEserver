
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        if v.add_attr_list then
            v.add_attr_dict = {}
            for i, attr_name in ipairs(v.add_attr_list) do
                v.add_attr_dict[attr_name] = v.add_attr_num_list[i]
            end
        end
        ret[k] = v
    end
    return ret
end

return M