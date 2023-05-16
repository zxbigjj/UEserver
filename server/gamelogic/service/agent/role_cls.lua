local role_cls = DECLARE_MODULE("role_cls")

local co_lock = require("srv_utils.co_lock")
local timer = require("timer")
local date = require("sys_utils.date")
local cluster_utils = require("msg_utils.cluster_utils")
local role_db = require("role_db")
local server_env = require("srv_utils.server_env")
local log_utils = require("log_utils")

DECLARE_RUNNING_ATTR(role_cls, "__attr_dict", {})
DECLARE_RUNNING_ATTR(role_cls, "__meta_mapper", {})
DECLARE_RUNNING_ATTR(role_cls, "role_dict", {})
DECLARE_RUNNING_ATTR(role_cls, "role_list", {})
DECLARE_RUNNING_ATTR(role_cls, "_lock_mgr", nil,
    function() return co_lock.new_lock_mgr(10) end)
DECLARE_RUNNING_ATTR(role_cls, "_server_call_lock_mgr", nil,
    function() return co_lock.new_lock_mgr(10) end)

-- 删除role_cls所有meta函数
for name, meta_name in pairs(role_cls.__meta_mapper) do
    role_cls[name] = nil
end

local function SET_ATTR(role, name, init_value)
    role_cls.__attr_dict[name] = true
    role[name] = init_value
end

local function __return(ok, ...)
    if ok then
        return ...
    end
    return
end

-- 赋值的时候加个检查
function role_cls.__newindex(tb, k, v)
    if not role_cls.__attr_dict[k] then
        error("cannot add new attr to role:" .. k)
    end
    rawset(tb, k, v)
end

function role_cls.new(urs, uuid, db)
    local self = {}

    SET_ATTR(self, 'urs', urs)
    SET_ATTR(self, 'uuid', uuid)

    SET_ATTR(self, 'db', db)
    SET_ATTR(self, 'sock_id', nil)
    SET_ATTR(self, 'token', nil)

    -- 模块
    SET_ATTR(self, 'base', require("meta_table.base").new(self))
    SET_ATTR(self, 'attr', require("meta_table.attr").new(self))
    SET_ATTR(self, 'total_hall', require("meta_table.total_hall").new(self))
    SET_ATTR(self, 'hero', require("meta_table.hero").new(self))
    SET_ATTR(self, 'lineup', require("meta_table.lineup").new(self))
    SET_ATTR(self, 'lover', require("meta_table.lover").new(self))
    SET_ATTR(self, 'child', require("meta_table.child").new(self))
    SET_ATTR(self, 'hunt', require("meta_table.hunt").new(self))
    SET_ATTR(self, 'bag', require("meta_table.bag").new(self))
    SET_ATTR(self, 'prison', require("meta_table.prison").new(self))
    SET_ATTR(self, 'stage', require("meta_table.stage").new(self))
    SET_ATTR(self, 'chat', require("meta_table.chat").new(self))
    SET_ATTR(self, 'mail', require("meta_table.mail").new(self))
    SET_ATTR(self, 'travel', require("meta_table.travel").new(self))
    SET_ATTR(self, 'daily_dare', require("meta_table.daily_dare").new(self))
    SET_ATTR(self, 'salon', require("meta_table.salon").new(self))
    SET_ATTR(self, 'arena', require("meta_table.arena").new(self))
    SET_ATTR(self, 'treasure', require("meta_table.treasure").new(self))
    SET_ATTR(self, 'train', require("meta_table.train").new(self))
    SET_ATTR(self, 'dare_tower', require("meta_table.dare_tower").new(self))
    SET_ATTR(self, 'party', require("meta_table.party").new(self))
    SET_ATTR(self, 'friend', require("meta_table.friend").new(self))
    SET_ATTR(self, 'rank', require("meta_table.rank").new(self))
    SET_ATTR(self, 'dynasty', require("meta_table.dynasty").new(self))
    SET_ATTR(self, 'check_in_monthly', require("meta_table.check_in_monthly").new(self))
    SET_ATTR(self, 'check_in_weekly', require("meta_table.check_in_weekly").new(self))
    SET_ATTR(self, 'task', require("meta_table.task").new(self))
    SET_ATTR(self, 'achievement', require("meta_table.achievement").new(self))
    SET_ATTR(self, 'daily_active', require("meta_table.daily_active").new(self))
    SET_ATTR(self, 'vip', require("meta_table.vip").new(self))
    SET_ATTR(self, 'recharge', require("meta_table.recharge").new(self))
    SET_ATTR(self, 'normal_shop', require("meta_table.normal_shop").new(self))
    SET_ATTR(self, 'crystal_shop', require("meta_table.crystal_shop").new(self))
    SET_ATTR(self, 'single_recharge', require("meta_table.single_recharge").new(self))
    SET_ATTR(self, 'worth_recharge', require("meta_table.worth_recharge").new(self))
    SET_ATTR(self, 'recharge_draw', require("meta_table.recharge_draw").new(self))
    SET_ATTR(self, 'traitor', require("meta_table.traitor").new(self))
    SET_ATTR(self, 'first_week', require("meta_table.first_week").new(self))
    SET_ATTR(self, 'guide', require("meta_table.guide").new(self))
    SET_ATTR(self, 'activity', require("meta_table.activity").new(self))
    SET_ATTR(self, 'rush_activity', require("meta_table.rush_activity").new(self))
    SET_ATTR(self, 'festival_activity', require("meta_table.festival_activity").new(self))
    SET_ATTR(self, 'action_point', require("meta_table.action_point").new(self))
    SET_ATTR(self, 'fund', require("meta_table.fund").new(self))
    SET_ATTR(self, 'luxury_check_in', require("meta_table.luxury_check_in").new(self))
    SET_ATTR(self, 'daily_recharge', require("meta_table.daily_recharge").new(self))
    SET_ATTR(self, 'title', require("meta_table.title").new(self))
    SET_ATTR(self, 'monthly_card', require("meta_table.monthly_card").new(self))
    SET_ATTR(self, 'accum_recharge', require("meta_table.accum_recharge").new(self))
    SET_ATTR(self, 'bar', require("meta_table.bar").new(self))
    SET_ATTR(self, 'lover_activities', require("meta_table.lover_activities").new(self))
    SET_ATTR(self, 'hero_activities', require("meta_table.hero_activities").new(self))
    SET_ATTR(self, 'daily_gift_package_activities', require("meta_table.daily_gift_package_activities").new(self))
    -- SET_ATTR(self, 'pack_activities', require("meta_table.pack_activities").new(self))

    --注意这里只放一些公共的数据，模块相关的放模块里面
    SET_ATTR(self, 'status', nil)
    SET_ATTR(self, 'event', require("meta_table.event").new(self))
    SET_ATTR(self, 'timer_dict', {})
    SET_ATTR(self, 'timer_logout', nil)
    SET_ATTR(self, 'timer_auto_save', timer.loop(3600, function(ti) self:save() end, math.random() * 3600))

    -- 加载标识
    SET_ATTR(self, 'is_doing_load', nil)
    -- 上线中标识
    SET_ATTR(self, 'is_doing_online', nil)
    -- 战斗奖励
    SET_ATTR(self, 'fight_reward', nil)

    setmetatable(self, role_cls)
    return self
