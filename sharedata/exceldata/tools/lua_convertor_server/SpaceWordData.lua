
local M = {}

--------------------服务器也需要， 改动要同步到服务器
--------------------服务器也需要， 改动要同步到服务器
--------------------服务器也需要， 改动要同步到服务器


function M:convert(data)
    local dict = {}
    for id, item in pairs(data) do
        if item.word then
            dict[item.word] = true
        end
    end
    dict[" "] = true  --空格特殊处理
    local ret = {}
    for word, _ in pairs(dict) do
        table.insert(ret, word)
    end
    table.sort(ret)
    return ret
end

return M
