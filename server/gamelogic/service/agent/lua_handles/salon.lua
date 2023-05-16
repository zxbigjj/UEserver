local salon_handles = DECLARE_MODULE("lua_handles.salon")
local offline_cmd = require("offline_cmd")

function salon_handles.ls_salon_pvp_results(uuid, data)
    local role = agent_utils.get_role(uuid)
    if role then
        role:salon_pvp_results(data.pvp_info)
    else
        offline_cmd.push_salon_pvp_results(uuid, {pvp_info = data.pvp_info})
    end
end

return salon_handles