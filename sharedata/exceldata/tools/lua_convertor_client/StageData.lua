local M = {}
local star_num_each_city = 3
local max_e_solider_count = 8
local max_treasure_item_count = 3
function M:convert(data)
    local ret = {}
    ret.city_dict = {}
    local city_dict = ret.city_dict
    ret.city_max_star_num = {}
    local city_max_star_num = ret.city_max_star_num
    ret.city_boss_stage = {}
    local city_boss_stage = ret.city_boss_stage
    local max_star_num = 0
    for k,v in pairs(data) do
        ret[k] = v
        if v.after_dialog_id and v.trigger_event_id then
            print(k)
            error("both after_dialog_id and trigger_event_id")
        end
        if v.city_id then
            if not city_dict[v.city_id] then
                city_dict[v.city_id] = {}
            end
            table.insert(city_dict[v.city_id], v.id)
        end
        if v.is_boss then
            if not city_boss_stage[v.city_id] then city_boss_stage[v.city_id] = {} end
            table.insert(city_boss_stage[v.city_id], v.id)
            max_star_num = city_max_star_num[v.city_id] or 0
            max_star_num = max_star_num + star_num_each_city
            city_max_star_num[v.city_id] = max_star_num
        end
        self:GatherList(v, "e_soldier_num", "enemy_num", max_e_solider_count)
        self:GatherList(v, "e_military_v", "enemy_military", max_e_solider_count)
        self:GatherDict(v, "treasure_item", "treasure_count", "treasure_dict", max_treasure_item_count)
    end
    for k, city_list in pairs(city_dict) do
        table.sort(city_list, function (id1, id2)
            return id1 < id2
        end)
    end
    
    for k,city_list in pairs(city_boss_stage) do
        table.sort(city_list, function (id1, id2)
            return id1 < id2
        end)
    end
    return ret
end

function M:GatherList(data, ori_key, result_key, max_count)
    local tb = {}
    local key
    for i = 1, max_count do
        key = ori_key .. i
        local v = data[key]
        if not v then break end
        table.insert(tb, v)
    end
    if not next(tb) then return end
    data[result_key] = tb
end

function M:GatherDict(data, ori_key_name, ori_value_name, result_key, max_count)
    local tb = {}
    local key_key
    local value_key
    local key
    local value
    for i = 1, max_count do
        key_key = ori_key_name .. i
        value_key = ori_value_name .. i
        key = data[key_key]
        if not key then break end
        value = data[value_key]
        tb[key] = value
    end
    if not next(tb) then return end
    data[result_key] = tb
end

return M