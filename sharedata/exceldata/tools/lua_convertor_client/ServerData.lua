local M = {}

function M:convert(data)
    local ret = {}
    ret["server_list"] = {}
    for k,v in pairs(data) do
        ret[k] = v
        if not ret["server_list"][v.partition] then
            ret["server_list"][v.partition] = {}
        end
        table.insert(ret["server_list"][v.partition], v)
    end
    for _,server_list in pairs(ret["server_list"]) do
        table.sort(server_list, function (server1, server2)
            return server1.build_time > server2.build_time
        end)
    end
    return ret
end

return M