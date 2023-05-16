local json = require "cjson"
local date = require "sys_utils.date"
local schema_cross = require "schema_cross"
local timer        = require "timer"
-- local const        = require "lualib.const"
local chat_history = DECLARE_MODULE("chat_history")
local chat_history_dict = DECLARE_RUNNING_ATTR(chat_history, "chat_history_dict", {})
local chat_history_save_timer = DECLARE_RUNNING_ATTR(chat_history, "chat_history_save_timer", nil)

---------------------------------------------------
function chat_history.init()
    local db_list = schema_cross.Chat:load_many()
    for _, value_list in pairs(db_list) do
        chat_history_dict[value_list.uuid] = value_list.chat_msg
    end

    chat_history_save_timer = timer.loop(600, function ()
        print(" ======= ")
        chat_history.save()
    end, 600)
end

function chat_history.save()
    for uuid, msg_info_list in pairs(chat_history_dict) do
        if schema_cross.Chat:load(uuid) then
            schema_cross.Chat:set_field({uuid = uuid}, msg_info_list)
        else
            schema_cross.Chat:insert(uuid, msg_info_list)
        end
    end
end

--------------
function chat_history.update_chat_msg(msg)
    if not msg.sender_uuid then return end
    msg.send_ts = date.time_second()

    print("------ add in dict ------")
    if chat_history_dict[msg.sender_uuid] then
        local chat_info_list = chat_history_dict[msg.sender_uuid][msg.chat_type]
        table.insert(chat_info_list, 1, msg)
    else
        chat_history_dict[msg.sender_uuid] = {{},{},{},{},{}}
        chat_history_dict[msg.sender_uuid][msg.chat_type] = { [1] = msg }
    end
end

function chat_history.get_chat_history(uuid)
    if not uuid then return end

    -- chat_history.update_chat_msg({
    --     sender_role_id=2,
    --     sender_uuid="55000001",
    --     sender_name="小二",
    --     chat_type=2,
    --     sender_server_id=55,
    --     content="tttttttttttt",
    --     sender_vip=10
    -- })

    local chat_info = chat_history_dict[uuid]
    print("==------== chat_history: " .. json.encode(chat_history_dict))
    return chat_info
end

return chat_history