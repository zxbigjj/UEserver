local M = DECLARE_MODULE("msg_handles.dynasty")

function M.c_create_dynasty(role, args)
    local ret, name_repeat,maskWord = role.dynasty:create_dynasty(args.dynasty_name)
    if maskWord then
        return {errcode = g_tips.error, name_repeat = name_repeat,mask = maskWord}
    end
    if ret then
        return {errcode = g_tips.ok, dynasty_base_info = ret}
    end
    return {errcode = g_tips.error, name_repeat = name_repeat}
end

function M.c_get_dynasty_list(role, args)
    return role.dynasty:get_dynasty_list(args.page)
end

function M.c_seek_dynasty(role, args)
    return role.dynasty:seek_dynasty(args.dynasty_name) or {}
end

function M.c_apply_dynasty(role, args)
    if role.dynasty:apply_dynasty(args.dynasty_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_cancel_apply_dynasty(role, args)
    if role.dynasty:cancel_apply_dynasty(args.dynasty_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_dynasty_base_info(role, args)
    local ret = role.dynasty:get_dynasty_base_info()
    if ret then
        return {errcode = g_tips.ok, dynasty_base_info = ret}
    end
    return g_tips.error_resp
end

function M.c_get_dynasty_member_info(role, args)
    local ret = role.dynasty:get_dynasty_member_info()
    if ret then
        return {errcode = g_tips.ok, member_dict = ret}
    end
    return g_tips.error_resp
end

function M.c_get_dynasty_apply_info(role, args)
    local ret, tips_id = role.dynasty:get_dynasty_apply_info()
    if ret then
        return {errcode = g_tips.ok, apply_dict = ret}
    end
    return {errcode = g_tips.error, tips_id = tips_id}
end

function M.c_agree_apply_dynasty(role, args)
    if role.dynasty:agree_apply_dynasty(args.member_uuid) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_ignore_apply_dynasty(role, args)
    if role.dynasty:refuse_apply_dynasty(args.member_uuid) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_quit_dynasty(role, args)
    if role.dynasty:quit_dynasty() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_dynasty_rank(role, args)
    return role.dynasty:get_dynasty_rank()
end

function M.c_modify_dynasty_badge(role, args)
    if role.dynasty:modify_dynasty_badge(args.dynasty_badge) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_modify_dynasty_name(role, args)
    
    local ret, name_repeat,maskWord = role.dynasty:modify_dynasty_name(args.dynasty_name)
    if maskWord then
        return {errcode = g_tips.error, name_repeat = name_repeat,mask = maskWord}
    end

    if ret then
        return g_tips.ok_resp
    end
    return {errcode = g_tips.error, name_repeat = name_repeat}
end

function M.c_modify_dynasty_notice(role, args)
    if role.dynasty:modify_dynasty_notice(args.dynasty_notice) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_modify_dynasty_declaration(role, args)
    if role.dynasty:modify_dynasty_declaration(args.dynasty_declaration) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_kick_out_dynasty(role, args)
    if role.dynasty:kick_out_dynasty(args.member_uuid) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_appoint_dynasty_member(role, args)
    if role.dynasty:appoint_dynasty_member(args.member_uuid, args.job) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_dissolve_dynasty(role, args)
    if role.dynasty:dissolve_dynasty() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_dynasty_build_info(role, args)
    local ret = role.dynasty:get_dynasty_build_info()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_dynasty_build(role, args)
    if role.dynasty:dynasty_build(args.build_type) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_dynasty_build_reward(role, args)
    if role.dynasty:get_dynasty_build_reward(args.reward_index) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_dynasty_active_reward(role, args)
    if role.dynasty:get_dynasty_active_reward(args.reward_index) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_dynasty_spell_info(role, args)
    local ret = role.dynasty:get_dynasty_spell_info()
    if ret then
        return {errcode = g_tips.ok, spell_dict = ret}
    end
    return g_tips.error_resp
end

function M.c_study_dynasty_spell(role, args)
    if role.dynasty:study_dynasty_spell(args.spell_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_upgrade_dynasty_spell(role, args)
    if role.dynasty:upgrade_dynasty_spell(args.spell_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_dynasty_challenge_info(role, args)
    local ret = role.dynasty:get_dynasty_challenge_info()
    if ret then
        return {errcode = g_tips.ok, challenge_info = ret}
    end
    return g_tips.error_resp
end

function M.c_dynasty_challenge_janitor(role, args)
    local ret = role.dynasty:dynasty_challenge_janitor(args.janitor_index)
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_dynasty_challenge_setting(role, args)
    if role.dynasty:dynasty_challenge_setting(args.setting_type) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_dynasty_challenge_rank(role, args)
    local ret = role.dynasty:get_dynasty_challenge_rank()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_challenge_janitor_box(role, args)
    local ret = role.dynasty:get_challenge_janitor_box(args.stage_id, args.janitor_index, args.box_index)
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_challenge_stage_reward(role, args)
    if role.dynasty:get_challenge_stage_reward(args.stage_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_challenge_all_reward(role, args)
    local ret = role.dynasty:get_challenge_all_reward()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_buy_dynasty_challenge_num(role, args)
    local ret = role.dynasty:buy_dynasty_challenge_num(args.buy_num)
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_dynasty_task_reward(role, args)
    if role.dynasty:get_task_reward(args.task_type) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_dynasty_compete_apply(role, args)
    if role.dynasty:dynasty_compete_apply() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_dynasty_building_defend(role, args)
    if role.dynasty:dynasty_building_defend(args.uuid, args.building_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_dynasty_compete_info(role, args)
    local ret = role.dynasty:get_dynasty_compete_info()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_dynasty_compete_fight(role, args)
    local ret, tips_id = role.dynasty:dynasty_compete_fight(args.dynasty_id, args.building_id, args.uuid)
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return {errcode = g_tips.error, tips_id = tips_id}
end

function M.c_buy_compete_attack_num(role, args)
    local ret = role.dynasty:buy_compete_attack_num(args.buy_num)
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_compete_defend_info(role, args)
    local ret = role.dynasty:get_compete_defend_info()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_compete_member_mark_info(role, args)
    local ret = role.dynasty:get_compete_member_mark_info()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_compete_reward_info(role, args)
    local ret = role.dynasty:get_compete_reward_info()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_compete_reward(role, args)
    if role.dynasty:get_compete_reward(args.reward_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_compete_dynasty_rank(role, args)
    local ret = role.dynasty:get_compete_dynasty_rank()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_compete_role_rank(role, args)
    local ret = role.dynasty:get_compete_role_rank()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_buy_dynasty_shop_item(role, args)
    if role.dynasty:buy_shop_item(args.shop_id, args.shop_num) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

return M