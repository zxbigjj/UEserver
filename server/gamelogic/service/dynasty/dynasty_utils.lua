local OfflineObjMgr = require("db.offline_db").OfflineObjMgr
local cluster_utils = require("msg_utils.cluster_utils")
local excel_data = require("excel_data")
local date = require("sys_utils.date")
local timer = require("timer")
local CSFunction = require("CSCommon.CSFunction")
local dynasty_rank = require("dynasty_rank")

local dynasty_utils = DECLARE_MODULE("dynasty_utils")
local DynastyCls = DECLARE_CLASS(dynasty_utils, "DynastyCls")
DECLARE_RUNNING_ATTR(dynasty_utils, "dynasty_dict", {})
DECLARE_RUNNING_ATTR(dynasty_utils, "dynasty_list", {})
DECLARE_RUNNING_ATTR(dynasty_utils, "role_dynasty_dict", {})
DECLARE_RUNNING_ATTR(dynasty_utils, "challenge_timer", nil)
DECLARE_RUNNING_ATTR(dynasty_utils, "challenge_num_timer", nil)
DECLARE_RUNNING_ATTR(dynasty_utils, "challenge_num_ts", nil)
DECLARE_RUNNING_ATTR(dynasty_utils, "challenge_flag", nil)
DECLARE_RUNNING_ATTR(dynasty_utils, "compete_timer", nil)
DECLARE_RUNNING_ATTR(dynasty_utils, "rush_list_activity_is_started", false) -- 王朝冲榜活动是否已开始

local CNAME = "Dynasty"
local _mgr = DECLARE_RUNNING_ATTR(dynasty_utils, "_mgr", nil, function()
    return OfflineObjMgr.new(require("schema_dynasty")[CNAME])
end)

-- 王朝初始化
function dynasty_utils.init()
    dynasty_rank.init()
    _mgr:load_all()
    for dynasty_id in pairs(_mgr:get_all()) do
        local dynasty = _mgr:get(dynasty_id)
        DynastyCls.new(dynasty)
    end

    -- 重启还原挑战数据
    local param_data = excel_data.ParamData
    local open_time = param_data["dynasty_challenge_open_time"].f_value
    local close_time = param_data["dynasty_challenge_close_time"].f_value
    local now = date.time_second()
    open_time = date.get_day_time(now, open_time)
    close_time = date.get_day_time(now, close_time)
    if now < open_time then
        dynasty_utils.challenge_flag = CSConst.DynastyChallenge.Unopen
        dynasty_utils.challenge_timer = timer.once(open_time-now, function()
            dynasty_utils.challenge_timer = nil
            dynasty_utils.challenge_open()
        end)
    elseif now > close_time then
        dynasty_utils.challenge_close()
    else
        dynasty_utils.challenge_open()
    end

    -- 王朝争霸
    local now = date.time_second()
    local start_time = param_data["dynasty_compete_start_time"].f_value
    start_time = date.get_day_time(now, start_time)
    if now < start_time then
        dynasty_utils.compete_timer = timer.once(start_time - now, function()
            dynasty_utils.compete_timer = nil
            dynasty_utils.compete_open()
        end)
    end

    -- 加载跨服王朝排行
    for _, dynasty_cls in pairs(dynasty_utils.dynasty_dict) do
        dynasty_cls:set_cross_dynasty_rank()
    end
end

function dynasty_utils.save_all()
    _mgr:save_all()
    dynasty_rank.save_rank()
end

-- 刷新王朝数据
function dynasty_utils.refresh_dynasty()
    for _, dynasty_cls in pairs(dynasty_utils.dynasty_dict) do
        xpcall(function() return dynasty_cls:dynasty_refresh() end, g_log.trace_handle)
    end

    -- 王朝争霸
    local param_data = excel_data.ParamData
    local now = date.time_second()
    local start_time = param_data["dynasty_compete_start_time"].f_value
    start_time = date.get_day_time(now, start_time)
    if now < start_time then
        local apply_day = param_data["dynasty_compete_apply_day"].str_value
        local fight_day_dict = param_data["dynasty_compete_fight_day"].tb_string
        local week_day = date.get_week_day(now)
        if week_day == apply_day then
            cluster_utils.send_cross_dynasty("ls_dynasty_compete_close")
        elseif fight_day_dict[week_day] then
            cluster_utils.send_cross_dynasty("ls_dynasty_compete_open")
        end
        if not dynasty_utils.compete_timer then
            dynasty_utils.compete_timer = timer.once(start_time - now, function()
                dynasty_utils.compete_timer = nil
                dynasty_utils.compete_open()
            end)
        end
    end
end

function dynasty_utils.send_agent(uuid, cmd, ...)
    cluster_utils.send_agent(nil, uuid, cmd, ...)
end

function dynasty_utils.call_agent(uuid, cmd, ...)
    return cluster_utils.call_agent(nil, uuid, cmd, ...)
end

function dynasty_utils.notify_tips(uuid, content, notify_type)
    cluster_utils.notify_client_tips(uuid, content, notify_type)
end

-- 给成员发送邮件
function dynasty_utils.send_member_mail(uuid, mail_id, mail_args, item_list)
    dynasty_utils.send_agent(uuid, "ls_send_member_mail", mail_id, mail_args, item_list)
end

-- 获取王朝类
function dynasty_utils.get_dynasty_cls(dynasty_id)
    if not dynasty_id then return end
    return dynasty_utils.dynasty_dict[dynasty_id]
end

local function table_sort(list, order)
    local comp = function(a, b)
        for _, v in ipairs(order) do
            local attr = v[1]
            if a[attr] < b[attr] then
                return v[2]
            elseif a[attr] > b[attr] then
                return not v[2]
            end
        end
        return false
    end
    table.sort(list, comp)
end

-- 排序王朝列表
function dynasty_utils.sort_dynasty()
    local all_dynasty = dynasty_utils.dynasty_list
    if #all_dynasty < 1 then return end
    local order = {{"dynasty_score", false},{"dynasty_id", true}}
    table_sort(all_dynasty, order)
end

-- 获取王朝列表
function dynasty_utils.get_dynasty_list(page)
    dynasty_utils.sort_dynasty()
    local dynasty_list = {}
    local index = CSConst.DynastyListPageNum*(page-1)
    for i = 1, CSConst.DynastyListPageNum do
        local dynasty = dynasty_utils.dynasty_list[index+i]
        if not dynasty then
            return dynasty_list
        end
        local dynasty_cls = dynasty_utils.get_dynasty_cls(dynasty.dynasty_id)
        table.insert(dynasty_list, dynasty_cls:build_dynasty_base_info())
    end
    return dynasty_list
