local M = DECLARE_MODULE("msg_handles.treasure")

function M.c_get_grab_role_list(role, args)
    local ret = role.treasure:get_grab_role_list(args.treasure_id, args.fragment_id)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_clear_grab_role_list(role, args)
    role.treasure:clear_grab_role_list()
end

function M.c_grab_treasure(role, args)
    local ret = role.treasure:grab_treasure(args.uuid)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_grab_treasure_select_reward(role, args)
    local ret = role.treasure:grab_treasure_select_reward(args.reward_index)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_grab_treasure_five_times(role, args)
    local ret = role.treasure:grab_treasure_five_times(args.uuid)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_quick_grab_treasure(role, args)
    local ret = role.treasure:quick_grab_treasure(args.treasure_id, args.auto_use_item)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_treasure_compose(role, args)
    if role.treasure:treasure_compose(args.treasure_id, args.compose_count) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_treasure_smelt(role, args)
    if role.treasure:treasure_smelt(args.guid_list, args.treasure_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

return M