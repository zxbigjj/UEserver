local M = DECLARE_MODULE("msg_handles.friend")

function M.c_send_friend_gift(role, args)
    if role.friend:send_gift(args.uuid) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_send_all_friend_gift(role, args)
    if role.friend:send_all_gift() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_all_friend_info(role, args)
    return role.friend:get_all_friend_info()
end

function M.c_receive_friend_gift(role, args)
    if role.friend:receive_gift(args.uuid) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_receive_all_friend_gift(role, args)
    if role.friend:receive_all_gift() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_receive_gift_info(role, args)
    return role.friend:get_all_receive_gift_info()
end

function M.c_confirm_friend_apply(role, args)
    local ret = role.friend:confirm_friend_apply(args.uuid)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_confirm_all_friend_apply(role, args)
    local ret = role.friend:confirm_all_friend_apply()
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_apply_friend(role, args)
    local ret = role.friend:add_friend_apply(args.uuid)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_friend_apply_list(role, args)
    return role.friend:get_all_friend_apply_list()
end

function M.c_delete_friend(role, args)
    if role.friend:delete_friend_operat(args.uuid) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_add_friend_to_blacklist(role, args)
    if role.friend:add_friend_to_blacklist(args.uuid) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_remove_friend_in_blacklist(role, args)
    local ret = role.friend:remove_friend_in_blacklist(args.uuid)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_remove_all_friend_in_blacklist(role, args)
    if role.friend:remove_all_friend_in_blacklist() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_delete_friend_in_blacklist(role, args)
    if role.friend:delete_friend_in_blacklist(args.uuid) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_delete_all_friend_in_blacklist(role, args)
    if role.friend:delete_all_friend_in_blacklist() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_all_blacklist_friend(role, args)
    return role.friend:get_all_blacklist_friend()
end

function M.c_refuse_friend_apply(role, args)
    if role.friend:refuse_friend_apply(args.uuid) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_refuse_all_friend_apply(role, args)
    role.friend:refuse_all_friend_apply()
    return g_tips.ok_resp
end

function M.c_get_recommend_friend(role, args)
    return role.friend:get_recommend_friend()
end

function M.c_get_lineup(role, args)
    local ret = role.friend:get_role_lineup(args.uuid)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_fight_with_friend(role, args)
    local ret = role.friend:fight_with_friend(args.uuid)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_self_info(role, args)
    return role.friend:get_self_info()
end

function M.c_send_mail_to_friend(role, args)
    if role.friend:send_mail_to_friend(args.uuid, args.msg) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_search_friend(role, args)
    local ret = role.friend:search_friend(args.uuid)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

return M