local M = DECLARE_MODULE("msg_handles.train")

function M.c_train_challenge_stage(role, args)
    local ret = role.train:train_challenge_stage(args.difficulty)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_train_quick_challenge(role, args)
    local ret = role.train:train_quick_challenge()
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_train_select_add_attr(role, args)
    if role.train:train_select_add_attr(args.index) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_train_reset_stage(role, args)
    if role.train:train_reset_stage() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_train_sweep_stage(role, args)
    local ret = role.train:train_sweep_stage()
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_train_buy_treasure(role, args)
    if role.train:train_buy_treasure() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_train_war_challenge(role, args)
    local ret = role.train:train_war_challenge(args.war_id)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_train_war_buy_fight_num(role, args)
    if role.train:train_war_buy_fight_num(args.num) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_train_buy_shop_item(role, args)
    if role.train:train_buy_shop_item(args.shop_id, args.shop_num) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

return M