end

-- 查找王朝
function dynasty_utils.seek_dynasty(dynasty_name)
    local dynasty_list = {}
    for _, dynasty_cls in pairs(dynasty_utils.dynasty_dict) do
        local name = dynasty_cls:get_dynasty_name()
        if string.find(name, dynasty_name) then
            table.insert(dynasty_list, dynasty_cls:build_dynasty_base_info())
        end
    end
    return dynasty_list
end

-- 检查王朝名字
function dynasty_utils.check_dynasty_name(dynasty_name)
    for _, dynasty_cls in pairs(dynasty_utils.dynasty_dict) do
        if dynasty_cls:get_dynasty_name() == dynasty_name then
            return true
        end
    end
end

-- 创建王朝
function dynasty_utils.create_dynasty(dynasty_info, role_info)
    role_info.job = CSConst.DynastyJob.GodFather
    role_info.join_ts = date.time_second()
    role_info.history_dedicate = 0
    role_info.challenge_num = 0
    local member_dict = {
        [role_info.uuid] = role_info,
    }
    local dynasty_id = dynasty_info.dynasty_id
    local param_data = excel_data.ParamData
    local dynasty = _mgr:get(dynasty_id)
    dynasty.dynasty_id = dynasty_id
    dynasty.is_init_badge = true
    dynasty.dynasty_name = dynasty_info.dynasty_name
    dynasty.dynasty_notice = param_data["dynasty_init_notice"].str_value
    dynasty.dynasty_declaration = param_data["dynasty_init_declaration"].str_value
    dynasty.member_dict = member_dict
    dynasty.dynasty_score = role_info.fight_score
    dynasty.daily_refresh_ts = date.time_second()

    local setting = dynasty.challenge.setting
    setting[CSConst.ChallengeSetting.Reset] = true
    setting[CSConst.ChallengeSetting.Back] = false
    return DynastyCls.new(dynasty)
end

----------------------- 冲榜活动 begin -------------------
function dynasty_utils.on_rush_list_activity_start()
    dynasty_utils.rush_list_activity_is_started = true
    for _, dynasty_obj in pairs(dynasty_utils.dynasty_dict) do
        dynasty_obj.dynasty.rush_list_activity_exp = dynasty_obj.dynasty.rush_list_activity_exp or 0
        dynasty_obj:save_dynasty()
    end
end

function dynasty_utils.on_rush_list_activity_stop()
    dynasty_utils.rush_list_activity_is_started = false
    for _, dynasty_obj in pairs(dynasty_utils.dynasty_dict) do
        dynasty_obj.dynasty.rush_list_activity_exp = nil
        dynasty_obj:save_dynasty()
    end
end
----------------------- 冲榜活动 end ---------------------

function DynastyCls.new(dynasty)
    local self = setmetatable({}, DynastyCls)
    self.dynasty_id = dynasty.dynasty_id
    self.dynasty = dynasty
    self.channel_name = g_const.ChatChannelName.Dynasty .. self.dynasty_id
    self.challenge_role_dict = {}
    self.compete_enemy_dict = {}
    self:init()
    dynasty_utils.dynasty_dict[self.dynasty_id] = self
    table.insert(dynasty_utils.dynasty_list, self.dynasty)
    return self
end

function DynastyCls:save_dynasty()
    _mgr:set(self.dynasty_id, self.dynasty)
end

function DynastyCls:init()
    local member_dict = self:get_member_dict()
    for uuid in pairs(member_dict) do
        dynasty_utils.role_dynasty_dict[uuid] = self.dynasty_id
    end
    local challenge = self.dynasty.challenge
    if challenge.hurt_rank then
        for _, v in ipairs(challenge.hurt_rank) do
            self.challenge_role_dict[v.uuid] = v
        end
    end
    if dynasty_utils.challenge_flag == CSConst.DynastyChallenge.Open then
        if not challenge.stage_dict then
            self:challenge_open()
        end
    end

    local compete_info = self.dynasty.compete
    if compete_info.is_open and compete_info.is_apply then
        self:build_compete_enemy_dict()
    end

    -- 冲榜活动
    if not dynasty_utils.rush_list_activity_is_started then return end
    self.dynasty.rush_list_activity_exp = 0
end

function DynastyCls:dynasty_refresh()
    local now = date.time_second()
    if self.dynasty.daily_refresh_ts < date.get_begin0(now) then
        self:daily_refresh()
    end
end

-- 每日刷新
function DynastyCls:daily_refresh()
    local dynasty = self.dynasty
    dynasty.build_progress = 0
    dynasty.build_num = 0
    for uuid, member_info in pairs(dynasty.member_dict) do
        if not member_info.offline_ts then
            dynasty_utils.send_agent(uuid, "ls_update_dynasty_build_progress", dynasty.build_progress)
        end
    end
    self:check_dynasty_godfather()
    dynasty.daily_refresh_ts = date.time_second()
    self:compete_daily()
    self:save_dynasty()
    g_log:dynasty("DynastyDailyRefresh", {dynasty_id = self.dynasty_id})
end

function DynastyCls:check_dynasty_godfather()
    local godfather_info = self:get_godfather_info()
    if not godfather_info.offline_ts then return end
    local max_offline_time = excel_data.ParamData["godfather_max_offline_time"].f_value * CSConst.Time.Day
    local now = date.time_second()
    -- 教父离线一定时间则自动转让
    if now - godfather_info.offline_ts >= max_offline_time then
        if self:get_member_count() <= 1 then
            -- 只剩下自己则解散王朝, 报名了王朝争霸不能解散
            local compete_info = self.dynasty.compete
            if not compete_info.is_apply then
                self:dissolve_dynasty()
                dynasty_utils.send_agent(godfather_info.uuid, "ls_kicked_out_dynasty")
            end
        else
            self:set_next_godfather()
        end
    end
end

function DynastyCls:get_dynasty_id()
    return self.dynasty_id
end

function DynastyCls:get_dynasty_name()
    return self.dynasty.dynasty_name
end

function DynastyCls:get_dynasty_level()
    return self.dynasty.dynasty_level
end

function DynastyCls:get_dynasty_exp()
    return self.dynasty.dynasty_exp
end

-- 获取王朝全部成员数量
function DynastyCls:get_member_count()
    return self.dynasty.member_count
end

