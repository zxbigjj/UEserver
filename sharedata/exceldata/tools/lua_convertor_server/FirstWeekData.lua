local M = {}

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        local task = {}
        for _, task_id in ipairs(v.first_task_id) do
            table.insert(task, task_id)
        end
        for _, task_id in ipairs(v.second_task_id) do
            table.insert(task, task_id)
        end
        for _, task_id in ipairs(v.third_task_id) do
            table.insert(task, task_id)
        end
        v.frist_task_id = nil
        v.second_task_id = nil
        v.third_task_id = nil
        v.task_id_list = task
        ret[k] = v
    end
    return ret
end

return M