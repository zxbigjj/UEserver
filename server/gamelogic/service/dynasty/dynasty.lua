local excel_data = require("excel_data")
local dynasty_utils = require("dynasty_utils")
local cluster_utils = require("msg_utils.cluster_utils")
local CSFunction = require("CSCommon.CSFunction")
local fight_game = require("CSCommon.Fight.Game")
local fight_const = require("CSCommon.Fight.FConst")
local date = require("sys_utils.date")

local dynasty = DECLARE_MODULE("dynasty")

function dynasty:get_dynasty_id(uuid)
    return dynasty_utils.role_dynasty_dict[uuid]
end

function dynasty:refresh_dynasty(uuid)
    if uuid then
        -- gm测试只刷自己的王朝
        local dynasty_cls = self:get_dynasty_cls(uuid)
        if not dynasty_cls then return end
        dynasty_cls:daily_refresh()
    else
        dynasty_utils.refresh_dynasty()
    end
end

-- 获取王朝类
function dynasty:get_dynasty_cls(uuid, dynasty_id)
    dynasty_id = dynasty_id or self:get_dynasty_id(uuid)
    if not dynasty_id then return end
    return dynasty_utils.get_dynasty_cls(dynasty_id)
end

function dynasty:get_dynasty_name(uuid)
    local dynasty_id = dynasty_utils.role_dynasty_dict[uuid]
    if not dynasty_id then return end
    local dynasty_cls = dynasty_utils.get_dynasty_cls(dynasty_id)
    return dynasty_cls:get_dynasty_name()
end

