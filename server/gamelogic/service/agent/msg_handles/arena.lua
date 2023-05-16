local M = DECLARE_MODULE("msg_handles.arena")

function M.c_get_arena_info(role, args)
    return role.arena:get_arena_info()
end

function M.c_arena_challenge(role, args)
    local ret = role.arena:arena_challenge(args.uuid)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_arena_select_reward(role, args)
    local ret = role.arena:arena_select_reward(args.reward_index)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_arena_quick_challenge(role, args)
    local ret = role.arena:arena_quick_challenge(args.uuid, args.challenge_count, args.auto_use_item)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_clear_arena_info(role, args)
    role.arena:clear_arena_info()
end

function M.c_arena_buy_shop_item(role, args)
    if role.arena:arena_buy_shop_item(args.shop_id, args.shop_num) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

return M