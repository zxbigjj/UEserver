
local M = {}

--------------------服务器也需要， 改动要同步到服务器
--------------------服务器也需要， 改动要同步到服务器
--------------------服务器也需要， 改动要同步到服务器

function M:convert(data)
    local dict = {}
    for id, item in pairs(data) do
        for index, word in ipairs(item.words) do
            word = self:trim(word)
            word = string.lower(word)
            if word ~= "" then
                dict[word] = true
            end
        end
    end
    local ret = {}
    for word, _ in pairs(dict) do
        table.insert(ret, word)
    end
    table.sort(ret)
    return ret
end

function M:trim(s) 
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

return M
