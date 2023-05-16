local M = DECLARE_MODULE("msg_handles.hero")

function M.c_upgrade_hero_level(role, args)
    if role.hero:upgrade_hero_level(args.hero_id, args.ten_level) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_hero_breakthrough(role, args)
    if role.hero:hero_breakthrough(args.hero_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_upgrade_hero_star_lv(role, args)
    if role.hero:upgrade_hero_star_lv(args.hero_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_upgrade_hero_destiny_lv(role, args)
    if role.hero:upgrade_hero_destiny_lv(args.hero_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_hero_recover(role, args)
    if role.hero:hero_recover(args.hero_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_give_hero_item(role, args)
    if role.hero:give_hero_item(args.hero_id, args.item_id, args.item_count) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_buy_hero_shop_item(role, args)
    if role.hero:buy_hero_shop_item(args.shop_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_refresh_hero_shop(role, args)
    if role.hero:refresh_hero_shop() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

---------------------------------------------------------   排行榜
--获取跨服战力排行榜
function M.c_get_cross_fight_score_rank_list(role, args)
    local tip = role.hero:get_rank()
    if tip then
        return tip
    end
    return g_tips.error_resp
end

--获取跨服帮力排行榜
function M.c_get_cross_score_rank_list(role, args)
    local tip = role.hero:get_cross_score_rank()
    if tip then
        return tip
    end
    return g_tips.error_resp
end

--获取跨服星星排行榜
function M.c_get_cross_stage_start_rank_list(role, args)
    local tip = role.hero:get_cross_stage_start_rank()
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_get_cross_hunt_rank_list(role, args)
    local tip = role.rank:get_cross_hunt_rank_list()
    -- print("++++++++ cross_hunt_rank_list rank: " .. json.encode(tip))
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_get_cross_train_rank_list(role, args)
    local tip = role.rank:get_cross_train_rank_list()
    -- print("++++++++ cross_train_rank rank: " .. json.encode(tip))
    if tip then
        return tip
    end
    return g_tips.error_resp
end

------------------------
function M.c_get_fight_score_rank_list(role, args)
    local tip = role.rank:get_fight_score_rank_list()
    -- print("++++++++ fight_score rank: " .. json.encode(tip))
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_get_score_rank_list(role, args)
    local tip = role.rank:get_score_rank_list()
    -- print("++++++++ score rank: " .. json.encode(tip))
    if tip then
        return tip
    end
    return g_tips.error_resp
end

function M.c_get_stage_star_rank_list(role, args)
    local tip = role.rank:get_stage_star_rank_list()
    -- print("++++++++ stage_start rank" .. json.encode(tip))
    if tip then
        return tip
    end
    return g_tips.error_resp
end

---------------------------------------------------------

return M