local M = DECLARE_MODULE("msg_handles.hunt")

function M.c_set_hunt_hero(role, args)
    if role.hunt:set_hunt_hero(args.ground_id, args.hero_list) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_hunt_ground_animal(role, args)
    local ret = role.hunt:hunt_ground_animal(args.ground_id, args.shoot_result)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_give_up_hunt_ground(role, args)
    local ret = role.hunt:give_up_hunt_ground()
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_hunt_hero_recover(role, args)
    if role.hunt:hunt_hero_recover(args.hero_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_first_reward(role, args)
    if role.hunt:get_first_reward(args.ground_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_add_hunt_num(role, args)
    if role.hunt:add_hunt_num() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_all_rare_animal_data(role, args)
    local ret = role.hunt:get_all_rare_animal_data()
    return {rare_animal = ret}
end

function M.c_get_rare_animal_data(role, args)
    local ret = role.hunt:get_rare_animal_data(args.animal_id)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_start_hunt_rare_animal(role, args)
    if role.hunt:start_hunt_rare_animal(args.animal_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_hunt_rare_animal(role, args)
    local ret = role.hunt:hunt_rare_animal(args.animal_id, args.shoot_result)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_hunt_inspire(role, args)
    if role.hunt:hunt_inspire(args.animal_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_listen_rare_animal(role, args)
    if role.hunt:listen_rare_animal(args.animal_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_hunt_point_exchange(role, args)
    if role.hunt:hunt_point_exchange(args.shop_id, args.shop_num) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_start_hunt_ground(role, args)
    role.hunt:start_hunt_ground()
end

function M.c_end_hunt_ground(role, args)
    role.hunt:end_hunt_ground()
end

return M