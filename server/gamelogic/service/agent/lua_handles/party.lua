local party_handles = DECLARE_MODULE("lua_handles.party")
local offline_cmd = require("offline_cmd")
local cache_utils = require("cache_utils")

function party_handles.ls_party_add_guests(uuid, data)
    local role = agent_utils.get_role(uuid)
    if role then
        role.party:add_guests(data.party_info)
    end
end

function party_handles.ls_party_end(uuid, data)
    local role = agent_utils.get_role(uuid)
    if role then
        role.party:end_party(data.party_info)
    else
        offline_cmd.push_party_end(uuid, {party_info = data.party_info})
    end
end

function party_handles.ls_party_games_end(uuid, data)
    local role = agent_utils.get_role(uuid)
    if role then
        role.party:games_end(data)
    else
        offline_cmd.push_party_games_end(uuid, data)
    end
end

function party_handles.lc_party_invite(uuid, data)
    local role = agent_utils.get_role(uuid)
    if role then
        return role.party:receive_invite(data.invite_info)
    else
        local info = cache_utils.get_role_info(uuid, {"party"})
        if not info.party or info.party.not_receive_invite then
            return CSConst.Party.InviteStatus.RefuseNoNotice
        end
        offline_cmd.push_party_receive_invite(uuid, {invite_info = data.invite_info})
        return CSConst.Party.InviteStatus.Wait
    end
end

function party_handles.ls_party_refuse_invite(uuid, data)
    local role = agent_utils.get_role(uuid)
    if role then
        role.party:receive_refuse_invite(data.refuse_info)
    else
        offline_cmd.push_party_receive_refuse_invite(uuid, {refuse_info = data.refuse_info})
    end
end

function party_handles.ls_clear_party_invite(uuid, host_uuid)
    local role = agent_utils.get_role(uuid)
    if role then
        role.party:clear_party_invite(host_uuid)
    end
end

return party_handles