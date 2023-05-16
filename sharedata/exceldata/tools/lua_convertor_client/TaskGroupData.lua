local M = {}

function M:convert(data)
    local ret = {}
    for k,v in pairs(data) do
        ret[k] = v
        ret[k]["index_dict"] = {}
        for index, task_id in ipairs(v.task_list) do
            ret[k]["index_dict"][task_id] = index
        end
    end
    return ret
end

return M