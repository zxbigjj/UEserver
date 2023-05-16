local M = {}

function myerror(format, ...)
    error(string.format('\n\n===> '..format..'\n', ...))
end

function check_for_errors(data)
    local all_reward_dict = {}
    for _, v in pairs(data) do
        for _, reward_id in ipairs(v.reward_list) do
            if all_reward_dict[reward_id] then
                myerror('duplicate reward_id(%d), field: "reward_list"', reward_id)
            else
                all_reward_dict[reward_id] = true
            end
        end
    end
    return data
end

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        if v.recharge_ids and v.recharge_times then
            v.recharge_dict = {}
            for i = 1, #v.recharge_ids do
                local reward_id = v.reward_list[i]
                local recharge_id = v.recharge_ids[i]
                local recharge_cnt = v.recharge_times[i]
                v.recharge_dict[recharge_id] = {reward = reward_id, count = recharge_cnt}
            end
        end
        ret[k] = v
    end
    return check_for_errors(ret)
end

return M