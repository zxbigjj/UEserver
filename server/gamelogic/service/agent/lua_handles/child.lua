local child_handles = DECLARE_MODULE("lua_handles.child")
local offline_cmd = require("offline_cmd")
local cluster_utils = require("msg_utils.cluster_utils")
local cache_utils = require("cache_utils")
local agent_utils = require("agent_utils")

function child_handles.ls_child_marriage(uuid, data)
    local role = agent_utils.get_role(uuid)
    if role then
        role:passive_marriage(data.child_id, data.object)
    else
        offline_cmd.push_child_marriage(uuid, {child_id = data.child_id, object = data.object})
    end
end

function child_handles.lc_receive_request(uuid, object)
    print('======uuid==============' .. json.encode(uuid))
    local name
    local role = agent_utils.get_role(uuid)
    if role then
        role:receive_request_child_info(object)
        name = role:get_name()
    else
        offline_cmd.push_child_receive_request(uuid, {object = object})
        print('======get_role_info==============' .. json.encode(cache_utils.get_role_info(uuid, {"name"})))
        name = cache_utils.get_role_info(uuid, {"name"}).name
    end
    return name
end

function child_handles.ls_cancel_request(uuid, data)
    local role = agent_utils.get_role(uuid)
    if role then
        role:passive_cancel_child_request(data.uuid, data.child_id)
    else
        offline_cmd.push_child_cancel_request(uuid, data)
    end
end

function child_handles.ls_refuse_request(uuid, child_id)
    local role = agent_utils.get_role(uuid)
    if role then
        role:passive_refuse_child_request(child_id)
    else
        offline_cmd.push_child_refuse_request(uuid, {child_id = child_id})
    end
end

function child_handles.ls_passive_marriage(uuid, object_child_id, object)
    local role = agent_utils.get_role(uuid)
    if role then
        role:passive_marriage(object_child_id, object)
    else
        offline_cmd.push_child_marriage(uuid, {child_id = object_child_id, object = object})
    end
end

return child_handles