end

function role_cls.get_role(uuid)
    return role_cls.role_dict[uuid]
end

function role_cls.lock_run(uuid, func)
    return role_cls._lock_mgr:run(uuid, func)
end

function role_cls.write_db(uuid, key, value)
    role_cls.lock_run(uuid, function()
        local role = role_cls.get_role(uuid)
        if role then
            role.db[key] = value
        else
            local schema = require('schema_game')
            if value == nil then
                value = SQL_NULL
            end
            schema.Role:set_field({uuid=uuid}, {[key]=value})
        end
    end)
end

function role_cls.read_db(uuid, key_list)
    return role_cls.lock_run(uuid, function()
        local role = role_cls.get_role(uuid)
        if role then
            local ret = {}
            for _, key in ipairs(key_list) do
                ret[key] = role.db[key]
                if type(ret[key]) == 'table' then
                    ret[key] = DB_COPY(ret[key])
                end
            end
            return ret
        else
            local schema = require('schema_game')
            return schema.Role:read_field({uuid=uuid}, key_list)
        end
    end)
end

function role_cls.create(urs, role_data)
    local server_data = require("server_data")
    local last_role_num = server_data.get_server_core("last_role_num")
    server_data.set_server_core("last_role_num", last_role_num + 1)
    if last_role_num >= g_const.Max_Role_Num then
        return
    elseif last_role_num > 0.9*g_const.Max_Role_Num then
        g_log:error("RoleNumOverload", last_role_num)
    end
    local server_id = tonumber(server_env.get_server_id())
    local uuid = "" .. (server_id * g_const.Max_Role_Num + last_role_num)
    if not require("name_utils").use_role_name(uuid, role_data.role_name) then end

    return role_cls.lock_run(uuid, function()
        return role_cls._create(uuid, urs, role_data)
    end)
end

function role_cls._create(uuid, urs, role_data)
    local db = role_db:get("Role", uuid)
    if not db then return nil end

    db.uuid = uuid
    db.urs = urs
    db.name = role_data.role_name
    db.role_id = role_data.role_id
    db.level = 1
    db.random_num = math.random(1, g_const.Max_Random_Num)

    local role = role_cls.new(urs, uuid, db)
    -- 初始化
    role:init()
    db.init_flag = true
    role:_on_load()

    db.hotfix_version = require("hotfix_utils").get_max_role_version()
    db.create_ts = date.time_second()

    role_cls.role_dict[uuid] = role
    table.insert(role_cls.role_list, uuid)
    role:save()

    role:give_init_item()
    role:gaea_log("RoleLogin", {
        loginType = g_const.LogloginType.create,
        duration = 0,
        roleName = role.db.name,
        roleRace = role.db.role_id,
    })

    return role
end

