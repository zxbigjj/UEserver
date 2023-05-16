local hotfix_utils = DECLARE_MODULE("hotfix_utils")

local role_hotfix = {
    [1] = "hotfix_role_test",
}
local server_hotfix = {
    [1] = "hotfix_server_test",
}

local max_role_version = #role_hotfix
local max_server_version = #server_hotfix

function hotfix_utils.hotfix_server_test()
end

function hotfix_utils.hotfix_role_test(role)
end

function hotfix_utils.get_max_role_version()
    return max_role_version
end

function hotfix_utils.get_max_server_version()
    return max_server_version
end

function hotfix_utils.do_role_hotfix(role)
    local version = role.db.hotfix_version
    while version < max_role_version do
        version = version + 1
        g_log:hotfix("BeginRoleHotfix", {uuid = role.uuid, version=version})
        local func = hotfix_utils[role_hotfix[version]]
        local result = func(role)
        role.db.hotfix_version = version
        g_log:hotfix("RoleHotfixDone", {uuid = role.uuid, version=version, result=result})
    end
end

function hotfix_utils.do_hotfix()
    -- online role
    for _, uuid in pairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        if role then
            hotfix_utils.do_role_hotfix(role)
        end
    end
end

skynet.timeout(1, function()
    hotfix_utils.do_hotfix()
end)

return hotfix_utils