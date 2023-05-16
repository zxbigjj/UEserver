local date = require("sys_utils.date")
local excel_data = require("excel_data")

local MAIL_PAST_TS = 30 * 24 * 60 * 60

local role_mail = DECLARE_MODULE("meta_table.mail")

function role_mail.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
        deadline_timer_dict = {}
    }
    return setmetatable(self, role_mail)
end

function role_mail:load_mail()
    local now = date.time_second()
    local mail_dict = self.db.mail_dict
    local past_mail_list = {}
    for _, mail in pairs(mail_dict) do
        if now >= mail.deadline_ts then
            table.insert(past_mail_list, mail.mail_guid)
        end
    end
    -- 清除过期邮件
    for _, mail_guid in ipairs(past_mail_list) do
        mail_dict[mail_guid] = nil
    end
    self:check_deadline_mail()
end

function role_mail:check_deadline_mail()
    local mail_dict = self.db.mail_dict
    local past_mail_list = {}
    for _, mail in pairs(mail_dict) do
        self:set_mail_deadline_timer(mail)
    end
end

function role_mail:set_mail_deadline_timer(mail)
    local left_time = mail.deadline_ts - date.time_second()
    if left_time < CSConst.Time.Hour then
        local mail_guid = mail.mail_guid
        if not self.deadline_timer_dict[mail_guid] then
            self.deadline_timer_dict[mail_guid] = self.role:timer_once(left_time, function ()
                self.deadline_timer_dict[mail_guid] = nil
                self:clear_mail(mail_guid)
            end)
        end
    end
end

function role_mail:clear_mail(mail_guid)
    local mail_dict = self.db.mail_dict
    local mail = mail_dict[mail_guid]
    if not mail then return end
    mail_dict[mail_guid] = nil
    self.role:send_client("s_update_deadline_mail", {has_unread = self:check_has_unread_mail()})
    self.role:log("DeleteMail", {mail = mail})
    self.role:gaea_log("RoleMail", {
        opType = g_const.LogMailOpType.delete,
        mailId = mail.mail_id,
        content = mail.content or self:get_mail_content(mail.mail_id, mail.mail_args),
        attach = mail.item_list or {}
    })
end

function role_mail:check_has_unread_mail()
    local has_unread
    local mail_dict = self.db.mail_dict
    for _, mail in pairs(mail_dict) do
        if not mail.is_read or (mail.item_list and not mail.is_get_item) then
            has_unread = true
            break
        end
    end
    return has_unread
end

function role_mail:online_mail()
    self.role:send_client("s_online_mail", {has_unread = self:check_has_unread_mail()})
end

-- 获取邮件内容
function role_mail:get_mail_content(mail_id, mail_args)
    local mail_data = excel_data.MailData[mail_id]
    local language = self.role:get_language()
    local content = Translatecontent(mail_data.content, language)
    if mail_args then
        return string.render(content, mail_args)
    else
        return content
    end
end

-- 获取全部邮件
function role_mail:get_all_mail()
    local all_mail = {}
    local language = self.role:get_language()
    local mail_dict = self.db.mail_dict
    for mail_guid, mail in pairs(mail_dict) do
        local mail_id = mail.mail_id
        local mail_data = excel_data.MailData[mail_id]
        all_mail[mail_guid] = {
            mail_guid = mail.mail_guid,
            mail_id = mail_id,
            content = mail.content or self:get_mail_content(mail_id, mail.mail_args),
            title = mail.title or Translatecontent(mail_data.name, language),
            send_ts = mail.send_ts,
            deadline_ts = mail.deadline_ts,
            is_read = mail.is_read,
            is_get_item = mail.is_get_item,
            item_list = mail.item_list,
        }
    end
    return {all_mail = all_mail}
end