function role_cls.load(uuid)
    return role_cls.lock_run(uuid, function()
        return role_cls._load(uuid)
    end)
end

function role_cls._load(uuid)
    local role = role_cls.role_dict[uuid]
    if role then return role end

    local db = role_db:find_one("Role", uuid)
    if not db then return end

    role = role_cls.new(db.urs, uuid, db)

    role:_on_load()

    role_cls.role_dict[uuid] = role
    table.insert(role_cls.role_list, uuid)
    return role
end

function role_cls.get(uuid)
    return role_cls.role_dict[uuid]
end

function role_cls.get_online_uuid()
    return role_cls.role_list
end

function role_cls.get_role_dict()
    return role_cls.role_dict
end

function role_cls:get_role_info()
    return self.base:get_role_info()
end

function role_cls:get_uuid()
    return self.uuid
end

function role_cls:get_level()
    return self.db.level
end

function role_cls:get_name()
    return self.db.name
end

function role_cls:get_score()
    return self.db.score
end

function role_cls:get_max_score()
    return self.db.max_score
end

function role_cls:get_fight_score()
    return self.db.fight_score
end

function role_cls:get_max_fight_score()
    return self.db.max_fight_score
end

function role_cls:get_currency(id)
    return self.db.currency[id]
end

function role_cls:get_attr_value(attr_name)
    return self.db.attr_dict[attr_name]
end

function role_cls:new_guid()
    self.db.guid = self.db.guid + 1
    return self.db.guid
end

function role_cls:get_lover(lover_id)
   return self.db.lover_dict[lover_id]
end

function role_cls:get_vip()
    return self.db.vip.vip_level
end

function role_cls:get_role_id()
   return self.db.role_id
end

function role_cls:get_create_ts()
    return self.db.create_ts
end

function role_cls:save(is_clear)
    return role_cls.lock_run(self.uuid, function()
        return self:_save(is_clear)
    end)
end

function role_cls:_save(is_clear)
    require("role_db"):save_role(self.uuid, is_clear)
end

function role_cls:remove()
    if self.timer_auto_save then
        self.timer_auto_save:cancel()
        self.timer_auto_save = nil
    end
    if self.timer_logout then
        self.timer_logout:cancel()
        self.timer_logout = nil
    end

    role_cls.role_dict[self.uuid] = nil
    table.delete(role_cls.role_list, self.uuid)

    local dict = self.timer_dict
    self.timer_dict = {}
    for _, ti in pairs(dict) do
        ti:cancel()
    end
end

function role_cls:timer_once(delay, func)
    local ti = {}
    ti._ti = timer.once(delay, function()
        self.timer_dict[ti.guid] = nil
        func()
    end)
    ti.guid = ti._ti.guid
    ti.cancel = function(_) self:cancel_timer(ti) end
    self.timer_dict[ti.guid] = ti
    return ti
end

function role_cls:timer_loop(duration_seconds, func, delay_seconds)
    local ti = {}
    ti._ti = timer.loop(duration_seconds, func, delay_seconds)
    ti.guid = ti._ti.guid
    ti.cancel = function(_) self:cancel_timer(ti) end

    self.timer_dict[ti.guid] = ti
    return ti
end

function role_cls:cancel_timer(ti)
    self.timer_dict[ti.guid] = nil
    ti._ti:cancel()
end

function role_cls:srv_call_lock_run(func)
    return role_cls._server_call_lock_mgr:run(self.uuid, func)
end

function role_cls:is_online()
    return self.sock_id and true or false
end

function role_cls:send_client(name, msg)
    if not self.is_doing_load and self.db.init_flag then
        cluster_utils.send_agent_gate("ls_role_send", self.uuid, name, msg)
    end
end

function role_cls:notify_tips(errstr, notify_type)
    notify_type = notify_type or CSConst.NotifyType.FloatWord
    self:send_client("s_notify_msg", {errstr=errstr, notify_type=notify_type})
end

function role_cls:log(name, args)
    g_log:role(name, {urs=self.urs, uuid=self.uuid, status=self.status}, args)
end

function role_cls:error(...)
    g_log:error({urs=self.urs, uuid=self.uuid}, ...)
end

function role_cls:trace(...)
    g_log:trace({urs=self.urs, uuid=self.uuid}, ...)
end

--------------- base method start ---------------
function role_cls:init(role_data)
    self.base:init(role_data)
end

function role_cls:_on_load()
    self.base:on_load()
end

function role_cls:on_online()
    self.base:on_online()
end

function role_cls:check_daily_zero_refresh()
    self.base:check_daily_zero_refresh()
end

function role_cls:check_hourly_refresh()
    self.base:check_hourly_refresh()
end

function role_cls:add_exp(count, reason, not_addition)
    return self.base:add_exp(count, reason, not_addition)
end

function role_cls:delete_exp(exp, reason)
    return self.base:delete_exp(exp, reason)
end

function role_cls:add_currency(id, count, reason)
    return self.base:add_currency(id, count, reason)
end

function role_cls:sub_currency(id, count, reason)
    return self.base:sub_currency(id, count, reason)
