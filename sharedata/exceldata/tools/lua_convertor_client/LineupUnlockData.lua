local M = {}
local kHeroType = 1
function M:convert(data)
    local ret = {}
    local type_to_id_list = {}
    for k, v in pairs(data) do
    	if not type_to_id_list[v.type] then type_to_id_list[v.type] = {} end
    	table.insert(type_to_id_list[v.type], k)
        ret[k] = v
    end
    for _, list in ipairs(type_to_id_list) do
    	table.sort(list, function (v1, v2)
    		return v1 < v2
    	end)
    end
    ret.type_to_id_list = type_to_id_list
    return ret
end

return M