-- 获取王朝成员个人信息
function DynastyCls:get_member_info(member_uuid)
    return self.dynasty.member_dict[member_uuid]
end

-- 获取王朝全部成员
function DynastyCls:get_member_dict()
    return self.dynasty.member_dict
end

-- 获取王朝申请数据
function DynastyCls:get_apply_dict()
    return self.dynasty.apply_dict
end

-- 获取王朝技能信息
function DynastyCls:get_dynasty_spell_info()
    return self.dynasty.spell_dict
end

-- 获取王朝徽章
function DynastyCls:get_dynasty_badge()
    return self.dynasty.dynasty_badge
end

-- 获取王朝建设进度
function DynastyCls:get_build_progress()
    return self.dynasty.build_progress
end

-- 获取教父信息
function DynastyCls:get_godfather_info()
    local member_dict = self:get_member_dict()
    for _, role_info in pairs(member_dict) do
        if role_info.job == CSConst.DynastyJob.GodFather then
            return role_info
        end
    end
end

-- 向在线成员广播消息
function DynastyCls:broad_dynasty_msg(proto_name, msg)
    local uuid_list = {}
    for uuid, role_info in pairs(self.dynasty.member_dict) do
        if not role_info.offline_ts then
            table.insert(uuid_list, uuid)
        end
    end
    cluster_utils.broad_client_msg(nil, uuid_list, proto_name, msg)
end

-- 成员上线
function DynastyCls:member_login(member_uuid)
    local dynasty = self.dynasty
    local role_info = dynasty.member_dict[member_uuid]
    role_info.offline_ts = nil
    self:save_dynasty()
    cluster_utils.enter_chat(member_uuid, self.channel_name)
    dynasty_utils.send_agent(member_uuid, "ls_update_dynasty_build_progress", dynasty.build_progress)
    self:send_client_dynasty_info(member_uuid)
end

-- 成员下线
function DynastyCls:member_logout(member_uuid)
    local role_info = self.dynasty.member_dict[member_uuid]
    role_info.offline_ts = date.time_second()
    self:save_dynasty()
    cluster_utils.leave_chat(member_uuid, self.channel_name)
end

-- 构建王朝基础信息
function DynastyCls:build_dynasty_base_info()
    local dynasty = self.dynasty
    local dynasty_base_info = {
        dynasty_id = dynasty.dynasty_id,
        dynasty_name = dynasty.dynasty_name,
        dynasty_level = dynasty.dynasty_level,
        dynasty_exp = dynasty.dynasty_exp,
        dynasty_badge = dynasty.dynasty_badge,
        dynasty_score = dynasty.dynasty_score,
        member_count = dynasty.member_count,
        dynasty_notice = dynasty.dynasty_notice,
        dynasty_declaration = dynasty.dynasty_declaration,
        godfather_name = self:get_godfather_info().name,
        is_init_badge = dynasty.is_init_badge
    }
    return dynasty_base_info
end

-- 判断王朝人数是否满
function DynastyCls:is_member_full()
    local dynasty_level = self:get_dynasty_level()
    local dynasty_data = excel_data.DynastyData[dynasty_level]
    return self:get_member_count() >= dynasty_data.max_num
end

-- 申请加入王朝
function DynastyCls:apply_dynasty(role_info)
    local apply_dict = self.dynasty.apply_dict
    local member_dict = self.dynasty.member_dict
    apply_dict[role_info.uuid] = role_info
    self:save_dynasty()
    self:broad_dynasty_msg("s_update_dynasty_member_apply_dict", { apply_dict = apply_dict, member_dict = member_dict })
end

-- 删除玩家加入申请
function DynastyCls:delete_role_apply(member_uuid, notify_role)
    local apply_dict = self.dynasty.apply_dict
    local member_dict = self.dynasty.member_dict
    if not apply_dict[member_uuid] then return end
    apply_dict[member_uuid] = nil
    self:save_dynasty()
    if notify_role then
        dynasty_utils.send_agent(member_uuid, "ls_delete_dynasty_apply", self.dynasty_id)
    end
    self:broad_dynasty_msg("s_update_dynasty_member_apply_dict", { apply_dict = apply_dict, member_dict = member_dict })
end

-- 是否为教父
function DynastyCls:is_godfather(member_uuid)
    local member_info = self:get_member_info(member_uuid)
    if not member_info then return end
    if member_info.job == CSConst.DynastyJob.GodFather then
        return true
    end
end

-- 是否为王朝管理
function DynastyCls:is_manager(member_uuid)
    local member_info = self:get_member_info(member_uuid)
    if not member_info then return end
    local job_data = excel_data.DynastyJobData[member_info.job]
    if job_data.is_manager then
        return true
    end
end

-- 添加成员
function DynastyCls:add_dynasty_member(member_uuid)
    dynasty_utils.role_dynasty_dict[member_uuid] = self.dynasty_id
    local dynasty = self.dynasty
    local role_info = dynasty.apply_dict[member_uuid]
    dynasty.apply_dict[member_uuid] = nil
    role_info.job = CSConst.DynastyJob.Member
    role_info.join_ts = date.time_second()
    role_info.offline_ts = date.time_second()
    role_info.history_dedicate = 0
    dynasty.member_dict[member_uuid] = table.deep_copy(role_info)
    dynasty.member_count = dynasty.member_count + 1
    dynasty.dynasty_score = dynasty.dynasty_score + role_info.fight_score
    dynasty_utils.send_agent(member_uuid, "ls_join_dynasty", self.dynasty_id)

    if dynasty_utils.challenge_flag ~= CSConst.DynastyChallenge.Unopen then
        -- 初始化王朝挑战数据
        local member_info = dynasty.member_dict[member_uuid]
        member_info.challenge_num = excel_data.ParamData["dynasty_challenge_init_num"].f_value
        member_info.challenge_total_num = 0
        member_info.max_challenge_hurt = 0
        member_info.stage_box = {[dynasty.challenge.curr_stage] = {}}
    end

    self:save_dynasty()
    g_log:dynasty("AddDynastyMember", {member_uuid = member_uuid, dynasty_id = self.dynasty_id})
end

