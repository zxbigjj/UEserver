local excel_data = require("excel_data")
local date = require("sys_utils.date")
local timer = require("timer")
local cluster_utils = require("msg_utils.cluster_utils")
local CSFunction = require("CSCommon.CSFunction")

local role_dynasty = DECLARE_MODULE("meta_table.dynasty")

function role_dynasty.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
        quit_timer = nil,
        dynasty_id = nil,
        dynasty_name = nil
    }
    return setmetatable(self, role_dynasty)
end

function role_dynasty:call_dynasty(cmd, ...)
    return cluster_utils.call_dynasty(cmd, self.uuid, ...)
end

function role_dynasty:send_dynasty(cmd, ...)
    cluster_utils.send_dynasty(cmd, self.uuid, ...)
end

function role_dynasty:init_dynasty()
    self:reset_dynasty_task()
end

-- 重置王朝任务
function role_dynasty:reset_dynasty_task()
    self.db.dynasty.task_dict = {}
    local task_dict = self.db.dynasty.task_dict
    for task_type, task_list in pairs(excel_data.DynastyTaskData["task_dict"]) do
        task_dict[task_type] = {
            progress = 0,
            task_id = task_list[1]
        }
    end
end

function role_dynasty:load_dynasty()
    local dynasty_name, build_progress
    self.dynasty_id, dynasty_name, build_progress = self:call_dynasty("lc_login_dynasty")
    self:on_dynasty_name_change(dynasty_name)
    self:set_quit_timer()
    if build_progress then
        self:update_dynasty_build_progress(build_progress)
    end
end

function role_dynasty:set_quit_timer()
    local dynasty = self.db.dynasty
    if not dynasty.quit_ts or self.quit_timer then return end
    local now = date.time_second()
    -- quit_ts为可以再次申请加入的时间
    if now >= dynasty.quit_ts then
        dynasty.quit_ts = nil
        return
    end
    local duration_time = dynasty.quit_ts - now
    self.quit_timer = self.role:timer_loop(duration_time, function()
        self.quit_timer = nil
        dynasty.quit_ts = nil
        self.role:send_client("s_update_dynasty_quit_ts", {quit_ts = dynasty.quit_ts})
    end)
end

function role_dynasty:online_dynasty()
    local dynasty = self.db.dynasty
    self.role:send_client("s_update_dynasty_info", {
        apply_dict = dynasty.apply_dict,
        dynasty_id = self.dynasty_id,
        daily_active = dynasty.daily_active,
        active_reward = dynasty.active_reward,
        task_dict = dynasty.task_dict,
        spell_dict = dynasty.spell_dict,
        build_type = dynasty.build_type,
        build_progress_reward = dynasty.build_progress_reward
    })
    self.role:send_client("s_update_dynasty_quit_ts", {quit_ts = dynasty.quit_ts})
    self.role:send_client("s_update_dynasty_shop_info", {shop_dict = dynasty.shop_dict})
    self:send_dynasty("ls_online_dynasty")
end

function role_dynasty:daily_dynasty()
    local dynasty = self.db.dynasty
    local apply_dict = dynasty.apply_dict
    local now = date.time_second()
    local keep_ts = excel_data.ParamData["dynasty_apply_keep_time"].f_value * CSConst.Time.Hour
    local dynasty_dict = {}
    for dynasty_id, apply_ts in pairs(apply_dict) do
        if now - apply_ts >= keep_ts then
            dynasty_dict[dynasty_id] = true
        end
    end
    if next(dynasty_dict) then
    -- 清除过期申请
        for dynasty_id in pairs(dynasty_dict) do
            apply_dict[dynasty_id] = nil
            self:send_dynasty("ls_cancel_apply_dynasty", dynasty_id)
        end
    end

    dynasty.daily_active = 0
    dynasty.active_reward = {}
    dynasty.buy_challenge_num = 0
    dynasty.buy_attack_num = 0
    dynasty.build_type = 0
    dynasty.build_progress_reward = {}
    for reward_id in ipairs(excel_data.ProgressRewardData) do
        dynasty.build_progress_reward[reward_id] = false
    end
    self:send_dynasty("ls_update_role_build_progress_reward")
    self:reset_dynasty_task()
    self.role:send_client("s_update_dynasty_info", {
        apply_dict = dynasty.apply_dict,
        active_reward = dynasty.active_reward,
        daily_active = dynasty.daily_active,
        task_dict = dynasty.task_dict,
        build_type = dynasty.build_type,
        build_progress_reward = dynasty.build_progress_reward
    })

    for shop_id, data in pairs(excel_data.DynastyShopData) do
        if data.daily_num then
            dynasty.shop_dict[shop_id] = nil
        end
    end
    self.role:send_client("s_update_dynasty_shop_info", {shop_dict = dynasty.shop_dict})
end

function role_dynasty:logout_dynasty()
    local dynasty = self.db.dynasty
    if not self.dynasty_id then return end
    self:send_dynasty("ls_logout_dynasty")
end

