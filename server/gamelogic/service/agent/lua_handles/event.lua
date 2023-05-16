local event_handle = DECLARE_MODULE("lua_handles.event")

local cluster_utils = require("msg_utils.cluster_utils")

function event_handle.ls_x_push_event(uuid, ev_type, subtype, value)
    local role = agent_utils.get_role(uuid)
    if role then
        role:push_event(ev_type, subtype, value)
    end
end

return event_handle