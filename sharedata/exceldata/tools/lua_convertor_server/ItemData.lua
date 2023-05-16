local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.max_plus = 99999999
        if v.attr_list then
            v.attr_dict = {}
            for i, attr_name in ipairs(v.attr_list) do
                v.attr_dict[attr_name] = v.attr_list_value[i]
            end
        end
        if v.sub_type == 102 then
            if v.add_exp and not v.add_attr then
                v.lover_exp = true
            elseif not v.add_exp and v.add_attr then
                v.lover_attr = true
            elseif v.sex and v.attr_list then
                v.lover_fashion = true
            end
        end
        if v.item_type == 4 then
            v.max_plus = 1
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
        if v.synthesize_count then
            if v.equipment then
                v.compose_item = v.equipment
            end
            if v.hero then
                v.compose_item = v.hero
            end
            if v.lover then
                v.compose_item = v.lover
            end
        end
        if v.item_weight_list then
            v.weight_table = {}
            v.total_weight = 0
            for key, weight in ipairs(v.item_weight_list) do
                v.weight_table[key] = weight
                v.total_weight = v.total_weight + weight
            end
        end
        if v.item_type == 8 then
            if v.add_role_attr_name_list then
                v.add_role_attr_dict = {}
                for i = 1, #v.add_role_attr_name_list do
                    v.add_role_attr_dict[v.add_role_attr_name_list[i]] = v.add_role_attr_value_list[i]
                end
            end
            if v.add_hero_attr_name_list then
                v.add_hero_attr_dict = {}
                for i = 1, #v.add_hero_attr_name_list do
                    v.add_hero_attr_dict[v.add_hero_attr_name_list[i]] = v.add_hero_attr_value_list[i]
                end
            end
            if v.sub_type == 801 or v.sub_type == 802 then
                if not v.validity_period then
                    error("\n\n===> [title] validity_period is empty, item_id: "..v.id.."\n")
                end
                if v.validity_period < 1 then
                    error("\n\n===> [title] validity_period is invalid, item_id: "..v.id..", validity_period: "..v.validity_period.."\n")
                end
                v.validity_period_sec = v.validity_period * 24 * 60 * 60
            end
        end
        ret[k] = v
    end
    return ret
end

return M