function role_dynasty:on_dynasty_name_change(dynasty_name)
    self.dynasty_name = dynasty_name
    self.role:update_rank_role_info({dynasty_name = dynasty_name or {}})
end

-- 创建王朝
function role_dynasty:create_dynasty(dynasty_name)
    if not dynasty_name or not IsStringBroken(dynasty_name) then return end
    if self.dynasty_id then return end

    --屏蔽字
    local name_utils = require("name_utils")
    local maskWord = name_utils.sdk_4399_check_name(dynasty_name)
    print('=======王朝名字屏蔽字==========' .. maskWord)
     if tostring(maskWord) ~= "{}" then
        return false,true,true
    end

    if not self:check_dynasty_name(dynasty_name) then return end
    local param_data = excel_data.ParamData
    if self.role:get_vip() < param_data["dynasty_create_vip"].f_value then
        return
    end
    local cost_data = param_data["dynasty_create_cost"]
    if not self.role:consume_item(cost_data.item_id, cost_data.count, g_reason.dynasty_create) then
        return
    end
    local dynasty = self.db.dynasty
    local dynasty_info = {
        dynasty_id = self:build_dynasty_id(),
        dynasty_name = dynasty_name,
        apply_dict = dynasty.apply_dict
    }
    local role_info = self:build_role_info()
    local ret, name_repeat = self:call_dynasty("lc_create_dynasty", dynasty_info, role_info)
    if not ret then
        self.role:add_item(cost_data.item_id, cost_data.count, g_reason.dynasty_create, true)
        return ret, name_repeat
    end
    self.dynasty_id = ret.dynasty_id
    self:on_dynasty_name_change(ret.dynasty_name)
    dynasty.apply_dict = {}
    self.role:send_client("s_update_dynasty_info", {apply_dict = dynasty.apply_dict})
    self.role:log("CreateDynasty", {dynasty = ret})
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.JoinDynasty, 1)
    self.role:rush_activity_on_join_dynasty(self.dynasty_id) -- 冲榜活动，加入王朝

    -- 添加王朝技能增加的属性
    local attr_dict = self:get_dynasty_spell_attr()
    self:modify_dynasty_spell_attr(nil, attr_dict)
    self.role:add_dynasty_honour()
    return ret
end

-- 检查王朝名字合法性
function role_dynasty:check_dynasty_name(dynasty_name)
    local param_data = excel_data.ParamData
    local min_len = param_data["dynasty_name_min_len"].f_value
    local max_len = param_data["dynasty_name_max_len"].f_value
    if string.len(dynasty_name) < min_len or string.len(dynasty_name) > max_len then return end
    -- 名字前后不能是空格
    if string.sub(dynasty_name, 1, 1) == " " or string.sub(dynasty_name, -1, -1) == " " then return end
    -- 名字不能存在连续空格
    if string.find(dynasty_name, "  ") then return end
    return true
end

-- 构建王朝ID
function role_dynasty:build_dynasty_id()
    local server_data = require("server_data")
    local last_dynasty_num = server_data.get_server_core("last_dynasty_num") + 1
    if last_dynasty_num >= g_const.Max_Dynasty_Num then
        error("create dynasty fail")
    end
    server_data.set_server_core("last_dynasty_num", last_dynasty_num)
    local server_id = require("srv_utils.server_env").get_server_id()
    local dynasty_id = "" .. (server_id * g_const.Max_Dynasty_Num + last_dynasty_num)
    return dynasty_id
end

-- 构建王朝成员信息
function role_dynasty:build_role_info()
    local role_info = {
        uuid = self.uuid,
        name = self.role:get_name(),
        level = self.role:get_level(),
        fight_score = self.role:get_fight_score(),
        score = self.role:get_score(),
        role_id = self.role:get_role_id(),
        vip = self.role:get_vip(),
    }
    return role_info
end

-- 获取王朝列表
function role_dynasty:get_dynasty_list(page)
    if not page then return end
    local dynasty_list = self:call_dynasty("lc_get_dynasty_list", page)
    return {dynasty_list = dynasty_list}
end

-- 获取王朝排行
function role_dynasty:get_dynasty_rank()
    return self:call_dynasty("lc_get_dynasty_rank")
end

-- 查找王朝
function role_dynasty:seek_dynasty(dynasty_name)
    if not dynasty_name then return end
    if not self:check_dynasty_name(dynasty_name) then return end
    local dynasty_list = self:call_dynasty("lc_seek_dynasty", dynasty_name)
    return {dynasty_list = dynasty_list}
end

-- 申请加入王朝
function role_dynasty:apply_dynasty(dynasty_id)
    if self.dynasty_id then return end
    local dynasty = self.db.dynasty
    if dynasty.quit_ts then return end
    if dynasty.apply_dict[dynasty_id] then return end
    local param_data = excel_data.ParamData
    if #dynasty.apply_dict >= param_data["dynasty_apply_num_limit"].f_value then
        return
    end
    local role_info = self:build_role_info()
    if not self:call_dynasty("lc_apply_dynasty", dynasty_id, role_info) then return end
    dynasty.apply_dict[dynasty_id] = date.time_second()
    self.role:send_client("s_update_dynasty_info", {apply_dict = dynasty.apply_dict})
    return true