-- 删除成员
function DynastyCls:delete_dynasty_member(member_uuid)
    local dynasty = self.dynasty
    local compete_info = dynasty.compete
    -- 报名了王朝争霸不能解散王朝
    if dynasty.member_count <= 1 and compete_info.is_apply then return end
    dynasty_utils.role_dynasty_dict[member_uuid] = nil
    local role_info = dynasty.member_dict[member_uuid]
    if not role_info then return end
    if dynasty.member_count <= 1 then
        return self:dissolve_dynasty()
    end
    dynasty.member_dict[member_uuid] = nil
    dynasty.member_count = dynasty.member_count - 1
    dynasty.dynasty_score = dynasty.dynasty_score - role_info.fight_score
    cluster_utils.leave_chat(member_uuid, self.channel_name)
    if role_info.job == CSConst.DynastyJob.GodFather then
        self:set_next_godfather()
    end
    if compete_info.building_dict then
        -- 玩家离开王朝，同步王朝争霸建筑守护数据
        for _, v in pairs(compete_info.building_dict) do
            if v.member_dict[member_uuid] then
                v.member_dict[member_uuid] = nil
                break
            end
        end
    end
    self:save_dynasty()
    g_log:dynasty("DeleteDynastyMember", {member_uuid = member_uuid, dynasty_id = self.dynasty_id})
end

-- 选出下任教父
function DynastyCls:set_next_godfather()
    local member_dict = self:get_member_dict()
    local member_list = table.values(member_dict)
    table_sort(member_list, {{"history_dedicate", false}})
    self:modify_member_job(member_list[1].uuid, CSConst.DynastyJob.GodFather)
end

-- 是否初始徽章
function DynastyCls:check_is_init_badge()
    return self.dynasty.is_init_badge
end

-- 修改王朝徽章
function DynastyCls:modify_dynasty_badge(dynasty_badge)
    local dynasty = self.dynasty
    if dynasty_badge == dynasty.dynasty_badge then return end
    dynasty.dynasty_badge = dynasty_badge
    if dynasty.is_init_badge then
        dynasty.is_init_badge = nil
    end
    self:save_dynasty()
    self:update_dynasty_rank_info({dynasty_badge = dynasty_badge})
end

-- 修改王朝名字
function DynastyCls:modify_dynasty_name(dynasty_name)
    local dynasty = self.dynasty
    if dynasty_name == dynasty.dynasty_name then return end
    dynasty.dynasty_name = dynasty_name
    for uuid, role_info in pairs(dynasty.member_dict) do
        if not role_info.offline_ts then
            dynasty_utils.send_agent(uuid, "ls_dynasty_name_change", dynasty_name)
        end
    end
    self:save_dynasty()
    self:update_dynasty_rank_info({dynasty_name = dynasty_name})
end

-- 修改王朝公告
function DynastyCls:modify_dynasty_notice(dynasty_notice)
    local dynasty = self.dynasty
    if dynasty_notice == dynasty.dynasty_notice then return end
    dynasty.dynasty_notice = dynasty_notice
    self:save_dynasty()
end

-- 修改王朝宣言
function DynastyCls:modify_dynasty_declaration(dynasty_declaration)
    local dynasty = self.dynasty
    if dynasty_declaration == dynasty.dynasty_declaration then return end
    dynasty.dynasty_declaration = dynasty_declaration
    self:save_dynasty()
end

-- 踢出玩家
function DynastyCls:kick_out_dynasty(member_uuid)
    self:delete_dynasty_member(member_uuid)
    dynasty_utils.send_agent(member_uuid, "ls_kicked_out_dynasty")
end

-- 修改成员职位
function DynastyCls:modify_member_job(member_uuid, job)
    local member_info = self:get_member_info(member_uuid)
    member_info.job = job
    self:save_dynasty()
    cluster_utils.send_client_msg(nil, member_uuid, "s_update_dynasty_member_job_info", {job = job})
end

-- 解散王朝
function DynastyCls:dissolve_dynasty()
    local apply_dict = self:get_apply_dict()
    for uuid in pairs(apply_dict) do
        self:delete_role_apply(uuid, true)
    end
    table.delete(dynasty_utils.dynasty_list, self.dynasty)
    dynasty_utils.dynasty_dict[self.dynasty_id] = nil
    cluster_utils.dissolve_chat(nil, self.channel_name)
    _mgr:delete(self.dynasty_id)
    g_log:dynasty("DissolveDynasty", {dynasty_id = self.dynasty_id})
    dynasty_rank.on_dissolve_dynasty(self.dynasty_id)
    cluster_utils.send_cross_dynasty("ls_on_dissolve_dynasty", self.dynasty_id)
end

-- 更新成员信息
function DynastyCls:update_dynasty_role_info(member_uuid, update_info)
    local member_info = self:get_member_info(member_uuid)
    for k, v in pairs(update_info) do
        if k == "dedicate" then
            member_info.history_dedicate = member_info.history_dedicate + v
        elseif k == "fight_score" then
            local old_score = member_info.fight_score
            member_info.fight_score = v
            self.dynasty.dynasty_score = self.dynasty.dynasty_score - old_score + v
        else
            member_info[k] = v
        end
    end
    self:save_dynasty()
end

-- 获取王朝建设信息
function DynastyCls:get_dynasty_build_info()
    local dynasty = self.dynasty
    return {
        build_num = dynasty.build_num,
        build_progress = dynasty.build_progress
    }
end

-- 王朝建设
function DynastyCls:dynasty_build(build_type)
    local build_data = excel_data.DynastyBuildData[build_type]
    local dynasty = self.dynasty
    dynasty.build_num = dynasty.build_num + 1
    dynasty.build_progress = dynasty.build_progress + build_data.progress
    for uuid in pairs(dynasty.member_dict) do
        dynasty_utils.send_agent(uuid, "ls_update_dynasty_build_progress", dynasty.build_progress)
    end
    self:add_dynasty_exp(build_data.dynasty_exp)
    self:save_dynasty()
end

-- 增加经验
function DynastyCls:add_dynasty_exp(add_exp)
    local dynasty = self.dynasty
    dynasty.dynasty_exp = dynasty.dynasty_exp + add_exp
    self:check_lvlup()
    self:save_dynasty()
    self:update_rush_list_activity_data(add_exp)
end

-- 王朝冲榜
function DynastyCls:update_rush_list_activity_data(add_exp)
    if not dynasty_utils.rush_list_activity_is_started then return end
    local dynasty = self.dynasty
    dynasty.rush_list_activity_exp = dynasty.rush_list_activity_exp + add_exp
    local rank_name = excel_data.RushActivityData[CSConst.RushActivityType.dynasty].rank
    local old_rank = dynasty_rank.get_dynasty_rank(rank_name, self.dynasty_id)
    self:update_dynasty_rank(rank_name, dynasty.rush_list_activity_exp)
    local new_rank = dynasty_rank.get_dynasty_rank(rank_name, self.dynasty_id)
    if new_rank ~= old_rank then
        self:broad_dynasty_msg("s_rush_activity_data_update", {activity_dict = {
            [CSConst.RushActivityType.dynasty] = { self_rank = new_rank },
        }})
    end
