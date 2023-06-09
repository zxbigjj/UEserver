local M = DECLARE_MODULE("lua_handles.gm")

local agent_gm = require("agent_gm")
local excel_data = require("excel_data")
local date = require("sys_utils.date")
local role_cls = require("role_cls")
local agent_utils = require("agent_utils")
local role_cache_utils = require("cache_utils")
local log_utils = require("log_utils")
local json = require("json")
local schema_game = require("schema_game")
local cluster_utils = require("msg_utils.cluster_utils")
local lover_activities_utils = require("lover_activities_utils")
local hero_activities_utils = require("hero_activities_utils")
local pack_activities_utils = require("pack_activities_utils")

local GM_HANDLE = {}

local function is_uuid_exist(uuid)
    if uuid then
        if role_cache_utils.get_role_info(uuid, {"uuid"}) then
            return true
        end
    end
    return false
end

function M.lc_yunwei_gm(args)
    print("lc_yunwei_gm : "..json.encode(args))
    local gm_name = args.gm_name
    if not GM_HANDLE[gm_name] then
        return false, "gm_name not exist"
    end
    local ok, is_success, data = xpcall(GM_HANDLE[gm_name], g_log.trace_handle, args)
    if ok then
        if is_success then
            g_log:yunwei(gm_name, {args=args, success=is_success, data=data})
            data = data or {}
        else
            g_log:yunwei(gm_name, {args=args, success=is_success, err_msg=data})
        end
        return is_success, data
    else
        g_log:yunwei(gm_name, {args=args, success=false, err_msg="server traceback"})
        return false, "server traceback"
    end
end

function M.lc_gm_copy_role(uuid)
    if not is_uuid_exist(uuid) then return end
    local data = {}

    local role = agent_utils.get_role(uuid)
    if role then
        data.main_db = table.deep_copy(role.db)
    else
        data.main_db = require("db.schema_game").Role:load(uuid)
    end

    return data
end

local function make_mail_attach(item_list)
    local attach = {}
    for _, info in ipairs(item_list or {}) do
        local item_id = tonumber(info.item_id)
        local count = tonumber(info.count)
        if not excel_data.ItemData[item_id] then
            return false, "item_id not exist:" .. tostring(info.item_id)
        end
        if count < 1 then
            return false, "item count <= 0"
        end
        table.insert(attach, {item_id=item_id, count=count})
    end
    if not next(attach) then
        attach = nil
    end
    return true, attach
end

function GM_HANDLE.test(args)
    -- local msg_info = {
    --     private_uuid="55000008",
    --     sender_vip=10,
    --     sender_role_id=2,
    --     sender_name="小二",
    --     sender_uuid="55000054",
    --     content="ttttttttttttt",
    --     sender_server_id=55,
    --     private_name="担忧的圣",
    --     chat_type=5
    -- }

    local msg_info = {
        sender_role_id=2,
        sender_uuid="55000067",
        chat_type=2,
        sender_vip=10,
        private_uuid="55000008",
        sender_server_id=55,
        private_name="担忧的圣",
        content="aaaaaaaaaaa",
        sender_name="小二",
    }


    local role_cls = agent_utils.get_role("55000006")
    role_cls:send_client("s_chat", msg_info)
end

function GM_HANDLE.forbid_speak(args)
    local uuid = args.uuid
    local end_ts = date.time_second() + tonumber(args.duration)
    local reason = args.reason or ""

    local data = {end_ts = end_ts, reason = reason}
    local role = agent_utils.get_role(uuid)
    if role then
        role.db.yw_forbid_speak = data
    else
        if not is_uuid_exist(uuid) then
            return false, g_tips.yunwei_uuid_not_exist
        end
        role_cls.write_db(uuid, "yw_forbid_speak", data)
    end
    return true, {end_ts=end_ts}
end

function GM_HANDLE.undo_forbid_speak(args)
    local uuid = args.uuid
    local role = agent_utils.get_role(uuid)
    if role then
        role.db.yw_forbid_speak = nil
    else
        if not is_uuid_exist(uuid) then
            return false, g_tips.yunwei_uuid_not_exist
        end
        role_cls.write_db(uuid, "yw_forbid_speak", nil)
    end
    return true, {}
end

function GM_HANDLE.query_user_info(args)
    local uuid = args.uuid or agent_utils.get_uuid_by_name(args.name)
    if not uuid then return false, g_tips.yunwei_uuid_not_exist end

    local db = role_cls.read_db(uuid, {
        "urs",
        "vip",
        "exp",
        "name",
        "level",
        "score",
        "currency",
        "login_ts",
        "hero_dict",
        "logout_ts",
        "create_ts",
        "lover_dict",
        "fight_score",
        "accum_recharge",
        "yw_forbid_login",
        "yw_forbid_speak",
    })

    if not db then return false, '请检查uuid或角色名' end

    local is_online = 0
    local now_ts = date.time_second()
    if date.now() > db.login_ts and date.now() < db.logout_ts  then
        is_online = 1
    end

    local info = {
        uuid = uuid,
        unit_id = 10,
        exp = db.exp,
        name = db.name,
        score = db.score,
        level = db.level,
        account = db.urs,
        is_online = is_online,
        vip = db.vip.vip_level,
        login_ts = db.login_ts,
        create_ts = db.create_ts,
        hero_dict = db.hero_dict,
        lover_dict = db.lover_dict,
        fight_score = db.fight_score,
        coin = db.currency[CSConst.Virtual.Money],
        vip_cost = db.accum_recharge.recharge_amount,
        diamond = db.currency[CSConst.Virtual.Diamond],
    }

    if db.yw_forbid_login and db.yw_forbid_login.end_ts > now_ts then
        info['is_forbid_login'] = true
        info['forbid_login_reason'] = db.yw_forbid_login.reason
        info['forbid_login_end_ts'] = db.yw_forbid_login.end_ts
    else
        info['is_forbid_login'] = false
    end

    if db.yw_forbid_speak and db.yw_forbid_speak.end_ts > now_ts then
        info['is_forbid_speak'] = true
        info['forbid_speak_reason'] = db.yw_forbid_speak.reason
        info['forbid_speak_end_ts'] = db.yw_forbid_speak.end_ts
    else
        info['is_forbid_speak'] = false
    end

    return true, info
end

