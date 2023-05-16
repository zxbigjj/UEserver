local M = {}
function M:convert(data)
    local ret = {}
    local cur_attr_list = {}
    for k, v in pairs(data) do
    	local is_add = true
    	for i, attr_name in ipairs(cur_attr_list) do
    		if attr_name == v.attr_name then
    			is_add = false
    		end
    	end
    	if is_add then
    		table.insert(cur_attr_list, v.attr_name)
    	end
        ret[k] = v
    end
    ret.attr_count = #cur_attr_list
    return ret
end
return M