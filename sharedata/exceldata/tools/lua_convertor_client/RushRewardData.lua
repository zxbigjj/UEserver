
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.reward_range_list = {}
        local init_rank = 1
        for i, rank in ipairs(v.rank_gear) do
            local range_data = {}
            range_data.start_rank = i == 1 and init_rank or (v.rank_gear[i - 1] + 1)
            range_data.end_rank = rank
            range_data.rank_reward = v.rank_reward[i]
            table.insert(v.reward_range_list, range_data)
        end
        ret[k] = v
    end
    return ret
end

return M