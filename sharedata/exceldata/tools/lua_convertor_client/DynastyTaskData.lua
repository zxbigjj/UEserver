local M = {}

function M:convert(data)
    local ret = {}
    ret["dynasty_task_list"] = {}
    local dynasty_task_with_type = {}
    for k,v in pairs(data) do
        dynasty_task_with_type[v.task_type] = dynasty_task_with_type[v.task_type] or {}
        table.insert(dynasty_task_with_type[v.task_type], v)
        ret[k] = v
    end
    for task_type, task_list in pairs(dynasty_task_with_type) do
        local task_data = {task_type = task_type, task_list = task_list}
        table.insert(ret["dynasty_task_list"], task_data)
    end
    table.sort(ret["dynasty_task_list"], function (data1, data2)
        return data1.task_type < data2.task_type
    end)
    return ret
end

return M