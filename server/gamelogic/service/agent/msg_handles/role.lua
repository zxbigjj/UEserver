local role_handle = DECLARE_MODULE("msg_handles.role")

function role_handle.c_gm(role, args)
    if __SERVER_DEBUG_FLAG then
        -- gm
        local name, args = args.cmd:match("([%w_]+)%s*(.*)")
        if not name then
            return
        end
        local agent_gm = require("agent_gm")
        agent_gm.on_gm(role.uuid, name, args)
        return
    end
end

function role_handle.c_handle_info(role, args)
    if role:handle_info(args.id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_publish_cmd(role, args)
    if role:publish_cmd(args.id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_use_hall_item(role, args)
    if role:use_hall_item(args.item_id, args.cmd_id, args.count) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_prison_torture(role, args)
    if role.prison:torture(args.torture_type, args.torture_num) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_send_chat_msg(role, args)
    local ret, tips_id = role.chat:send_chat_msg(args)
    if ret then
        return g_tips.ok_resp
    end
    return {errcode = g_tips.error, tips_id = tips_id}
end

function role_handle.c_complete_guide(role, args)
    if role.guide:complete_guide(args.guide_group_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_travel_area_unlock(role, args)
    if role.travel:area_unlock(args.area_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_random_travel(role, args)
    local tips = role.travel:random_travel()
    if tips then
        return tips
    end
    return g_tips.error_resp
end

function role_handle.c_assign_travel(role, args)
    local tips = role.travel:assign_travel(args.area_id)
    if tips then
        return tips
    end
    return g_tips.error_resp
end

function role_handle.c_travel_use_item(role, args)
    if role.travel:use_item() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_travel_luck_restore_set(role, args)
    if role.travel:luck_restore_set(args.set_value, args.set_item_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_travel_luck_restore(role, args)
    if role.travel:luck_restore(args.item_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_salon_dispatch_lover(role, args)
    if role.salon:dispatch_lover(args.salon_id, args.lover_id, args.attr_point_dict) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_salon_buy_attr_point(role, args)
    if role.salon:buy_attr_point() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_salon_receive_integral(role, args)
    if role.salon:receive_integral(args.salon_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_salon_get_pvp(role, args)
    local tips = role.salon:get_pvp_record(args.day, args.salon_id, args.pvp_id)
    if tips then
        return tips
    end
    return g_tips.error_resp
end

function role_handle.c_buy_salon_shop_item(role, args)
    if role.salon:buy_salon_shop_item(args.shop_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_refresh_salon_shop(role, args)
    if role.salon:refresh_salon_shop() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_salon_get_rank(role, args)
    local tips = role.salon:get_rank()
    if tips then
        return tips
    end
    return g_tips.error_resp
end

function role_handle.c_daily_dare_fight(role, args)
    local tips = role.daily_dare:dare(args.dare_id, args.difficult_id)
    if tips then
        return tips
    end
    return g_tips.error_resp
end

function role_handle.c_dare_tower_fight(role, args)
    local tips = role.dare_tower:dare(args.tower_id)
    if tips then
        return tips
    end
    return g_tips.error_resp
end

function role_handle.c_dare_tower_treasure_reward(role, args)
    if role.dare_tower:receive_treasure_reward(args.tower_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_check_in_monthly(role, args)
    if role.check_in_monthly:check_in(args.check_in_date) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_check_in_monthly_chest(role, args)
    if role.check_in_monthly:receive_chest_award(args.reward_pos) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_check_in_weekly(role, args)
    local ret = role.check_in_weekly:check_in(args.check_in_date)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function role_handle.c_get_task_reward(role, args)
    if role.task:get_task_reward() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_get_task_group_reward(role, args)
    if role.task:get_task_group_reward() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_get_achievement_reward(role, args)
    if role.achievement:get_achievement_reward(args.achievement_type) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_receive_active_task_reward(role, args)
    local ret = role.daily_active:receive_active_task_reward(args.task_id)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function role_handle.c_receive_active_chest_reward(role, args)
    if role.daily_active:receive_active_chest_reward(args.chest_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_modify_role_image(role, args)
    if role.base:modify_role_image(args.role_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_modify_role_name(role, args)
    local ret, name_repeat,maskWord = role.base:modify_role_name(args.name)
    if ret then
        return g_tips.ok_resp
    end
    return {errcode = g_tips.error, name_repeat = name_repeat,mask = maskWord}
end

function role_handle.c_modify_role_flag(role, args)
    if role.base:modify_role_flag(args.flag_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_first_week_recive_reward(role, args)
    if role.first_week:recive_task_reward(args.task_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_first_week_buy_half_sell(role, args)
    if role.first_week:buy_half_sell(args.day_index) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_first_week_buy_sell_item(role, args)
    if role.first_week:buy_sell_item(args.day_index, args.sell_id, args.buy_num) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_receive_vip_daily_gift(role, args)
    if role.vip:recive_daily_gift() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_buy_vip_sell_gift(role, args)
    if role.vip:buy_sell_gift(args.buy_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_buy_vip_shop_item(role, args)
    if role.vip:buy_vip_shop_item(args.shop_id, args.shop_num) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_buy_normal_shop_item(role, args)
    if role.normal_shop:buy_normal_shop_item(args.shop_id, args.shop_num) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_buy_crystal_shop_item(role, args)
    if role.crystal_shop:buy_crystal_shop_item(args.shop_id, args.shop_num) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function role_handle.c_get_rank_list(role, args)
    local ret = role.rank:get_rank_list(args.rank_id)
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function role_handle.c_publish_all_cmd(role, args)
    local ret = role.total_hall:publish_all_cmd()
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function role_handle.c_total_random_travel(role, args)
    local ret = role.travel:total_random_travel()
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function role_handle.c_set_language(role, args)
    if role.base:set_language(args.language) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

function role_handle.c_get_role_base_info(role, args)
    local ret = role.base:get_player_base_info(args.uuid)
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function role_handle.c_can_use_gift_key(role, args)
    local channel = role:get_channel()
    if not channel or not require("gift_key_utils").is_close(channel) then
        return {can_use = true}
    end
    return {can_use = false}
end

function role_handle.c_use_gift_key(role, args)
    local ok, data = require("gift_key_utils").use_gift_key(role, args.gift_key)
    if ok then
        return {success = ok, item_list = data}
    else
        return {success = ok, error_tips = data}
    end
end

function role_handle.c_get_vip_gift(role, args)
    if role.vip:get_vip_gift() then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

function role_handle.c_comment_setting(role, args)
    if role.base:comment_setting(args.not_comment) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

function role_handle.c_save_comment(role, args)
    if role.base:save_comment(args.comment_id, args.star_num, args.content) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

return role_handle