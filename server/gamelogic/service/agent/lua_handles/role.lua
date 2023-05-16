local M = DECLARE_MODULE("lua_handles.role")
local cache_utils = require("cache_utils")
local cluster_utils = require("msg_utils.cluster_utils")

function M.lc_set_agent_start(node_name)
    agent_utils.set_agent_start(node_name)
end

function M.lc_private_chat(uuid, msg)
    local role = agent_utils.get_role(uuid)
    if not role then return end
    role:send_client("s_chat", msg)
    return true
end

function M.lc_get_role_info(uuid)
    local info = {}
    local role = agent_utils.get_role(uuid)
    if role then
        info = role:get_role_info()
    else
        info = cache_utils.get_role_info(uuid, {"uuid", "name", "level", "role_id", "vip", "fight_score"})
        info.vip = info.vip.vip_level
    end
    info.server_id = cluster_utils.get_server_id(uuid)
    info.dynasty_name = agent_utils.get_dynasty_name(uuid)
    return info
end

function M.ls_give_rank_reward(uuid, mail_id, mail_args, item_list)
    agent_utils.add_mail(uuid, {mail_id=mail_id, mail_args=mail_args, item_list=item_list})
end

return M