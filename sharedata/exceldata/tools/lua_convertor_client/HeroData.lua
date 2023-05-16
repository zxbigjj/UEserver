local M = {}

function M:convert(data)
    local ret = {}
    ret["hero_list"] = {}
    ret["power_list"] = {}
    for k,v in pairs(data) do
        if v.spell then
            v.spell_dict = {}
            for _, spell_id in ipairs(v.spell) do
                v.spell_dict[spell_id] = 1
            end
        end
        table.insert(v.tag,1,0)
        ret[k] = v
        if not ret["power_list"][v.power] then
            ret["power_list"][v.power] = {}
        end
        table.insert(ret["power_list"][v.power],v)
        for _,tag in pairs(v.tag) do
            if not ret["hero_list"][tag] then
                ret["hero_list"][tag] = {}
            end
            ret["hero_list"][tag][v.id] = v
        end
    end
    return ret
end

return M