-- function GM_HANDLE.query_forbid_speak(args)
--     local uuid = args.uuid
--     local role = agent_utils.get_role(uuid)
--     local data
--     if role then
--         data = role.db.yw_forbid_speak
--     else
--         if not is_uuid_exist(uuid) then
--             return false, g_tips.yunwei_uuid_not_exist
--         end
--         data = role_cls.read_db(uuid, {"yw_forbid_speak"})
--         data = data and data.yw_forbid_speak
--     end
--     if data and data.end_ts > date.time_second() then
--         return true, {is_forbid=true, end_ts=data.end_ts, reason=data.reason}
--     else
--         return true, {is_forbid=false}
--     end
-- end

function GM_HANDLE.forbid_login(args)
    local uuid = args.uuid
    local end_ts = date.time_second() + tonumber(args.duration)
    local reason = args.reason or ""

    local data = {end_ts = end_ts, reason = reason}
    local role = agent_utils.get_role(uuid)
    if role then
        role.db.yw_forbid_login = data
        role:kick()
    else
        local dict = role_cache_utils.get_role_info(uuid, {'urs'})
        if not dict or not dict.urs then
            return false, g_tips.yunwei_uuid_not_exist
        end
        role_cls.write_db(uuid, "yw_forbid_login", data)
    end
    return true, {end_ts=end_ts}
end

function GM_HANDLE.undo_forbid_login(args)
    local uuid = args.uuid

    local role = agent_utils.get_role(uuid)
    if role then
        role.db.yw_forbid_login = nil
    else
        local dict = role_cache_utils.get_role_info(uuid, {'urs'})
        if not dict or not dict.urs then
            return false, g_tips.yunwei_uuid_not_exist
        end
        role_cls.write_db(uuid, "yw_forbid_login", nil)
    end
    return true, {}
end

-- function GM_HANDLE.query_forbid_login(args)
--     local uuid = args.uuid

--     local role = agent_utils.get_role(uuid)
--     local info
--     if role then
--         info = role.db.yw_forbid_login
--     else
--         local dict = role_cache_utils.get_role_info(uuid, {'urs', 'yw_forbid_login'})
--         if not dict or not dict.urs then
--             return false, g_tips.yunwei_uuid_not_exist
--         end
--         info = dict.yw_forbid_login
--     end
--     if info and info.end_ts > date.time_second() then
--         return true, {is_forbid=true, end_ts=info.end_ts, reason=info.reason}
--     else
--         return true, {is_forbid=false}
--     end
-- end

function GM_HANDLE.kick_role(args)
    local uuid = args.uuid
    local role = agent_utils.get_role(uuid)
    if role then
        role:kick()
    end
    return true, {}
end

function GM_HANDLE.role_mail(args)
    local deadline_ts = tonumber(args.expire_ts)
    if deadline_ts <= 0 then
        return false, "expire_ts wrong:" .. tostring(args.expire_ts)
    end

    local ok, data = make_mail_attach(args.item_list)
    if not ok then
        return false, data
    end

    local fail_list = {}
    for _, uuid in ipairs(args.uuid_list) do
        uuid = tostring(uuid)
        if is_uuid_exist(uuid) then
            local role = agent_utils.get_role(uuid)
            local language
            if role then
                language = role:get_language()
            else
                local data = role_cls.read_db(uuid, {"language"})
                language = data and data.language
            end
            language = language or "chs"
            local mail_info = {
                mail_id = CSConst.MailId.Gm,
                title = args.title[language],
                content = args.content[language],
                deadline_ts = deadline_ts,
                item_list = data
            }
            agent_utils.add_mail(uuid, mail_info)
        else
            table.insert(fail_list, uuid)
        end
    end
    if next(fail_list) then
        return false, {fail_list=fail_list}
    else
        return true
    end
end

-- 全服邮件
function GM_HANDLE.global_mail(args)
    local deadline_ts = tonumber(args.expire_ts)
    if deadline_ts <= 0 then
        return false, "expire_ts wrong:" .. tostring(args.expire_ts)
    end

    local start_ts = tonumber(args.start_ts)
    if start_ts <= 0 then
        return false, "start_ts wrong:" .. tostring(args.start_ts)
    end

    local end_ts = tonumber(args.end_ts)
    if end_ts <= 0 then
        return false, "end_ts wrong:" .. tostring(args.end_ts)
    end

    if start_ts >= end_ts then
        return false, "start_ts must < end_ts"
    end

    local role_create_ts1 = tonumber(args.role_create_ts1)
    if role_create_ts1 <= 0 then
        return false, "role_create_ts1 wrong:" .. tostring(args.role_create_ts1)
    end

    local role_create_ts2 = tonumber(args.role_create_ts2)
    if role_create_ts2 <= 0 then
        return false, "role_create_ts2 wrong:" .. tostring(args.role_create_ts2)
    end

    if role_create_ts1 >= role_create_ts2 then
        return false, "role_create_ts1 must < role_create_ts2"
    end

    local is_all_channel = args.is_all_channel and true or false

    local ok, data = make_mail_attach(args.item_list)
    if not ok then
        return false, data
    end
    local attach = data

    local global_mail = require("global_mail")
    global_mail.add_global_mail(start_ts, end_ts, is_all_channel, args.channel,
        role_create_ts1, role_create_ts2,
        attach, args.title, args.content, deadline_ts)
    return true
end

-- 查询邮件
function GM_HANDLE.query_mail(args)
    local uuid = args.uuid

    local role = agent_utils.get_role(uuid)
    local mail_dict, language
    if role then
        mail_dict = role.db.mail_dict
        language = role.db.language
    else
        local dict = role_cache_utils.get_role_info(uuid, {'mail_dict', 'language'})
        if not dict then
            return false, g_tips.yunwei_uuid_not_exist
        end
        mail_dict = dict.mail_dict
        language = dict.language
    end

    local mail_list = {}
    for mail_guid, mail in pairs(mail_dict) do
        local mail_id = mail.mail_id
        local mail_data = excel_data.MailData[mail_id]
        local content = Translatecontent(mail_data.content, language)
        if mail.mail_args then
            content = string.render(content, mail.mail_args)
        end
        table.insert(mail_list, {
            mail_guid = mail.mail_guid,
            mail_id = mail_id,
            content = mail.content or content,
            title = mail.title or Translatecontent(mail_data.name, language),
            send_ts = mail.send_ts,
            deadline_ts = mail.deadline_ts,
            is_read = mail.is_read,
            is_get_item = mail.is_get_item,
            item_list = mail.item_list,
        })
    end
    return true, {mail_list = mail_list}
end