end

-- 取消申请
function role_dynasty:cancel_apply_dynasty(dynasty_id)
    if not dynasty_id then return end
    local dynasty = self.db.dynasty
    if not dynasty.apply_dict[dynasty_id] then return end
    dynasty.apply_dict[dynasty_id] = nil
    self:send_dynasty("ls_cancel_apply_dynasty", dynasty_id)
    self.role:send_client("s_update_dynasty_info", {apply_dict = dynasty.apply_dict})
    return true
end

-- 获取王朝基础信息
function role_dynasty:get_dynasty_base_info()
    if not self.dynasty_id then return end
    return self:call_dynasty("lc_get_dynasty_base_info")
end

-- 获取王朝成员信息
function role_dynasty:get_dynasty_member_info()
    if not self.dynasty_id then return end
    return self:call_dynasty("lc_get_dynasty_member_info")
end

-- 获取王朝申请信息
function role_dynasty:get_dynasty_apply_info()
    if not self.dynasty_id then return end
    return self:call_dynasty("lc_get_dynasty_apply_info")
end

-- 同意申请加入王朝
function role_dynasty:agree_apply_dynasty(member_uuid)
    if not member_uuid then return end
    if not self.dynasty_id then return end
    return self:call_dynasty("lc_agree_apply_dynasty", member_uuid)
end

-- 拒绝申请加入王朝
function role_dynasty:refuse_apply_dynasty(member_uuid)
    if not self.dynasty_id then return end
    return self:call_dynasty("lc_refuse_apply_dynasty", member_uuid)
end

-- 加入王朝
function role_dynasty:join_dynasty(dynasty_id)
    self.dynasty_id = dynasty_id
    local role_info = {
        level = self.role:get_level(),
        fight_score = self.role:get_fight_score(),
        vip = self.role:get_vip(),
    }
    local dynasty = self.db.dynasty
    local dynasty_name = self:call_dynasty("lc_join_dynasty", dynasty.apply_dict, role_info)
    self:on_dynasty_name_change(dynasty_name)
    dynasty.apply_dict = {}
    self.role:send_client("s_update_dynasty_info", {apply_dict = dynasty.apply_dict})
    self.role:send_client("s_join_dynasty", {dynasty_id = dynasty_id})
    self.role:log("JoinDynasty", {dynasty_id = dynasty_id})
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.JoinDynasty, 1)
    self.role:rush_activity_on_join_dynasty(self.dynasty_id) -- 冲榜活动，加入王朝

    -- 添加王朝技能增加的属性
    local attr_dict = self:get_dynasty_spell_attr()
    self:modify_dynasty_spell_attr(nil, attr_dict)
    self.role:add_dynasty_honour()
end

-- 退出王朝
function role_dynasty:quit_dynasty()
    if not self.dynasty_id then return end
    self:send_dynasty("ls_quit_dynasty")
    self.role:delete_dynasty_honour()
    local dynasty_id = self.dynasty_id
    self.dynasty_id = nil
    self:on_dynasty_name_change(nil)
    local param_data = excel_data.ParamData
    local cooling_time
    if self.role:get_level() >= param_data["dynasty_quit_apply_level"].f_value then
        cooling_time = param_data["dynasty_apply_cooling_max_time"].f_value
    else
        cooling_time = param_data["dynasty_apply_cooling_min_time"].f_value
    end
    local dynasty = self.db.dynasty
    dynasty.quit_ts = date.time_second() + cooling_time * CSConst.Time.Hour
    self.role:send_client("s_update_dynasty_quit_ts", {quit_ts = dynasty.quit_ts})
    self:set_quit_timer()
    self.role:log("QuitDynasty", {dynasty_id = dynasty_id})
    self.role:rush_activity_on_quit_dynasty() -- 冲榜活动，退出王朝

    -- 清除王朝技能增加的属性
    local attr_dict = self:get_dynasty_spell_attr()
    self:modify_dynasty_spell_attr(attr_dict, nil)
    return true
end

-- 删除申请
function role_dynasty:delete_role_apply(dynasty_id)
    local dynasty = self.db.dynasty
    local apply_dict = dynasty.apply_dict
    if not apply_dict[dynasty_id] then return end
    apply_dict[dynasty_id] = nil
    self.role:send_client("s_update_dynasty_info", {apply_dict = dynasty.apply_dict})
end

-- 修改王朝徽章
function role_dynasty:modify_dynasty_badge(dynasty_badge)
    if not dynasty_badge then return end
    if not self.dynasty_id then return end
    if not excel_data.DynastyBadgeData[dynasty_badge] then return end
    local is_init_badge = self:call_dynasty("lc_check_is_init_badge")
    local cost_data = excel_data.ParamData["modify_dynasty_badge_cost"]
    if not is_init_badge then
        -- 第一次不消耗
        if not self.role:consume_item(cost_data.item_id, cost_data.count, g_reason.modify_dynasty_badge) then
            return
        end
    end
    if not self:call_dynasty("lc_modify_dynasty_badge", dynasty_badge) then
        if not is_init_badge then
            self.role:add_item(cost_data.item_id, cost_data.count, g_reason.modify_dynasty_badge)
        end
        return
    end
    return true
