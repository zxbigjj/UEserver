local M = {}

function myerror(format, ...)
    error(string.format('\n\n===> '..format..'\n', ...))
end

function check_for_errors(data)
    local rewards_dict = {}
    for _, v in pairs(data) do 
        for _, reward_id in ipairs(v.activity_reward_list) do
            if rewards_dict[reward_id] then
                myerror('duplicate reward_id in activity_reward_list: reward_id: %d', reward_id)
            else
                rewards_dict[reward_id] = true
            end
        end
    end
    return data
end

function M:convert(data)
    return check_for_errors(data)
end

return M