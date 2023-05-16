local M = {}

function M:convert(data)
    local ret = {}
    ret["boy_name_list"] = {}
    ret["girl_name_list"] = {}
    for k,v in pairs(data) do
        table.insert(ret["boy_name_list"], v.boy_name)
        table.insert(ret["girl_name_list"], v.girl_name)
    end
    return ret
end

return M