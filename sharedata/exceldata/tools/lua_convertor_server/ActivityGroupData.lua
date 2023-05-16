local M = {}

function myerror(format, ...)
    error(string.format('\n\n===> '..format..'\n', ...))
end

function check_for_errors(data)
    local details_dict = {}
    for _, v in pairs(data) do 
        for _, detail_id in ipairs(v.activity_detail_list) do
            if details_dict[detail_id] then
                myerror('duplicate detail_id in activity_detail_list, detail_id: %d', detail_id)
            else
                details_dict[detail_id] = true
            end
        end
    end
    return data
end

function M:convert(data)
    return check_for_errors(data)
end

return M