end

-- 检查是否升级
function DynastyCls:check_lvlup()
    local dynasty = self.dynasty
    local dynasty_data = excel_data.DynastyData
    if dynasty.dynasty_level >= #dynasty_data then return end
    if dynasty.dynasty_exp < dynasty_data[dynasty.dynasty_level + 1].exp then return end

    local new_level = dynasty.dynasty_level + 1
    dynasty.dynasty_level = new_level
    self:check_lvlup()
    g_log:dynasty("DynastyLvlUp", {dynasty_id = self.dynasty_id, new_level = new_level})
    self:update_dynasty_rank_info({dynasty_level = dynasty.dynasty_level})
end

-- 提升技能等级
function DynastyCls:upgrade_dynasty_spell(spell_id, cost_exp)
    local dynasty = self.dynasty
    dynasty.dynasty_exp = dynasty.dynasty_exp - cost_exp
    local spell_dict = dynasty.spell_dict
    spell_dict[spell_id] = (spell_dict[spell_id] or 0) + 1
    self:save_dynasty()
    for uuid, role_info in pairs(dynasty.member_dict) do
        cluster_utils.send_client_msg(nil, uuid, "s_update_dynasty_spell_dict", {spell_dict = spell_dict})
    end
end

function DynastyCls:get_dynasty_rank_info()
    local dynasty = self.dynasty
    return {
        dynasty_id = dynasty.dynasty_id,
        dynasty_name = dynasty.dynasty_name,
        dynasty_level = dynasty.dynasty_level,
        dynasty_badge = dynasty.dynasty_badge
    }
end

-- 更新王朝排行榜排名
function DynastyCls:update_dynasty_rank(rank_name, rank_score)
    local dynasty_info = self:get_dynasty_rank_info()
    dynasty_info.rank_score = rank_score
    dynasty_rank.update_dynasty_rank(rank_name, dynasty_info)
end

-- 更新王朝跨服排行榜排名
function DynastyCls:update_cross_dynasty_rank(rank_name, rank_score)
    local dynasty_info = self:get_dynasty_rank_info()
    dynasty_info.rank_score = rank_score
    cluster_utils.send_cross_dynasty("ls_update_dynasty_rank", rank_name, dynasty_info)
end

-- 更新排行榜王朝信息
function DynastyCls:update_dynasty_rank_info(dynasty_info)
    dynasty_info.dynasty_id = self.dynasty_id
    dynasty_rank.update_dynasty_info(dynasty_info)
    cluster_utils.send_cross_dynasty("ls_update_dynasty_rank_info", dynasty_info)
end

function DynastyCls:update_traitor_honour(traitor_honour)
    local dynasty = self.dynasty
    dynasty.traitor_honour = dynasty.traitor_honour + traitor_honour
    self:save_dynasty()
    self:update_dynasty_rank("traitor_boss_honour_dynasty_rank", dynasty.traitor_honour)
    self:update_cross_dynasty_rank("cross_boss_honour_dynasty_rank", dynasty.traitor_honour)
end

function DynastyCls:clear_traitor_honour()
    local dynasty = self.dynasty
    dynasty.traitor_honour = 0
    self:save_dynasty()
end

function DynastyCls:send_client_dynasty_info(uuid)
    local spell_dict = self:get_dynasty_spell_info()
    cluster_utils.send_client_msg(nil, uuid, "s_update_dynasty_spell_dict", {spell_dict = spell_dict})
    local apply_dict = self:get_apply_dict()
    local member_dict = self:get_member_dict()
    cluster_utils.send_client_msg(nil, uuid, "s_update_dynasty_member_apply_dict", { apply_dict = apply_dict, member_dict = member_dict })
    cluster_utils.send_client_msg(nil, uuid, "s_dynasty_challenge_refresh", {})
    cluster_utils.send_client_msg(nil, uuid, "s_dynasty_compete_refresh", {})
end
-------------------------------- dynasty chalenge star ----------------------------
-- 挑战开启
function dynasty_utils.challenge_open()
    dynasty_utils.challenge_flag = CSConst.DynastyChallenge.Open
    local param_data = excel_data.ParamData
    local open_time = param_data["dynasty_challenge_open_time"].f_value
    local close_time = param_data["dynasty_challenge_close_time"].f_value
    local now = date.time_second()
    open_time = date.get_day_time(now, open_time)
    close_time = date.get_day_time(now, close_time)
    dynasty_utils.challenge_timer = timer.once(close_time-now, function()
        dynasty_utils.challenge_close()
    end)

    local challenge_num_time = param_data["dynasty_challenge_num_time"].f_value * CSConst.Time.Hour
    local delay = challenge_num_time - (now - open_time)%challenge_num_time
    dynasty_utils.challenge_num_ts = now + delay
    dynasty_utils.challenge_num_timer = timer.loop(challenge_num_time, function()
        dynasty_utils.challenge_num_ts = dynasty_utils.challenge_num_ts + challenge_num_time
        dynasty_utils.challenge_num_recover()
    end, delay)

    for _, dynasty_cls in pairs(dynasty_utils.dynasty_dict) do
        xpcall(function() return dynasty_cls:challenge_open() end, g_log.trace_handle)
    end
end

-- 挑战结束
function dynasty_utils.challenge_close()
    dynasty_utils.challenge_flag = CSConst.DynastyChallenge.Close
    local param_data = excel_data.ParamData
    local close_time = param_data["dynasty_challenge_close_time"].f_value
    local delay = (CSConst.DayHour - close_time)*CSConst.Time.Hour
    dynasty_utils.challenge_timer = timer.once(delay, function()
        dynasty_utils.challenge_reset()
    end)
end

-- 挑战重置
function dynasty_utils.challenge_reset()
    dynasty_utils.challenge_flag = CSConst.DynastyChallenge.Unopen
    local param_data = excel_data.ParamData
    local open_time = param_data["dynasty_challenge_open_time"].f_value
    local now = date.time_second()
    open_time = date.get_day_time(now, open_time)
    dynasty_utils.challenge_timer = timer.once(open_time - now, function()
        dynasty_utils.challenge_open()
    end)

    for _, dynasty_cls in pairs(dynasty_utils.dynasty_dict) do
        xpcall(function() return dynasty_cls:challenge_reset() end, g_log.trace_handle)
    end
