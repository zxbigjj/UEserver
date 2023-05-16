
local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        if v.consume_item then
            ret[v.consume_item] = v
        end
    end
    return ret
end

return M