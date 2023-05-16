local M = DECLARE_MODULE("lua_handles.traitor")

function M.ls_update_cross_traitor_data(uuid, data)
    local role = agent_utils.get_role(uuid)
    if role then
        role.traitor:update_cross_traitor_info(data)
    end
end

function M.lc_update_cross_traitor_fight(uuid, data)
    local role = agent_utils.get_role(uuid)
    if role then
        return role.traitor:update_cross_traitor_fight(data)
    end
end

return M