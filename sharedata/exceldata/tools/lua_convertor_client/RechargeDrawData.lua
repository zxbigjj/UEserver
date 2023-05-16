local M = {}

function M:convert(data)
    local ret = {}
    for i,v in ipairs(data) do
        ret[i] = v
        if v.activity_id then
            local key = "activity" .. v.activity_id
            if not ret[key] then
                ret[key] = {}
            end
            table.insert(ret[key], v.id)
        end
    end
    return ret
end

return M