local M = {}

function myerror(format, ...)
    error(string.format('\n\n=====> '..format..' <=====\n', ...))
end

function M:convert(data)
    local length = 0
    for _, _ in pairs(data) do
        length = length + 1
    end
    if length ~= 1 then
        myerror("there should be only one piece of data in the table: %d", length)
    end
    for k, v in pairs(data) do
        data.fund_data = {
            id = k,
            item_id = v.item_id
        }
    end
    return data
end

return M