local date = require("sys_utils.date")
local schema_game = require("schema_game")
local offline_cmd = DECLARE_MODULE("offline_cmd")

local cmd_mapper = {
    test = {curr_version = 1, cmd_func = "cmd_test"},
    child_receive_request = {curr_version = 1, cmd_func = "cmd_child_receive_request"},
    child_refuse_request = {curr_version = 1, cmd_func = "cmd_child_refuse_request"},
    child_cancel_request = {curr_version = 1, cmd_func = "cmd_child_cancel_request"},
    child_marriage = {curr_version = 1, cmd_func = "cmd_child_marriage"},
    add_mail = {curr_version = 1, cmd_func = "cmd_add_mail"},
    salon_pvp_results = {curr_version = 1, cmd_func = "cmd_salon_pvp_results"},
    party_end = {curr_version = 1, cmd_func = "cmd_party_end"},
    party_games_end = {curr_version = 1, cmd_func = "cmd_party_games_end"},
    party_receive_invite = {curr_version = 1, cmd_func = "cmd_party_receive_invite"},
    party_receive_refuse_invite = {curr_version = 1, cmd_func = "cmd_party_receive_refuse_invite"},
    join_dynasty = {curr_version = 1, cmd_func = "cmd_join_dynasty"},
    delete_dynasty_apply = {curr_version = 1, cmd_func = "cmd_delete_dynasty_apply"},
    kicked_out_dynasty = {curr_version = 1, cmd_func = "cmd_kicked_out_dynasty"},
    friend_send_gift = {curr_version = 1, cmd_func = "cmd_friend_send_gift"},
    add_friend = {curr_version = 1, cmd_func = "cmd_add_friend"},
    add_friend_apply = {curr_version = 1, cmd_func = "cmd_add_friend_apply"},
    delete_friend = {curr_version = 1, cmd_func = "cmd_delete_friend"},
    delete_traitor = {curr_version = 1, cmd_func = "cmd_delete_traitor"},
    add_title = {curr_version = 1, cmd_func = "cmd_add_title"},
    on_rename = {curr_version = 1, cmd_func = "cmd_on_rename"},
}

function offline_cmd.push_test(uuid)
    offline_cmd._push(uuid, "test", {abc = 123})
end

function offline_cmd.cmd_test(role, args_dict, ts, version)
    PRINT("-----------cmd_test", role.uuid, args_dict, ts, version)
end

function offline_cmd.push_child_receive_request(uuid, args_dict)
    offline_cmd._push(uuid, "child_receive_request", args_dict)
end

function offline_cmd.cmd_child_receive_request(role, args_dict)
    role.child:receive_request(args_dict.object)
end

function offline_cmd.push_child_refuse_request(uuid, args_dict)
    offline_cmd._push(uuid, "child_refuse_request",args_dict)
end

function offline_cmd.cmd_child_refuse_request(role, args_dict)
    role.child:passive_refuse_request(args_dict.child_id)
end

function offline_cmd.push_child_cancel_request(uuid, args_dict)
    offline_cmd._push(uuid, "child_cancel_request",args_dict)
end

function offline_cmd.cmd_child_cancel_request(role,args_dict)
    role.child:passive_cancel_request(args_dict.uuid, args_dict.child_id)
end

function offline_cmd.push_child_marriage(uuid, args_dict)
    offline_cmd._push(uuid, "child_marriage",args_dict)
end

function offline_cmd.cmd_child_marriage(role, args_dict)
    role.child:passive_marriage(args_dict.child_id, args_dict.object)
end

function offline_cmd.push_salon_pvp_results(uuid, args_dict)
    offline_cmd._push(uuid, "salon_pvp_results",args_dict)
end

function offline_cmd.cmd_salon_pvp_results(role, args_dict)
    role:salon_pvp_results(args_dict.pvp_info)
end

function offline_cmd.push_party_end(uuid, args_dict)
    offline_cmd._push(uuid, "party_end",args_dict)
end

function offline_cmd.cmd_party_end(role, args_dict)
    role.party:end_party(args_dict.party_info)
end

function offline_cmd.push_party_games_end(uuid, args_dict)
    offline_cmd._push(uuid, "party_games_end",args_dict)
end

function offline_cmd.cmd_party_games_end(role, args_dict)
    role.party:games_end(args_dict)
end

function offline_cmd.push_party_receive_invite(uuid, args_dict)
    offline_cmd._push(uuid, "party_receive_invite",args_dict)
end

function offline_cmd.cmd_party_receive_invite(role, args_dict)
    role.party:receive_invite(args_dict.invite_info)
end