end

-- 挑战次数恢复
function dynasty_utils.challenge_num_recover()
    local param_data = excel_data.ParamData
    local close_time = param_data["dynasty_challenge_close_time"].f_value
    local now = date.time_second()
    close_time = date.get_day_time(now, close_time)
    if now >= close_time then
        dynasty_utils.challenge_num_timer:cancel()
        dynasty_utils.challenge_num_timer = nil
        dynasty_utils.challenge_num_ts = nil
        return
    end
    local challenge_num_time = param_data["dynasty_challenge_num_time"].f_value * CSConst.Time.Hour
    dynasty_utils.challenge_num_ts = now + challenge_num_time
    for _, dynasty_cls in pairs(dynasty_utils.dynasty_dict) do
        xpcall(function() return dynasty_cls:challenge_num_recover() end, g_log.trace_handle)
    end
end

function DynastyCls:challenge_open()
    local dynasty = self.dynasty
    local challenge = dynasty.challenge
    if challenge.stage_dict then return end
    challenge.hurt_rank = {}
    local challenge_data = excel_data.DynastyChallengeData[challenge.curr_stage]
    local janitor_info = self:build_janitor_info(challenge_data.janitor_list)
    challenge.stage_dict = {[challenge.curr_stage] = {janitor_dict = janitor_info}}
    local challenge_init_num = excel_data.ParamData["dynasty_challenge_init_num"].f_value
    for uuid, member_info in pairs(dynasty.member_dict) do
        member_info.challenge_num = challenge_init_num
        member_info.challenge_total_num = 0
        member_info.max_challenge_hurt = 0
        member_info.stage_box = {[challenge.curr_stage] = {}}
        cluster_utils.send_client_msg(nil, uuid, "s_dynasty_challenge_refresh", {})
    end
    self:save_dynasty()
end

function DynastyCls:challenge_reset()
    self.challenge_role_dict = {}
    local dynasty = self.dynasty
    local challenge = dynasty.challenge
    challenge.hurt_rank = nil
    challenge.stage_dict = nil
    if challenge.setting[CSConst.ChallengeSetting.Back] then
        -- 回退到最大通关数
        if challenge.max_victory_stage > 0 then
            challenge.curr_stage = challenge.max_victory_stage
        end
    end
    for _, member_info in pairs(dynasty.member_dict) do
        member_info.challenge_num = 0
        member_info.challenge_total_num = nil
        member_info.max_challenge_hurt = nil
        member_info.stage_box = nil
    end
    self:save_dynasty()
end

