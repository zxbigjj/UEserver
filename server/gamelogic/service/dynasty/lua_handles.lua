local dynasty = require("dynasty")
local dynasty_compete = require("dynasty_compete")
local dynasty_rank = require("dynasty_rank")
local dynasty_utils = require("dynasty_utils")

local lua_handles = DECLARE_MODULE("lua_handles")

function lua_handles.ls_refresh_dynasty(...)
    dynasty:refresh_dynasty(...)
end

function lua_handles.lc_login_dynasty(...)
    return dynasty:login_dynasty(...)
end

function lua_handles.ls_logout_dynasty(...)
    dynasty:logout_dynasty(...)
end

function lua_handles.ls_online_dynasty(...)
    dynasty:online_dynasty(...)
end

function lua_handles.lc_get_dynasty_id(...)
    return dynasty:get_dynasty_id(...)
end

function lua_handles.lc_get_dynasty_name(...)
    return dynasty:get_dynasty_name(...)
end

function lua_handles.lc_seek_dynasty(...)
    return dynasty:seek_dynasty(...)
end

function lua_handles.lc_create_dynasty(...)
    return dynasty:create_dynasty(...)
end

function lua_handles.lc_get_dynasty_list(...)
    return dynasty:get_dynasty_list(...)
end

function lua_handles.lc_apply_dynasty(...)
    return dynasty:apply_dynasty(...)
end

function lua_handles.ls_cancel_apply_dynasty(...)
    dynasty:delete_role_apply(...)
end

function lua_handles.lc_get_dynasty_base_info(...)
    return dynasty:get_dynasty_base_info(...)
end

function lua_handles.lc_get_dynasty_member_info(...)
    return dynasty:get_dynasty_member_info(...)
end

function lua_handles.lc_get_dynasty_apply_info(...)
    return dynasty:get_dynasty_apply_info(...)
end

function lua_handles.lc_agree_apply_dynasty(...)
    return dynasty:agree_apply_dynasty(...)
end

function lua_handles.lc_refuse_apply_dynasty(...)
    return dynasty:refuse_apply_dynasty(...)
end

function lua_handles.lc_join_dynasty(...)
    return dynasty:join_dynasty(...)
end

function lua_handles.ls_quit_dynasty(...)
    dynasty:quit_dynasty(...)
end

function lua_handles.lc_get_dynasty_rank(...)
    return dynasty:get_dynasty_rank(...)
end

function lua_handles.lc_modify_dynasty_badge(...)
    return dynasty:modify_dynasty_badge(...)
end

function lua_handles.lc_modify_dynasty_name(...)
    return dynasty:modify_dynasty_name(...)
end

function lua_handles.lc_modify_dynasty_notice(...)
    return dynasty:modify_dynasty_notice(...)
end

function lua_handles.lc_modify_dynasty_declaration(...)
    return dynasty:modify_dynasty_declaration(...)
end

function lua_handles.lc_kick_out_dynasty(...)
    return dynasty:kick_out_dynasty(...)
end

function lua_handles.lc_appoint_dynasty_member(...)
    return dynasty:appoint_dynasty_member(...)
end

function lua_handles.lc_dissolve_dynasty(...)
    return dynasty:dissolve_dynasty(...)
end

function lua_handles.ls_update_dynasty_role_info(...)
    dynasty:update_dynasty_role_info(...)
end

function lua_handles.lc_check_is_init_badge(...)
    return dynasty:check_is_init_badge(...)
end

function lua_handles.lc_get_dynasty_build_info(...)
    return dynasty:get_dynasty_build_info(...)
end

function lua_handles.lc_dynasty_build(...)
    return dynasty:dynasty_build(...)
end

function lua_handles.ls_update_role_build_progress_reward(...)
    dynasty:update_role_build_progress_reward(...)
end

function lua_handles.lc_get_dynasty_spell_info(...)
    return dynasty:get_dynasty_spell_info(...)
end

function lua_handles.lc_upgrade_dynasty_spell(...)
    return dynasty:upgrade_dynasty_spell(...)
end

function lua_handles.lc_get_dynasty_challenge_info(...)
    return dynasty:get_dynasty_challenge_info(...)
end

function lua_handles.lc_dynasty_challenge_janitor(...)
    return dynasty:dynasty_challenge_janitor(...)
end

function lua_handles.lc_dynasty_challenge_setting(...)
    return dynasty:dynasty_challenge_setting(...)
