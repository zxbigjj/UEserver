
local M = {}

function M:convert(data)
    local ret = {}
    ret.open_date_dict = {}
    for k, v in pairs(data) do
        v.difficult_dict = {}
        if v.difficult_list then
            for index, value in ipairs(v.difficult_list) do
                v.difficult_dict[value] = {
                    suggest_power = v.suggest_power[index],
                    drop_item_count = v.drop_item_count[index],
                    open_level = v.open_level[index],
                    victory_id = v.victory_list[index],
                    monster_level = v.monster_level_list[index]
                }
            end
        end
        if v.open_date then
            for index, date in ipairs(v.open_date) do
                if date == 0 then
                    date = 7
                end
                if not ret.open_date_dict[tostring(date)] then
                    ret.open_date_dict[tostring(date)] = {}
                end
                ret.open_date_dict[tostring(date)][k] = true
            end
        end
        v.open_level = v.open_level[1]
        v.difficult_list = nil
        v.suggest_power = nil
        v.drop_item_count = nil
        v.open_date = nil
        v.victory_list = nil
        ret[k] = v
    end
    return ret
end

return M