function offline_cmd.push_party_receive_refuse_invite(uuid, args_dict)
    offline_cmd._push(uuid, "party_receive_refuse_invite",args_dict)
end

function offline_cmd.cmd_party_receive_refuse_invite(role, args_dict)
    role.party:receive_refuse_invite(args_dict.uuid)
end

function offline_cmd.push_add_mail(uuid, args_dict)
    offline_cmd._push(uuid, "add_mail", args_dict)
end

function offline_cmd.cmd_add_mail(role, args_dict, ts)
    role:add_mail(args_dict)
end

function offline_cmd.push_join_dynasty(uuid, dynasty_id)
    offline_cmd._push(uuid, "join_dynasty",{dynasty_id = dynasty_id})
end

function offline_cmd.cmd_join_dynasty(role, args_dict)
    role:join_dynasty(args_dict.dynasty_id)
end

function offline_cmd.push_delete_dynasty_apply(uuid, dynasty_id)
    offline_cmd._push(uuid, "delete_dynasty_apply",{dynasty_id = dynasty_id})
end

function offline_cmd.cmd_delete_dynasty_apply(role, args_dict)
    role:delete_dynasty_apply(args_dict.dynasty_id)
end

function offline_cmd.push_kicked_out_dynasty(uuid)
    offline_cmd._push(uuid, "kicked_out_dynasty")
end

function offline_cmd.cmd_kicked_out_dynasty(role, args_dict)
    role:kicked_out_dynasty()
end

function offline_cmd.push_delete_traitor(uuid, reward_list)
    offline_cmd._push(uuid, "delete_traitor",{reward_list = reward_list})
end

function offline_cmd.push_friend_send_gift(uuid, args_dict)
    offline_cmd._push(uuid, "friend_send_gift", args_dict)
end

function offline_cmd.cmd_friend_send_gift(role, args_dict)
    role.friend:insert_gift(args_dict.uuid)
end

function offline_cmd.push_add_friend(uuid, args_dict)
    offline_cmd._push(uuid, "add_friend", args_dict)
end

function offline_cmd.cmd_add_friend(role, args_dict)
    role.friend:insert_friend(args_dict.uuid)
end

function offline_cmd.push_add_friend_apply(uuid, args_dict)
    offline_cmd._push(uuid, "add_friend_apply", args_dict)
end

function offline_cmd.cmd_add_friend_apply(role, args_dict)
    role.friend:insert_friend_apply(args_dict.uuid)
end

function offline_cmd.push_delete_friend(uuid, args_dict)
    offline_cmd._push(uuid, "delete_friend", args_dict)
end

function offline_cmd.cmd_delete_friend(role, args_dict)
    role.friend:delete_friend(args_dict.uuid)
end

function offline_cmd.cmd_delete_traitor(role, args_dict)
    role:delete_traitor(args_dict.reward_list, true)
end

function offline_cmd.push_add_title(uuid, title_id, add_ts)
    offline_cmd._push(uuid, "add_title", {title_id = title_id, add_ts = add_ts})
end

function offline_cmd.cmd_add_title(role, args)
    role:add_title(args.title_id, args.add_ts)
end

function offline_cmd.push_on_rename(uuid)
    offline_cmd._push(uuid, "on_rename")
end

function offline_cmd.cmd_on_rename(role)
    role:on_rename()
end

function offline_cmd.online_do_offline_cmd(role)
    local need_delete = false
    for _, obj in pairs(schema_game.OfflineCmd:load_many({uuid=role.uuid})) do
        xpcall(offline_cmd._do_cmd, g_log.trace_handle, role, obj)
        skynet.sleep(150)
        need_delete = true
    end
    if need_delete then
        schema_game.OfflineCmd:delete_many({uuid=role.uuid})
    end
end

function offline_cmd._do_cmd(role, obj)
    local config = cmd_mapper[obj.cmd]
    if not config then return false end
    local func = offline_cmd[config.cmd_func]
    if not func then return false end
    g_log:offline("DoCmd", {uuid = role.uuid, obj = obj})
    func(role, obj.args, obj.ts, obj.version)
end

function offline_cmd._push(uuid, cmd, args_dict)
    local config = cmd_mapper[cmd] --配置
    local obj = {
        uuid = uuid,
        cmd = cmd,
        version = config.curr_version,
        ts = date.time_second(),
        args = args_dict,
    }
    local role_cls = require("role_cls")
    role_cls.lock_run(uuid, function()
        local role = role_cls.get_role(uuid)
        if role then
            offline_cmd._do_cmd(role, obj)
            return
        end
        g_log:offline("PushCmd", obj)
        schema_game.OfflineCmd:insert(nil, obj)
    end)
end

return offline_cmd