-- 删除邮件
function GM_HANDLE.delete_mail(args)
    local uuid = args.uuid
    local mail_guid = args.mail_guid

    local role = agent_utils.get_role(uuid)
    if role then
        role.db.mail_dict[mail_guid] = nil
    else
        local data = role_cls.read_db(uuid, {"mail_dict"})
        if data and data.mail_dict then
            data.mail_dict[mail_guid] = nil
            role_cls.write_db(uuid, "mail_dict", data.mail_dict)
        end
    end
    return true, {}
end

-- 跑马灯公告
function GM_HANDLE.add_roll_notice(args)
    local start_ts = tonumber(args.start_ts)
    if start_ts <= 0 then
        return false, "start_ts wrong:" .. tostring(args.start_ts)
    end

    local end_ts = tonumber(args.end_ts)
    if end_ts <= 0 then
        return false, "end_ts wrong:" .. tostring(args.end_ts)
    end

    if start_ts >= end_ts then
        return false, "start_ts must < end_ts"
    end

    local interval = tonumber(args.interval)
    if interval < 1 then
        return false, "interval must >= 1"
    end

    if type(args.content) ~= 'string' or args.content == "" then
        return false, "content error"
    end

    local notice_id = require("server_data").add_roll_notice(args.content,
        start_ts, end_ts, interval)
    return true, {notice_id=notice_id}
end

function GM_HANDLE.delete_roll_notice(args)
    local notice_id = tonumber(args.notice_id)
    local ok = require("server_data").delete_roll_notice(notice_id)
    return true, {delete_success=ok}
end

function GM_HANDLE.query_roll_notice(args)
    local notice_list = require("server_data").get_all_roll_notice()
    return true, {notice_list=notice_list}
end

-- 编辑跑马灯公告
function GM_HANDLE.edit_roll_notice(args)
    local start_ts = tonumber(args.start_ts)
    if start_ts <= 0 then
        return false, "start_ts wrong:" .. tostring(args.start_ts)
    end

    local end_ts = tonumber(args.end_ts)
    if end_ts <= 0 then
        return false, "end_ts wrong:" .. tostring(args.end_ts)
    end

    if start_ts >= end_ts then
        return false, "start_ts must < end_ts"
    end

    local interval = tonumber(args.interval)
    if interval < 1 then
        return false, "interval must >= 1"
    end

    if type(args.content) ~= 'string' or args.content == "" then
        return false, "content error"
    end

    if not require("server_data").edit_roll_notice(args.notice_id, args.content, start_ts, end_ts, interval) then
        return false, "notice_id error"
    end
    return true, {}
end

function GM_HANDLE.rename_role(args)
    local uuid = args.uuid
    local new_name = args.new_name
    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    if not require("CSCommon.CSFunction").check_player_name_legality(new_name) then
        return false, "The name is illegal"
    end
    local name_utils = require("name_utils")
    if name_utils.is_role_name_repeat(new_name) then
        return false, "The name is repeat"
    end
    if not name_utils.use_role_name(uuid, new_name) then
        return false, "use name error"
    end

    local old_name
    local role = agent_utils.get_role(uuid)
    if role then
        old_name = role.db.name
        name_utils.unuse_role_name(old_name)
        role.db.name = new_name
        role:on_rename()
    else
        local data = role_cls.read_db(uuid, {"name"})
        if not data or not data.name then
            return false, g_tips.yunwei_uuid_not_exist
        end
        old_name = data.name
        name_utils.unuse_role_name(old_name)
        role_cls.write_db(uuid, 'name', new_name)
        require("offline_cmd").push_on_rename(uuid)
    end
    log_utils.gaea_log(uuid, "RoleName", {oldName = old_name, newName = new_name})
    return true, {change_ok=true}
end

-- 添加货币
function GM_HANDLE.add_currency(args)
    local uuid = args.uuid
    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    local currency_id = tonumber(args.currency_id)
    if not excel_data.ItemData[currency_id] then
        return false, "currency_id wrong:" .. tostring(args.currency_id)
    end
    local count = tonumber(args.count)
    if count <= 0 then
        return false, "count wrong:" .. tostring(args.count)
    end

    local currency_num
    local role = agent_utils.get_role(uuid)
    if role then
        if not role:add_currency(currency_id, count, g_reason.yunwei_gm) then
            return false, "add_currency wrong:" .. tostring(args.currency_id)
        end
        currency_num = role:get_item_count(currency_id)
    else
        local data = role_cls.read_db(uuid, {"currency"})
        if not data or not data.currency then
            return false, g_tips.yunwei_uuid_not_exist
        end
        data.currency[currency_id] = data.currency[currency_id] + count
        currency_num = data.currency[currency_id]
        role_cls.write_db(uuid, 'currency', data.currency)
        log_utils.gaea_log(uuid, "VirtualCoin", {
            coinNum = count,
            coinType = CSConst.LogCoinName[currency_id] or "",
            type = g_reason.yunwei_gm or "",
            isGain = 1,
            totalCoin = currency_num,
        })
    end
    return true, {currency_id = currency_id, currency_num = currency_num}
end

-- 删除货币
function GM_HANDLE.delete_currency(args)
    local uuid = args.uuid
    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    local currency_id = tonumber(args.currency_id)
    if not excel_data.ItemData[currency_id] then
        return false, "currency_id wrong:" .. tostring(args.currency_id)
    end
    local count = tonumber(args.count)
    if count <= 0 then
        return false, "count wrong:" .. tostring(args.count)
    end

    local currency_num
    local role = agent_utils.get_role(uuid)
    if role then
        local num = role:get_item_count(currency_id)
        if count > num then
            count = num
        end
        currency_num = num - count
        if count > 0 and not role:sub_currency(currency_id, count, g_reason.yunwei_gm) then
            return false, "sub_currency wrong:" .. tostring(args.currency_id)
        end
    else
        local data = role_cls.read_db(uuid, {"currency"})
        if not data or not data.currency then
            return false, g_tips.yunwei_uuid_not_exist
        end
        if count > data.currency[currency_id] then
            count = data.currency[currency_id]
        end
        data.currency[currency_id] = data.currency[currency_id] - count
        currency_num = data.currency[currency_id]
        role_cls.write_db(uuid, 'currency', data.currency)
        log_utils.gaea_log(uuid, "VirtualCoin", {
            coinNum = count,
            coinType = CSConst.LogCoinName[currency_id] or "",
            type = g_reason.yunwei_gm or "",
            isGain = 0,
            totalCoin = currency_num,
        })
    end
    return true, {currency_id = currency_id, currency_num = currency_num}
