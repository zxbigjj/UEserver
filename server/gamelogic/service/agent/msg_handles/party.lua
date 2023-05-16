local M = DECLARE_MODULE("msg_handles.party")

function M.c_party_start(role, args)
    if role.party:start_party(args.lover_id, args.party_type_id, args.is_private) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_party_set_receive_invite(role, args)
    if role.party:set_receive_invite(args.set_value) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_party_invite_role(role, args)
    if role.party:invite_friend(args.role_dict) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_party_refuse_invite(role, args)
    if role.party:refuse_invite(args.uuid) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_party_end(role, args)
    if role.party:host_end_party() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_party_random(role, args)
    local tip = role.party:get_random_party()
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_party_join(role, args)
    local ret = role.party:join_party(args.party_id, args.lover_id, args.gift_id)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_party_interrupt(role, args)
    local ret = role.party:interrupt_party(args.party_id)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_party_games(role, args)
    local tip = role.party:games(args.score)
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_party_receive_integral(role, args)
    if role.party:receive_integral() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_party_info(role, args)
    local tip = role.party:get_party_info(args.party_id)
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_party_get_enemy_list(role, args)
    local tip = role.party:get_enemy_list()
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_party_get_rank(role, args)
    local tip = role.party:get_rank()
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_find_party(role, args)
    local tip = role.party.find_party(args.uuid)
    return tip
end

function M.c_party_get_invite_list(role, args)
    local tip = role.party:get_receive_invite_list()
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_party_get_record_list(role, args)
    local ret = role.party:get_record_list()
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_buy_party_shop_item(role, args)
    if role.party:buy_party_shop_item(args.shop_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_refresh_party_shop(role, args)
    if role.party:refresh_party_shop() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

return M