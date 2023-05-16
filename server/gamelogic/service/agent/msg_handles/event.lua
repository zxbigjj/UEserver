local M = DECLARE_MODULE("msg_handles.event")

---------------------------------------------------
-- world boss
function M.c_set_world_boss_hero(role, args) -- ok
    if role.event:set_world_boss_hero(args.map_id, args.hero_list) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_set_world_boss_hero_marching(role, args)
    local ret = role.event:set_world_boss_hero_marching()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_decline_world_boss_hero_marching_time(role, args)
    if role.event.decline_world_boss_hero_marching_time() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_recover_world_boss_hero(role, args) -- ok
    if role.event:recover_world_boss_hero(args.hero_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_world_boss_first_reward(role, args) -- ok
    if role.event:get_world_boss_first_reward(args.map_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_world_boss_data(role, args)
    local ret = role.event:get_world_boss_data()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_challenge_world_boss(role, args)       -- 缺数据,utils
    local ret = role.event:challenge_world_boss()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

return M