-- 构建王朝挑战守卫信息
function DynastyCls:build_janitor_info(janitor_list)
    local janitor_dict = {}
    for _, janitor_id in ipairs(janitor_list) do
        janitor_dict[janitor_id] = {hp_dict = {}, max_hp = 0, reward_list = {}}
        local janitor_info = janitor_dict[janitor_id]
        local janitor_data = excel_data.ChallengeJanitorData[janitor_id]
        local fight_data = CSFunction.get_fight_data_by_group_id(janitor_data.monster_group_id, janitor_data.monster_level)
        for pos, data in ipairs(fight_data) do
            if data.fight_attr_dict then
                janitor_info.hp_dict[pos] = data.fight_attr_dict["max_hp"]
                janitor_info.max_hp = janitor_info.max_hp + janitor_info.hp_dict[pos]
            end
        end
        local list = {}
        local count = 0
        for _, num in ipairs(janitor_data.box_reward_num) do
            for i = 1, num do
                count = count + 1
                list[count] = count
            end
        end
        -- 生成奖励宝箱
        local reward_list = janitor_info.reward_list
        for i, num in ipairs(janitor_data.box_reward_num) do
            for j = 1, num do
                local index = math.random(1, #list)
                reward_list[list[index]] = {
                    value = janitor_data.box_reward_value[i]
                }
                table.remove(list, index)
            end
        end
    end
    return janitor_dict
end

-- 挑战次数恢复
function DynastyCls:challenge_num_recover()
    local dynasty = self.dynasty
    local challenge_init_num = excel_data.ParamData["dynasty_challenge_init_num"].f_value
    for uuid, member_info in pairs(dynasty.member_dict) do
        member_info.challenge_num = member_info.challenge_num + 1
        cluster_utils.send_client_msg(nil, uuid, "s_dynasty_challenge_refresh", {})
    end
    self:save_dynasty()
end

-- 获取王朝挑战信息
function DynastyCls:get_dynasty_challenge_info()
    return self.dynasty.challenge
end

-- 王朝挑战守卫死亡
function DynastyCls:on_janitor_death()
    local dynasty = self.dynasty
    for uuid in pairs(dynasty.member_dict) do
        cluster_utils.send_client_msg(nil, uuid, "s_dynasty_challenge_refresh", {})
    end
    self:unlock_challenge_stage()
end

-- 解锁王朝挑战新关卡
function DynastyCls:unlock_challenge_stage()
    local dynasty = self.dynasty
    local challenge = dynasty.challenge
    local janitor_dict = challenge.stage_dict[challenge.curr_stage].janitor_dict
    for _, v in pairs(janitor_dict) do
        for _, hp in pairs(v.hp_dict) do
            if hp > 0 then return end
        end
    end
    if challenge.curr_stage > challenge.max_victory_stage then
        challenge.max_victory_stage = challenge.curr_stage
    end
    if challenge.curr_stage >= #excel_data.DynastyChallengeData then return end
    challenge.curr_stage = challenge.curr_stage + 1
    local challenge_data = excel_data.DynastyChallengeData[challenge.curr_stage]
    local janitor_info = self:build_janitor_info(challenge_data.janitor_list)
    challenge.stage_dict[challenge.curr_stage] = {janitor_dict = janitor_info}
    for _, member_info in pairs(dynasty.member_dict) do
        member_info.stage_box[challenge.curr_stage] = {}
    end
    self:save_dynasty()
    for uuid in pairs(dynasty.member_dict) do
        cluster_utils.send_client_msg(nil, uuid, "s_dynasty_challenge_refresh", {})
    end
end

-- 加入王朝挑战伤害排行榜
function DynastyCls:add_challenge_hurt_rank(uuid, max_hurt)
    local rank_info = self.challenge_role_dict[uuid]
    if not rank_info then
        self.challenge_role_dict[uuid] = {uuid = uuid}
        rank_info = self.challenge_role_dict[uuid]
    end
    rank_info.max_hurt = max_hurt
    local challenge = self.dynasty.challenge
    update_sorted_list(challenge.hurt_rank, rank_info, "max_hurt", true)
    self:save_dynasty()
end

-- 王朝挑战设置
function DynastyCls:dynasty_challenge_setting(setting_type)
    local setting = self.dynasty.challenge.setting
    setting[setting_type] = true
    if setting_type == CSConst.ChallengeSetting.Reset then
        setting[CSConst.ChallengeSetting.Back] = false
    else
        setting[CSConst.ChallengeSetting.Reset] = false
    end
    self:save_dynasty()
end
-------------------------------- dynasty chalenge end -----------------------------
function dynasty_utils.compete_open()
    for _, dynasty_cls in pairs(dynasty_utils.dynasty_dict) do
        xpcall(function() return dynasty_cls:compete_open() end, g_log.trace_handle)
    end
end

-- 王朝争霸开启
function DynastyCls:compete_open()
    local dynasty = self.dynasty
    if dynasty.compete.is_open then return end

    local param_data = excel_data.ParamData
    local apply_day = param_data["dynasty_compete_apply_day"].str_value
    local fight_day_dict = param_data["dynasty_compete_fight_day"].tb_string
    local now = date.time_second()
    local week_day = date.get_week_day(now)
    if week_day == apply_day then
        -- 报名阶段
        dynasty.compete = {}
        for uuid, member_info in pairs(dynasty.member_dict) do
            member_info.building_id = nil
            member_info.total_mark = 0
            member_info.daily_mark = 0
            member_info.attack_num = 0
            member_info.compete_reward = nil
            cluster_utils.send_client_msg(nil, uuid, "s_dynasty_compete_refresh", {})
        end
    elseif fight_day_dict[week_day] then
        -- 战斗阶段
        local compete_info = dynasty.compete
        if not compete_info.is_apply then return end
        compete_info.attack_mark = 0
        compete_info.defend_mark = 0
        compete_info.defend_info = nil
        compete_info.compete_index = compete_info.compete_index + 1
        self:build_compete_enemy_dict()
        local init_attack_num = param_data["dynasty_compete_init_attack_num"].f_value
        for uuid, member_info in pairs(dynasty.member_dict) do
            member_info.daily_mark = 0
            member_info.total_mark = 0
            member_info.attack_num = init_attack_num
            member_info.compete_reward = {}
            for id in pairs(excel_data.CompeteRewardData) do
                member_info.compete_reward[id] = false
            end
            cluster_utils.send_client_msg(nil, uuid, "s_dynasty_compete_refresh", {})
        end
    end
    dynasty.compete.is_open = true
    self:save_dynasty()
end

-- 构建王朝争霸敌军信息
function DynastyCls:build_compete_enemy_dict()
    self.compete_enemy_dict = {}
    local compete_info = self.dynasty.compete
    for dynasty_id, enemy_info in pairs(compete_info.enemy_dict) do
        local building_dict = {}
        for building_id, info in pairs(enemy_info.building_dict) do
            local role_dict = {}
            for uuid, defend_num in pairs(info.role_dict) do
                if not cluster_utils.is_player_uuid_valid(uuid) then
                    -- 测试机器人
                    role_dict[uuid] = {
                        defend_num = defend_num,
                        role_id = 1,
                        role_name = string.rand_string(5),
                        fight_score = math.random(1000, 10000),
                        fight_data = CSFunction.get_fight_data_by_group_id(1)
                    }
                else
                    local role_info = dynasty_utils.call_agent(uuid, "lc_get_dynasty_compete_role_info")
                    role_dict[uuid] = {
                        defend_num = defend_num,
                        role_id = role_info.role_id,
                        role_name = role_info.role_name,
                        fight_score = role_info.fight_score,
                        fight_data = role_info.fight_data
                    }
                end
            end
            building_dict[building_id] = {building_hp = info.building_hp, role_dict = role_dict}
        end
        self.compete_enemy_dict[dynasty_id] = {
            server_id = cluster_utils.get_server_id_by_dynasty(dynasty_id),
            dynasty_name = enemy_info.dynasty_name,
            building_dict = building_dict
        }
    end
end

-- 王朝争霸每日刷新
function DynastyCls:compete_daily()
    local dynasty = self.dynasty
    local compete_info = dynasty.compete
    if not compete_info.is_apply then return end
    compete_info.is_open = nil
    self.compete_enemy_dict = {}
    local apply_day = excel_data.ParamData["dynasty_compete_apply_day"].str_value
    local fight_day_dict = excel_data.ParamData["dynasty_compete_fight_day"].tb_string
    local now = date.time_second()
    local pre_week_day = date.get_week_day(now - CSConst.Time.Day)
    if pre_week_day == apply_day then
        self:auto_set_building_defend()
        self:add_dynasty_compete()
    elseif fight_day_dict[pre_week_day] then
        -- 记录前一天的防守战绩
        compete_info.defend_info = {}
        local defend_mark = 0
        local defend_dict = self:get_compete_defend_info()
        for dynasty_id, dynasty_info in pairs(defend_dict) do
            local building_dict = {}
            for building_id, building_info in pairs(dynasty_info.building_dict) do
                local building_data = excel_data.DynastyBuildingData[building_id]
                defend_mark = defend_mark + building_data.defend_param * building_info.defend_num
                building_dict[building_id] = building_info.defend_num
            end
            compete_info.defend_info[dynasty_id] = {
                building_dict = building_dict,
                dynasty_name = dynasty_info.dynasty_name
            }
        end
        if defend_mark > 0 then
            compete_info.defend_mark = compete_info.defend_mark + defend_mark
            compete_info.total_mark = compete_info.total_mark + defend_mark
            self:add_compete_dynasty_rank(compete_info.total_mark)
        end
    end
    self:save_dynasty()
end

-- 获取王朝争霸信息
function DynastyCls:get_dynasty_compete_info()
    return self.dynasty.compete
end

-- 获取王朝争霸敌军信息
function DynastyCls:get_dynasty_compete_enemy_info()
    return self.compete_enemy_dict
end

-- 王朝争霸报名
function DynastyCls:dynasty_compete_apply()
    local compete_info = self.dynasty.compete
    compete_info.is_apply = true
    compete_info.building_dict = {}
    for building_id in pairs(excel_data.DynastyBuildingData) do
        compete_info.building_dict[building_id] = {member_dict = {}}
    end
    self:save_dynasty()
end

-- 王朝争霸驻守建筑
function DynastyCls:dynasty_building_defend(member_uuid, building_id)
    local member_info = self:get_member_info(member_uuid)
    local building_dict = self.dynasty.compete.building_dict
    if member_info.building_id then
        building_dict[member_info.building_id].member_dict[member_uuid] = nil
    end
    member_info.building_id = building_id
    if building_id then
        building_dict[building_id].member_dict[member_uuid] = true
    end
    self:save_dynasty()
end

-- 自动驻守建筑
function DynastyCls:auto_set_building_defend()
    local member_dict = self.dynasty.member_dict
    local member_list = {}
    for _, member_info in pairs(member_dict) do
        if not member_info.building_id then
            table.insert(member_list, member_info)
        end
    end
    if not next(member_list) then return end
    table.sort(member_list, function (a, b)
        return a.fight_score > b.fight_score
    end)
    local building_dict = self.dynasty.compete.building_dict
    local building_data = excel_data.DynastyBuildingData
    local index = 1
    for i = #building_data, 1, -1 do
        if index > #member_list then break end
        local need_member_count = building_data[i].defend_member_count - #building_dict[i].member_dict
        if need_member_count > 0 then
            for j = 1, need_member_count do
                local member_info = member_list[index]
                member_info.building_id = i
                building_dict[i].member_dict[member_info.uuid] = true
                index = index + 1
                if index > #member_list then break end
            end
        end
    end
    self:save_dynasty()
end

-- 加入王朝争霸
function DynastyCls:add_dynasty_compete()
    local dynasty = self.dynasty
    local compete_info = dynasty.compete
    local args = {
        dynasty_id = self.dynasty_id,
        dynasty_name = dynasty.dynasty_name,
        building_dict = compete_info.building_dict
    }
    cluster_utils.send_cross_dynasty("ls_add_dynasty_compete", args)
end

-- 设置王朝争霸敌对王朝
function DynastyCls:set_dynasty_compete_enemy(enemy_dict)
    local compete_info = self.dynasty.compete
    if compete_info.is_open then return end
    compete_info.enemy_dict = {}
    for dynasty_id, enemy_info in pairs(enemy_dict) do
        local building_dict = {}
        for building_id, info in pairs(enemy_info.building_dict) do
            local role_dict = {}
            local building_data = excel_data.DynastyBuildingData[building_id]
            for uuid in pairs(info.member_dict) do
                role_dict[uuid] = building_data.defend_count
            end
            building_dict[building_id] = {
                building_hp = building_data.building_hp,
                role_dict = role_dict
            }
        end
        compete_info.enemy_dict[dynasty_id] = {
            dynasty_name = enemy_info.dynasty_name,
            building_dict = building_dict
        }
    end
    self:save_dynasty()
end

-- 建筑是否被攻破
function dynasty_utils.is_building_destroy(building_info)
    if building_info.building_hp <= 0 then return true end
    for _, data in pairs(building_info.role_dict) do
        if data.defend_num > 0 then return end
    end
    return true
end

-- 是否可以攻击总部
function dynasty_utils.can_attack_headquarters(building_dict)
    local headquarters_id = #excel_data.DynastyBuildingData
    for building_id, building_info in pairs(building_dict) do
        if building_id ~= headquarters_id then
            if dynasty_utils.is_building_destroy(building_info) then
                return true
            end
        end
    end
end

-- 设置王朝争霸奖励领取状态
function DynastyCls:set_compete_reward()
    local compete_reward = {}
    for id, data in pairs(excel_data.CompeteRewardData) do
        local count = 0
        if data.condition == CSConst.CompeteRewardCondition.One then
            for _, v in pairs(self.compete_enemy_dict) do
                for _, building_info in pairs(v.building_dict) do
                    if dynasty_utils.is_building_destroy(building_info) then
                        count = count + 1
                    end
                end
            end
        elseif data.condition == CSConst.CompeteRewardCondition.Two then
            for _, v in pairs(self.compete_enemy_dict) do
                local headquarters_id = #excel_data.DynastyBuildingData
                if dynasty_utils.is_building_destroy(v.building_dict[headquarters_id]) then
                    count = count + 1
                end
            end
        elseif data.condition == CSConst.CompeteRewardCondition.Three then
            for _, v in pairs(self.compete_enemy_dict) do
                local num = 0
                for _, building_info in pairs(v.building_dict) do
                    if dynasty_utils.is_building_destroy(building_info) then
                        num = num + 1
                    end
                end
                if num == #excel_data.DynastyBuildingData then
                    count = count + 1
                end
            end
        end
        if count >= data.num then
            compete_reward[id] = true
        end
    end
    if not next(compete_reward) then return end

    local member_dict = self:get_member_dict()
    for uuid, member_info in pairs(member_dict) do
        for id in pairs(compete_reward) do
            if member_info.compete_reward[id] == false then
                member_info.compete_reward[id] = true
            end
        end
        cluster_utils.send_client_msg(nil, uuid, "s_dynasty_compete_refresh", {})
    end
    self:save_dynasty()
end

-- 加入王朝争霸王朝排行
function DynastyCls:add_compete_dynasty_rank(mark)
    self:update_cross_dynasty_rank("compete_mark_dynasty_rank", mark)
end

-- 获取王朝争霸防守
function DynastyCls:get_compete_defend_info()
    local compete_info = self.dynasty.compete
    local defend_dict = {}
    for dynasty_id, enemy_info in pairs(compete_info.enemy_dict) do
        local server_id = cluster_utils.get_server_id_by_dynasty(dynasty_id)
        local node_name = string.format("s%d_dynasty", server_id)
        local ret = cluster_utils.lua_call(node_name, '.dynasty', "lc_get_dynasty_defend_info", self.dynasty_id, dynasty_id)
        defend_dict[dynasty_id] = {
            dynasty_name = enemy_info.dynasty_name,
            building_dict = ret
        }
    end
    return defend_dict
end

-- 2022年5月18日, 跨服王朝战力
function DynastyCls:set_cross_dynasty_rank()
    local dynasty_base_info = self:build_dynasty_base_info()
    print("---- " .. dynasty_base_info.dynasty_id)
    print("=" .. dynasty_base_info.dynasty_score)
    self:update_cross_dynasty_rank("cross_dynasty_rank", dynasty_base_info.dynasty_score)
end
------------------------------------------------------------------------------------

return dynasty_utils