end

-- 修改王朝名字
function role_dynasty:modify_dynasty_name(dynasty_name)
    if not dynasty_name or not IsStringBroken(dynasty_name) then return end
    if not self.dynasty_id then return end

    --屏蔽字
    local name_utils = require("name_utils")
    local maskWord = name_utils.sdk_4399_check_name(dynasty_name)
    print('=======修改王朝名字屏蔽字==========' .. maskWord)
    if tostring(maskWord) ~= "{}" then
        return false,true,true
    end

    if not self:check_dynasty_name(dynasty_name) then return end
    local cost_data = excel_data.ParamData["modify_dynasty_name_cost"]
    if not self.role:consume_item(cost_data.item_id, cost_data.count, g_reason.modify_dynasty_name) then
        return
    end
    local ret, name_repeat = self:call_dynasty("lc_modify_dynasty_name", dynasty_name)
    if not ret then
        self.role:add_item(cost_data.item_id, cost_data.count, g_reason.modify_dynasty_name)
        return ret, name_repeat
    end
    return true
end

-- 修改王朝公告
function role_dynasty:modify_dynasty_notice(dynasty_notice)
    if not self.dynasty_id then return end
    local len = excel_data.ParamData["dynasty_notice_declaration_len"].f_value
    if dynasty_notice then
        if not IsStringBroken(dynasty_notice) then return end
        if string.len(dynasty_notice) > len then return end
    end
    if not self:call_dynasty("lc_modify_dynasty_notice", dynasty_notice) then return end
    return true
end

-- 修改王朝宣言
function role_dynasty:modify_dynasty_declaration(dynasty_declaration)
    if not self.dynasty_id then return end
    local len = excel_data.ParamData["dynasty_notice_declaration_len"].f_value
    if dynasty_declaration then
        if not IsStringBroken(dynasty_declaration) then return end
        if string.len(dynasty_declaration) > len then return end
    end
    if not self:call_dynasty("lc_modify_dynasty_declaration", dynasty_declaration) then return end
    return true
end

-- 踢人
function role_dynasty:kick_out_dynasty(member_uuid)
    if not member_uuid then return end
    if self.uuid == member_uuid then return end
    if not self.dynasty_id then return end
    return self:call_dynasty("lc_kick_out_dynasty", member_uuid)
end

-- 被踢
function role_dynasty:kicked_out_dynasty()
    self.dynasty_id = nil
    self:on_dynasty_name_change(nil)
    self.role:send_client("s_kicked_out_dynasty", {})
    self.role:rush_activity_on_quit_dynasty() -- 冲榜活动，退出王朝

    -- 清除王朝技能增加的属性
    local attr_dict = self:get_dynasty_spell_attr()
    self:modify_dynasty_spell_attr(attr_dict, nil)
end

-- 任命成员
function role_dynasty:appoint_dynasty_member(member_uuid, job)
    if not member_uuid then return end
    if not excel_data.DynastyJobData[job] then return end
    if self.uuid == member_uuid then return end
    if not self.dynasty_id then return end
    return self:call_dynasty("lc_appoint_dynasty_member", member_uuid, job)
end

-- 解散王朝
function role_dynasty:dissolve_dynasty()
    if not self.dynasty_id then return end
    if self:call_dynasty("lc_dissolve_dynasty") then
        self.dynasty_id = nil
        self:on_dynasty_name_change(nil)
        return true
    end
    self.role:rush_activity_on_quit_dynasty() -- 冲榜活动，退出王朝

    -- 清除王朝技能增加的属性
    local attr_dict = self:get_dynasty_spell_attr()
    self:modify_dynasty_spell_attr(attr_dict, nil)
end

-- 更新家族成员信息
function role_dynasty:update_dynasty_role_info(update_info)
    if not update_info then return end
    if not self.dynasty_id then return end
    self:send_dynasty("ls_update_dynasty_role_info", update_info)
end

-- 更新王朝建设进度
function role_dynasty:update_dynasty_build_progress(build_progress)
    local has_change
    local build_progress_reward = self.db.dynasty.build_progress_reward
    for reward_id, data in ipairs(excel_data.ProgressRewardData) do
        if build_progress >= data.progress and build_progress_reward[reward_id] == false then
            build_progress_reward[reward_id] = true
            has_change = true
        elseif build_progress < data.progress and build_progress_reward[reward_id] == true then
            build_progress_reward[reward_id] = false
            has_change = true
        end
    end
    if has_change then
        self.role:send_client("s_update_dynasty_info", {build_progress_reward = build_progress_reward})
    end
end

-- 获取王朝建设信息
function role_dynasty:get_dynasty_build_info()
    if not self.dynasty_id then return end
    return self:call_dynasty("lc_get_dynasty_build_info")