end

-- 掉线
function role_cls:on_disconnect()
    g_log:role("RoleDisconnect", {urs = self.urs})
    if self.timer_logout then
        self.timer_logout:cancel()
    end
    self.sock_id = nil
    self.db.last_offline_ts = date.time_second()
    -- 掉线自动给奖励
    self:give_fight_reward()
    self:arena_select_reward(1)
    self:grab_treasure_select_reward(1)
    self:end_hunt_ground()
    self:traitor_boss_delete_role()
    self.vip:get_vip_gift()

    self.timer_logout = timer.once(g_const.Logout_Max_Time, function()
        -- 半小时后登出
        self.timer_logout = nil
        self:logout()
    end)
end

-- 重连
function role_cls:on_reconnect(sock, token)
    if token ~= self.token then
        return
    end
    g_log:role("RoleReconnect", {urs = self.urs})

    if self.timer_logout then
        self.timer_logout:cancel()
    end
    if self.sock_id then
        -- 关闭旧连接, token正确说明是同一个客户端
        local SockCls = require("sock").SockCls
        local sock = SockCls.get_sock(self.sock_id)
        if sock then
            sock:bind_role(nil)
        end
        cluster_utils.send_agent_gate("ls_close_sock", self.sock_id)
    end
    -- 绑定新连接
    self.sock_id = sock.sock_id
    sock:bind_role(self)
    cluster_utils.send_agent_gate("ls_bind_role", self.sock_id, self.uuid)
    return true
end

function role_cls:login(sock, json_data)
    if self.timer_logout then
        self.timer_logout:cancel()
        self.timer_logout = nil
    end

    if sock.role and sock.role ~= self then
        -- 换号?
        sock.role:logout()
    end
    if self.sock_id and self.sock_id ~= sock.sock_id then
        -- 顶号
        local old_sock_id = self.sock_id
        local SockCls = require("sock").SockCls
        local old_sock = SockCls.get_sock(old_sock_id)
        if old_sock then
            old_sock:send("s_kick_out", {})
        end
        self:logout(true)
        if old_sock_id > 0 then
            cluster_utils.send_agent_gate("ls_close_sock", old_sock_id)
        end
    end

    -- 登陆
    self.db.login_type = json_data and json_data.type
    self.db.gata_param = json_data and json_data.gata_param
    self.db.login_param = json_data and json_data.param
    self.sock_id = sock.sock_id
    sock:bind_role(self)
    cluster_utils.send_agent_gate("ls_bind_role", self.sock_id, self.uuid)
    self:on_online()
    self.db.login_ts = date.time_second()
    self.token = string.rand_string(32)
    g_log:role("RoleLogin", {urs = self.urs, uuid = self.uuid})
    self:gaea_log("RoleLogin", {
        loginType = g_const.LogloginType.login,
        duration = 0,
        roleName = self.db.name,
        roleRace = self.db.role_id,
    })
end

function role_cls:logout(no_remove)
    cluster_utils.send_agent_gate("ls_unbind_role", self.uuid)
    if self.sock_id then
        local SockCls = require("sock").SockCls
        local sock = SockCls.get_sock(self.sock_id)
        if sock then
            sock:bind_role(nil)
        end
        self.sock_id = nil
    end
    self.db.logout_ts = date.time_second()
    self.chat:logout_chat()
    self.dynasty:logout_dynasty()

    self:logout_log()
    g_log:role("RoleLogout", {urs = self.urs, uuid = self.uuid})
    local duration = (date.time_second() - self.db.login_ts) * 1000
    self:gaea_log("RoleLogin", {
        loginType = g_const.LogloginType.logout,
        duration = duration,
        roleName = self.db.name,
        roleRace = self.db.role_id,
    })

    self:save(not no_remove)
    if not no_remove then
        self:remove()
    end
end

function role_cls:kick()
    local sock_id = self.sock_id
    if sock_id then
        local SockCls = require("sock").SockCls
        local sock = SockCls.get_sock(sock_id)
        if sock then
            sock:send("s_kick_out", {})
        end
        cluster_utils.send_agent_gate("ls_close_sock", sock_id)
    end
    self.db.last_offline_ts = date.time_second()
    self:logout()
end

function role_cls:insert_login_role_info(role_info)
    -- if self:get_channel() ~= 'wpx' then return end
    role_info = g_const.StLoginRoleInfo(role_info)
    return cluster_utils.send_login("ls_insert_role_info", self.db.urs, self.uuid, role_info)
end

function role_cls:update_login_role_info(key, value)
    -- if self:get_channel() ~= 'wpx' then return end
    return cluster_utils.send_login("ls_update_role_info", self.db.urs, self.uuid, key, value)
end

function role_cls:give_fight_reward()
    if not self.fight_reward then return end
    self:add_item_list(self.fight_reward.item_list, self.fight_reward.reason)
    self.fight_reward = nil
end

function role_cls:updata_fight_score(not_notify)
    self.base:updata_fight_score(not_notify)
end

