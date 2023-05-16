local M = {}

function myerror(format, ...)
    error(string.format('\n\n===> '..format..'\n', ...))
end

function M:convert(table)
    for id, data in pairs(table) do
        local func_id = data.func_id
        local guide_id = data.start_guide_group
        if not func_id and not guide_id then
            myerror("func_id and start_guide_group must have one, id: %s", id)
        end
        if func_id and guide_id then
            myerror("func_id and start_guide_group can only fill one, id: %s", id)
        end
    end
    return table
end

return M