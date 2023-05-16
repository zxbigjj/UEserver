
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.suit_dict = {}
        if v.attr_list then
            local attr_dict = {}
            for i, attr_name in ipairs(v.attr_list) do
                attr_dict[attr_name] = v.attr_list_value[i]
            end
            v.suit_dict[2] = attr_dict
        end
        if v.attr1_list then
            local attr_dict = {}
            for i, attr_name in ipairs(v.attr1_list) do
                attr_dict[attr_name] = v.attr1_list_value[i]
            end
            v.suit_dict[3] = attr_dict
        end
        if v.attr2_list then
            local attr_dict = {}
            for i, attr_name in ipairs(v.attr2_list) do
                attr_dict[attr_name] = v.attr2_list_value[i]
            end
            v.suit_dict[4] = attr_dict
        end
        ret[k] = v
    end
    return ret
end

return M