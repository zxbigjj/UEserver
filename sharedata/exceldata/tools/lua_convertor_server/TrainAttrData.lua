
local M = {}

function M:convert(data)
    local ret = {}
    ret["id_list"] = {[1] = {}, [2] = {}, [3] = {}}
    for k, v in pairs(data) do
        if v.cost_star == 3 then
            table.insert(ret["id_list"][1], k)
        elseif v.cost_star == 6 then
            table.insert(ret["id_list"][2], k)
        elseif v.cost_star == 9 then
            table.insert(ret["id_list"][3], k)
        end
        ret[k] = v
    end
    return ret
end

return M