local M = {}

function myerror(format, ...)
    error(string.format('\n\n===> '..format..'\n', ...))
end

function check_for_errors(data)
    for _, v in pairs(data) do
        if v.cost_item_type ~= 1 and v.cost_item_type ~= 2 then
            myerror('cost_item_type error(%d), should be 1 or 2', v.cost_item_type)
        end
    end
    return data
end

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.item_list = {{item_id = v.sell_item_id, count = v.sell_item_num}}
        ret[k] = v
    end
    return check_for_errors(ret)
end

return M