end

-- 添加道具
function GM_HANDLE.add_item(args)
    local uuid = args.uuid
    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    local item_id = tonumber(args.item_id)
    local item_data = excel_data.ItemData[item_id]
    if not item_data then
        return false, "item_id wrong:" .. tostring(args.item_id)
    end
    local count = tonumber(args.count)
    if count <= 0 then
        return false, "count wrong:" .. tostring(args.count)
    end

    local item_num
    local role = agent_utils.get_role(uuid)
    if role then
        role:add_item(item_id, count, g_reason.yunwei_gm)
        item_num = role:get_item_count(item_id)
    else
        local data = role_cls.read_db(uuid, {"bag_item_list", "guid"})
        if not data or not data.bag_item_list then
            return false, g_tips.yunwei_uuid_not_exist
        end
        if item_data.item_type == CSConst.ItemType.Equip then
            for i=1, count do
                data.guid = data.guid + 1
                DB_LIST_INSERT(data.bag_item_list, {
                    guid = data.guid .. string.rand_string(2) .. "_" .. item_id,
                    item_id = item_id,
                    count = 1,
                    star_lv = 0,
                    refine_lv = 0,
                    refine_exp = 0,
                    strengthen_lv = 1,
                    strengthen_exp = 0,
                    smelt_lv = 0,
                    smelt_exp = 0,
                    lucky_value = 0,
                })
            end
        else
            data.guid = data.guid + 1
            DB_LIST_INSERT(data.bag_item_list, {
                guid = data.guid .. string.rand_string(2) .. "_" .. item_id,
                item_id = item_id,
                count = count,
            })
        end
        role_cls.write_db(uuid, 'guid', data.guid)
        role_cls.write_db(uuid, 'bag_item_list', data.bag_item_list)

        item_num = 0
        for _, item in ipairs(data.bag_item_list) do
            if item.item_id == item_id then
                item_num = item_num + item.count
            end
        end
        log_utils.gaea_log(uuid, "AddItem", {
            itemId = item_id,
            itemType = ItemTypeName(item_id),
            itemCnt = count,
            itemTotal = item_num,
            reason = g_reason.yunwei_gm,
        })
    end
    return true, {item_id = item_id, item_num = item_num}
end

-- 删除道具
function GM_HANDLE.delete_item(args)
    local uuid = args.uuid or agent_utils.get_uuid_by_name(args.name)
    if not uuid then return false, g_tips.yunwei_uuid_not_exist end

    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    local count = tonumber(args.count)
    if count <= 0 then
        return false, "count wrong:" .. tostring(args.count)
    end

    local item_num, item_id
    -- local role = agent_utils.get_role(uuid)
    -- if role then
    --     local item = role:get_bag_item(args.guid)
    --     if not item then
    --         return false, "item not exist"
    --     end
    --     if count > item.count then
    --         count = item.count
    --     end
    --     item_id = item.item_id
    --     item_num = item.count - count
    --     if count > 0 and not role:consume_item(item_id, count, g_reason.yunwei_gm) then
    --         return false, "consume_item wrong"
    --     end
    -- else

    local data = role_cls.read_db(uuid, {"bag_item_list"})
    if not data or not data.bag_item_list then
        return false, g_tips.yunwei_uuid_not_exist
    end
    for i, item in ipairs(data.bag_item_list) do
        if item.item_id == tonumber(args.guid) then
            item_id = item.item_id
            if item.count > count then
                item.count = item.count - count
                item_num = item.count
                break
            else
                DB_LIST_REMOVE(data.bag_item_list, i)
                item_num = 0
                break
            end
        end
    end
    role_cls.write_db(uuid, 'bag_item_list', data.bag_item_list)
    log_utils.gaea_log(uuid, "ConsumeItem", {
        itemId = item_id,
        itemType = ItemTypeName(item_id),
        itemCnt = count,
        itemTotal = item_num,
        reason = g_reason.yunwei_gm,
    })

    -- end
    return true, {item_id = item_id, item_num = item_num}
end

function GM_HANDLE.query_bag(args)
    local uuid = args.uuid
    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end

    local bag_item_list
    local role = agent_utils.get_role(uuid)
    if role then
        bag_item_list = role.db.bag_item_list
    else
        bag_item_list = require("role_cls").read_db(uuid, {"bag_item_list"}).bag_item_list
    end

    local ItemData = excel_data.ItemData
    local all_item = {}
    for _, item in ipairs(bag_item_list) do
        table.insert(all_item, {
            guid = item.guid,
            item_id = item.item_id,
            count = item.count,
            name = ItemData[item.item_id].name,
            star_lv = item.star_lv,
            refine_lv = item.refine_lv,
            strengthen_lv = item.strengthen_lv,
            smelt_lv = item.smelt_lv,
        })
    end
    return true, {item_list=all_item}
end

-- 设置Vip
function GM_HANDLE.set_role_vip(args)
    local vip_level = tonumber(args.vip_level)
    local uuid = tostring(args.uuid)
    if not is_uuid_exist(uuid) then return false, g_tips.yunwei_uuid_not_exist end
    local status, resp = agent_gm.on_gm(uuid, "set_vip", vip_level)
    if status then return true, resp
    else return false, "请检查角色是否在线" end
end

-- 跳关
function GM_HANDLE.set_role_stage_to(args)
    local stage = args.stage
    local uuid = tostring(args.uuid)
    if not is_uuid_exist(uuid) then return false, g_tips.yunwei_uuid_not_exist end
    local status, resp = agent_gm.on_gm(uuid, "to_stage", stage)
    if status then return true, resp
    else return false, "操作失败" end
end

function GM_HANDLE.query_role_level(args)
    local uuid = tostring(args.uuid)
    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    local db = role_cls.read_db(uuid, {
        "name",
        "level",
        "exp",
    })
    local info = {
        name = db.name,
        level = db.level,
        exp = db.exp,
    }

    return true, info
end