function dynasty:online_dynasty(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    dynasty_cls:send_client_dynasty_info(uuid)
end

-- 王朝成员上线
function dynasty:login_dynasty(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    dynasty_cls:member_login(uuid)
    local dynasty_id = dynasty_cls:get_dynasty_id()
    local dynasty_name = dynasty_cls:get_dynasty_name()
    local build_progress = dynasty_cls:get_build_progress()
    return dynasty_id, dynasty_name, build_progress
end

-- 王朝成员下线
function dynasty:logout_dynasty(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    dynasty_cls:member_logout(uuid)
end

-- 查找王朝
function dynasty:seek_dynasty(uuid, dynasty_name)
    return dynasty_utils.seek_dynasty(dynasty_name)
end

-- 创建王朝
function dynasty:create_dynasty(uuid, dynasty_info, role_info)
    if dynasty_utils.role_dynasty_dict[uuid] then return end
    if dynasty_utils.check_dynasty_name(dynasty_info.dynasty_name) then
        return nil, true
    end
    dynasty_utils.role_dynasty_dict[uuid] = dynasty_info.dynasty_id
    for dynasty_id in pairs(dynasty_info.apply_dict) do
        self:delete_role_apply(uuid, dynasty_id)
    end
    local dynasty_cls = dynasty_utils.create_dynasty(dynasty_info, role_info)
    dynasty_cls:member_login(uuid)
    return dynasty_cls:build_dynasty_base_info()
end

-- 获取王朝列表
function dynasty:get_dynasty_list(uuid, page)
    return dynasty_utils.get_dynasty_list(page)
end

-- 获取王朝排行榜
function dynasty:get_dynasty_rank(uuid)
    dynasty_utils.sort_dynasty()
    local dynasty_list = {}
    local self_rank, self_dynasty_info
    local self_dynasty_id = self:get_dynasty_id(uuid)
    for i, dynasty in ipairs(dynasty_utils.dynasty_list) do
        local dynasty_cls = dynasty_utils.get_dynasty_cls(dynasty.dynasty_id)
        if self_dynasty_id == dynasty.dynasty_id then
            self_rank = i
            self_dynasty_info = dynasty_cls:build_dynasty_base_info()
        end
        if i <= CSConst.DynastyRankLen then
            table.insert(dynasty_list, dynasty_cls:build_dynasty_base_info())
        else
            if self_rank then break end
        end
    end
    return {
        dynasty_list = dynasty_list,
        self_rank = self_rank,
        self_dynasty_info = self_dynasty_info
    }
end

-- 申请加入王朝
function dynasty:apply_dynasty(uuid, dynasty_id, role_info)
    local dynasty_cls = self:get_dynasty_cls(nil, dynasty_id)
    if not dynasty_cls then return end
    dynasty_cls:apply_dynasty(role_info)
    return true
end

-- 删除玩家申请
function dynasty:delete_role_apply(uuid, dynasty_id)
    local dynasty_cls = self:get_dynasty_cls(nil, dynasty_id)
    if not dynasty_cls then return end
    dynasty_cls:delete_role_apply(uuid)
end

-- 获取王朝基础信息
function dynasty:get_dynasty_base_info(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    return dynasty_cls:build_dynasty_base_info()
end

-- 获取王朝成员信息
function dynasty:get_dynasty_member_info(uuid, dynasty_id)
    local dynasty_cls = self:get_dynasty_cls(uuid, dynasty_id)
    if not dynasty_cls then return end
    return dynasty_cls:get_member_dict()
end

-- 获取王朝申请信息
function dynasty:get_dynasty_apply_info(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    return dynasty_cls:get_apply_dict()
end

-- 同意加入王朝
function dynasty:agree_apply_dynasty(uuid, member_uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    if dynasty_utils.role_dynasty_dict[member_uuid] then
        dynasty_cls:delete_role_apply(member_uuid)
        return false, CSConst.AgreeApplyDynastyTips.HasDynasty
    end
    if not dynasty_cls:is_manager(uuid) then
        return false, CSConst.AgreeApplyDynastyTips.NotManager
    end
    if dynasty_cls:is_member_full() then return end
    local apply_dict = dynasty_cls:get_apply_dict()
    if not apply_dict[member_uuid] then
        return false, CSConst.AgreeApplyDynastyTips.NotInApplyDict
    end
    dynasty_cls:add_dynasty_member(member_uuid)
    dynasty_cls:broad_dynasty_msg("s_update_dynasty_member_apply_dict", {
        apply_dict = dynasty_cls:get_apply_dict(),
        member_dict = dynasty_cls:get_member_dict()
    })
    return true
end

-- 拒绝加入王朝
function dynasty:refuse_apply_dynasty(uuid, member_uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    if not dynasty_cls:is_manager(uuid) then return end
    local apply_dict = dynasty_cls:get_apply_dict()
    if member_uuid then
        if not apply_dict[member_uuid] then return true end
        dynasty_cls:delete_role_apply(member_uuid, true)
    else
        for uuid in pairs(apply_dict) do
            dynasty_cls:delete_role_apply(uuid, true)
        end
    end
    return true
end

-- 加入王朝
function dynasty:join_dynasty(uuid, apply_dict, role_info)
    for dynasty_id in pairs(apply_dict) do
        self:delete_role_apply(nil, dynasty_id)
    end
    local _, dynasty_name = self:login_dynasty(uuid)
    self:update_dynasty_role_info(uuid, role_info)
    return dynasty_name
end

-- 退出王朝
function dynasty:quit_dynasty(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    dynasty_cls:delete_dynasty_member(uuid)
end

-- 是否为初始徽章
function dynasty:check_is_init_badge(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    return dynasty_cls:check_is_init_badge()
end

-- 修改王朝徽章
function dynasty:modify_dynasty_badge(uuid, dynasty_badge)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    if not dynasty_cls:is_godfather(uuid) then return end
    dynasty_cls:modify_dynasty_badge(dynasty_badge)
    return true
end

-- 修改王朝名字
function dynasty:modify_dynasty_name(uuid, dynasty_name)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    if not dynasty_cls:is_godfather(uuid) then return end
    if dynasty_utils.check_dynasty_name(dynasty_name) then
        return nil, true
    end
    dynasty_cls:modify_dynasty_name(dynasty_name)
    return true
end

-- 修改王朝公告
function dynasty:modify_dynasty_notice(uuid, dynasty_notice)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    if not dynasty_cls:is_manager(uuid) then return end
    dynasty_cls:modify_dynasty_notice(dynasty_notice)
    return true
end

-- 修改王朝宣告
function dynasty:modify_dynasty_declaration(uuid, dynasty_declaration)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    if not dynasty_cls:is_manager(uuid) then return end
    dynasty_cls:modify_dynasty_declaration(dynasty_declaration)
    return true
end

-- 踢人
function dynasty:kick_out_dynasty(uuid, member_uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    if not dynasty_cls:is_manager(uuid) then return end
    local member_info = dynasty_cls:get_member_info(member_uuid)
    if not member_info then return true end
    if dynasty_cls:get_member_info(uuid).job >= member_info.job then return end
    dynasty_cls:kick_out_dynasty(member_uuid)
    return true
end

-- 任命成员
function dynasty:appoint_dynasty_member(uuid, member_uuid, job)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    local member_info = dynasty_cls:get_member_info(member_uuid)
    if not member_info or member_info.job == job then return end
    -- 只有教父有权限任命成员
    if not dynasty_cls:is_godfather(uuid) then return end
    local job_data = excel_data.DynastyJobData
    if job == CSConst.DynastyJob.GodFather then
        -- 转让教父
        if member_info.job ~= CSConst.DynastyJob.SecondChief then return end
        dynasty_cls:modify_member_job(member_uuid, job)
        dynasty_utils.send_member_mail(member_uuid, CSConst.MailId.DynastyJob, {job = job_data[job].name})
        job = CSConst.DynastyJob.Member
        dynasty_cls:modify_member_job(uuid, job)
        dynasty_utils.send_member_mail(uuid, CSConst.MailId.DynastyJob, {job = job_data[job].name})
        return true
    else
        if job == CSConst.DynastyJob.SecondChief then
            local job_num = 0
            local member_dict = dynasty_cls:get_member_dict()
            for _, role_info in pairs(member_dict) do
                if role_info.job == CSConst.DynastyJob.SecondChief then
                    job_num = job_num + 1
                end
            end
            if job_num >= job_data[job].max_num then return end
        end
        dynasty_cls:modify_member_job(member_uuid, job)
        dynasty_utils.send_member_mail(member_uuid, CSConst.MailId.DynastyJob, {job = job_data[job].name})
        return true
    end
end

-- 解散王朝
function dynasty:dissolve_dynasty(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    -- 只剩下最后一个人才能解散
    if dynasty_cls:get_member_count() > 1 then return end
    dynasty_utils.role_dynasty_dict[uuid] = nil
    dynasty_cls:dissolve_dynasty()
    return true
end

-- 更新成员信息
function dynasty:update_dynasty_role_info(uuid, update_info)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    update_info.uuid = uuid
    return dynasty_cls:update_dynasty_role_info(uuid, update_info)
end

-- 获取王朝建设信息
function dynasty:get_dynasty_build_info(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    return dynasty_cls:get_dynasty_build_info()
end

-- 王朝建设
function dynasty:dynasty_build(uuid, build_type)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    dynasty_cls:dynasty_build(build_type)
    return true
end

function dynasty:update_role_build_progress_reward(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    dynasty_utils.send_agent(uuid, "ls_update_dynasty_build_progress", dynasty_cls:get_build_progress())
end

-- 获取王朝技能信息
function dynasty:get_dynasty_spell_info(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    return dynasty_cls:get_dynasty_spell_info()
end

-- 升级王朝技能
function dynasty:upgrade_dynasty_spell(uuid, spell_id)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    if not dynasty_cls:is_manager(uuid) then return end
    local spell_dict = dynasty_cls:get_dynasty_spell_info()
    local dynasty_level = dynasty_cls:get_dynasty_level()
    local spell_data = excel_data.DynastySpellData[spell_id]
    if not spell_dict[spell_id] and dynasty_level < spell_data.dynasty_level then return end
    local index
    for i, level in ipairs(spell_data.dynasty_level_list) do
        index = i
        if level >= dynasty_level then break end
    end
    local new_level = (spell_dict[spell_id] or 0) + 1
    if new_level > spell_data.spell_level_list[index] then return end
    local dynasty_data = excel_data.DynastyData[dynasty_level]
    local can_use_exp = dynasty_cls:get_dynasty_exp() - dynasty_data.exp
    local spell_grow_data = CSFunction.get_dynasty_spell_cost(spell_id, new_level)
    if can_use_exp < spell_grow_data.dynasty_cost then return end
    dynasty_cls:upgrade_dynasty_spell(spell_id, spell_grow_data.dynasty_cost)
    return true
end

-- 获取王朝挑战信息
function dynasty:get_dynasty_challenge_info(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    local challenge = dynasty_cls:get_dynasty_challenge_info()
    local member_info = dynasty_cls:get_member_info(uuid)
    return {
        curr_stage = challenge.curr_stage,
        max_victory_stage = challenge.max_victory_stage,
        stage_dict = challenge.stage_dict or {},
        setting = challenge.setting,
        challenge_num = member_info.challenge_num or 0,
        challenge_num_ts = dynasty_utils.challenge_num_ts,
        stage_box = member_info.stage_box,
    }
end

-- 挑战守卫
function dynasty:dynasty_challenge_janitor(uuid, janitor_index, own_fight_data)
    if dynasty_utils.challenge_flag ~= CSConst.DynastyChallenge.Open then return end
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    local challenge = dynasty_cls:get_dynasty_challenge_info()
    local member_info = dynasty_cls:get_member_info(uuid)
    if member_info.challenge_num <= 0 then return end
    local challenge_data = excel_data.DynastyChallengeData[challenge.curr_stage]
    local janitor_id = challenge_data.janitor_list[janitor_index]
    if not janitor_id then return end
    local janitor_info = challenge.stage_dict[challenge.curr_stage].janitor_dict[janitor_id]
    local janitor_hp = 0
    for _, hp in pairs(janitor_info.hp_dict) do
        janitor_hp = janitor_hp + hp
    end
    if janitor_hp <= 0 then return {} end

    local stage_id = challenge.curr_stage
    member_info.challenge_num = member_info.challenge_num - 1
    member_info.challenge_total_num = member_info.challenge_total_num + 1
    local janitor_data = excel_data.ChallengeJanitorData[janitor_id]
    local enemy_fight_data = CSFunction.get_fight_data_by_group_id(janitor_data.monster_group_id, janitor_data.monster_level)
    for i, data in ipairs(enemy_fight_data) do
        if data.fight_attr_dict then
            data.fight_attr_dict["hp"] = janitor_info.hp_dict[i]
        end
    end
    local fight_data = {
        seed = math.random(1, g_const.Fight_Random_Num),
        own_fight_data = own_fight_data,
        enemy_fight_data = enemy_fight_data,
    }
    local game = fight_game.New(fight_data)
    local is_win = game:GoToFight()
    local result = game:GetFightResultInfo(fight_const.Side.Enemy)
    janitor_info.hp_dict = result.hp_dict
    local new_janitor_hp = 0
    for _, hp in pairs(janitor_info.hp_dict) do
        new_janitor_hp = new_janitor_hp + hp
    end
    local hurt = janitor_hp - new_janitor_hp
    if not member_info.max_challenge_hurt or hurt > member_info.max_challenge_hurt then
        member_info.max_challenge_hurt = hurt
        dynasty_cls:add_challenge_hurt_rank(uuid, hurt)
    end
    local is_kill
    if new_janitor_hp <= 0 then
        is_kill = true
        dynasty_cls:add_dynasty_exp(janitor_data.dynasty_kill_reward)
        dynasty_cls:on_janitor_death()
    end
    dynasty_cls:save_dynasty()
    return {
        stage_id = stage_id,
        fight_data = fight_data,
        is_win = is_win,
        is_kill = is_kill,
        hurt = hurt
    }
end

-- 王朝挑战设置
function dynasty:dynasty_challenge_setting(uuid, setting_type)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    if not dynasty_cls:is_manager(uuid) then return end
    dynasty_cls:dynasty_challenge_setting(setting_type)
    return true
end

-- 获取王朝挑战排行
function dynasty:get_dynasty_challenge_rank(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    local challenge = dynasty_cls:get_dynasty_challenge_info()
    local member_dict = dynasty_cls:get_member_dict()
    local rank_list = {}
    if challenge.hurt_rank then
        for _, v in ipairs(challenge.hurt_rank) do
            local member_info = member_dict[v.uuid]
            table.insert(rank_list, {
                name = member_info.name,
                role_id = member_info.role_id,
                challenge_num = member_info.challenge_total_num,
                max_hurt = v.max_hurt,
                rank = v.rank
            })
        end
    end
    local self_rank = {}
    local rank_info = dynasty_cls.challenge_role_dict[uuid]
    if rank_info then
        local member_info = member_dict[uuid]
        self_rank = {
            challenge_num = member_info.challenge_total_num,
            max_hurt = rank_info.max_hurt,
            rank = rank_info.rank
        }
    end
    return {rank_list = rank_list, self_rank = self_rank}
end

-- 领取王朝挑战守卫箱子
function dynasty:get_challenge_janitor_box(uuid, stage_id, janitor_index, box_index)
    if dynasty_utils.challenge_flag == CSConst.DynastyChallenge.Unopen then return end
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    local challenge = dynasty_cls:get_dynasty_challenge_info()
    local stage_info = challenge.stage_dict[stage_id]
    if not stage_info then return end
    local challenge_data = excel_data.DynastyChallengeData[stage_id]
    local janitor_id = challenge_data.janitor_list[janitor_index]
    if not janitor_id then return end
    local janitor_info = stage_info.janitor_dict[janitor_id]
    local janitor_hp = 0
    for _, hp in pairs(janitor_info.hp_dict) do
        janitor_hp = janitor_hp + hp
    end
    -- 守卫被击杀才能领取
    if janitor_hp > 0 then return end
    local box = janitor_info.reward_list[box_index]
    if not box or box.role_name then
        -- 宝箱已被领取
        return {}
    end
    local member_info = dynasty_cls:get_member_info(uuid)
    -- 判断自己是否已经领取过宝箱
    if member_info.stage_box[stage_id][janitor_id] then return end
    member_info.stage_box[stage_id][janitor_id] = true
    box.role_name = member_info.name
    dynasty_cls:save_dynasty()
    local janitor_data = excel_data.ChallengeJanitorData[janitor_id]
    return {box_reward = {[janitor_data.box_reward] = box.value}}
end

-- 领取王朝挑战所有守卫箱子
function dynasty:get_challenge_all_box(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    local member_info = dynasty_cls:get_member_info(uuid)
    local challenge = dynasty_cls:get_dynasty_challenge_info()
    local stage_dict = challenge.stage_dict
    local reward_dict = {}
    if stage_dict then
        for stage_id, stage_info in pairs(stage_dict) do
            if member_info.stage_box[stage_id] then
                for janitor_id, janitor_info in pairs(stage_info.janitor_dict) do
                    local janitor_hp = 0
                    for _, hp in pairs(janitor_info.hp_dict) do
                        janitor_hp = janitor_hp + hp
                    end
                    if janitor_hp <= 0 and not member_info.stage_box[stage_id][janitor_id] then
                        -- 自动领取第一个没有被领取的宝箱
                        for _, v in ipairs(janitor_info.reward_list) do
                            if not v.role_name then
                                member_info.stage_box[stage_id][janitor_id] = true
                                v.role_name = member_info.name
                                local janitor_data = excel_data.ChallengeJanitorData[janitor_id]
                                reward_dict[janitor_data.box_reward] = (reward_dict[janitor_data.box_reward] or 0) + v.value
                                break
                            end
                        end
                    end
                end
            end
        end
        dynasty_cls:save_dynasty()
    end
    return {reward_dict = reward_dict, max_victory_stage = challenge.max_victory_stage}
end

-- 增加王朝挑战次数
function dynasty:add_challenge_num(uuid, buy_num)
    if dynasty_utils.challenge_flag ~= CSConst.DynastyChallenge.Open then return end
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    local member_info = dynasty_cls:get_member_info(uuid)
    member_info.challenge_num = member_info.challenge_num + buy_num
    dynasty_cls:save_dynasty()
    return member_info.challenge_num
end

-- 王朝争霸报名
function dynasty:dynasty_compete_apply(uuid)
    print("=== 报名")
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then print("= is no cls") return end
    if not dynasty_cls:is_manager(uuid) then print("= is no mgr") return end
    local compete_info = dynasty_cls:get_dynasty_compete_info()
    if compete_info.is_apply then print("= is no apply") return end
    local param_data = excel_data.ParamData
    local apply_day = param_data["dynasty_compete_apply_day"].str_value
    local now = date.time_second()
    if date.get_week_day(now) ~= apply_day then print("= is not time") return end
    local start_time = param_data["dynasty_compete_start_time"].f_value
    start_time = date.get_day_time(now, start_time)
    print(now, start_time)
    if now < start_time then print("= is no time") return end
    local member_count = param_data["dynasty_compete_apply_member_count"].f_value
    if dynasty_cls:get_member_count() < member_count then print("= is no mumber") return end
    local level_limit = param_data["dynasty_compete_apply_level_limit"].f_value
    if dynasty_cls:get_dynasty_level() < level_limit then print("= is no level") return end
    dynasty_cls:dynasty_compete_apply()
    return true
end

-- 王朝争霸建筑驻守
function dynasty:dynasty_building_defend(uuid, member_uuid, building_id)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    if not dynasty_cls:is_manager(uuid) then return end
    local member_info = dynasty_cls:get_member_info(member_uuid)
    if not member_info or member_info.building_id == building_id then return end
    local compete_info = dynasty_cls:get_dynasty_compete_info()
    if not compete_info.is_apply then return end
    if building_id then
        local building_data = excel_data.DynastyBuildingData[building_id]
        if not building_data then return end
        local defend_member_count = #compete_info.building_dict[building_id].member_dict
        if defend_member_count >= building_data.defend_member_count then return end
    end
    dynasty_cls:dynasty_building_defend(member_uuid, building_id)
    return true
end

-- 设置王朝争霸敌对王朝
function dynasty:set_dynasty_compete_enemy(dynasty_id, enemy_dict)
    local dynasty_cls = self:get_dynasty_cls(nil, dynasty_id)
    if not dynasty_cls then return end
    dynasty_cls:set_dynasty_compete_enemy(enemy_dict)
end

-- 获取王朝争霸信息
function dynasty:get_dynasty_compete_info(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    local member_info = dynasty_cls:get_member_info(uuid)
    if not member_info then return end
    local compete_info = dynasty_cls:get_dynasty_compete_info()
    return {
        is_apply = compete_info.is_apply,
        dynasty_total_mark = compete_info.total_mark,
        self_total_mark = member_info.total_mark or 0,
        self_daily_mark = member_info.daily_mark or 0,
        total_attack_num = compete_info.total_attack_num,
        compete_index = compete_info.compete_index,
        attack_mark = compete_info.attack_mark,
        defend_mark = compete_info.defend_mark,
        defend_info = compete_info.defend_info or {},
        building_dict = compete_info.building_dict or {},
        attack_num = member_info.attack_num or 0,
        enemy_dict = dynasty_cls:get_dynasty_compete_enemy_info(),
    }
end

-- 王朝争霸战斗
function dynasty:dynasty_compete_fight(uuid, fight_info)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    local member_info = dynasty_cls:get_member_info(uuid)
    if not member_info then return end
    if date.time_second() - member_info.join_ts < CSConst.Time.Day then return end
    if member_info.attack_num <= 0 then return end
    local enemy_dict = dynasty_cls:get_dynasty_compete_enemy_info()
    local enemy_dynasty = enemy_dict[fight_info.dynasty_id]
    if not enemy_dynasty then return end
    local building_info = enemy_dynasty.building_dict[fight_info.building_id]
    if not building_info then return end
    if dynasty_utils.is_building_destroy(building_info) then
        return false, CSConst.DynastyCompeteFightTips.BuildingHasDestroy
    end
    if fight_info.building_id == #excel_data.DynastyBuildingData then
        if not dynasty_utils.can_attack_headquarters(enemy_dynasty.building_dict) then return end
    end
    local fight_role = building_info.role_dict[fight_info.uuid]
    if not fight_role then return end
    if fight_role.defend_num <= 0 then
        return false, CSConst.DynastyCompeteFightTips.FightRoleHasKilled
    end

    member_info.attack_num = member_info.attack_num - 1
    local compete_info = dynasty_cls:get_dynasty_compete_info()
    compete_info.total_attack_num = compete_info.total_attack_num + 1
    local fight_data = {
        seed = math.random(1, g_const.Fight_Random_Num),
        own_fight_data = fight_info.own_fight_data,
        enemy_fight_data = fight_role.fight_data
    }
    local game = fight_game.New(fight_data)
    local is_win = game:GoToFight()
    local building_data = excel_data.DynastyBuildingData[fight_info.building_id]
    local old_hp = building_info.building_hp
    if is_win then
        building_info.building_hp = building_info.building_hp - building_data.win_hp
        fight_role.defend_num = fight_role.defend_num - 1
    else
        building_info.building_hp = building_info.building_hp - building_data.fail_hp
    end
    building_info.building_hp = building_info.building_hp < 0 and 0 or building_info.building_hp
    local save_data = compete_info.enemy_dict[fight_info.dynasty_id].building_dict[fight_info.building_id]
    save_data.building_hp = building_info.building_hp
    save_data.role_dict[fight_info.uuid] = fight_role.defend_num
    local mark = old_hp - building_info.building_hp
    compete_info.attack_mark = compete_info.attack_mark + mark
    compete_info.total_mark = compete_info.total_mark + mark
    dynasty_cls:add_compete_dynasty_rank(compete_info.total_mark)
    member_info.daily_mark = member_info.daily_mark + mark
    member_info.total_mark = member_info.total_mark + mark
    dynasty_utils.send_agent(uuid, "ls_update_dynasty_role_cross_rank", "compete_mark_role_rank", member_info.total_mark)
    dynasty_cls:save_dynasty()

    local is_destroy_building
    if dynasty_utils.is_building_destroy(building_info) then
        -- 击破建筑
        is_destroy_building = true
        dynasty_cls:add_dynasty_exp(building_data.dynasty_exp_reward)
        dynasty_cls:set_compete_reward()
    end
    return {
        fight_data = fight_data,
        is_win = is_win,
        is_destroy_building = is_destroy_building,
        dynasty_level = dynasty_cls:get_dynasty_level()
    }
end

-- 增加王朝争霸攻打次数
function dynasty:add_compete_attack_num(uuid, add_num)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    local compete_info = dynasty_cls:get_dynasty_compete_info()
    if not compete_info.is_open then return end
    local member_info = dynasty_cls:get_member_info(uuid)
    member_info.attack_num = member_info.attack_num + add_num
    dynasty_cls:save_dynasty()
    return member_info.attack_num
end

-- 获取防守战况
function dynasty:get_compete_defend_info(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    local compete_info = dynasty_cls:get_dynasty_compete_info()
    if not compete_info.is_open then return end
    return {defend_dict = dynasty_cls:get_compete_defend_info()}
end

-- 获取防守信息
function dynasty:get_dynasty_defend_info(self_dynasty_id, dynasty_id)
    local dynasty_cls = self:get_dynasty_cls(nil, dynasty_id)
    local compete_info = dynasty_cls:get_dynasty_compete_info()
    local dynasty_info = compete_info.enemy_dict[self_dynasty_id]
    local building_dict = {}
    for building_id, info in pairs(dynasty_info.building_dict) do
        local defend_num = 0
        local role_num = 0
        for _, num in pairs(info.role_dict) do
            defend_num = defend_num + num
            role_num = role_num + 1
        end
        building_dict[building_id] = {defend_num = defend_num, role_num = role_num}
    end
    return building_dict
end

-- 获取王朝争霸成员战绩
function dynasty:get_compete_member_mark_info(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    local compete_info = dynasty_cls:get_dynasty_compete_info()
    if not compete_info.is_open then return end
    local member_dict = dynasty_cls:get_member_dict()
    return {member_dict = member_dict}
end

-- 获取王朝争霸奖励领取状态
function dynasty:get_compete_reward_info(uuid)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    local compete_info = dynasty_cls:get_dynasty_compete_info()
    if not compete_info.is_open then
        local compete_reward = {}
        for id in pairs(excel_data.CompeteRewardData) do
            compete_reward[id] = false
        end
        return {compete_reward = compete_reward}
    end
    local member_info = dynasty_cls:get_member_info(uuid)
    return {compete_reward = member_info.compete_reward}
end

-- 领取攻城奖励
function dynasty:get_compete_reward(uuid, reward_id)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    local member_info = dynasty_cls:get_member_info(uuid)
    if member_info.compete_reward[reward_id] then
        member_info.compete_reward[reward_id] = nil
        dynasty_cls:save_dynasty()
        return true
    end
end

-- 发放王朝排行奖励
function dynasty:give_dynasty_rank_reward(dynasty_id, mail_id, mail_args, item_list)
    local dynasty_cls = self:get_dynasty_cls(nil, dynasty_id)
    if not dynasty_cls then return end
    local member_dict = dynasty_cls:get_member_dict()
    for uuid in pairs(member_dict) do
        if cluster_utils.is_player_uuid_valid(uuid) then
            -- 过滤测试机器人
            dynasty_utils.send_agent(uuid, "ls_give_rank_reward", mail_id, mail_args, item_list)
        end
    end
end

function dynasty:update_traitor_honour(uuid, honour)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    dynasty_cls:update_traitor_honour(honour)
end

function dynasty:clear_traitor_honour()
    for _, dynasty_cls in pairs(dynasty_utils.dynasty_dict) do
        dynasty_cls:clear_traitor_honour()
    end
    require("dynasty_rank").clear_rank_data("traitor_boss_honour_dynasty_rank")
end
----------------------------- 王朝争霸 gm测试代码 -----------------------------------
-- 增加王朝经验
function dynasty:add_dynasty_exp(uuid, exp)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    dynasty_cls:add_dynasty_exp(exp)
end

function dynasty:add_dynasty_exp_by_id(dynasty_id, exp)   -- 太dn了, 回头改一下
    print("dynasty_id, exp")
    print(dynasty_id, exp)
    local dynasty_cls = self:get_dynasty_cls(nil, dynasty_id)
    if not dynasty_cls then print("======== no dynasty cls") return end
    dynasty_cls:add_dynasty_exp(exp)
end

function dynasty:add_member(uuid, count)
    local dynasty_cls = self:get_dynasty_cls(uuid)
    if not dynasty_cls then return end
    local member_dict = dynasty_cls:get_member_dict()
    for i = 1, count do
        local role_info = {
            uuid = tostring(i),
            name = string.rand_string(5),
            level = math.random(1, 10),
            fight_score = math.random(1000, 10000),
            role_id = 1,
            vip = 0,
            job = CSConst.DynastyJob.Member,
            join_ts = date.time_second(),
            offline_ts = date.time_second(),
            history_dedicate = 0,
            challenge_num = 0
        }
        if not member_dict[role_info.uuid] then
            member_dict[role_info.uuid] = role_info
            dynasty_cls.dynasty.member_count = dynasty_cls.dynasty.member_count + 1
            dynasty_cls.dynasty.dynasty_score = dynasty_cls.dynasty.dynasty_score + role_info.fight_score
        end
    end
end
-------------------------------------------------------------------------------------

return dynasty