
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
    	local level_limit = v.level_limit
    	v.cost_num = {}
    	for i=1, level_limit do
    		local val = v.param_a * i * i + v.param_b * i + v.param_c
    		v.cost_num[i] = math.ceil(val)
    	end
        ret[k] = v
    end
    return ret
end

return M