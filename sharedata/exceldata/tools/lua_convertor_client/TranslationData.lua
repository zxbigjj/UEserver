
local M = {}

function M:convert(data)
    local ret = {lua = {}, ui = {}, excel = {}}
    for id, item in pairs(data) do
        local text_type
        if id >=100000 and id < 200000 then
            text_type = "lua"
        elseif id >= 200000 and id < 300000 then
            text_type = "ui"
        else
            text_type = "excel"
        end
        if item.count and item.count > 0 then
            ret[text_type][item.raw] = {
                chs = item.chs,
                cht = item.cht,
                eng = item.eng,
            }
        end
    end
    return ret
end

return M