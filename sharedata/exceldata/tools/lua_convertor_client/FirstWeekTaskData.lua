local M = {}
function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
    	v.reward_list = {}
    	for i, id in ipairs(v.reward_id) do
    		table.insert(v.reward_list, {item_id = id, count = v.reward_count[i]})
    	end
        ret[k] = v
    end
    return ret
end
return M