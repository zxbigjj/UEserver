local global_mail = DECLARE_MODULE("global_mail")

local OfflineObjMgr = require("db.offline_db").OfflineObjMgr
local date = require("sys_utils.date")
local timer = require("timer")
local server_data = require("server_data")


local Mail_DB = DECLARE_RUNNING_ATTR(global_mail, "_mail_db", nil, function()
    return OfflineObjMgr.new(require("schema_game")["GlobalMail"])
end)

local Mail_Timer = DECLARE_RUNNING_ATTR(global_mail, "_mail_timer", {})

local Mail_Guid_Mapper = DECLARE_RUNNING_ATTR(global_mail, "_mail_guid_mapper", {})

-- 加载全服邮件
function global_mail.load_all_mail()
    Mail_DB:load_all()
    local now_ts = date.time_second()
    for _, v in pairs(Mail_DB:get_all()) do
        if not v.last_global_mail_id then
            local delay_seconds = v.start_ts - now_ts
            if delay_seconds > 0 then
                global_mail.add_mail_timer(v.guid, delay_seconds)
            else
                global_mail.mail_take_effect(v)
            end
        else
            Mail_Guid_Mapper[v.last_global_mail_id] = v.guid
        end
    end
end

-- 发送全服邮件
function global_mail.add_global_mail(start_ts, end_ts, is_all_channel, channel, role_create_ts1, role_create_ts2, attach, title, content, deadline_ts)
    local param = {
        start_ts = start_ts,
        end_ts = end_ts,
        is_all_channel=is_all_channel,
        channel=channel,
        role_create_ts1=role_create_ts1,
        role_create_ts2=role_create_ts2,
        attach = attach,
        title = title,
        content = content,
        deadline_ts = deadline_ts,
    }
    global_mail._add_global_mail(param)
end

function global_mail._add_global_mail(param)
    local guid = nil
    for i = 1, 100 do
        guid = string.rand_string(8)
        if not Mail_DB:get_all()[guid] then
            break
        end
        guid = nil
    end
    if not guid then return end
    local db_obj = Mail_DB:get(guid)
    table.update(db_obj, param)
    Mail_DB:set(guid, db_obj)
    local delay_seconds = db_obj.start_ts - date.time_second()
    if delay_seconds > 0 then
        -- 未来某个时间点发送
        global_mail.add_mail_timer(guid, delay_seconds)
    else
        -- 立即生效
        global_mail.mail_take_effect(db_obj)
    end
end

function global_mail.mail_take_effect(db_obj)
    local last_global_mail_id = server_data.get_server_core("last_global_mail_id") + 1
    server_data.set_server_core("last_global_mail_id", last_global_mail_id)
    db_obj.last_global_mail_id = last_global_mail_id
    Mail_Guid_Mapper[last_global_mail_id] = db_obj.guid
    Mail_DB:set(db_obj.guid, db_obj)

    skynet.timeout(1, function()
        for i, uuid in pairs(agent_utils.get_online_uuid()) do
            local role = agent_utils.get_role(uuid)
            if role then
                global_mail.check_send_global_mail(role)
            end
            if i%10 == 0 then
                skynet.sleep(1)
            end
        end
    end)
end

function global_mail.check_send_global_mail(role)
    local start = role.db.last_global_mail + 1
    for i = start, server_data.get_server_core("last_global_mail_id") do
        role.db.last_global_mail = i
        global_mail._send_global_mail(i, role)
    end
end

function global_mail._send_global_mail(last_global_mail_id, role)
    local mail_guid = Mail_Guid_Mapper[last_global_mail_id]
    if not mail_guid then return end
    local mail = Mail_DB:get(mail_guid)
    local now_ts = date.time_second()
    if now_ts < mail.start_ts or now_ts > mail.end_ts then return end
    if not mail.is_all_channel and mail.channel ~= role:get_channel() then
        return
    end
    local create_ts = role:get_create_ts()
    if create_ts < mail.role_create_ts1 or create_ts > mail.role_create_ts2 then
        return
    end
    local language = role:get_language() or "chs"
    local mail_info = {
        mail_id = CSConst.MailId.Gm,
        title = mail.title[language],
        content = mail.content[language],
        deadline_ts = math.floor(mail.deadline_ts),
        item_list = mail.attach,
    }
    role:add_mail(mail_info)
    return true
end

function global_mail.add_mail_timer(guid, delay_seconds)
    global_mail.delete_mail_timer(guid)
    Mail_Timer[guid] = timer.once(delay_seconds, function()
        global_mail.mail_take_effect(Mail_DB:get(guid))
        global_mail.delete_mail_timer(guid)
    end)
end

function global_mail.delete_mail_timer(guid)
    if not Mail_Timer[guid] then return end
    Mail_Timer[guid]:cancel()
    Mail_Timer[guid] = nil
end

return global_mail