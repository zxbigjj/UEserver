local M = {}

function M:convert(data)
    local type_to_task = {}
    for k, v in ipairs(data) do
        if not type_to_task[v.task_type] then type_to_task[v.task_type] = {} end
        table.insert(type_to_task[v.task_type], k)
    end
    data.type_to_task = type_to_task
    return data
end

return M