function role_cls:send_score_msg()
    self:send_client("s_update_base_info", {fight_score = self.db.fight_score, score = self.db.score})
end

function role_cls:give_init_item()
    self.base:give_init_item()
end

function role_cls:logout_log()
    self.base:logout_log()
end

function role_cls:get_language()
    return self.db.language
end

function role_cls:on_rename()
    self.base:on_rename()
end

function role_cls:set_level(new_level, reason)
    self.base:set_level(new_level, reason)
end

function role_cls:check_send_question()
    require("questionnaire").check_send_question(self)
end
--------------- base method end ---------------

-------------------yunwei start-----------------
function role_cls:get_channel()
    local login_param = self.db.login_param
    return login_param and login_param.channel or ""
end

function role_cls:yw_is_forbid_speak()
    local data = self.db.yw_forbid_speak
    if data then
        if data.end_ts and data.end_ts > date.time_second() then
            return true
        else
            self.db.yw_forbid_speak = nil
        end
    end
end

function role_cls:yw_is_forbid_login()
    local data = self.db.yw_forbid_login
    if data then
        if data.end_ts and data.end_ts > date.time_second() then
            return true
        else
            self.db.yw_forbid_login = nil
        end
    end
end
-------------------yunwei end-------------------

-------------------log start----------------------
function role_cls:gaea_log(log_name, extra_args)
    return log_utils.gaea_log(self.uuid, log_name, extra_args)
end
------------------log end-------------------------

--------------- total_hall method start ---------------
function role_cls:online_total_hall()
    self.total_hall:online_total_hall()
end

function role_cls:handle_info(id)
    return self.total_hall:handle_info(id)
end

function role_cls:publish_cmd(id)
    return self.total_hall:publish_cmd(id)
end

function role_cls:use_hall_item(item_id, cmd_id, count)
    return self.total_hall:add_number(item_id, cmd_id, count)
end

--------------- total_hall method end ---------------

--------------- hero method start -------------------
function role_cls:get_hero(hero_id)
    return self.db.hero_dict[hero_id]
end

function role_cls:get_all_hero_score()
    return self.hero:get_all_hero_score()
end

function role_cls:add_hero(hero_id)
    self.hero:add_hero(hero_id)
end

function role_cls:modify_hero_attr(hero_id, old_attr_dict, new_attr_dict, not_notify)
    self.hero:modify_hero_attr(hero_id, old_attr_dict, new_attr_dict, not_notify)
end

function role_cls:change_lineup_hero_talent_attr(hero_id, is_clear)
    self.hero:change_lineup_hero_talent_attr(hero_id, is_clear)
end

function role_cls:get_hero_dict()
    return self.db.hero_dict
end

function role_cls:get_add_talent_attr(hero_id, self_power)
    return self.hero:get_add_talent_attr(hero_id, self_power)
end

function role_cls:refresh_fate(hero_id)
    return self.hero:refresh_fate(hero_id)
end

function role_cls:vip_level_up_privilege_heroshop_num(old_level, new_level)
    self.hero:vip_level_up_privilege_heroshop_num(old_level, new_level)
end
--------------- hero method end ----------------------

--------------- lineup method start -------------------
function role_cls:lvlup_check_lineup_unlock()
    self.lineup:check_lineup_unlock()
end

function role_cls:get_role_fight_data()
    return self.lineup:get_role_fight_data()
end

function role_cls:eval_fight_score()
    return self.lineup:eval_fight_score()
end

function role_cls:get_hero_lineup_id(hero_id)
    return self.lineup:get_hero_lineup_id(hero_id)
end

function role_cls:get_lineup_info()
    return self.db.lineup_dict
end

function role_cls:check_lineup_has_hero()
    return self.lineup:check_lineup_has_hero()
end

function role_cls:check_reinforcements_unlock()
    return self.lineup:check_reinforcements_unlock()
end

function role_cls:get_reinforcements_pos_id(hero_id)
    return self.lineup:get_reinforcements_pos_id(hero_id)
end
--------------- lineup method end ----------------------

--------------- hunt method start -------------------
function role_cls:get_listen_animal()
    return self.db.hunt.listen_animal
end

function role_cls:unlock_hunt_ground(not_notify)
    return self.hunt:unlock_hunt_ground(not_notify)
end

function role_cls:add_hunt_point(hunt_point)
    return self.hunt:add_hunt_point(hunt_point)
end

function role_cls:end_hunt_ground()
    return self.hunt:end_hunt_ground()
end

function role_cls:get_hunt_rank_list()
    return self.hunt:get_hunt_rank()
end
--------------- hunt method end ----------------------

--------------- attr method start ---------------
function role_cls:modify_attr(old_attr_dict, new_attr_dict, is_role)
    return self.attr:modify_attr(old_attr_dict, new_attr_dict, is_role)
end
--------------- attr method end ---------------

--------------- bag method start ---------------------
function role_cls:add_item(item_id, count, reason, not_notify)
    return self.bag:add_new_item(item_id, count, reason, not_notify)
end

function role_cls:add_item_list(item_list, reason, not_notify)
    return self.bag:add_item_list(item_list, reason, not_notify)
