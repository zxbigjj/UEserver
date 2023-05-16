local M = {}

function M:convert(data)
    local ret = {}
	for k, v in pairs(data) do
		v["level_list"] = v.accum_level_list
		v["reward_list"] = v.accum_reward_list
		if v["reset_cycle"] == 1 then
			v["daily_limit_time"] = v["rechargeable_times"]
		elseif v["reset_cycle"] == 7 then
			v["month_limit_time"] = v["rechargeable_times"]
		end
		ret[k] = v
	end
    return ret
end

return M