
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        if k == "grab_init_blue_treasure_list" then
            v.item_dict = {}
            for _, item_id in ipairs(v.item_list) do
                v.item_dict[item_id] = true
            end
            v.item_list = nil
        end
        if k == "dynasty_compete_fight_day" then
            local tb_string = {}
            for _, v in ipairs(v.tb_string) do
                tb_string[v] = true
            end
            v.tb_string = tb_string
        end
        if k == "traitor_boss_open_day" then
            local tb_int = {}
            for _, v in ipairs(v.tb_int) do
                tb_int[tostring(v)] = true
            end
            v.tb_int = tb_int
        end
        if k == "questionnaire_reward" then
            local item_list = {}
            for i, item_id in ipairs(v.item_list) do
                table.insert(item_list, {item_id = item_id, count = v.count_list[i]})
            end
            v.item_list = item_list
        end
        if k == "bar_refresh_time_list" then
            local hour_dict = {}
            for i, hour in ipairs(v.tb_int) do
                hour_dict[hour] = i
            end
            v.hour_dict = hour_dict
        end
        ret[k] = v
    end
    return ret
end

return M