end

function role_cls:add_item_dict(item_dict, reason, not_notify)
    return self.bag:add_item_dict(item_dict, reason, not_notify)
end

function role_cls:consume_item(item_id, count, reason, item_guid, force_consume)
    return self.bag:consume_item(item_id, count, reason, item_guid, force_consume)
end

function role_cls:consume_item_list(item_list, reason, force_consume)
    return self.bag:consume_item_list(item_list, reason, force_consume)
end

function role_cls:consume_item_dict(item_dict, reason, force_consume)
    return self.bag:consume_item_dict(item_dict, reason, force_consume)
end

function role_cls:get_item_count(item_id, item_guid)
    return self.bag:get_item_count(item_id, item_guid)
end

function role_cls:get_bag_item(item_guid)
    return self.bag:get_bag_item(item_guid)
end
--------------- bag method end -----------------------

--------------- lover method start ---------------
function role_cls:add_lover(lover_id)
    self.lover:add_lover(lover_id)
end

function role_cls:add_lover_exp(lover_id, count)
    self.lover:add_lover_exp(lover_id, count)
end

function role_cls:get_lover_dict()
    return self.db.lover_dict
end

function role_cls:use_discuss_item(item_count)
    return self.lover:recover_energy(item_count)
end

function role_cls:get_random_lover()
    return self.lover:get_random_lover()
end

function role_cls:vip_level_up_privilege_lovershop_num(old_level, new_level)
    self.lover:vip_level_up_privilege_lovershop_num(old_level, new_level)
end
--------------- lover method end ---------------

--------------- child method start ---------------
function role_cls:new_child(place_id, mather_id)
    return self.child:new_child(place_id, mather_id)
end

function role_cls:receive_request_child_info(object)
    return self.child:receive_request(object)
end

function role_cls:passive_cancel_child_request(uuid, child_id)
    return self.child:passive_cancel_request(uuid, child_id)
end

function role_cls:passive_refuse_child_request(child_id)
    return self.child:passive_refuse_request(child_id)
end

function role_cls:passive_marriage(child_id, object)
   return self.child:passive_marriage(child_id, object)
end

function role_cls:get_child(child_id)
   return self.db.child[child_id]
end

function role_cls:get_child_count()
   return #self.db.child
end

function role_cls:vip_level_up_privilege_child_vitality_num(old_level, new_level)
    self.child:vip_level_up_privilege_child_vitality_num(old_level, new_level)
end

function role_cls:get_marry_attr(child_id)
   return self.child:get_marry_attr(child_id)
end
--------------- child method end ---------------

--------------- stage method start -------------------
function role_cls:get_curr_stage()
    return self.db.stage.curr_stage
end

function role_cls:stage_to_criminal()
    self.prison:stage_to_criminal()
end

function role_cls:change_action_point(num, is_add)
    return self.stage:change_action_point(num, is_add)
end

function role_cls:use_action_point_item(item_count)
    return self.stage:use_action_point_item(item_count)
end

function role_cls:get_manage_city_count()
    return self.stage:get_manage_city_count()
end

function role_cls:get_stage_star()
    return self.stage:get_stage_star()
end

function role_cls:vip_level_up_privilege_stage(old_level, new_level)
    self.stage:vip_level_up_privilege_stage(old_level, new_level)
end
--------------- stage method end ----------------------

--------------- travel method start ----------------------
function role_cls:unlock_travel_tolvlup()
    self.travel:unlock_tolvlup()
end

function role_cls:vip_level_up_privilege_travel_num(old_level, new_level)
    self.travel:vip_level_up_privilege_travel_num(old_level, new_level)
end
--------------- travel method end ----------------------

--------------- salon method start ----------------------
function role_cls:salon_lover_compute()
    self.salon:lover_compute()
end

function role_cls:salon_pvp_results(pvp_info)
    self.salon:receive_pvp_results(pvp_info)
end

function role_cls:get_salon_rank_list()
    return self.salon:get_rank()
end
--------------- salon method end ----------------------

--------------- arena method start ----------------------
function role_cls:change_vitality(num, is_add)
    return self.arena:change_vitality(num, is_add)
end

function role_cls:arena_select_reward(reward_index)
    return self.arena:arena_select_reward(reward_index)
end

function role_cls:get_arena_rank_list()
    return self.arena:get_arena_rank_list()
end
--------------- arena method end ------------------------

--------------- daily_dare method start ----------------------
function role_cls:daily_dare_unlock_lvl()
    return self.daily_dare:unlock_lvl()
end
--------------- daily_dare method end ----------------------

--------------- treasure method start ----------------------
function role_cls:add_treasure_fragment(item_id, count)
    return self.treasure:add_treasure_fragment(item_id, count)
end

function role_cls:grab_treasure_select_reward(reward_index)
    return self.treasure:grab_treasure_select_reward(reward_index)
end
--------------- treasure method end ------------------------

--------------- arena method start ----------------------
function role_cls:use_vitality_item(item_count)
    return self.arena:use_vitality_item(item_count)
