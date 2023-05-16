local dynasty_handles = DECLARE_MODULE("lua_handles.dynasty")
local offline_cmd = require("offline_cmd")
local cache_utils = require("cache_utils")
local role_utils = require("role_utils")

function dynasty_handles.ls_join_dynasty(uuid, dynasty_id)
    agent_utils.add_mail(uuid, {mail_id = CSConst.MailId.DynastyIn})
    local role = agent_utils.get_role(uuid)
    if role then
        role:join_dynasty(dynasty_id)
    else
        offline_cmd.push_join_dynasty(uuid, dynasty_id)
    end
end

function dynasty_handles.ls_kicked_out_dynasty(uuid)
    agent_utils.add_mail(uuid, {mail_id = CSConst.MailId.DynastyOut})
    local role = agent_utils.get_role(uuid)
    if role then
        role.dynasty:kicked_out_dynasty()
    else
        offline_cmd.push_kicked_out_dynasty(uuid)
    end
end

function dynasty_handles.ls_delete_dynasty_apply(uuid, dynasty_id)
    local role = agent_utils.get_role(uuid)
    if role then
        role:delete_dynasty_apply(dynasty_id)
    else
        offline_cmd.push_delete_dynasty_apply(uuid, dynasty_id)
    end
end

function dynasty_handles.ls_send_member_mail(uuid, mail_id, mail_args, item_list)
    agent_utils.add_mail(uuid, {mail_id=mail_id, mail_args=mail_args, item_list=item_list})
end

function dynasty_handles.lc_get_dynasty_compete_role_info(uuid)
    local role_info = {}
    local role = agent_utils.get_role(uuid)
    if role then
        role_info.role_id = role:get_role_id()
        role_info.role_name = role:get_name()
        role_info.fight_score = role:get_fight_score()
        role_info.fight_data = role:get_role_fight_data()
    else
        local info = cache_utils.get_role_info(uuid, {"role_id", "name","fight_score","lineup_dict","hero_dict"})
        role_info.role_id = info.role_id
        role_info.role_name = info.name
        role_info.fight_score = info.fight_score
        role_info.fight_data = role_utils.get_role_fight_data(info.lineup_dict, info.hero_dict)
    end
    return role_info
end

function dynasty_handles.ls_dynasty_name_change(uuid, dynasty_name)
    local role = agent_utils.get_role(uuid)
    if role then
        role.dynasty:on_dynasty_name_change(dynasty_name)
    end
end

function dynasty_handles.ls_update_dynasty_role_cross_rank(uuid, rank_name, rank_score)
    local role = agent_utils.get_role(uuid)
    if role then
        role:update_cross_role_rank(rank_name, rank_score)
    end
end

function dynasty_handles.ls_update_dynasty_build_progress(uuid, build_progress)
    local role = agent_utils.get_role(uuid)
    if role then
        role.dynasty:update_dynasty_build_progress(build_progress)
    end
end

return dynasty_handles