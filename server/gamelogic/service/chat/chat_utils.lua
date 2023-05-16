local cluster_utils = require("msg_utils.cluster_utils")
local chat_utils = DECLARE_MODULE("chat_utils")

local function get_node_name(uuid)
    return cluster_utils.get_agent_gate_node_name(uuid)
end

local all_chat_channel = DECLARE_RUNNING_ATTR(chat_utils, "all_chat_channel", {})

local ChatChannel = DECLARE_CLASS(chat_utils, "ChatChannel")
function ChatChannel.New(name)
    local self = {}
    self.name = name
    self.uuid_dict = {}
    self.node_dict = {}
    setmetatable(self, ChatChannel)

    all_chat_channel[name] = self
    return self
end

function ChatChannel:add(uuid)
    local node_name = get_node_name(uuid)
    if self.uuid_dict[uuid] then return end
    self.uuid_dict[uuid] = node_name
    if not self.node_dict[node_name] then
        self.node_dict[node_name] = {}
    end
    table.insert(self.node_dict[node_name], uuid)
end

function ChatChannel:remove(uuid)
    local node_name = self.uuid_dict[uuid]
    if not node_name then return end
    self.uuid_dict[uuid] = nil
    table.delete(self.node_dict[node_name], uuid)
    if not next(self.node_dict[node_name]) then
        self.node_dict[node_name] = nil
    end
    if not next(self.uuid_dict) then
        all_chat_channel[self.name] = nil
    end
end

function ChatChannel:dissolve()
    self.uuid_dict = nil
    self.node_dict = nil
    all_chat_channel[self.name] = nil
end

function ChatChannel:broad_chat(msg)
    if self.name == g_const.ChatChannelName.World then
        print("==== in world")
        -- 全服广播时，uuid_list传nil
        for node_name in pairs(self.node_dict) do
            cluster_utils.broad_client_msg(node_name, nil, "s_chat", msg)
        end
    else
        print("==== not in world")
        for node_name, uuid_list in pairs(self.node_dict) do
            cluster_utils.broad_client_msg(node_name, uuid_list, "s_chat", msg)
            -- add in here
        end
    end
end

---------------------------------------------------------------
function chat_utils.enter_channel(uuid, channel_name)
    local channel = all_chat_channel[channel_name] or ChatChannel.New(channel_name)
    channel:add(uuid)
end

function chat_utils.leave_channel(uuid, channel_name)
    local channel = all_chat_channel[channel_name]
    if channel then
        channel:remove(uuid)
    end
end

function chat_utils.dissolve_channel(channel_name)
    local channel = all_chat_channel[channel_name]
    if channel then
        channel:dissolve()
    end
end

function chat_utils.broad_chat(channel_name, msg)
    local channel = all_chat_channel[channel_name]
    if channel then
        channel:broad_chat(msg)
    end
end

return chat_utils