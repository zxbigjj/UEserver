local agent_utils = DECLARE_MODULE("agent_utils")
rawset(_G, 'agent_utils', agent_utils)

local cluster_utils = require("msg_utils.cluster_utils")
local LRU = require("table_extend").LRU
local Timer = require("timer")
local Date = require("sys_utils.date")

DECLARE_RUNNING_ATTR(agent_utils, "_is_shutdowning", nil)
DECLARE_RUNNING_ATTR(agent_utils, "_shutdown_uuid_dict", {})
DECLARE_RUNNING_ATTR(agent_utils, "_agent_correlate_node", {
    ["dynasty"] = false,
    ["chat"] = false,
})

function agent_utils.shutdown()
    agent_utils._is_shutdowning = true
    agent_utils._shutdown_uuid_dict = {}
    g_log:info("shutdown....")
    -- 所有玩家下线
    local total_count = 0
    local saved_count = 0
    local saving_count = 0

    local uuid_list = agent_utils.get_online_uuid()
    total_count = #uuid_list

    local timer
    timer = require("timer").loop(1, function()
        g_log:info(string.format("SaveInfo %d %d %d", total_count, saving_count, saved_count))
        if saved_count == total_count then
            timer:cancel()
        end
    end)

    for i, uuid in ipairs(uuid_list) do
        if i%3==0 then
            skynet.sleep(1)
        end
        while saving_count > 800 do
            skynet.sleep(1)
        end
        saving_count = saving_count + 1

        agent_utils._shutdown_uuid_dict[uuid] = skynet.fork(function()
            local role = agent_utils.get_role(uuid)
            if role then
                xpcall(role.kick, g_log.trace_handle, role)
            end
            agent_utils._shutdown_uuid_dict[uuid] = nil
            saving_count = saving_count - 1
            saved_count = saved_count + 1
        end)
    end
    -- 等待
    while next(agent_utils._shutdown_uuid_dict) do
        skynet.sleep(100)
    end
    -- 保存服务器数据
    require("role_db").save_all()
    require("db.offline_db").save_all()
    require("arena_utils").save_all_rank()
    require("rank_utils").save_rank()
    require("server_data").save_all()
    require("rush_activity_utils").shutdown()
    require("fund_utils").shutdown()

    local server_id = tonumber(skynet.getenv("server_id"))
    local other_list = table.keys(agent_utils._agent_correlate_node)
    for _, name in ipairs(other_list) do
        skynet.fork(function()
            local node_name = string.format("s%d_%s", server_id, name)
            if cluster_utils.probe(node_name, '.debug_console') then
                cluster_utils.lua_call(node_name, ".debug_console", "lc_do_shutdown")
                print('shutdown finish:' .. name)
            end
            table.delete(other_list, name)
        end)
    end
    while true do
        print('wait shutdown:' .. table.concat(other_list, " "))
        skynet.sleep(10)
        if not next(other_list) then break end
    end
    print('shutdown over')
    return
end

function agent_utils.is_shutdowning()
    return agent_utils._is_shutdowning
end

function agent_utils.on_server_start()
    local server_data = require("server_data")
    local now = Date.time_second()
    if not server_data.get_server_core("init_server_flag") then
        server_data.set_server_core("last_hotfix_version", require("hotfix_utils").get_max_server_version())
        server_data.set_server_core("init_server_flag", true)
        server_data.set_server_core("server_open_time", now)
        require("arena_utils").init()
    end
end

-- agent启动后，等待其他节点都初始化完成后，再跑相关逻辑
function agent_utils.set_agent_start(node_name)
    print(string.format("node started:%s", node_name))
    if not agent_utils._agent_correlate_node then return end
    agent_utils._agent_correlate_node[node_name] = true
end

function agent_utils.check_agent_correlate_node()
    for k, v in pairs(agent_utils._agent_correlate_node) do
        if not v then return true end
    end
end

function agent_utils.get_online_uuid()
    return require("role_cls").get_online_uuid()
end

function agent_utils.get_role(uuid)
    return require("role_cls").get_role(uuid)
end

function agent_utils.send_system_chat(uuid, content)
    local msg = {
        chat_type = CSConst.ChatType.System,
        content = content,
    }
    cluster_utils.send_client_msg(nil, uuid, "s_chat", msg)
end

function agent_utils.add_mail(uuid, mail_info)
    local role = agent_utils.get_role(uuid)
    if role then
        role:add_mail(mail_info)
    else
        require("offline_cmd").push_add_mail(uuid, mail_info)
    end
end

function agent_utils.add_title(uuid, title_id, add_ts)
    local role = agent_utils.get_role(uuid)
    if role then
        role:add_title(title_id, add_ts)
    else
        require("offline_cmd").push_add_title(uuid, title_id, add_ts)
    end
end

function agent_utils.get_uuid_by_name(name)
    local schema = require('schema_game')
    local name_info = schema.RoleName:load(name)
    return name_info and name_info.uuid
end

function agent_utils.get_dynasty_id(uuid)
    local role = agent_utils.get_role(uuid)
    if role then
        return role:get_dynasty_id()
    else
        return cluster_utils.call_dynasty("lc_get_dynasty_id", uuid)
    end
end

function agent_utils.get_dynasty_name(uuid)
    local role = agent_utils.get_role(uuid)
    if role then
        return role:get_dynasty_name()
    else
        return cluster_utils.call_dynasty("lc_get_dynasty_name", uuid)
    end
end

function agent_utils.refresh_dynasty()
    cluster_utils.send_dynasty("ls_refresh_dynasty")
end

function agent_utils.delete_traitor(uuid, reward_list)
    local role = agent_utils.get_role(uuid)
    if role then
        role:delete_traitor(reward_list)
    else
        require("offline_cmd").push_delete_traitor(uuid, reward_list)
    end
end

-- 获取开服天数
function agent_utils.get_server_day()
    local now = Date.time_second()
    local server_open_time = require("server_data").get_server_core("server_open_time")
    local server_day = (now - server_open_time)/CSConst.Time.Day
    return math.floor(server_day)
end

function agent_utils.broadcast_server_notice(msg)
    local info = {
        chat_type = CSConst.ChatType.System,
        content = msg.notice_content,
    }
    cluster_utils.broad_client_msg(nil, nil, "s_chat", info)
end

return agent_utils