function GM_HANDLE.set_role_level(args)
    local uuid = tostring(args.uuid)
    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    local level = tonumber(args.level)
    if level <= 0 then
        return false, "level wrong:" .. tostring(args.level)
    end

    local info = {}
    local role = agent_utils.get_role(uuid)
    if role then
        role:set_level(level, g_reason.yunwei_gm)
        info.level = role.db.level
        info.exp = role.db.exp
    else
        local data = role_cls.read_db(uuid, {"level", "exp"})
        if not data then
            return false, g_tips.yunwei_uuid_not_exist
        end
        local old_level = data.level
        local old_exp = data.exp
        local max_level = #excel_data.LevelData
        if level > max_level then
            level = max_level
        end
        role_cls.write_db(uuid, 'level', level)
        local exp = excel_data.LevelData[level].exp
        role_cls.write_db(uuid, 'exp', exp)
        info.level = level
        info.exp = exp
        log_utils.gaea_log(uuid, "RoleLvlup", {oldLevel = old_level, newLevel = level})
        log_utils.gaea_log(uuid, "RoleExp", {
            expNum = exp - old_exp,
            oldExp = old_exp,
            newExp = exp,
            reason = g_reason.yunwei_gm,
        })
    end

    return true, info
end

function GM_HANDLE.add_role_exp(args)
    local uuid = tostring(args.uuid)
    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    local count = tonumber(args.count)
    if count <= 0 then
        return false, "count wrong:" .. tostring(args.count)
    end

    local info = {}
    local role = agent_utils.get_role(uuid)
    if role then
        role:add_exp(count, g_reason.yunwei_gm, true)
        info.level = role.db.level
        info.exp = role.db.exp
    else
        local data = role_cls.read_db(uuid, {"level", "exp"})
        if not data then
            return false, g_tips.yunwei_uuid_not_exist
        end
        local old_level = data.level
        local old_exp = data.exp
        local new_exp = old_exp + count
        local new_level
        local max_level = #excel_data.LevelData
        if old_level < max_level then
            for i = old_level+1, max_level do
                if new_exp < excel_data.LevelData[i].exp then
                    break
                end
                new_level = i
            end
        end
        role_cls.write_db(uuid, 'exp', new_exp)
        if new_level then
            role_cls.write_db(uuid, 'level', new_level)
            log_utils.gaea_log(uuid, "RoleLvlup", {oldLevel = old_level, newLevel = new_level})
        end
        info.level = new_level or old_level
        info.exp = new_exp
        log_utils.gaea_log(uuid, "RoleExp", {
            expNum = count,
            oldExp = old_exp,
            newExp = new_exp,
            reason = g_reason.yunwei_gm,
        })
    end

    return true, info
end

function GM_HANDLE.delete_role_exp(args)
    local uuid = tostring(args.uuid)
    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    local count = tonumber(args.count)
    if count <= 0 then
        return false, "count wrong:" .. tostring(args.count)
    end

    local info = {}
    local role = agent_utils.get_role(uuid)
    if role then
        role:delete_exp(count, g_reason.yunwei_gm)
        info.level = role.db.level
        info.exp = role.db.exp
    else
        local data = role_cls.read_db(uuid, {"level", "exp"})
        if not data then
            return false, g_tips.yunwei_uuid_not_exist
        end
        local old_level = data.level
        local old_exp = data.exp
        if count > old_exp then
            count = old_exp
        end
        local new_exp = old_exp - count
        local new_level
        if old_exp > 0 then
            local LevelData = excel_data.LevelData
            if old_level > 1 then
                for i = old_level, 1, -1 do
                    if new_exp >= LevelData[i].exp then
                        break
                    end
                    new_level = i - 1
                end
            end
            role_cls.write_db(uuid, 'exp', new_exp)
            if new_level then
                role_cls.write_db(uuid, 'level', new_level)
                log_utils.gaea_log(uuid, "RoleLvlup", {oldLevel = old_level, newLevel = new_level})
            end
        end
        info.level = new_level or old_level
        info.exp = new_exp
        log_utils.gaea_log(uuid, "RoleExp", {
            expNum = count,
            oldExp = old_exp,
            newExp = new_exp,
            reason = g_reason.yunwei_gm,
        })
    end

    return true, info
end

function GM_HANDLE.add_rank_forbid(args)
    local uuid = args.uuid
    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end

    local rank_id = tostring(args.rank_id)
    local data = excel_data.RankData[rank_id]
    if not data then
        return false, "rank_id is wrong"
    end
    if data.is_dynasty_rank then
        return false, "cannot set dynasty rank"
    end
    require('rank_utils').add_rank_forbid(rank_id, uuid)
    return true
end

function GM_HANDLE.query_rank_forbid(args)
    local all_forbid = require('rank_utils').query_forbid_list()
    return true, {all_forbid = all_forbid}
end

-- function GM_HANDLE.query_uuid(args)
--     local uuid = agent_utils.get_uuid_by_name(args.name)
--     if not uuid then
--         return false, "no this role name:" .. args.name
--     else
--         return true, {uuid = uuid}
--     end
-- end

