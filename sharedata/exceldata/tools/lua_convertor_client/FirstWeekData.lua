local M = {}
function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.task_id_list = {}
        v.task_id_list[1] = v.first_task_id
        v.task_id_list[2] = v.second_task_id
        v.task_id_list[3] = v.third_task_id
        ret[k] = v
    end
    return ret
end
return M