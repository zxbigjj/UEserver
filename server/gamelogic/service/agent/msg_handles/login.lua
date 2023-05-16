local date = require("sys_utils.date")

local M = DECLARE_MODULE("msg_handles.login")

function M.c_client_ping(sock, args)
    sock:send("s_client_ping", args)
end

function M.c_heartbeat(sock, args)
    local resp = {}
    resp.server_time = math.floor(date.time() * 100)
    return resp
end

function M.c_reconnect(sock, args)
    if not args.uuid then return g_tips.error_resp end
    if agent_utils.is_shutdowning() then
        skynet.fork(function() sock:close() end)
        return g_tips.error_resp
    end

    local role = require("role_cls").get_role(args.uuid)
    if not role then
        return g_tips.error_resp
    end
    if not role:on_reconnect(sock, args.token) then
        return g_tips.error_resp
    end
    return g_tips.ok_resp
end

function M.c_client_quit(sock, args)
    if not args.uuid then return g_tips.error_resp end
    local role = require("role_cls").get_role(args.uuid)
    if not role then
        return g_tips.error_resp
    end
    role:logout()
    return g_tips.ok_resp
end

function M.c_login(sock, args)
    local urs = args.urs
    if not urs then return end
    if agent_utils.is_shutdowning() then
        skynet.fork(function() sock:close() end)
        return g_tips.error_resp
    end

    local schema = require("schema_game")
    local player_db = schema.Player:load(urs)
    if not player_db then
        return {errcode = g_tips.ok, urs = urs, no_role = true}
    end

    local role = require("role_cls").load(player_db.uuid)
    if not role then
        return g_tips.error_resp
    end
    if role:yw_is_forbid_login() then
        role:notify_tips(g_tips.yunwei_forbid_login)
        skynet.timeout(100, function() role:kick() end)
        return g_tips.error_resp
    end
    role:login(sock)
    -- 是否完成新手指引
    local is_guide_not_end = role.db.guide_dict[1] and true or false
    local is_not_flag = (not role.db.flag_id) and true or false
    return {
        errcode = g_tips.ok,
        urs = urs,
        token = role.token,
        is_guide_not_end = is_guide_not_end,
        is_not_flag = is_not_flag
    }
end

function M.c_new_role(sock, args)
    local urs = args.urs
    if not urs or not args.role_id or not args.role_name then
        return g_tips.error_resp
    end
    if not IsStringBroken(args.role_name) then return g_tips.error_resp end
    if not require("CSCommon.CSFunction").check_player_name_legality(args.role_name) then
        return g_tips.error_resp
    end

    --屏蔽字
    local maskWord = require("name_utils").sdk_4399_check_name(args.role_name)
    print('====屏蔽字======' .. maskWord)
    if tostring(maskWord) ~= "{}" then
       return {errcode = g_tips.error, name_repeat = false,mask = true}
    end
  
    if require("name_utils").is_role_name_repeat(args.role_name) then
        return {errcode = g_tips.error, name_repeat = true}
    end
   
    local schema = require("schema_game")
    if schema.Player:load(urs) then return g_tips.error_resp end

    local role_data = {
        role_name = args.role_name,
        role_id = args.role_id
    }
    local role = require("role_cls").create(urs, role_data)
    if not role then return end
    if not schema.Player:insert(urs) then return g_tips.error_resp end

    schema.Player:set_field({urs = urs}, {uuid = role.uuid})
    local role_info = {
        role_id = role.db.role_id,
        name = role.db.name,
        level = role.db.level,
        server_id = require("srv_utils.server_env").get_server_id()
    }
    role:insert_login_role_info(role_info)
    role:login(sock)
    return {errcode = g_tips.ok, token = role.token}
end

function M.c_query_random_name(sock, args)
    local name = require("name_utils").rand_role_name(args.sex)
    return {role_name = name}
end

return M