end

function lua_handles.lc_get_dynasty_challenge_rank(...)
    return dynasty:get_dynasty_challenge_rank(...)
end

function lua_handles.lc_get_challenge_janitor_box(...)
    return dynasty:get_challenge_janitor_box(...)
end

function lua_handles.lc_get_challenge_all_box(...)
    return dynasty:get_challenge_all_box(...)
end

function lua_handles.lc_add_challenge_num(...)
    return dynasty:add_challenge_num(...)
end

function lua_handles.lc_dynasty_compete_apply(...)
    return dynasty:dynasty_compete_apply(...)
end

function lua_handles.lc_dynasty_building_defend(...)
    return dynasty:dynasty_building_defend(...)
end

function lua_handles.ls_set_dynasty_compete_enemy(...)
    dynasty:set_dynasty_compete_enemy(...)
end

function lua_handles.lc_get_dynasty_compete_info(...)
    return dynasty:get_dynasty_compete_info(...)
end

function lua_handles.lc_dynasty_compete_fight(...)
    return dynasty:dynasty_compete_fight(...)
end

function lua_handles.lc_add_compete_attack_num(...)
    return dynasty:add_compete_attack_num(...)
end

function lua_handles.lc_get_compete_defend_info(...)
    return dynasty:get_compete_defend_info(...)
end

function lua_handles.lc_get_dynasty_defend_info(...)
    return dynasty:get_dynasty_defend_info(...)
end

function lua_handles.lc_get_compete_member_mark_info(...)
    return dynasty:get_compete_member_mark_info(...)
end

function lua_handles.lc_get_compete_reward_info(...)
    return dynasty:get_compete_reward_info(...)
end

function lua_handles.lc_get_compete_reward(...)
    return dynasty:get_compete_reward(...)
end

function lua_handles.ls_give_dynasty_rank_reward(...)
    dynasty:give_dynasty_rank_reward(...)
end

function lua_handles.ls_update_traitor_honour(...)
    dynasty:update_traitor_honour(...)
end

function lua_handles.ls_clear_traitor_honour(...)
    dynasty:clear_traitor_honour(...)
end

function lua_handles.ls_add_dynasty_exp(...)
    dynasty:add_dynasty_exp(...)
end

function lua_handles.ls_add_dynasty_exp_by_id(...) -- 临时完成功能
    dynasty:add_dynasty_exp_by_id(...)
end

function lua_handles.ls_add_member(...)
    dynasty:add_member(...)
end
----------------------------王朝争霸-------------------------------------
function lua_handles.ls_add_dynasty_compete(...)
    dynasty_compete.add_dynasty_compete(...)
end

function lua_handles.ls_dynasty_compete_open(...)
    dynasty_compete.dynasty_compete_open(...)
end

function lua_handles.ls_dynasty_compete_close(...)
    dynasty_compete.dynasty_compete_close(...)
end
--------------------------------- 王朝排行榜 --------------------------
function lua_handles.ls_update_dynasty_rank(rank_name, dynasty_info)
    dynasty_rank.update_dynasty_rank(rank_name, dynasty_info)
end

function lua_handles.ls_update_dynasty_rank_info(dynasty_info)
    dynasty_rank.update_dynasty_info(dynasty_info)
end

function lua_handles.ls_clear_dynasty_rank(rank_name)
    dynasty_rank.clear_rank_data(rank_name)
end

function lua_handles.lc_get_dynasty_rank_list(rank_name, dynasty_id)
    return dynasty_rank.get_rank_list(rank_name, dynasty_id)
end

function lua_handles.lc_get_dynasty_rank_index(rank_name, dynasty_id)
    return dynasty_rank.get_dynasty_rank(rank_name, dynasty_id)
end

function lua_handles.lc_get_rank_dynasty_list(rank_name)
    return dynasty_rank.get_dynasty_list(rank_name)
end

function lua_handles.ls_on_dissolve_dynasty(dynasty_id)
    dynasty_rank.on_dissolve_dynasty(dynasty_id)
end
------------------------冲榜活动---------------------------
function lua_handles.ls_notify_rush_list_activity_start()
    dynasty_utils.on_rush_list_activity_start()
end

function lua_handles.ls_notify_rush_list_activity_stop()
    dynasty_utils.on_rush_list_activity_stop()
end

return lua_handles