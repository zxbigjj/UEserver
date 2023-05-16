local M = {}
function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        ret[k] = v
        for i, buy_num in ipairs(v.buy_num) do
        	if buy_num > 0 then
        		v.require_level = i - 1 -- vip0 对应 1
        		break
        	end
        end
    end
    return ret
end
return M