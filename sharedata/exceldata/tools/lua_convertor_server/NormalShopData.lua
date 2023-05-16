local M = {}

function M:convert(data)
    for k, v in pairs(data) do
        if (not v.discount or not v.discount_num) and not v.gift_limit_num then
            v.discount = {}
            v.discount_num = {}
        end
    end
    return data
end

return M