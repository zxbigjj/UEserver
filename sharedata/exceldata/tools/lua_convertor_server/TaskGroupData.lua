
local M = {}

function M:convert(data)
    local ret = {task_to_group = {}}
    for k, v in pairs(data) do
        v.task_dict = {}
        for index, task_id in ipairs(v.task_list) do
            v.task_dict[task_id] = index
            ret.task_to_group[task_id] = k
        end
        ret[k] = v
    end
    return ret
end

return M