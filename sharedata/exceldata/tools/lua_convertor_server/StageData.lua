
local M = {}

function M:convert(data)
    local ret = {}
    ret["city_dict"] = {}
    for k, v in pairs(data) do
        if not ret["city_dict"][v.city_id] then
            ret["city_dict"][v.city_id] = {stage_list = {}, boss_stage_list = {}, last_stage = 0}
        end
        table.insert(ret["city_dict"][v.city_id].stage_list, k)
        if k > ret["city_dict"][v.city_id].last_stage then
            ret["city_dict"][v.city_id].last_stage = k
        end
        if v.is_boss then
            table.insert(ret["city_dict"][v.city_id].boss_stage_list, k)
        end
        for i = 1, 10 do
            if not v["e_soldier_num"..i] then break end
            v.enemy_num = v.enemy_num or {}
            v.enemy_military = v.enemy_military or {}
            v.enemy_num[i] = v["e_soldier_num"..i]
            v.enemy_military[i] = v["e_military_v"..i]
        end
        for i = 1, 30 do
            if not v["treasure_item"..i] then break end
            v.reward_list = v.reward_list or {}
            v.reward_list[i] = {item_id = v["treasure_item"..i], count = v["treasure_count"..i]}
        end
        ret[k] = v
    end
    for _, v in pairs(ret["city_dict"]) do
        table.sort(v.stage_list, function (a, b) return a < b end)
        table.sort(v.boss_stage_list, function (a, b) return a < b end)
    end
    return ret
end

return M