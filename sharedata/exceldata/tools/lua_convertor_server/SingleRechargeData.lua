local M = {}

function myerror(format, ...)
    error(string.format('\n\n===> '..format..'\n', ...))
end

function convert_luxury_check_in_activity(datas)
    for id, data in pairs(datas) do
        if type(id) ~= 'number' or not data.mark then goto continue end
        data.recharge_id = data.recharge_rank
        if data.reset_cycle ~= 1 and data.reset_cycle ~= 7 then
            myerror("reset_cycle invalid: '%d', it is should be 1 or 7", data.reset_cycle)
        end
        local reward_dict = {}
        for _, reward_id in ipairs(data.reward_list) do
            if reward_dict[reward_id] then
                myerror("[luxury_check_in] reward_id should be different, key: %d", id)
            else
                reward_dict[reward_id] = true
            end
        end
        ::continue::
    end
    return datas
end

function convert_accumulated_recharge_activity(datas)
    local id_list = {}
    for id, data in pairs(datas) do
        if data.is_accumulated_recharge_activity then
            table.insert(id_list, id)
        end
    end
    if #id_list == 0 then
        myerror("accumulated_recharge_activity should be at least one")
    end
    table.sort(id_list, function(left_id, right_id) return left_id < right_id end)
    local data = datas[id_list[1]]
    data.id_list = id_list
    data.duration_sec = data.duration_days * 24 * 60 * 60
    data.reserve_sec = data.reserve_days * 24 * 60 * 60
    data.interval_sec = data.interval_days * 24 * 60 * 60
    data.recharge_amount_list = {}
    for _, id in ipairs(id_list) do
        table.insert(data.recharge_amount_list, datas[id].recharge_amount)
    end
    datas.accumulated_recharge_activity = data
end

function M:convert(datas)
    convert_accumulated_recharge_activity(datas)
    convert_luxury_check_in_activity(datas)
    local recharge_dict = {} -- key: recharge_id, value: id_list
    for id, data in pairs(datas) do
        if type(id) ~= 'number' or not data.mark then goto continue end
        recharge_dict[data.recharge_id] = recharge_dict[data.recharge_id] or {}
        table.insert(recharge_dict[data.recharge_id], id)
        ::continue::
    end
    for recharge_id, id_list in pairs(recharge_dict) do
        table.sort(recharge_dict[recharge_id], function(id1, id2) return id1 < id2 end)
    end
    for _, id_list in pairs(recharge_dict) do
        for i = 1, #id_list do
            datas[id_list[i]].next_id = id_list[i + 1] or id_list[1]
        end
    end
    datas.recharge_dict = recharge_dict
    return datas
end

return M