end

-- 王朝建设
function role_dynasty:dynasty_build(build_type)
    if not build_type then return end
    if not self.dynasty_id then return end
    local build_data = excel_data.DynastyBuildData[build_type]
    if not build_data then return end
    local dynasty = self.db.dynasty
    if dynasty.build_type ~= 0 then return end
    if not self.role:consume_item(build_data.build_cost, build_data.cost_num, g_reason.dynasty_build) then
        return
    end
    if not self:call_dynasty("lc_dynasty_build", build_type) then
        self.role:add_item(build_data.build_cost, build_data.cost_num, g_reason.dynasty_build)
        return
    end

    dynasty.build_type = build_type
    self.role:add_item(CSConst.Virtual.Dedicate, build_data.dedicate, g_reason.dynasty_build)
    self.role:send_client("s_update_dynasty_info", {build_type = dynasty.build_type})
    self:update_task(CSConst.DynastyTaskType.Build, build_data.dedicate)
    if build_type == CSConst.DynastybuildType.High then
        self.role:update_first_week_task(CSConst.FirstWeekTaskType.DynastyBuild, 1)
    end
    return true
end

-- 获取王朝建设进度奖励
function role_dynasty:get_dynasty_build_reward(reward_index)
    if not reward_index then return end
    if not self.dynasty_id then return end
    local data = excel_data.ProgressRewardData[reward_index]
    if not data then return end
    local build_progress_reward = self.db.dynasty.build_progress_reward
    if not build_progress_reward[reward_index] then return end
    build_progress_reward[reward_index] = nil
    local reward_data = excel_data.RewardData[data.reward_id]
    self.role:add_item_list(reward_data.item_list, g_reason.dynasty_build_reward)
    self.role:send_client("s_update_dynasty_info", {build_progress_reward = build_progress_reward})
    return true
end

-- 获取王朝活跃奖励
function role_dynasty:get_dynasty_active_reward(reward_index)
    if not reward_index then return end
    if not self.dynasty_id then return end
    local data = excel_data.DynastyActiveRewardData[reward_index]
    if not data then return end
    local dynasty = self.db.dynasty
    if dynasty.daily_active < data.active then return end
    if dynasty.active_reward[reward_index] then return end
    dynasty.active_reward[reward_index] = true
    local reward_data = excel_data.RewardData[data.reward_id]
    self.role:add_item_list(reward_data.item_list, g_reason.dynasty_active_reward)
    self.role:send_client("s_update_dynasty_info", {active_reward = dynasty.active_reward})
    return true
end

-- 获取王朝技能信息
function role_dynasty:get_dynasty_spell_info()
    if not self.dynasty_id then return end
    return self:call_dynasty("lc_get_dynasty_spell_info")
end

-- 学习王朝技能
function role_dynasty:study_dynasty_spell(spell_id)
    if not spell_id then return end
    if not self.dynasty_id then return end
    local spell_data = excel_data.DynastySpellData[spell_id]
    if not spell_data then return end
    local spell_dict = self.db.dynasty.spell_dict
    local old_level = spell_dict[spell_id] or 0
    local new_level = old_level + 1
    local spell_info = self:call_dynasty("lc_get_dynasty_spell_info")
    if not spell_info then return end
    if not spell_info[spell_id] or spell_info[spell_id] < new_level then return end

    local spell_grow_data = CSFunction.get_dynasty_spell_cost(spell_id, new_level)
    if not self.role:consume_item(CSConst.Virtual.Dedicate, spell_grow_data.player_cost, g_reason.study_dynasty_spell) then
        return
    end
    spell_dict[spell_id] = new_level
    self.role:send_client("s_update_dynasty_info", {spell_dict = spell_dict})
    local attr_value = CSFunction.get_dynasty_spell_attr_value(spell_id, new_level)
    if old_level > 0 then
        attr_value = attr_value - CSFunction.get_dynasty_spell_attr_value(spell_id, old_level)
    end
    local attr_dict = {[spell_data.attribute] = attr_value}
    -- 更新技能属性
    self:modify_dynasty_spell_attr(nil, attr_dict)
    return true
end

-- 更新王朝技能属性加成
function role_dynasty:modify_dynasty_spell_attr(old_attr_dict, new_attr_dict)
    local lineup_dict = self.role:get_lineup_info()
    -- 王朝技能会给所有上阵英雄加属性
    for _, lineup_info in pairs(lineup_dict) do
        if lineup_info.hero_id then
            self.role:modify_hero_attr(lineup_info.hero_id, old_attr_dict, new_attr_dict)
        end
    end
end

-- 升级王朝技能
function role_dynasty:upgrade_dynasty_spell(spell_id)
    if not spell_id then return end
    if not self.dynasty_id then return end
    local spell_data = excel_data.DynastySpellData[spell_id]
    if not spell_data then return end
    return self:call_dynasty("lc_upgrade_dynasty_spell", spell_id)
end

