local M = {}

function M:convert(data)
    local ret = {}
    ret["cost_list"] = {}
    for k,v in pairs(data) do
        if not ret["cost_list"][v.consume_item] then
            ret["cost_list"][v.consume_item] = {}
        end
        ret["cost_list"][v.consume_item] = v
        ret[k] = v
    end
    return ret
end

return M