-- 添加邮件
function role_mail:add_mail(mail_info)
    mail_info = g_const.StMailInfo(mail_info)
    local mail_id = mail_info.mail_id
    local mail_data = excel_data.MailData[mail_id]
    if not mail_data then return end
    local mail_guid = self.role:new_guid() .. string.rand_string(5)
    local item_list = mail_info.item_list
    if mail_data.item_list then
        item_list = item_list or {}
        for i, item_id in ipairs(mail_data.item_list) do
            table.insert(item_list, {item_id = item_id, count = mail_data.item_value_list[i]})
        end
    end
    local send_ts = mail_info.send_ts or date.time_second()
    local mail = {
        mail_guid = mail_guid,
        mail_id = mail_id,
        content = mail_info.content,
        mail_args = mail_info.mail_args,
        title = mail_info.title,
        item_list = item_list,
        send_ts = send_ts,
        deadline_ts = mail_info.deadline_ts or (send_ts + MAIL_PAST_TS),
        is_read = false,
        is_get_item = false,
    }
    self.db.mail_dict[mail_guid] = mail
    self:set_mail_deadline_timer(mail)
    self.role:send_client("s_add_mail", {})
    self.role:log("AddMail", {mail = mail})
    self.role:gaea_log("RoleMail", {
        opType = g_const.LogMailOpType.recv,
        mailId = mail_id,
        content = mail_info.content or self:get_mail_content(mail.mail_id, mail.mail_args),
        attach = item_list or {}
    })
end

-- 一键删除邮件
function role_mail:quick_delete_mail(mail_type)
    local mail_dict = self.db.mail_dict
    local delete_mail_list = {}
    local mail_data = excel_data.MailData
    for _, mail in pairs(mail_dict) do
        -- 只删除已读取并且没有附件或者附件已领取的邮件
        if not mail_type or mail_data[mail.mail_id].mail_type == mail_type then
            -- mail_type 存在时只删除同一种类型的邮件
            if (mail.is_read and not mail.item_list) or mail.is_get_item then
                table.insert(delete_mail_list, mail.mail_guid)
            end
        end
    end
    if next(delete_mail_list) then
        for _, mail_guid in ipairs(delete_mail_list) do
            local mail = mail_dict[mail_guid]
            mail_dict[mail_guid] = nil
            if self.deadline_timer_dict[mail_guid] then
                self.deadline_timer_dict[mail_guid]:cancel()
                self.deadline_timer_dict[mail_guid] = nil
            end
            self.role:log("DeleteMail", {mail = mail})
            self.role:gaea_log("RoleMail", {
                opType = g_const.LogMailOpType.delete,
                mailId = mail.mail_id,
                content = mail.content or self:get_mail_content(mail.mail_id, mail.mail_args),
                attach = mail.item_list or {}
            })
        end
    end
    return {mail_guid_list = delete_mail_list}
end

-- 读邮件
function role_mail:read_mail(mail_guid)
    local mail = self.db.mail_dict[mail_guid]
    if not mail then return end
    mail.is_read = true
    return true
end

-- 领取附件
function role_mail:get_mail_item(mail_guid)
    local mail = self.db.mail_dict[mail_guid]
    if not mail or not mail.item_list then return end
    if mail.is_get_item then return end
    mail.is_get_item = true
    mail.is_read = true
    self.role:add_item_list(mail.item_list, g_reason.mail)
    self.role:gaea_log("RoleMail", {
        opType = g_const.LogMailOpType.pick,
        mailId = mail.mail_id,
        content = mail.content or self:get_mail_content(mail.mail_id, mail.mail_args),
        attach = mail.item_list
    })
    return {mail_guid_list = {mail_guid}}
end

-- 一键领取附件
function role_mail:quick_get_mail_item(mail_type)
    local mail_dict = self.db.mail_dict
    local item_list = {}
    local mail_guid_list = {}
    local mail_data = excel_data.MailData
    for mail_id, mail in pairs(mail_dict) do
        if not mail_type or mail_data[mail.mail_id].mail_type == mail_type then
            -- mail_type 存在时只领取同一种类型的邮件
            if mail.item_list and not mail.is_get_item then
                mail.is_get_item = true
                mail.is_read = true
                table.insert(mail_guid_list, mail.mail_guid)
                table.extend(item_list, mail.item_list)
                self.role:gaea_log("RoleMail", {
                    opType = g_const.LogMailOpType.pick,
                    mailId = mail.mail_id,
                    content = mail.content or self:get_mail_content(mail.mail_id, mail.mail_args),
                    attach = mail.item_list
                })
            end
        end
    end
    if next(item_list) then
        self.role:add_item_list(item_list, g_reason.mail)
    end
    return {mail_guid_list = mail_guid_list}
end

return role_mail