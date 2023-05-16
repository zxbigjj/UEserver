local M = DECLARE_MODULE("questionnaire")

local OfflineObjMgr = require("db.offline_db").OfflineObjMgr
local date = require("sys_utils.date")
local timer = require("timer")
local server_data = require("server_data")
local excel_data = require("excel_data")

local Question_DB = DECLARE_RUNNING_ATTR(M, "_question_db", nil, function()
    return OfflineObjMgr.new(require("schema_game")["Questionnaire"])
end)

local Question_Timer = DECLARE_RUNNING_ATTR(M, "_question_timer", {})
local Question_Guid_Mapper = DECLARE_RUNNING_ATTR(M, "_question_guid_mapper", {})
local Question_Actid_Mapper = DECLARE_RUNNING_ATTR(M, "_question_actid_mapper", {})

function M.load_all_question()
    Question_DB:load_all()
    local now_ts = date.time_second()
    for _, v in pairs(Question_DB:get_all()) do
        if not v.question_id then
            local delay_seconds = v.start_ts - now_ts
            if delay_seconds > 0 then
                M.add_question_timer(v.guid, delay_seconds)
            else
                M.question_take_effect(v)
            end
        else
            Question_Guid_Mapper[v.question_id] = v.guid
        end
        Question_Actid_Mapper[v.activity_id] = v.guid
    end
end

function M.add_question(start_ts, end_ts, activity_id, title, role_minlv)
    if Question_Actid_Mapper[activity_id] then
        return false, "this question activity_id is already exist"
    end
    local guid = nil
    for i = 1, 100 do
        guid = string.rand_string(8)
        if not Question_DB:get_all()[guid] then break end
        guid = nil
    end
    if not guid then return end
    local db_obj = Question_DB:get(guid)
    local param = {
        guid = guid,
        title = title,
        start_ts = start_ts,
        end_ts = end_ts,
        role_minlv = role_minlv,
        activity_id = activity_id
    }
    table.update(db_obj, param)
    Question_Actid_Mapper[activity_id] = guid
    Question_DB:set(guid, db_obj)
    local delay_seconds = db_obj.start_ts - date.time_second()
    if delay_seconds > 0 then
        M.add_question_timer(guid, delay_seconds)
    else
        M.question_take_effect(db_obj)
    end
    return true
end

function M.question_take_effect(db_obj)
    local last_question_id = server_data.get_server_core("last_question_id") + 1
    server_data.set_server_core("last_question_id", last_question_id)
    db_obj.question_id = last_question_id
    Question_Guid_Mapper[last_question_id] = db_obj.guid
    Question_DB:set(db_obj.guid, db_obj)
    skynet.timeout(1, function()
        local agent_utils = require("agent_utils")
        for i, uuid in pairs(agent_utils.get_online_uuid()) do
            local role = agent_utils.get_role(uuid)
            if role then
                M.check_send_question(role)
            end
            if i%10 == 0 then
                skynet.sleep(1)
            end
        end
    end)
end

function M.check_send_question(role)
    local now_ts = date.time_second()
    local start = (role.db.questionnaire.last_id or 0) + 1
    for i = start, server_data.get_server_core("last_question_id") do
        M._send_question(i, role)
    end
end

function M._send_question(last_question_id, role)
    local guid = Question_Guid_Mapper[last_question_id]
    if not guid then return end
    local question = Question_DB:get(guid)
    local now_ts = date.time_second()
    if now_ts < question.start_ts or now_ts > question.end_ts then return end
    if role:get_level() < question.role_minlv then return end
    role:send_client("s_update_quetionnaire", {
        op_type = CSConst.OperateType.Add,
        title = question.title,
        activity_id = question.activity_id,
        start_ts = question.start_ts,
        end_ts = question.end_ts,
    })
end

function M.add_question_timer(guid, delay_seconds)
    M.delete_question_timer(guid)
    Question_Timer[guid] = timer.once(delay_seconds, function()
        M.question_take_effect(Question_DB:get(guid))
        M.delete_question_timer(guid)
    end)
end

function M.delete_question_timer(guid)
    if not Question_Timer[guid] then return end
    Question_Timer[guid]:cancel()
    Question_Timer[guid] = nil
end

function M.give_question_reward(uuid, activity_id)
    local role = agent_utils.get_role(uuid)
    local db = nil
    if role then
        db = role.db.questionnaire
    else
        db = require("role_cls").read_db(uuid, {"questionnaire"}).questionnaire
    end
    db.reward_dict = db.reward_dict or {}
    if db.reward_dict[activity_id] then
        return false, "the activity_id questionnaire reward already pick"
    end
    db.reward_dict[activity_id] = true
    db.last_id = db.last_id or 0
    db.last_id = db.last_id + 1
    local item_list = excel_data.ParamData["questionnaire_reward"].item_list
    agent_utils.add_mail(uuid, {mail_id = CSConst.MailId.Questionnaire, item_list = table.deep_copy(item_list)})
    if role then
        role:send_client("s_update_quetionnaire", {
            op_type = CSConst.OperateType.Del,
            activity_id = activity_id,
        })
    else
        require("role_cls").write_db(uuid, "questionnaire", db)
    end
    return true
end

return M