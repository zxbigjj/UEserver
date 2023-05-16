local M = {}

function M:convert(data)
    local ret = {}
    ret["meet_list"] = {}
    for k,v in pairs(data) do
        if not ret["meet_list"][v.lover_id] then
            ret["meet_list"][v.lover_id] = {}
        end
        table.insert(ret["meet_list"][v.lover_id], v)
        ret[k] = v
    end
    for _, lover_meet_list in pairs(ret["meet_list"]) do
        table.sort(lover_meet_list, function (event1, event2)
            return event1.id < event2.id
        end)
        for index, meet_data in ipairs(lover_meet_list) do
            ret[meet_data.id]["meet_index"] = index
        end
    end
    return ret
end

return M