-- 获取王朝技能属性
function role_dynasty:get_dynasty_spell_attr()
    local attr_dict = {}
    local spell_dict = self.db.dynasty.spell_dict
    local spell_data = excel_data.DynastySpellData
    for spell_id, level in pairs(spell_dict) do
        local attr_name = spell_data[spell_id].attribute
        if attr_name then
            local attr_value = CSFunction.get_dynasty_spell_attr_value(spell_id, level)
            attr_dict[attr_name] = (attr_dict[attr_name] or 0) + attr_value
        end
    end
    return attr_dict
end

-- 获取王朝技能经验加成
function role_dynasty:get_dynasty_spell_add_exp(exp)
    local spell_dict = self.db.dynasty.spell_dict
    return CSFunction.get_dynasty_spell_add_exp(spell_dict, exp)
end

-- 获取王朝挑战信息
function role_dynasty:get_dynasty_challenge_info()
    if not self.dynasty_id then return end
    local ret = self:call_dynasty("lc_get_dynasty_challenge_info")
    if not ret then return end
    local dynasty = self.db.dynasty
    ret.challenge_reward = dynasty.challenge_reward
    ret.buy_challenge_num = dynasty.buy_challenge_num
    if ret.stage_box then
        ret.box_dict = {}
        for stage_id, box_dict in pairs(ret.stage_box) do
            ret.box_dict[stage_id] = {box_dict = box_dict}
        end
    end
    return ret
end

-- 挑战守卫
function role_dynasty:dynasty_challenge_janitor(janitor_index)
    if not janitor_index then return end
    if not self.dynasty_id then return end
    local own_fight_data = self.role:get_role_fight_data()
    if not own_fight_data then return end
    local challenge_info = self:call_dynasty("lc_dynasty_challenge_janitor", janitor_index, own_fight_data)
    if not challenge_info then return end
    local challenge_data = excel_data.DynastyChallengeData[challenge_info.stage_id]
    local janitor_id = challenge_data.janitor_list[janitor_index]
    local janitor_data = excel_data.ChallengeJanitorData[janitor_id]
    local value = math.random(janitor_data.reward_range[1], janitor_data.reward_range[2])
    local challenge_reward = {[CSConst.Virtual.Dedicate] = value}
    local item_list = {{item_id = CSConst.Virtual.Dedicate, count = value}}
    local kill_reward
    if challenge_info.is_kill then
        -- 击杀奖励
        kill_reward = {[CSConst.Virtual.Dedicate] = janitor_data.player_kill_reward}
        table.insert(item_list, {item_id = CSConst.Virtual.Dedicate, count = janitor_data.player_kill_reward})
    end
    self.role.fight_reward = {item_list = item_list, reason = g_reason.challenge_janitor_reward}
    self:update_task(CSConst.DynastyTaskType.Challenge, 1)
    self.role:update_first_week_task(CSConst.FirstWeekTaskType.DynastyChallenge, 1)
    self.role:update_festival_activity_data(CSConst.FestivalActivityType.dynasty) -- 节日活动-王朝挑战次数
    return {
        fight_data = challenge_info.fight_data,
        is_win = challenge_info.is_win,
        hurt = challenge_info.hurt,
        challenge_reward = challenge_reward,
        kill_reward = kill_reward
    }
end

-- 王朝挑战设置
function role_dynasty:dynasty_challenge_setting(setting_type)
    if setting_type ~= CSConst.ChallengeSetting.Reset
        and setting_type ~= CSConst.ChallengeSetting.Back then
        return
    end
    if not self.dynasty_id then return end
    return self:call_dynasty("lc_dynasty_challenge_setting", setting_type)
end

-- 获取王朝挑战排行榜
function role_dynasty:get_dynasty_challenge_rank()
    if not self.dynasty_id then return end
    return self:call_dynasty("lc_get_dynasty_challenge_rank")
end

-- 获取王朝挑战守卫宝箱
function role_dynasty:get_challenge_janitor_box(stage_id, janitor_index, box_index)
    if not stage_id or not janitor_index or not box_index then return end
    if not self.dynasty_id then return end
    local ret = self:call_dynasty("lc_get_challenge_janitor_box", stage_id, janitor_index, box_index)
    if not ret then return end
    self.role:add_item_dict(ret.box_reward, g_reason.challenge_janitor_box)
    return ret
end

-- 获取王朝挑战通关奖励
function role_dynasty:get_challenge_stage_reward(stage_id)
    if not stage_id then return end
    if not self.dynasty_id then return end
    local dynasty = self.db.dynasty
    if dynasty.challenge_reward[stage_id] then return end
    local challenge_info = self:call_dynasty("lc_get_dynasty_challenge_info")
    if not challenge_info then return end
    if stage_id > challenge_info.max_victory_stage then return end
    dynasty.challenge_reward[stage_id] = true
    local challenge_data = excel_data.DynastyChallengeData[stage_id]
    local reward_data = excel_data.RewardData[challenge_data.reward_id]
    self.role:add_item_list(reward_data.item_list, g_reason.challenge_stage_reward)
    return true
end

