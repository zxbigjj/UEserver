
local M = {}

function M:convert(data)
    local ret = {item_dict = {}}
    for k, v in pairs(data) do
        v.total_progress = v.task_param[#v.task_param]
        if v.item_id then
            ret.item_dict[v.item_id] = true
        end
        ret[k] = v
    end
    return ret
end

return M