function GM_HANDLE.copy_role(args)
    local cluster_utils = require("msg_utils.cluster_utils")

    local from_server_id = args.from_server_id
    local from_uuid = args.from_uuid
    if cluster_utils.get_role_server_id(from_uuid) ~= from_server_id then
        return false, "from_server_id do not match from_uuid"
    end

    local to_uuid = args.uuid
    local name = args.name
    if not is_uuid_exist(to_uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end

    if not require("CSCommon.CSFunction").check_player_name_legality(name) then
        return false, "The name is illegal"
    end
    -- 先检查下名字
    local name_utils = require("name_utils")
    if name_utils.is_role_name_repeat(name) then
        return false, "The name is repeat"
    end

    local data = cluster_utils.call_agent(nil, from_uuid, "lc_gm_copy_role")
    if not data then
        return false, "cannot find from_uuid"
    end
    local role = agent_utils.get_role(to_uuid)
    if role then
        role:kick()
    end
    if not name_utils.use_role_name(to_uuid, name) then
        return false, "use name error"
    end
    data.main_db.name = name
    data.main_db.urs = require("role_cls").read_db(to_uuid, {"urs"}).urs
    data.main_db.uuid = to_uuid
    if require("schema_game").Role:set_field({uuid = to_uuid}, data.main_db) then
        return true, {new_uuid = to_uuid}
    else
        return false, "copy fail"
    end
end

function GM_HANDLE.query_uuid(args)
    local uuid = agent_utils.get_uuid_by_name(args.name)
    if not uuid then
        return false, "no this role name:" .. args.name
    else
        return true, {uuid = uuid}
    end
end

-- 充值：todo
function GM_HANDLE.imitate_recharge(args)
    print("imitate_recharge args :"..json.encode(args))
    local uuid = args.uuid
    local order_id = args.order_id
    g_log:warn("imitate_recharge:"..order_id)
   -- local order_info = schema_game.order.load(order_id)--(tonumber(order_id))
    local order_info = schema_game.order:get_db_client():query_one("select * from t_order where order_id = "..order_id)
    print("imitate_recharge order_info :"..json.encode(order_info))

    if not order_info then
        return false, "order is not exist"
    end

    if not is_uuid_exist(uuid) then
    return false, g_tips.yunwei_uuid_not_exist
    end
    local data = excel_data.RechargeData[tonumber(order_info.recharge_id)]
    if not data then
    return false, "recharge_id is wrong"
    end
    if order_info.product_number <= 0 then
    return false, "count is wrong"
    end

    local role = agent_utils.get_role(uuid)
    if role then
    for i = 1, order_info.product_number do
    role:role_recharge(tonumber(order_info.recharge_id))
    end
    role.recharge:online()
    else

    end
    return true
    end

-- 验证订单
function GM_HANDLE.validation_recharge(args)
    print("validation_recharge args :"..json.encode(args))
    local uuid = args.uuid
    local price = tonumber(args.price);
    local order_id = args.order_id
    local count = tonumber(args.count)
    local recharge_id = tonumber(args.recharge_id)
    local order_info = schema_game.order:get_db_client():query_one("select * from t_order where order_id = "..order_id)
    print("validation_recharge order_info :"..json.encode(order_info))
    if not order_info then
        return false, "order is not exist"
    end

    if recharge_id ~= order_info.recharge_id then
        return false, "recharge_id error"
    end
    if uuid ~= order_info.uuid then
        return false, "uuid error"
    end

    if count ~= order_info.product_number then
        return false, "count error"
    end

    if price ~= order_info.local_price then
        return false, "price error"
    end

    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    role.recharge:activation_recharge_activities(order_info.local_price)
    return true , "ok"
end

-- 月卡充值：todo
function GM_HANDLE.imitate_yueka_recharge(args)
    print("imitate_yueka_recharge args :"..json.encode(args))
    local uuid = args.uuid

    --local price = tonumber(args.price);
    local order_id = args.order_id
    --local count = tonumber(args.count)
    --local card_id = tonumber(args.card_id)
    print("imitate_yueka_recharge order_id :"..order_id)
    --local order_info = schema_game.CardOrder.load(order_id)
    local order_info = schema_game.order:get_db_client():query_one("select * from t_cardorder where order_id = "..order_id)
    print("imitate_yueka_recharge order_info :"..json.encode(order_info))
    if not order_info then
        return false, "order is not exist"
    end

    --if card_id ~= order_info.card_id then
    --    return false, "recharge_id error"
    --end
    --
    --if count ~= order_info.product_number then
    --    return false, "count error"
    --end
    --
    --if price ~= order_info.local_price then
    --    return false, "price error"
    --end

    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    if order_info.product_number <= 0 then
        return false, "count is wrong"
    end
    print("imitate_yueka_recharge uuid："..uuid)
    local role = agent_utils.get_role(uuid)
   -- print("imitate_yueka_recharge role："..json.encode(role))
    if role then
        print("imitate_yueka_recharge role1："..uuid.."order_info.card_id:"..order_info.card_id..",order_info.product_number:"..order_info.product_number)--..json.encode(role))
        for i = 1, tonumber(order_info.product_number+1) do
            role.monthly_card:buy_card(order_info.card_id)
        end
        role.monthly_card:on_online()
    else
        g_log:warn("imitate_yueka_recharge role warn:"..uuid)
    end
    role.recharge:activation_recharge_activities(order_info.local_price)
    return true
end

-- 验证月卡订单
function GM_HANDLE.validation_yueka_recharge(args)
    print("imitate_yueka_recharge args :"..json.encode(args))
    local uuid = args.uuid

    local price = tonumber(args.price);
    local order_id = args.order_id
    local count = tonumber(args.count)
    local card_id = tonumber(args.card_id)
    local order_info = schema_game.CardOrder.load(tonumber(order_id))

    if not order_info then
        return false, "order is not exist"
    end

    if uuid ~= order_info.uuid then
        return false, "uuid error"
    end

    if card_id ~= order_info.card_id then
        return false, "recharge_id error"
    end

    if count ~= order_info.product_number then
        return false, "count error"
    end

    if price ~= order_info.local_price then
        return false, "price error"
    end


    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end

    if count <= 0 then
        return false, "count is wrong"
    end
    return true, "ok"
end

-- 情人礼包充值：todo
function GM_HANDLE.imitate_loverpackage_recharge(args)
    print("imitate_loverpackage_recharge args :"..json.encode(args))
    local uuid = args.uuid
    local order_id = args.order_id
    local order_info = schema_game.LoverPackageOrder:get_db_client():query_one("select * from t_loverpackageorder where order_id = "..order_id)

    if not order_info then
        return false, "order is not exist"
    end


    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    if order_info.product_number <= 0 then
        return false, "count is wrong"
    end

    local role = agent_utils.get_role(uuid)

    if role then
        for i = 1, order_info.product_number do
            local lover_activities_info = schema_game.LoverActivities:load(tonumber(order_info.package_id))
            local item_list = lover_activities_info.item_list

            local reward_dict = {}
            for k, v in ipairs(item_list) do
                reward_dict[v.item_id] = v.count
            end

            local reason = g_reason.lover_package
            role:add_item_dict(reward_dict, reason)

            local  args =  {
                ['uuid'] = uuid,
                ['id']  =  order_info.package_id
            }
            local flag ,info = lover_activities_utils.buy_ongoing_lover_activities(args)
            print("activityInfo :"..json.encode(info))
            if flag then
                local times =  info.deal_count
                local lover_activity_id = info.lover_activity_id
                local status = 1
                if info.deal_count >=  info.purchase_count then
                    status =  0
                end
                local activityInfo = {
                    ['times'] = times;
                    ['lover_activity_id'] =lover_activity_id ,
                    ['status'] = status
                }
                print("activityInfo :"..json.encode(activityInfo))
                role:send_client("s_update_lover_activity", activityInfo)
            end
        end
    end
    role.recharge:activation_recharge_activities(order_info.local_price)
    return true
end

