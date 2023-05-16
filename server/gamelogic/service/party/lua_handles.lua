local lua_handles = DECLARE_MODULE("lua_handles")
local party_utils = require("party_utils")

function lua_handles.lc_get_party_info(data)
    local party_cls = party_utils.get_party_cls(data.party_id)
    if not party_cls then return end
    return party_cls.info.party_info
end

function lua_handles.lc_random_get_party(data)
    return party_utils.random_get_party(data.uuid)
end

function lua_handles.lc_find_party(data)
    if not data.uuid then return end
    return party_utils.find_party(data.uuid)
end

function lua_handles.lc_add_party(data)
    return party_utils.add_party(data.party_info, data.is_private)
end

function lua_handles.lc_end_party(data)
    local party_cls = party_utils.get_party_cls(data.party_id)
    if not party_cls then return end
    return party_cls:party_end(data.end_type, data.enemy_info)
end

function lua_handles.lc_join_party(data)
    local party_cls = party_utils.get_party_cls(data.party_id)
    if not party_cls then return end
    return party_cls:add_guests(data.guests_info)
end

function lua_handles.ls_update_lover_level(data)
    local party_cls = party_utils.get_party_cls(data.party_id)
    if not party_cls then return end
    party_cls:update_lover_level(data.value)
end

function lua_handles.lc_games_score(data)
    local party_cls = party_utils.get_party_cls(data.party_id)
    if not party_cls then return end
    return party_cls:games_score(data.uuid, data.integral)
end

function lua_handles.lc_party_receive_integral(data)
    local party_cls = party_utils.get_party_cls(data.party_id)
    if not party_cls then return end
    return party_cls:receive_integral()
end

return lua_handles