local M = DECLARE_MODULE("msg_handles.stage")

function M.c_stage_fight(role, args)
    local ret = role.stage:stage_fight()
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_boss_stage_fight(role, args)
    local ret = role.stage:boss_stage_fight(args.stage_id)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_sweep_boss_stage(role, args)
    local ret = role.stage:sweep_boss_stage(args.stage_id, args.is_first)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_reset_boss_stage(role, args)
    if role.stage:reset_boss_stage(args.stage_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_stage_first_reward(role, args)
    if role.stage:get_stage_first_reward(args.stage_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_add_action_point(role, args)
    if role.stage:use_action_point_item(args.item_count) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_city_star_reward(role, args)
    if role.stage:get_city_star_reward(args.city_id, args.reward_index) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_city_all_reward(role, args)
    local ret
    if args.city_id then
        ret = role.stage:get_city_all_reward(args.city_id)
    else
        ret = role.stage:get_all_city_reward()
    end
    if ret then
        return {errcode = g_tips.ok, item_list = ret}
    end
    return g_tips.error_resp
end

function M.c_get_country_occupy_reward(role, args)
    if role.stage:get_country_occupy_reward(args.country_id, args.reward_index) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_city_resource(role, args)
    if role.stage:get_city_resource() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_manage_city(role, args)
    if role.stage:manage_city(args.city_id, args.manager_type, args.manager_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_stage_fight_end(role, args)
    role:give_fight_reward()
end

function M.c_enter_stage(role, args)
    if role.stage:enter_stage(args.stage_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

return M