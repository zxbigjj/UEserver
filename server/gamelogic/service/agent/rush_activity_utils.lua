local timer = require("timer")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local rank_utils = require("rank_utils")
local agent_utils = require("agent_utils")
local schema_game = require("schema_game")
local server_data = require("server_data")
local cluster_utils = require("msg_utils.cluster_utils")
local STATE = CSConst.ActivityState -- 活动状态

local rush_activity_utils = DECLARE_MODULE("rush_activity_utils")
local ActivityClass = DECLARE_CLASS(rush_activity_utils, "ActivityClass")

-- activity_id => activity_obj
local activity_dict = DECLARE_RUNNING_ATTR(rush_activity_utils, "activity_dict", {}) -- 所有的活动对象

-- rank_name => activity_id
local rank_to_activity_dict = DECLARE_RUNNING_ATTR(rush_activity_utils, "rank_to_activity_dict", {})

-- item_id => activity_id
local item_to_activity_dict = DECLARE_RUNNING_ATTR(rush_activity_utils, "item_to_activity_dict", {})

-- 启动时初始化
function rush_activity_utils.start()
    print("=====================")
    print("rush activity start")
    print("=====================")
    local first_start_ts = date.get_begin0(server_data.get_server_core("server_open_time"))
    local last_shutdown_ts = server_data.get_server_core("last_shutdown_ts")
    for _, data in pairs(excel_data.RushActivityData) do
        ActivityClass.new(data, first_start_ts, last_shutdown_ts)
    end
    for activity_id, activity_obj in pairs(activity_dict) do
        if activity_id == CSConst.RushActivityType.dynasty then
            if activity_obj.state == STATE.started then
                cluster_utils.send_dynasty("ls_notify_rush_list_activity_start")
            else
                cluster_utils.send_dynasty("ls_notify_rush_list_activity_stop")
            end
            break
        end
    end
    for _, data in ipairs(schema_game.RushActivityTitle:load_many()) do
        if data.current_uuid then
            local exldata = excel_data.ItemData[data.title_id]
            local expire_ts = data.history_list[#data.history_list].ts + exldata.validity_period_sec
            local now_ts = date.time_second()
            if expire_ts <= now_ts then
                schema_game.RushActivityTitle:set_field({title_id = data.title_id}, {current_uuid = SQL_NULL})
            else
                timer.once(expire_ts - now_ts, function() notify_title_expired(data.title_id) end)
            end
        end
    end
end

-- 记录关闭时间
function rush_activity_utils.shutdown()
    server_data.set_server_core("last_shutdown_ts", date.time_second())
end

-- 检查活动是否可用(started), 返回 boolean
function rush_activity_utils.check_activity_is_available(activity_id)
    if not activity_id then return end
    local activity_obj = activity_dict[activity_id]
    if not activity_obj then return end
    if activity_obj.state == STATE.started then
        return true
    end
end

-- 检查排行榜是否可用(started|stopped), 返回 activity_id
function rush_activity_utils.check_rank_is_available(rank_name)
    if not rank_name then return end
    local activity_id = rank_to_activity_dict[rank_name]
    if not activity_id then return end
    local state = activity_dict[activity_id].state
    if state == STATE.started or state == STATE.stopped then
        return activity_id
    end
end

-- 构造 activity_obj
function ActivityClass.new(data, first_start_ts, last_shutdown_ts)
    local self = setmetatable({}, ActivityClass)
    self.id           = data.id
    self.offset_sec   = data.offset   * CSConst.Time.Day
    self.duration_sec = data.duration * CSConst.Time.Day
    self.reserve_sec  = data.reserve  * CSConst.Time.Day
    self.loop_sec     = data.loop     * CSConst.Time.Day - self.reserve_sec
    self.rank_name    = data.rank
    activity_dict[self.id] = self
    rank_to_activity_dict[self.rank_name] = self.id
    if data.item_id then item_to_activity_dict[data.item_id] = self.id end
    self:init(first_start_ts, last_shutdown_ts)
    return self
end

-- 初始化 activity_obj
function ActivityClass:init(first_start_ts, last_shutdown_ts)
    local now_ts = date.time_second()
    local data = schema_game.RushActivity:load(self.id)
    local loop_unit_sec = self.duration_sec + self.reserve_sec + self.loop_sec
    if not data then
        local loop_total_sec = now_ts - first_start_ts - self.offset_sec
        if loop_total_sec < 0 then
            self.start_ts = first_start_ts + self.offset_sec
            self.stop_ts = self.start_ts + self.duration_sec
            self.end_ts = self.stop_ts + self.reserve_sec
        else
            local loop_multiple = math.floor(loop_total_sec / loop_unit_sec)
            self.start_ts = first_start_ts + self.offset_sec + (loop_unit_sec * loop_multiple)
            self.stop_ts = self.start_ts + self.duration_sec
            self.end_ts = self.stop_ts + self.reserve_sec
        end
        self:save_to_db(true)
    else
        -- 如果停服期间该活动已结束，则发放奖励
        if (last_shutdown_ts < data.stop_ts) and (data.stop_ts <= now_ts) then
            self:give_activity_reward(data.stop_ts)
            -- 如果停服期间该活动已过期，则清除数据
            if data.end_ts <= now_ts then
                self:clear_rank_data()
            end
        end
        -- 如果停服期间该活动已过期，则清除数据
        if data.stop_ts <= last_shutdown_ts and last_shutdown_ts < data.end_ts and data.end_ts <= now_ts then
            self:clear_rank_data()
        end
        local loop_total_sec = now_ts - last_shutdown_ts
        local loop_multiple = math.floor(loop_total_sec / loop_unit_sec)
        self.start_ts = data.start_ts + (loop_unit_sec * loop_multiple)
        self.stop_ts = self.start_ts + self.duration_sec
        self.end_ts = self.stop_ts + self.reserve_sec
        self:save_to_db()
    end

    print("===== is start_ts " .. self.start_ts)
    print("===== is now_ts " .. now_ts)
    print("===== is end_ts " .. self.end_ts)
    print("===== is stop_ts " .. self.stop_ts)

    if now_ts < self.start_ts then
        self.state = STATE.nostart
        print("===== is from_nostart_to_started " .. self.start_ts - now_ts)
        timer.once(self.start_ts - now_ts, function() self:from_nostart_to_started() end)
    elseif self.start_ts <= now_ts and now_ts < self.stop_ts then
        self.state = STATE.started
        print("===== is from_started_to_stopped " .. self.stop_ts - now_ts)
        timer.once(self.stop_ts - now_ts, function() self:from_started_to_stopped() end)
    elseif self.stop_ts <= now_ts and now_ts < self.end_ts then
        self.state = STATE.stopped
        print("===== is from_stopped_to_nostart " .. self.end_ts - now_ts)
        timer.once(self.end_ts - now_ts, function() self:from_stopped_to_nostart() end)
    elseif now_ts > self.end_ts then
        self.state = STATE.invalid
        print("===== is from_stopped_to_nostart " ..  now_ts - self.end_ts)
    end
end

-- 持久化到数据库
function ActivityClass:save_to_db(is_new)
    if is_new then
        schema_game.RushActivity:insert(self.id, {activity_id=self.id, start_ts=self.start_ts, stop_ts=self.stop_ts, end_ts=self.end_ts})
    else
        schema_game.RushActivity:set_field({activity_id=self.id}, {start_ts=self.start_ts, stop_ts=self.stop_ts, end_ts=self.end_ts})
    end
end

-- nostart -> started (此刻活动进入开始状态)
function ActivityClass:from_nostart_to_started()
    self.state = STATE.started
    timer.once(self.duration_sec, function() self:from_started_to_stopped() end)
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        role.rush_activity:notify_activity_started(self.id, self)
    end
    if self.id == CSConst.RushActivityType.dynasty then
        cluster_utils.send_dynasty("ls_notify_rush_list_activity_start")
    end
end

-- started -> stopped (此刻活动进入保留状态)
function ActivityClass:from_started_to_stopped()
    self.state = STATE.stopped
    timer.once(self.reserve_sec, function() self:from_stopped_to_nostart() end)
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        role.rush_activity:notify_activity_stopped(self.id)
    end
    if self.id == CSConst.RushActivityType.dynasty then
        cluster_utils.send_dynasty("ls_notify_rush_list_activity_stop")
    end
    self:give_activity_reward()
end

-- stopped -> nostart (结束后又开始下轮循环)
function ActivityClass:from_stopped_to_nostart(not_save)
    self.state = STATE.nostart
    self.start_ts = self.end_ts + self.loop_sec
    self.stop_ts = self.start_ts + self.duration_sec
    self.end_ts = self.stop_ts + self.reserve_sec
    if not not_save then self:save_to_db() end
    timer.once(self.loop_sec, function() self:from_nostart_to_started() end)
    self:clear_rank_data()
    for _, uuid in ipairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        role.rush_activity:notify_activity_invalid(self.id)
    end
end

-- 清空排行榜, 入库留存
function ActivityClass:clear_rank_data()
    if self.id == CSConst.RushActivityType.dynasty then
        cluster_utils.send_dynasty("ls_clear_dynasty_rank", self.rank_name)
        -- cluster_utils.send_dynasty("ls_save_as_dynasty_rank", self.rank_name)
    else
        rank_utils.clear_rank_data(self.rank_name)
        -- rank_utils.save_as_history(self.rank_name)
    end
end

-- 发放冲榜活动奖励
function ActivityClass:give_activity_reward(give_ts)
    if self.id == CSConst.RushActivityType.dynasty then
        self:give_dynasty_reward()
        return
    end
    local role_list = rank_utils.get_role_list(self.rank_name)
    if not role_list or #role_list == 0 then return end
    local reward_record = excel_data.RushRewardData[excel_data.RushActivityData[self.id].reward]
    if reward_record.title then
        local uuid = role_list[1].uuid
        local title_id = reward_record.title
        local title_exldata = excel_data.ItemData[title_id]
        local is_expired = false
        give_ts = give_ts or date.time_second()
        local expire_ts = give_ts + title_exldata.validity_period_sec
        local now_ts = date.time_second()
        if expire_ts <= now_ts then is_expired = true end
        if not is_expired then agent_utils.add_title(uuid, title_id, give_ts) end
        local db_data = schema_game.RushActivityTitle:load(title_id)
        if not db_data then
            db_data = {
                title_id = title_id,
                current_uuid = is_expired and nil or uuid,
                history_list = {{uuid = uuid, ts = give_ts}},
            }
            schema_game.RushActivityTitle:insert(title_id, db_data)
        else
            db_data.current_uuid = is_expired and SQL_NULL or uuid
            table.insert(db_data.history_list, {uuid = uuid, ts = give_ts})
            if #db_data.history_list > CSConst.TitleMaxHistorySize then
                table.remove(db_data.history_list, 1)
            end
            schema_game.RushActivityTitle:set_field({title_id = title_id}, db_data)
        end
        if not is_expired then
            timer.once(expire_ts - now_ts, function() notify_title_expired(title_id) end)
        end
    end
    for rank, info in ipairs(role_list) do
        for index, gear in ipairs(reward_record.rank_gear) do
            if rank <= gear then
                self:send_reward_mail(info.uuid, rank, reward_record.rank_reward[index])
                break
            end
        end
    end
end

-- 发放王朝冲榜奖励
function ActivityClass:give_dynasty_reward()
    local dynasty_list = cluster_utils.call_dynasty("lc_get_rank_dynasty_list", self.rank_name)
    if not dynasty_list or #dynasty_list == 0 then return end
    local activity_exldata = excel_data.RushActivityData[self.id]
    local member_reward_exldata = excel_data.RushRewardData[activity_exldata.reward]
    local godfather_reward_exldata = excel_data.RushRewardData[activity_exldata.godfather_reward]
    for rank, dynasty_info in ipairs(dynasty_list) do
        for index, gear in ipairs(member_reward_exldata.rank_gear) do
            if rank <= gear then
                local member_dict = cluster_utils.call_dynasty("lc_get_dynasty_member_info", nil, dynasty_info.dynasty_id)
                for uuid, role_info in pairs(member_dict) do
                    if role_info.job == CSConst.DynastyJob.GodFather then
                        self:send_reward_mail(uuid, rank, godfather_reward_exldata.rank_reward[index])
                    else
                        self:send_reward_mail(uuid, rank, member_reward_exldata.rank_reward[index])
                    end
                end
                break
            end
        end
    end
end

-- 发送活动奖励邮件
function ActivityClass:send_reward_mail(uuid, rank, item_record_id)
    local mail_id = CSConst.MailId.RushActivity
    local mail_args = {activity=excel_data.RushActivityData[self.id].name, rank=rank}
    local item_list = excel_data.RushItemData[item_record_id].item_list
    agent_utils.add_mail(uuid, {
        mail_id = mail_id,
        mail_args = mail_args,
        item_list = table.deep_copy(item_list)
    })
end

-- 冲榜称号过期通知
function notify_title_expired(title_id)
    schema_game.RushActivityTitle:set_field({title_id = title_id}, {current_uuid = SQL_NULL})
end

return rush_activity_utils
