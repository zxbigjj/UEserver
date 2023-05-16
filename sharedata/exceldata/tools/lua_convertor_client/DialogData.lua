local M = {}

function M:convert(data)
    local ret = {}
    ret["dialog_group"] = {}
    for k,v in pairs(data) do
        ret[k] = v
        ret["dialog_group"][v.group_id] = ret["dialog_group"][v.group_id] or {}
        table.insert(ret["dialog_group"][v.group_id], v)
    end
    for _, group in pairs(ret["dialog_group"]) do
        table.sort(group, function (dialog1, dialog2)
            return dialog1.id < dialog2.id
        end)
    end
    return ret
end

return M