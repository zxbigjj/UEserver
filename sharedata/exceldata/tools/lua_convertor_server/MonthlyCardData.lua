local M = {}

function myerror(format, ...)
    error(string.format('\n\n===> '..format..'\n', ...))
end

function M:convert(table)
    local length = 0
    for id, data in pairs(table) do
        length = length + 1
        if data.type == 1 and not data.validity_period_day then
            myerror("monthly card needs to fill in the 'validity_period_day', id: %d", id)
        elseif data.type == 2 and data.validity_period_day then
            myerror("permanent card should not be filled the 'validity_period_day', id: %d", id)
        end
    end
    if length ~= 2 then
        myerror("there should be only two records, length: %d", length)
    end
    return table
end

return M