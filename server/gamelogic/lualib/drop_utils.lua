local excel_data = require("excel_data")

local M = DECLARE_MODULE("drop_utils")

local function _push_item(item_list, item_id, count)
    local data = excel_data.ItemData[item_id]
    if data then
        if data.max_plus > 1 then
            table.insert(item_list, {item_id=item_id, count=count})
        else
            for i=1, count do
                table.insert(item_list, {item_id=item_id, count=1})
            end
        end
    else
        error("unknown item id:" .. item_id)
    end
end

local function _roll_group(item_list, group_id)
    local group_data = excel_data.DropGroupData[group_id]
    if not group_data then return end
    local total_weight = 0
    local weight_table = {}
    local extra_rate = {}
    for key, data in pairs(group_data) do
        total_weight = total_weight + data.weight
        weight_table[key] = data.weight
    end
    if not next(weight_table) then return end

    local rolled = group_data[math.roll(weight_table, total_weight)]
    local count = math.random(rolled.min_count, rolled.max_count)
    if rolled.drop_item then
        _push_item(item_list, rolled.drop_item, count)
    elseif rolled.drop_group then
        for i=1, count do
            _roll_group(item_list, rolled.drop_group)
        end
    else
        error("unknown drop id:" .. rolled.id)
    end
end

function M.roll_drop(drop_id)
    local drop_data = excel_data.DropData[drop_id]
    if not drop_data then return end
    local random = math.random
    local item_list = {}
    for _, data in pairs(drop_data) do
        if data.percent > 0 then
            for i=1, data.times do
                if random() <= data.percent then
                    local count = random(data.min_count, data.max_count)
                    if data.drop_item then
                        _push_item(item_list, data.drop_item, count)
                    elseif data.drop_group then
                        for i=1, count do
                            _roll_group(item_list, data.drop_group)
                        end
                    else
                        error("unknown drop type:" .. data.id)
                    end
                end
            end
        end
    end
    return item_list
end

return M