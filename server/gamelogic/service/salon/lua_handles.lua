local lua_handles = DECLARE_MODULE("lua_handles")
local salon_utils = require("salon_utils")

function lua_handles.lc_add_role(data)
    if not data.salon_id or not data.role_info then return end
    local salon_cls = salon_utils.get_salon_cls(data.salon_id)
    if not salon_cls then return end
    if not salon_cls:add_role(data.role_info) then return end
    return true
end

function lua_handles.lc_get_salon_pvp_record(data)
    if not data.day or not data.salon_id or not data.pvp_id then return end
    return salon_utils.get_salon_pvp_record(data.day, data.salon_id, data.pvp_id)
end

return lua_handles