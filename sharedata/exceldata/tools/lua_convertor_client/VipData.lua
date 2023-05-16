local M = {}

function M:convert(data)
    data.max_vip_level = #data
    for i = 0, #data do
    	data[i]["total_exp"] = i > 0 and data[i - 1].total_exp + data[i - 1].exp or 0
    end
    return data
end

return M