-- 验证情人礼包订单
function GM_HANDLE.validation_loverpackage_recharge(args)
    print("imitate_loverpackage_recharge args :"..json.encode(args))
    local uuid = args.uuid

    local price = tonumber(args.price);
    local order_id = args.order_id
    local count = tonumber(args.count)
    local package_id = tonumber(args.package_id)
    local order_info = schema_game.LoverPackageOrder:get_db_client():query_one("select * from t_loverpackageorder where order_id = "..order_id)

    if not order_info then
        return false, "order is not exist"
    end

    if package_id ~= order_info.package_id then
        return false, "recharge_id error"
    end

    if count ~= order_info.product_number then
        return false, "count error"
    end
    if uuid ~= order_info.uuid then
        return false, "count error"
    end

    if price ~= order_info.local_price then
        return false, "price error"
    end


    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    if count <= 0 then
        return false, "count is wrong"
    end
    return true , "ok"
end

-- 模拟英雄礼包充值：todo
function GM_HANDLE.imitate_heropackage_recharge(args)
    print("imitate_heropackage_recharge args :"..json.encode(args))
    local uuid = args.uuid

    --local price = tonumber(args.price);
    local order_id = args.order_id
    --local count = tonumber(args.count)
    --local package_id = tonumber(args.package_id)
    local order_info = schema_game.HeroPackageOrder:get_db_client():query_one("select * from t_heropackageorder where order_id = "..order_id)

    if not order_info then
        return false, "order is not exist"
    end
    --
    --if package_id ~= order_info.package_id then
    --    return false, "recharge_id error"
    --end
    --
    --if count ~= order_info.product_number then
    --    return false, "count error"
    --end
    --
    --if price ~= order_info.local_price then
    --    return false, "price error"
    --end

    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end

    if order_info.product_number <= 0 then
        return false, "count is wrong"
    end

    local role = agent_utils.get_role(uuid)

    if role then
        for i = 1, order_info.product_number do
            local hero_activities_info = schema_game.HeroActivities:load(tonumber(order_info.package_id))
            local item_list = hero_activities_info.item_list

            local reward_dict = {}
            for k, v in ipairs(item_list) do
                reward_dict[v.item_id] = v.count
            end

            local reason = g_reason.hero_package
            role:add_item_dict(reward_dict, reason)
            local  args =  {
                ['uuid'] = uuid,
                ['id']  =  order_info.package_id
            }
            local flag , info = hero_activities_utils.buy_ongoing_hero_activities(args)
            print("activityInfo :"..json.encode(info))
            if flag then
                local times =  info.deal_count
                local hero_activity_id = info.hero_activity_id
                local status = 1
                if info.deal_count >=  info.purchase_count then
                    status =  0
                end
                local activityInfo = {
                    ['times'] = times;
                    ['hero_activity_id'] =hero_activity_id ,
                    ['status'] = status
                }
                print("activityInfo :"..json.encode(activityInfo))
                role:send_client("s_update_hero_activity", activityInfo)
            end
        end
    end
    role.recharge:activation_recharge_activities(order_info.local_price)
    return true
end

-- 验证英雄礼包订单
function GM_HANDLE.validation_heropackage_recharge(args)
    print("imitate_heropackage_recharge args :"..json.encode(args))
    local uuid = args.uuid

    local price = tonumber(args.price);
    local order_id = args.order_id
    local count = tonumber(args.count)
    local package_id = tonumber(args.package_id)
    local order_info = schema_game.HeroPackageOrder:get_db_client():query_one("select * from t_heropackageorder where order_id = "..order_id)

    if not order_info then
        return false, "order is not exist"
    end

    if package_id ~= order_info.package_id then
        return false, "recharge_id error"
    end

    if uuid ~= order_info.uuid then
        return false, "uuid error"
    end


    if count ~= order_info.product_number then
        return false, "count error"
    end

    if price ~= order_info.local_price then
        return false, "price error"
    end

    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end

    if count <= 0 then
        return false, "count is wrong"
    end
    return true , "ok"
end


function GM_HANDLE.imitate_giftpackage_recharge(args)
    print("imitate_giftpackage_recharge args :"..json.encode(args))
    local uuid = args.uuid
    local order_id = args.order_id
    local order_info = schema_game.GiftPackageOrder:get_db_client():query_one("select * from t_giftpackageorder where order_id = "..order_id)
    if not order_info then
        return false, "order is not exist"
    end

    if order_info.status ~= 0 then
        print("imitate_giftpackage_recharge order had used order_info :"..json.encode(order_info))
        return true
    end

    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end

    print("===order_info === "..json.encode(order_info))
    schema_game.GiftPackageOrder:get_db_client():query("update t_giftpackageorder  set status = 2 where order_id = '"..order_id.."'")

    if order_info.product_number <= 0 then
        return false, "count is wrong"
    end

    local role = agent_utils.get_role(uuid)

    if role then
        role.daily_gift_package_activities:send_gift_reward(role , order_info.gift_id)
    end
    role.recharge:activation_recharge_activities(order_info.local_price)
    return true
end

function GM_HANDLE.add_questionnaire(args)
    local start_ts = tonumber(args.start_ts)
    if start_ts <= 0 then
        return false, "start_ts wrong:" .. tostring(args.start_ts)
    end

    local end_ts = tonumber(args.end_ts)
    if end_ts <= 0 then
        return false, "end_ts wrong:" .. tostring(args.end_ts)
    end

    if start_ts >= end_ts then
        return false, "start_ts must < end_ts"
    end
    return require("questionnaire").add_question(start_ts, end_ts, args.activity_id, args.title, args.role_minlv)
end

function GM_HANDLE.questionnaire_reward(args)
    local uuid = args.uuid
    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    return require("questionnaire").give_question_reward(uuid, args.activity_id)
end

--修改服务器时间
function GM_HANDLE.set_serverTimes(args)
    print('======修改系统时间======' .. args.servertime)
    return true
    --return agent_gm.offset_time(args.servertime)
end

-------------------------------------------------------- 情人礼包 & 英雄礼包
local function make_gift_activities_attach(item_list)
    if not next(item_list) then return false, nil end
    local attach = {}
    for item_key, item_value in pairs(item_list) do
        local item_id = tonumber(item_key)
        local count = tonumber(item_value)
        if not excel_data.ItemData[item_id] then
            return false, "item_id not exist:" .. tostring(item_id)
        end
        if count < 1 then return false, "item count <= 0" end
        table.insert(attach, { item_id = item_id, count = count })
    end
    return true, attach
end

