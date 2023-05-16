local friend_handles = DECLARE_MODULE("lua_handles.friend")
local excel_data = require("excel_data")
local offline_cmd = require("offline_cmd")
local cache_utils = require("cache_utils")
local role_utils = require("role_utils")
local cluster_utils = require("msg_utils.cluster_utils")

function friend_handles.lc_get_friend_info(uuid)
    local basic_info = {}
    local role = agent_utils.get_role(uuid)
    basic_info.dynasty = agent_utils.get_dynasty_name(uuid)
    basic_info.server_id = cluster_utils.get_server_id(uuid)
    basic_info.uuid = uuid
    if role then
        basic_info.offline_time = 0
        basic_info.role_id = role:get_role_id()
        basic_info.name = role:get_name()
        basic_info.level = role:get_level()
        basic_info.fight_score = role:get_fight_score()
        basic_info.score = role:get_score()
    else
        local role_info = cache_utils.get_role_info(uuid, {"role_id","name","level","fight_score","last_offline_ts", "score"})
        if not role_info then return end
        basic_info.offline_time = role_info.last_offline_ts
        basic_info.role_id = role_info.role_id
        basic_info.name = role_info.name
        basic_info.level = role_info.level
        basic_info.fight_score = role_info.fight_score
        basic_info.score = role_info.score
    end
    return basic_info
end

function friend_handles.ls_send_gift(uuid, friend_uuid)
    local role = agent_utils.get_role(uuid)
    if role then
        role.friend:insert_gift(friend_uuid)
    else
        offline_cmd.push_friend_send_gift(uuid, {uuid = friend_uuid})
    end
end

function friend_handles.lc_confirm_friend_apply(uuid, friend_uuid)
    local role = agent_utils.get_role(uuid)
    local max_friend_count = excel_data.ParamData["max_friend_count"].f_value
    if role then
        local friend_info = role.db.friend.handsel_gift
        local black_dict = role.db.friend.black_dict
        local friend_count = #friend_info
        if friend_count >= max_friend_count then
            return {
                errcode = g_tips.error,
                tips = CSConst.FriendError.MaxOtherFriendCount
            }
        end
        if friend_info[uuid] or black_dict[uuid] then
            return{
                errcode = g_tips.error,
                tips = CSConst.FriendError.RepeatedFriend
            }
        end
        role.friend:insert_friend(friend_uuid)
    else
        local role_info = cache_utils.get_role_info(uuid, {"friend"})
        local friend_info = role_info.friend.handsel_gift
        local black_dict = role_info.friend.black_dict
        local friend_count = #friend_info
        if friend_count >= max_friend_count then
            return {
                errcode = g_tips.error,
                tips = CSConst.FriendError.MaxOtherFriendCount
            }
        end
        if friend_info[uuid] or black_dict[uuid] then
            return{
                errcode = g_tips.error,
                tips = CSConst.FriendError.RepeatedFriend
            }
        end
        offline_cmd.push_add_friend(uuid, {uuid = friend_uuid})
    end
    return g_tips.ok_resp
end

function friend_handles.ls_add_friend_apply(uuid, friend_uuid)
    local other_role = agent_utils.get_role(uuid)
    if other_role then
        other_role.friend:insert_friend_apply(friend_uuid)
    else
        offline_cmd.push_add_friend_apply(uuid, {uuid = friend_uuid})
    end
end

function friend_handles.lc_delete_friend(uuid, friend_uuid)
    local role = agent_utils.get_role(uuid)
    if role then
        return role.friend:delete_friend(friend_uuid)
    else
        offline_cmd.push_delete_friend(uuid, {uuid = friend_uuid})
    end
    return true
end

function friend_handles.lc_get_role_lineup(uuid)
    local role = agent_utils.get_role(uuid)
    local lineup_dict, hero_dict
    if role then
        lineup_dict = role.db.lineup_dict
        hero_dict = role.db.hero_dict
    else
        local info = cache_utils.get_role_info(uuid, {"lineup_dict", "hero_dict"})
        if not info then return end
        lineup_dict = info.lineup_dict
        hero_dict = info.hero_dict
    end
    local hero_lineup_dict = {}
    for lineup_id, data in pairs(lineup_dict) do
        local hero_info
        if data.hero_id then
            hero_info = hero_dict[data.hero_id]
            local equip_dict = {}
            for k, v in pairs(data.equip_dict) do
                equip_dict[k] = data.equip_info_dict[v]
            end
            hero_lineup_dict[lineup_id] = {
                hero_info = hero_info,
                pos_id = data.pos_id,
                lineup_id = lineup_id,
                equip_dict = equip_dict
            }
        end
    end
    return hero_lineup_dict
end

function friend_handles.lc_get_friend_fight_data(uuid)
    local role = agent_utils.get_role(uuid)
    if role then
        return role:get_role_fight_data()
    else
        local role_info = cache_utils.get_role_info(uuid, {"lineup_dict","hero_dict"})
        return role_utils.get_role_fight_data(role_info.lineup_dict, role_info.hero_dict)
    end
end

function friend_handles.ls_send_friend_mail(uuid, friend_uuid, msg)
    local role = agent_utils.get_role(uuid)
    if role then
        local friend_info = role.db.friend.handsel_gift
        if friend_info[friend_uuid] == nil then return end
    else
        local role_info = cache_utils.get_role_info(uuid, {"friend"})
        local friend_info = role_info.friend.handsel_gift
        if friend_info[friend_uuid] == nil then return end
    end
    agent_utils.add_mail(uuid, {mail_id=CSConst.MailId.Friend, mail_args=msg})
end

function friend_handles.lc_can_private_chat(uuid, friend_uuid)
    local role = agent_utils.get_role(uuid)
    if role then
        if role.db.friend.black_dict[friend_uuid] then return false end
    else
        local role_info = cache_utils.get_role_info(uuid, {"friend"})
        local black_dict = role_info.friend.black_dict
        if black_dict[friend_uuid] then return false end
    end
    return true
end

return friend_handles