-- 获取王朝挑战所有奖励（包括守卫宝箱和通关奖励）
function role_dynasty:get_challenge_all_reward()
    if not self.dynasty_id then return end
    local dynasty = self.db.dynasty
    local ret = self:call_dynasty("lc_get_challenge_all_box")
    if not ret then return end
    local dynasty = self.db.dynasty
    local reward_dict = ret.reward_dict
    for stage_id = 1, ret.max_victory_stage do
        if not dynasty.challenge_reward[stage_id] then
            dynasty.challenge_reward[stage_id] = true
            local challenge_data = excel_data.DynastyChallengeData[stage_id]
            local reward_data = excel_data.RewardData[challenge_data.reward_id]
            for item_id, count in pairs(reward_data.item_dict) do
                reward_dict[item_id] = (reward_dict[item_id] or 0) + count
            end
        end
    end
    self.role:add_item_dict(reward_dict, g_reason.challenge_all_reward)
    return {reward_dict = reward_dict}
end

-- 购买王朝挑战次数
function role_dynasty:buy_dynasty_challenge_num(buy_num)
    if not buy_num then return end
    if not self.dynasty_id then return end
    local dynasty = self.db.dynasty
    local data = excel_data.ChallengeNumData
    local buy_challenge_num = dynasty.buy_challenge_num
    if buy_challenge_num + buy_num > #data then return end
    local item_dict = {}
    for i = buy_challenge_num + 1, buy_challenge_num + buy_num do
        item_dict[data[i].cost_item] = (item_dict[data[i].cost_item] or 0) + data[i].cost_num
    end
    if not next(item_dict) then return end
    if not self.role:consume_item_dict(item_dict, g_reason.buy_challenge_num) then return end
    local challenge_num = self:call_dynasty("lc_add_challenge_num", buy_num)
    if not challenge_num then
        self.role:add_item_dict(item_dict, g_reason.buy_challenge_num)
        return
    end
    dynasty.buy_challenge_num = buy_challenge_num + buy_num
    return {
        buy_challenge_num = dynasty.buy_challenge_num,
        challenge_num = challenge_num
    }
end
-------------------------- 王朝任务 ----------------------------------
local TaskMapper = {
    [CSConst.DynastyTaskType.Challenge] = "cumulation_task",
    [CSConst.DynastyTaskType.Build] = "cumulation_task",
    [CSConst.DynastyTaskType.DailyActive] = "cumulation_task",
    [CSConst.DynastyTaskType.Compete] = "cumulation_task",
}

-- 更新王朝任务进度
function role_dynasty:update_task(task_type, progress)
    local task = self.db.dynasty.task_dict[task_type]
    if not task or not task.task_id then return end
    local func = TaskMapper[task_type]
    if func then
        self[func](self, task_type, progress)
    end
end

-- 累计任务
function role_dynasty:cumulation_task(task_type, progress)
    local task_dict = self.db.dynasty.task_dict
    local task = task_dict[task_type]
    local task_data = excel_data.DynastyTaskData[task.task_id]
    task.progress = task.progress + progress
    if task.progress >= task_data.progress then
        task.is_finish = true
    end
    self.role:send_client("s_update_dynasty_info", {
        task_dict = {[task_type] = task}
    })
end

-- 领取任务奖励
function role_dynasty:get_task_reward(task_type)
    local dynasty = self.db.dynasty
    local task = dynasty.task_dict[task_type]
    if not task or not task.is_finish then return end
    local task_data = excel_data.DynastyTaskData[task.task_id]
    task.is_finish = nil
    dynasty.daily_active = dynasty.daily_active + task_data.reward_active_num
    local task_list = excel_data.DynastyTaskData["task_dict"][task_type]
    if task_data.finish_order == #task_list then
        -- 该类别最后一个任务
        task.task_id = nil
    else
        task.task_id = task_list[task_data.finish_order + 1]
        local data = excel_data.DynastyTaskData[task.task_id]
        -- 接取新成就时自动刷一遍任务完成状态
        if task.progress >= data.progress then
            task.is_finish = true
        end
    end
    self.role:send_client("s_update_dynasty_info", {
        daily_active = dynasty.daily_active,
        task_dict = {[task_type] = task}
    })
    return true
end
----------------------------------------------------------------------

-----------------------------王朝争霸---------------------------------
-- 获取王朝争霸信息
function role_dynasty:get_dynasty_compete_info()
    print("=== get dynasty compete ===")
    if not self.dynasty_id then return end
    local ret = self:call_dynasty("lc_get_dynasty_compete_info")
    if not ret then return print("=== return ") end
    ret.buy_attack_num = self.db.dynasty.buy_attack_num
    local json = require("cjson")
    print(json.encode(ret))
    return ret
end

-- 王朝争霸报名
function role_dynasty:dynasty_compete_apply()
    if not self.dynasty_id then return end
    return self:call_dynasty("lc_dynasty_compete_apply")
end

