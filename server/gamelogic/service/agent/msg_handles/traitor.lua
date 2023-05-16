local M = DECLARE_MODULE("msg_handles.traitor")

function M.c_challenge_traitor(role, args)
    local ret, tips = role.traitor:challenge_traitor(args.traitor_guid, args.attack_type)
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return {tips = tips, errcode = g_tips.error}
end

function M.c_share_traitor(role, args)
    if role.traitor:share_traitor() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_add_traitor_challenge_ticket(role, args)
    if role.traitor:add_challenge_ticket(args.item_count) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_traitor_list(role, args)
    local ret = role.traitor:get_traitor_list()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_feats_reward(role, args)
    local ret = role.traitor:get_feats_reward(args.reward_id)
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_buy_traitor_shop_item(role, args)
    if role.traitor:buy_shop_item(args.shop_id, args.shop_num) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_traitor_set_auto_kill(role, args)
    if role.traitor:set_auto_kill_traitor(args.quality_dict, args.is_share, args.is_cost) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_traitor_info(role, args)
    local ret = role.traitor:get_traitor_info(args.traitor_guid)
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_traitor_max_hurt_rank(role, args)
    local ret = role.traitor:get_traitor_max_hurt_rank()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_cross_max_hurt_rank(role, args)
    local ret = role.traitor:get_cross_max_hurt_rank()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_traitor_boss_data(role, args)
    local ret = role.traitor:get_traitor_boss_data()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_enter_traitor_boss(role, args)
    role.traitor:enter_traitor_boss()
end

function M.c_quit_traitor_boss(role, args)
    role.traitor:quit_traitor_boss()
end

function M.c_challenge_traitor_boss(role, args)
    local ret = role.traitor:challenge_traitor_boss()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_traitor_boss_dynasty_rank(role, args)
    local ret = role.traitor:get_traitor_boss_dynasty_rank(args.is_cross)
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_traitor_boss_reward(role, args)
    local ret = role.traitor:get_traitor_boss_reward(args.reward_id)
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_buy_traitor_boss_challenge_num(role, args)
    local ret = role.traitor:buy_traitor_boss_challenge_num(args.buy_num)
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_traitor_boss_record(role, args)
    local ret = role.traitor:get_traitor_boss_record()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_cross_traitor_boss_data(role, args)
    local ret = role.traitor:get_cross_traitor_boss_data()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_enter_cross_traitor_boss(role, args)
    role.traitor:enter_cross_traitor_boss()
end

function M.c_quit_cross_traitor_boss(role, args)
    role.traitor:quit_cross_traitor_boss()
end

function M.c_cross_traitor_boss_occupy_pos(role, args)
    local ret = role.traitor:cross_traitor_boss_occupy_pos(args.pos_id)
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

------------------------------------------------------- rank
function M.c_get_feats_rank_list(role, args)
    local tip = role.traitor:get_feats_rank()
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_get_cross_feats_rank_list(role, args)
    local tip = role.traitor:get_cross_feats_rank()
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_get_hurt_rank_list(role, args)
    local tip = role.traitor:get_hurt_rank()
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_get_cross_hurt_rank_list(role, args)
    local tip = role.traitor:get_cross_hurt_rank()
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_get_traitor_boss_honour_rank_list(role, args)
    local tip = role.rank:get_traitor_boss_honour_rank_list()
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_get_traitor_boss_hurt_rank_list(role, args)
    local tip = role.rank:get_traitor_boss_hurt_rank_list()
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_get_cross_traitor_honour_rank_list(role, args)
    local tip = role.rank:get_cross_traitor_honour_rank_list()
    if tip then
        return tip
    end
    return g_tips.error_resp
end

-------------------------------------------------------

return M