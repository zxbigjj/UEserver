local schema_game = require('schema_game')

local server_name = require("srv_utils.server_env").get_server_name()
local db_mapper = {
    ServerCore = "_server_core",
}

assert(skynet.localname('.agent') == skynet.self())

local server_data = DECLARE_MODULE("server_data")
DECLARE_RUNNING_ATTR(server_data, "_roll_notice_timer", {})

for db_name, name in pairs(db_mapper) do
    DECLARE_RUNNING_ATTR(server_data, name, nil)
    server_data["get" .. name] = function(field_name)
        return server_data[name][field_name]
    end
    server_data["set" .. name] = function(field_name, value)
        server_data[name][field_name] = value
        skynet.fork(function()
            schema_game[db_name]:set_field(
                schema_game[db_name]:make_key_query(server_name),
                {[field_name] = (value==nil and SQL_NULL or value)})
        end)
    end
    server_data["multiset" .. name] = function(kv_pairs)
        local obj = server_data[name]
        local kv = {}
        for k,v in pairs(kv_pairs) do
            obj[k] = v
            kv[k] = (v==nil and SQL_NULL or v)
        end
        skynet.fork(function()
            schema_game[db_name]:set_field(
                schema_game[db_name]:make_key_query(server_name),
                kv)
        end)
    end
end

function server_data.load_all()
    for db_name, name in pairs(db_mapper) do
        local schema = schema_game[db_name]
        local db = schema:load(server_name)
        if not db then
            db = schema:insert(server_name)
        end
        assert(db, "db create fail:" .. db_name)
        server_data[name] = db
    end
end

function server_data.save_all()
    for db_name, name in pairs(db_mapper) do
        schema_game[db_name]:save(server_data[name])
    end
end

function server_data.start()
    server_data.load_all()

    local db = server_data.get_server_core("yw_roll_notice")
    local now = require("sys_utils.date").time_second()
    if db then
        local delete_list = {}
        for i, notice in ipairs(db.notice_list) do
            if notice.end_ts < now then
                table.insert(delete_list, notice.notice_id)
            else
                server_data.check_start_roll_notice(notice)
            end
        end
        for i, notice_id in ipairs(delete_list) do
            server_data.delete_roll_notice(notice_id)
        end
    end
end

function server_data.roll_notice_cb(notice)
    if notice.end_ts < require("sys_utils.date").time_second() then
        server_data.delete_roll_notice(notice.notice_id)
        return
    end
    require("agent_utils").broadcast_server_notice({notice_content=notice.content})
end

function server_data.check_start_roll_notice(notice)
    local now = require("sys_utils.date").time_second()
    if notice.end_ts < now then return end
    local callback = function()
        server_data.roll_notice_cb(notice)
    end
    local timer = require("timer").loop(notice.interval, callback, notice.start_ts - now)
    server_data._roll_notice_timer[notice.notice_id] = timer
end

function server_data.add_roll_notice(content, start_ts, end_ts, interval)
    local db = server_data.get_server_core("yw_roll_notice")
    db = db or {last_id = 0, notice_list={}}

    local new_id = db.last_id + 1
    db.last_id = new_id
    local new_notice = {
        notice_id = db.last_id,
        content = content,
        start_ts = start_ts,
        end_ts = end_ts,
        interval = interval,
    }
    table.insert(db.notice_list, new_notice)
    server_data.set_server_core('yw_roll_notice', db)
    server_data.check_start_roll_notice(new_notice)
    g_log:info("AddRollNotice", new_notice)
    return new_id
end

function server_data.delete_roll_notice(notice_id)
    local db = server_data.get_server_core("yw_roll_notice")
    if not db then return false end
    local del_notice
    for i, notice in ipairs(db.notice_list) do
        if notice.notice_id == notice_id then
            table.remove(db.notice_list, i)
            del_notice = notice
            break
        end
    end
    if not del_notice then return false end
    server_data.set_server_core('yw_roll_notice', db)
    local timer = server_data._roll_notice_timer[notice_id]
    if timer then
        timer:cancel()
        server_data._roll_notice_timer[notice_id] = nil
    end
    g_log:info("DelRollNotice", del_notice)
    return true
end

function server_data.get_all_roll_notice()
    local db = server_data.get_server_core("yw_roll_notice")
    if not db then return {} end
    return table.deep_copy(db.notice_list)
end

function server_data.edit_roll_notice(notice_id, content, start_ts, end_ts, interval)
    local db = server_data.get_server_core("yw_roll_notice")
    if not db then return end
    local index
    for i, v in ipairs(db.notice_list) do
        if v.notice_id == notice_id then
            index = i
            break
        end
    end
    if not index then return end

    local notice = db.notice_list[index]
    notice.content = content
    notice.start_ts = start_ts
    notice.end_ts = end_ts
    notice.interval = interval
    server_data.set_server_core('yw_roll_notice', db)
    local timer = server_data._roll_notice_timer[notice_id]
    if timer then
        timer:cancel()
        server_data._roll_notice_timer[notice_id] = nil
    end
    server_data.check_start_roll_notice(notice)
    g_log:info("EditRollNotice", notice)
    return true
end

return server_data