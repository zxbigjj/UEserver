
local M = {}

function split(str, delimiter)
    if str == nil or str == '' then
        return {}
    end

    if delimiter == nil or delimiter == '' then
        return {str}
    end

    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function M:convert(data)
    for k, v in pairs(data) do
        v.name = split(v.name, ",")
    end
    return {
        [1] = {[1] = data[1].name, [2] = data[2].name},
        [2] = {[1] = data[3].name, [2] = data[4].name}
    }
end

return M