function GM_HANDLE.add_lover_activities(args)
    args.gm_name = nil
    -- if args.end_ts <= 0 then return false, "end_ts wrong:" .. tostring(args.end_ts) end
    -- if args.start_ts >= args.end_ts then return false, "end_ts must > now" end
    local ok, item_list_data = make_gift_activities_attach(args.item_list)
    if not ok then return false, item_list_data end
    if item_list_data then args.item_list = item_list_data else args.item_list = nil end
    args.end_ts = date.time_second() + 60 * args.refresh_interval
    local result = schema_game.LoverActivities:insert(nil, args)
    local role_online_list = agent_utils.get_online_uuid()
    for _, uuid in pairs(role_online_list) do
        print("======= uuid : " .. uuid)
        local role_cls = agent_utils.get_role(uuid)
        role_cls.lover_activities:set_activities_timer()
    end
    if result then return true, result end
end

function GM_HANDLE.edit_lover_activities(args)
    args.gm_name = nil
    -- if args.end_ts <= 0 then return false, "end_ts wrong:" .. tostring(args.end_ts) end
    -- if args.start_ts >= args.end_ts then return false, "end_ts must > now" end
    local ok, item_list_data = make_gift_activities_attach(args.item_list)
    if not ok then return false, item_list_data end
    if item_list_data then args.item_list = item_list_data else args.item_list = nil end
    args.end_ts = date.time_second() + 60 * args.refresh_interval
    local result = schema_game.LoverActivities:set_field({ id = args.id }, args)
    local role_online_list = agent_utils.get_online_uuid()
    for _, uuid in pairs(role_online_list) do
        print("======= uuid : " .. uuid)
        local role_cls = agent_utils.get_role(uuid)
        role_cls.lover_activities:set_activities_timer()
    end
    if result then return true, result end
end

function GM_HANDLE.del_lover_activities(args)
    local result = schema_game.LoverActivities:delete(args.id)
    local role_online_list = agent_utils.get_online_uuid()
    for _, uuid in pairs(role_online_list) do
        print("======= uuid : " .. uuid)
        local role_cls = agent_utils.get_role(uuid)
        role_cls.lover_activities:delete_activity(args.id)
    end
    if not result then return true, result end
end

function GM_HANDLE.query_lover_activities(args)
    local result = schema_game.LoverActivities:load_many()
    if result then return true, result end
end

-- function GM_HANDLE.set_lover_activities(args)
--     local lover_activities_info = {
--         status = args.status,
--         end_ts = date.time_second() + 60 * args.refresh_interval,   -- 刷新时间,分
--     }
--     local result = schema_game.LoverActivities:set_field({id = args.id}, lover_activities_info)
--     if result then return true, result end
-- end

----------------------------------------
function GM_HANDLE.add_hero_activities(args)
    local data = {
        server_id = args.server_id,
        goods_name = args.goods_name,
        end_ts = date.time_second() + 60 * args.refresh_interval,
        price = args.price, discount = args.discount, item_list = args.item_list,
        icon = args.icon, status = args.status, refresh_interval = args.refresh_interval,
        activity_name_fir = args.activity_name_fir, activity_name_sec = args.activity_name_sec,
        hero_id = args.hero_id, hero_left_id = args.hero_left_id, hero_right_id = args.hero_right_id,
    }
    local ok, item_list_data = make_gift_activities_attach(data.item_list)
    if not ok then return false, item_list_data end
    if item_list_data then data.item_list = item_list_data else data.item_list = nil end
    local result = schema_game.HeroActivities:insert(nil, data)
    local role_online_list = agent_utils.get_online_uuid()
    for _, uuid in pairs(role_online_list) do
        print("======= uuid : " .. uuid)
        local role_cls = agent_utils.get_role(uuid)
        role_cls.hero_activities:set_activities_timer()
    end
    if result then return true, result end
end

function GM_HANDLE.edit_hero_activities(args)
    local data = {
        id = args.id,
        server_id = args.server_id,
        goods_name = args.goods_name,
        end_ts = date.time_second() + 60 * args.refresh_interval,
        price = args.price, discount = args.discount, item_list = args.item_list,
        icon = args.icon, status = args.status, refresh_interval = args.refresh_interval,
        activity_name_fir = args.activity_name_fir, activity_name_sec = args.activity_name_sec,
        hero_id = args.hero_id, hero_left_id = args.hero_left_id, hero_right_id = args.hero_right_id,
    }
    local ok, item_list_data = make_gift_activities_attach(data.item_list)
    if not ok then return false, item_list_data end
    if item_list_data then data.item_list = item_list_data else data.item_list = nil end
    local result = schema_game.HeroActivities:set_field({ id = data.id }, data)
    local role_online_list = agent_utils.get_online_uuid()
    for _, uuid in pairs(role_online_list) do
        print("======= uuid : " .. uuid)
        local role_cls = agent_utils.get_role(uuid)
        role_cls.lover_activities:set_activities_timer()
    end
    if result then return true, result end
end

function GM_HANDLE.del_hero_activities(args)
    local result = schema_game.HeroActivities:delete(args.id)
    if not result then return true, result end
end

function GM_HANDLE.query_hero_activities(args)
    local result = schema_game.HeroActivities:load_many()
    if result then return true, result end
end

------------------------------------------------------
function GM_HANDLE.query_by_sql(args)
    local db_cfg = require("srv_utils.server_env").get_db_cfg("gamedb")
    local client = require("db.mysql_db").new(db_cfg)
    local result = client:query(args.cmd)
    client:close()
    if result then return true, result end
end

------------------------------------------------------ 王朝
function GM_HANDLE.seek_dynasty(args)
    local dynasty_name = args.dynasty_name
    local dynasty_info = cluster_utils.call_dynasty("lc_seek_dynasty", nil, dynasty_name)
    print("====== dynasty_info: ".. json.encode(dynasty_info))
    if dynasty_info then return true, dynasty_info end
end

function GM_HANDLE.add_dynasty_exp(args)
    local dynasty_id = tostring(args.dynasty_id)
    local uuid = args.uuid
    local dynasty_exp = tonumber(args.dynasty_exp)
    cluster_utils.send_dynasty("ls_add_dynasty_exp_by_id", dynasty_id, dynasty_exp)
    return true, dynasty_exp
end

------------------------------------------------------ Server
function GM_HANDLE.get_server_info_role_online(args)
    local role_online_list = agent_utils.get_online_uuid()

    local db_cfg = require("srv_utils.server_env").get_db_cfg("gamedb")
    local client = require("db.mysql_db").new(db_cfg)
    local result = client:query("select count(*) from t_Role")
    client:close()

    local response = {
        role_online_num = #role_online_list,
        role_total_num = result[1]['count(*)']
    }

    print("-- role online info: " .. json.encode(response))
    return true, response
end


return M