-- 王朝争霸建筑驻守
function role_dynasty:dynasty_building_defend(uuid, building_id)
    if not uuid or not self.dynasty_id then return end
    return self:call_dynasty("lc_dynasty_building_defend", uuid, building_id)
end

-- 王朝争霸战斗
function role_dynasty:dynasty_compete_fight(dynasty_id, building_id, uuid)
    if not dynasty_id or not building_id or not uuid then return end
    if not self.dynasty_id then return end
    local own_fight_data = self.role:get_role_fight_data()
    if not own_fight_data then return end
    local ret = self:call_dynasty("lc_dynasty_compete_fight", {
        own_fight_data = own_fight_data,
        dynasty_id = dynasty_id,
        building_id = building_id,
        uuid = uuid
    })
    if not ret then return end
    self:update_task(CSConst.DynastyTaskType.Compete, 1)
    local building_data = excel_data.DynastyBuildingData[building_id]
    local reward_num = building_data["dedicate_"..ret.dynasty_level] * (ret.is_win and 1 or building_data.fail_reward_ratio)
    local item_list = {{item_id = CSConst.Virtual.Dedicate, count = reward_num}}
    self.role.fight_reward = {item_list = item_list, reason = g_reason.dynasty_compete_fight_reward}
    return ret
end

-- 购买王朝争霸攻打次数
function role_dynasty:buy_compete_attack_num(buy_num)
    if not buy_num then return end
    if not self.dynasty_id then return end
    local dynasty = self.db.dynasty
    local data = excel_data.CompeteNumData
    local buy_attack_num = dynasty.buy_attack_num
    if buy_attack_num + buy_num > #data then return end
    local item_dict = {}
    for i = buy_attack_num + 1, buy_attack_num + buy_num do
        item_dict[data[i].cost_item] = (item_dict[data[i].cost_item] or 0) + data[i].cost_num
    end
    if not next(item_dict) then return end
    if not self.role:consume_item_dict(item_dict, g_reason.buy_attack_num) then return end
    local attack_num = self:call_dynasty("lc_add_compete_attack_num", buy_num)
    if not attack_num then
        self.role:add_item_dict(item_dict, g_reason.buy_attack_num)
        return
    end
    dynasty.buy_attack_num = buy_attack_num + buy_num
    return {
        buy_attack_num = dynasty.buy_attack_num,
        attack_num = attack_num
    }
end

-- 获取王朝争霸防守战况
function role_dynasty:get_compete_defend_info()
    if not self.dynasty_id then return end
    return self:call_dynasty("lc_get_compete_defend_info")
end

-- 获取王朝争霸成员战绩
function role_dynasty:get_compete_member_mark_info()
    if not self.dynasty_id then return end
    return self:call_dynasty("lc_get_compete_member_mark_info")
end

-- 获取王朝争霸奖励领取状态
function role_dynasty:get_compete_reward_info()
    if not self.dynasty_id then return end
    return self:call_dynasty("lc_get_compete_reward_info")
end

-- 领取攻城奖励
function role_dynasty:get_compete_reward(reward_id)
    if not reward_id then return end
    if not self.dynasty_id then return end
    local ret = self:call_dynasty("lc_get_compete_reward", reward_id)
    if not ret then return end
    local reward_data = excel_data.CompeteRewardData[reward_id]
    for i, item_id in ipairs(reward_data.reward_list) do
        self.role:add_item(item_id, reward_data.reward_value_list[i], g_reason.compete_attack_building_reward)
    end
    return true
end

-- 获取王朝争霸王朝排行
function role_dynasty:get_compete_dynasty_rank()
    return cluster_utils.call_cross_dynasty("lc_get_dynasty_rank_list", "compete_mark_dynasty_rank", self.dynasty_id)
end

-- 获取王朝争霸个人排行
function role_dynasty:get_compete_role_rank()
    return cluster_utils.call_cross_rank("lc_get_rank_list", "compete_mark_role_rank", self.uuid)
end
----------------------------------------------------------------------
-- 购买王朝商店物品
function role_dynasty:buy_shop_item(shop_id, shop_num)
    if not shop_id or not shop_num then return end
    local data = excel_data.DynastyShopData[shop_id]
    if not data then return end
    local shop_dict = self.db.dynasty.shop_dict
    local new_num = shop_dict[shop_id] + shop_num
    if data.forever_num and new_num > data.forever_num then return end
    if data.daily_num and new_num > data.daily_num then return end

    local item_list = {}
    for i, item_id in ipairs(data.cost_item_list) do
        table.insert(item_list, {item_id = item_id, count = data.cost_item_value[i] * shop_num})
    end
    if not self.role:consume_item_list(item_list, g_reason.dynasty_shop) then return end
    shop_dict[shop_id] = new_num
    local item_count = data.item_count * shop_num
    self.role:add_item(data.item_id, item_count, g_reason.dynasty_shop)
    self.role:send_client("s_update_dynasty_shop_info", {shop_dict = shop_dict})
    self.role:gaea_log("ShopConsume", {
        itemId = data.item_id,
        itemCount = item_count,
        consume = item_list
    })
    return true
end

return role_dynasty
