
local M = {}

function M:convert(data)
    local ret = {}
    ret["male_role_list"] = {}
    ret["female_role_list"] = {}
    for k, v in pairs(data) do
        table.insert(v.sex == 1 and ret["male_role_list"] or ret["female_role_list"], v)
        ret[k] = v
    end
    table.sort(ret["male_role_list"], function (role1, role2)
        return role2.role_look_id > role1.role_look_id
    end)
    return ret
end

return M