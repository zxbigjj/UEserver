
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        if v.expend_item and v.diamond then
            v[1] = { }
            v[1][v.expend_item] = v.expend_item_num
            v[1][v.diamond] = v.diamond_num
            v[2] = { }
            v[2][v.expend_item] = v.expend_item_num
            v[2][v.diamond] = v.diamond_num
            v[3] = { }
            v[3][v.expend_item] = v.cross_expend_item_num
            v[3][v.diamond] = v.cross_diamond_num
            ret[k] = v
        end
    end
    return ret
end

return M