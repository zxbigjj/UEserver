local cluster_utils = require("msg_utils.cluster_utils")
local role_db = require("role_db")

local role_chat = DECLARE_MODULE("meta_table.chat")

local CHAT = "Chat"
local Chat_Broad = {
    [CSConst.ChatType.World] = "send_world_chat",
    [CSConst.ChatType.Cross] = "send_cross_chat",
    [CSConst.ChatType.Dynasty] = "send_dynasty_chat",
    [CSConst.ChatType.Private] = "send_private_chat",
}

function role_chat.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
    }
    return setmetatable(self, role_chat)
end

function role_chat:load_chat()
    self:enter_world_chat()
    self:enter_cross_chat()
end

function role_chat:logout_chat()
    self:leave_world_chat()
    self:leave_cross_chat()
end

function role_chat:send_chat_msg(msg)
    if self.role:yw_is_forbid_speak() then
        return false, CSConst.ChatTips.ForbidSpeak
    end
    local func = Chat_Broad[msg.chat_type]
    if func then
        msg.sender_name = self.role:get_name()
        msg.sender_uuid = self.uuid
        msg.sender_vip = self.role:get_vip()
        msg.sender_role_id = self.role:get_role_id()
        msg.sender_server_id = cluster_utils.get_server_id(self.uuid)
        msg.sender_title = self.role:get_title()

        self.role:gaea_log("RoleChat", {
            chatType = msg.chat_type,
            content = msg.content,
            privateUuid = msg.private_uuid or ""
        })
        return self[func](self, msg)
    end
end

--world
function role_chat:enter_world_chat()
    cluster_utils.enter_chat(self.uuid, g_const.ChatChannelName.World)
end

function role_chat:leave_world_chat()
    cluster_utils.leave_chat(self.uuid, g_const.ChatChannelName.World)
end

function role_chat:send_world_chat(msg)
    cluster_utils.broad_chat(self.uuid, g_const.ChatChannelName.World, msg)
    return true
end

--cross
function role_chat:enter_cross_chat()
    cluster_utils.enter_cross_chat(self.uuid, g_const.ChatChannelName.Cross)
end

function role_chat:leave_cross_chat()
    cluster_utils.leave_cross_chat(self.uuid, g_const.ChatChannelName.Cross)
end

function role_chat:send_cross_chat(msg)
    cluster_utils.broad_cross_chat(self.uuid, g_const.ChatChannelName.Cross, msg)
    return true
end

--dynasty
function role_chat:send_dynasty_chat(msg)
    local dynasty_id = self.role:get_dynasty_id()
    if not dynasty_id then return end
    local channel_name = g_const.ChatChannelName.Dynasty .. dynasty_id
    cluster_utils.broad_chat(self.uuid, channel_name, msg)
    return true
end

-- 私聊
function role_chat:send_private_chat(msg)
    local json = require("cjson")
	print("===: " .. json.encode(msg))

	if not msg.private_uuid then return end
    if not self.role:can_private_chat(msg.private_uuid) then
        return false, CSConst.ChatTips.BlackListFriend
    end
    if not cluster_utils.is_player_uuid_valid(msg.private_uuid) then
        return false, CSConst.ChatTips.PlayerNotExist
    end
    if not cluster_utils.call_agent(nil, msg.private_uuid, "lc_private_chat", msg) then
        return false, CSConst.ChatTips.PlayerOffline
    end
    if self.uuid ~= msg.private_uuid then
	print("===" .. json.encode(msg))
	self.role:send_client("s_chat", msg)
    end
    return true
end

return role_chat