end
--------------- arena method end ------------------------

--------------- party method start ----------------------
function role_cls:party_update_lover_level(lover_id, level)
    self.party:update_lover_level(lover_id, level)
end

function role_cls:get_party_rank_list()
    return self.party:get_rank()
end
--------------- party method end ------------------------

--------------- dynasty method start ----------------------
function role_cls:get_dynasty_id()
    return self.dynasty.dynasty_id
end

function role_cls:get_dynasty_name()
    return self.dynasty.dynasty_name
end

function role_cls:join_dynasty(dynasty_id)
    return self.dynasty:join_dynasty(dynasty_id)
end

function role_cls:delete_dynasty_apply(dynasty_id)
    return self.dynasty:delete_role_apply(dynasty_id)
end

function role_cls:update_dynasty_role_info(update_info)
    return self.dynasty:update_dynasty_role_info(update_info)
end

function role_cls:get_dynasty_spell_attr()
    return self.dynasty:get_dynasty_spell_attr()
end

function role_cls:get_dynasty_member_info()
    return self.dynasty:get_dynasty_member_info()
end

function role_cls:kicked_out_dynasty()
    return self.dynasty:kicked_out_dynasty()
end

function role_cls:get_dynasty_spell_add_exp(exp)
    return self.dynasty:get_dynasty_spell_add_exp(exp)
end

function role_cls:update_dynasty_task(task_type, progress)
    return self.dynasty:update_task(task_type, progress)
end
--------------- dynasty method end ------------------------

--------------- task method start ------------------------
function role_cls:update_task(task_type, task_param)
    return self.task:update_task(task_type, task_param)
end
--------------- task method end --------------------------

--------------- achievement method start ------------------------
function role_cls:update_achievement(achievement_type, progress)
    return self.achievement:update_achievement(achievement_type, progress)
end
--------------- achievement method end --------------------------

--------------- guide method start ------------------------
-- 指引事件
function role_cls:guide_event_trigger_check(event_id)
    return self.guide:event_trigger_check(event_id)
end

-- 等级事件
function role_cls:level_event_trigger_check(new_level)
    return self.guide:level_trigger_check(new_level)
end

-- vip等级事件
function role_cls:vip_level_trigger_check(lock_id)
    return self.guide:vip_level_trigger_check(lock_id)
end

-- 检查功能/系统是否已解锁
function role_cls:check_function_is_unlocked(func_id)
    return self.guide:check_function_is_unlocked(func_id)
end
--------------- guide method end --------------------------

--------------- daily_active method start ------------------------
function role_cls:update_daily_active(task_type, progress, id)
    return self.daily_active:update_daily_active(task_type, progress, id)
end
--------------- daily_active method end --------------------------

--------------- first_week method start ------------------------
function role_cls:update_first_week_task(task_type, progress)
    return self.first_week:update_first_week_task(task_type, progress)
end
--------------- first_week method end --------------------------

--------------- train method start ------------------------
function role_cls:get_train_rank_list()
    return self.train:train_get_rank()
end
--------------- train method end --------------------------

--------------- traitor method start ------------------------
function role_cls:add_traitor(is_auto_kill)
    return self.traitor:add_traitor(is_auto_kill)
end

function role_cls:delete_traitor(reward_list, no_notify)
    return self.traitor:delete_traitor(reward_list, no_notify)
end

function role_cls:get_traitor_hurt_rank_list()
    return self.traitor:get_hurt_rank()
end

function role_cls:get_traitor_feats_rank_list()
    return self.traitor:get_feats_rank()
end

function role_cls:add_dynasty_honour()
    return self.traitor:add_dynasty_honour()
end

function role_cls:delete_dynasty_honour()
    return self.traitor:delete_dynasty_honour()
end

function role_cls:get_traitor_honour()
    return self.db.traitor_boss.honour
end

function role_cls:get_traitor_boss_hurt()
    return self.db.traitor_boss.max_hurt
end

function role_cls:traitor_boss_delete_role()
    self.traitor:quit_traitor_boss()
    self.traitor:quit_cross_traitor_boss()
end
--------------- traitor method end --------------------------

--------------- activity method start ------------------------
function role_cls:update_activity_data(detail_id, add_value)
    return self.activity:update_activity_data(detail_id, add_value)
end

function role_cls:update_activity_item_data(item_id, sub_count)
    return self.activity:update_activity_item_data(item_id, sub_count)
end
--------------- activity method end --------------------------

--------------- rush_activity method start ------------------------
function role_cls:update_rush_activity_data(activity_id, add_value)
    return self.rush_activity:update_activity_data(activity_id, add_value)
end

function role_cls:update_rush_activity_item_data(item_id, add_count)
    return self.rush_activity:update_activity_item_data(item_id, add_count)
end

function role_cls:rush_activity_on_join_dynasty(dynasty_id)
    return self.rush_activity:on_join_dynasty(dynasty_id)
end

function role_cls:rush_activity_on_quit_dynasty()
    return self.rush_activity:on_quit_dynasty()
end
--------------- rush_activity method end --------------------------

