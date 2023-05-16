
local M = {}

function M:convert(data)
    local ret = {}
    ret["task_dict"] = {}
    for k, v in pairs(data) do
        ret["task_dict"][v.task_type] = ret["task_dict"][v.task_type] or {}
        ret["task_dict"][v.task_type][v.finish_order] = k
        ret[k] = v
    end
    return ret
end

return M