
local M = {}

function M:convert(data)
    local ret = {}
    ret["info_item_list"] = {}
    ret["attr_item_list"] = {}
    ret["attr_item_list"]["random"] = {}
    for k, v in pairs(data) do
        if v.item_type == 4 then
            v.refine_level_list = v.refine_level_list or {}
            v.refine_spell_list = v.refine_spell_list or {}
            if v.part_index then
                if v.part_index == 5 or v.part_index == 6 then
                    v.is_treasure = true
                end
            else
                if v.add_exp then
                    v.is_treasure = true
                end
            end
        end
        if v.show_in_info then
            table.insert(ret["info_item_list"], v)
        end
        if v.random_attr_list then
            if #v.random_attr_list == 1 then
                ret["attr_item_list"][v.random_attr_list[1]] = ret["attr_item_list"][v.random_attr_list[1]] or {}
                table.insert(ret["attr_item_list"][v.random_attr_list[1]], v)
            else
                table.insert(ret["attr_item_list"]["random"], v)
            end
        end
        ret[k] = v
    end
    table.sort(ret["info_item_list"], function (item1, item2)
        return item2.id > item1.id
    end)
    return ret
end

return M