--------------- friend method start ------------------------
function role_cls:add_friend_apply(uuid)
    return self.friend:add_friend_apply(uuid)
end

function role_cls:can_private_chat(friend_uuid)
    return self.friend:can_private_chat(friend_uuid)
end

function role_cls:get_friend_dict()
    return self.db.friend.handsel_gift
end
--------------- friend method end --------------------------

--------------- vip method start ------------------------
function role_cls:get_vip_privilege_num(privilege_id)
    return self.vip:get_vip_privilege_num(privilege_id)
end

function role_cls:add_vip_exp(progress, reason)
    return self.vip:add_vip_exp(progress, reason)
end
--------------- vip method end --------------------------

--------------- dare_tower method start ------------------------
function role_cls:vip_level_up_privilege_tower_num(old_level, new_level)
    return self.dare_tower:vip_level_up_privilege_tower_num(old_level, new_level)
end
--------------- dare_tower method end --------------------------

--------------- festival_activity method start ------------------------
function role_cls:update_festival_activity_data(type_id, args)
    return self.festival_activity:update_activity_data(type_id, args)
end
--------------- festival_activity method end --------------------------

--------------- check_in_monthly method start ------------------------
function role_cls:get_replenish_count_by_active(require_num)
    return self.check_in_monthly:get_replenish_count_by_active(require_num)
end

function role_cls:get_replenish_count_by_recharge(progress)
    return self.check_in_monthly:get_replenish_count_by_recharge(progress)
end
--------------- check_in_monthly method end --------------------------

----------------------- recharge method start ------------------------
function role_cls:role_recharge(recharge_id)
    return self.recharge:recharge(recharge_id)
end
----------------------- recharge method end --------------------------

--------------- single_recharge method start ------------------------
function role_cls:unlock_single_recharge(recharge_rank)
    return self.single_recharge:unlock_single_recharge(recharge_rank)
end
--------------- single_recharge method end --------------------------

--------------- recharge_draw method start ------------------------
function role_cls:get_recharge_addition_draw_num(recharge_count)
    return self.recharge_draw:get_addition_draw_num(recharge_count)
end
--------------- recharge_draw method end --------------------------

-------------- fund method begin ---------------
function role_cls:notify_fund_level_up(new_level)
    return self.fund:notify_level_up(new_level)
end
--------------- fund method end ----------------

-------------- luxury_check_in method begin ---------------
function role_cls:luxury_check_in_recharge(recharge_id)
    return self.luxury_check_in:recharge_event(recharge_id)
end
--------------- luxury_check_in method end ----------------

-------------- daily_recharge method begin ---------------
function role_cls:daily_recharge_recharge_event(recharge_id)
    return self.daily_recharge:on_recharge_event(recharge_id)
end
--------------- daily_recharge method end ----------------

-------------- title method begin ---------------
function role_cls:get_title()
    return self.db.title.wearing_id
end

function role_cls:add_title(title_id, add_ts)
    return self.title:add_title(title_id, add_ts)
end

function role_cls:get_hero_title_attr()
    return self.title:get_hero_title_attr()
end
--------------- title method end ----------------

--------------- rank method start ------------------------
function role_cls:update_role_rank(rank_name, rank_score)
    self.rank:update_role_rank(rank_name, rank_score)
end

function role_cls:update_cross_role_rank(rank_name, rank_score)
    self.rank:update_cross_role_rank(rank_name, rank_score)
end

function role_cls:update_rank_role_info(role_info)
    self.rank:update_role_info(role_info)
end
--------------- rank method end --------------------------

---------------------- mail method begin ---------------
function role_cls:add_mail(mail_info)
    return self.mail:add_mail(mail_info)
end

function role_cls:check_deadline_mail()
    return self.mail:check_deadline_mail()
end
---------------------- mail method end -----------------

------------------------------------------------------  hunt method
function role_cls:get_hunting_hurt()
    return self.db.hunt.history_point
end

------------------------------------------------------  train method
function role_cls:get_train_history_star()
    return self.db.train.history_star_num
end

------------------------------------------------------
local function add_meta(meta_name)
    local reload = require("srv_utils.reload")
    local meta = require("meta_table." .. meta_name)
    reload.set_reload_after_callback(meta, function()
        add_meta(meta_name)
    end)
    -- 添加
    for name, func in pairs(meta) do
        if type(func) == "function" and string.sub(name, 1, 2) ~= "__" then
            if role_cls[name] and meta_name ~= role_cls.__meta_mapper[name] then
                g_log:raise("重复的role方法", name, meta_name)
            end
        end
    end
    for name, func in pairs(meta) do
        if type(func) == "function" and string.sub(name, 1, 2) ~= "__" then
            role_cls[name] = func
            role_cls.__meta_mapper[name] = meta_name
        end
    end
end

-- 记录role_cls自己的meta
for name, func in pairs(role_cls) do
    if type(func) == "function" and string.sub(name, 1, 2) ~= "__" then
        role_cls.__meta_mapper[name] = "role_cls"
    end
end

return role_cls
