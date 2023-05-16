local M = {}

function myerror(format, ...)
    error(string.format('\n\n===> '..format..'\n', ...))
end

function check_for_errors(data)
    local all_content_dict = {}
    local all_discount_dict = {}
    local all_exchange_dict = {}
    for _, v in pairs(data) do
        for _, content_id in ipairs(v.welfare) do
            if all_content_dict[content_id] then
                myerror('duplicate content_id(%d), field: "welfare"', content_id)
            else
                all_content_dict[content_id] = true
            end
        end
        for _, content_id in ipairs(v.celebration) do
            if all_content_dict[content_id] then
                myerror('duplicate content_id(%d), field: "celebration"', content_id)
            else
                all_content_dict[content_id] = true
            end
        end
        for _, content_id in ipairs(v.activity) do
            if all_content_dict[content_id] then
                myerror('duplicate content_id(%d), field: "activity"', content_id)
            else
                all_content_dict[content_id] = true
            end
        end
        for _, discount_id in ipairs(v.discount) do
            if all_discount_dict[discount_id] then
                myerror('duplicate discount_id(%d), field: "discount"', discount_id)
            else
                all_discount_dict[discount_id] = true
            end
        end
        for _, exchange_id in ipairs(v.exchange) do
            if all_exchange_dict[exchange_id] then
                myerror('duplicate exchange_id(%d), field: "exchange"', exchange_id)
            else
                all_exchange_dict[exchange_id] = true
            end
        end
    end
    return data
end

function M:convert(data)
    return check_for_errors(data)
end

return M