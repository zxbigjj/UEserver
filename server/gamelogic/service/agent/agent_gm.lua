local excel_data = require("excel_data")
local date = require("sys_utils.date")

local agent_gm = DECLARE_MODULE("agent_gm")

local role_gm = {}

function role_gm.test(role, args)
    PRINT("-----gm test-------", args)
    return true
end

-- -- 让自己成为教父[教父殿堂]
-- function role_gm.become_godfather(role, args)
--     local title_id = tonumber(args)
--     local self_uuid = role:get_uuid()
--     local now_ts = date.time_second()
--     local db_table = require("schema_game").RushActivityTitle
--     local db_record = db_table:load(title_id)
--     if not db_record then
--         db_record = {
--             title_id = title_id,
--             current_uuid = self_uuid,
--             history_list = { { uuid = self_uuid, ts = now_ts } },
--         }
--         db_table:insert(title_id, db_record)
--     else
--         db_record.current_uuid = self_uuid
--         table.insert(db_record.history_list, { uuid = self_uuid, ts = now_ts })
--         if #db_record.history_list > CSConst.TitleMaxHistorySize then
--             table.remove(db_record.history_list, 1)
--         end
--         db_table:set_field({title_id = title_id}, db_record)
--     end
--     return true
-- end

-- -- 天天充值, arg: "2018-12-12"
-- function role_gm.daily_recharge(role, args)
--     local pattern = "(%d%d%d%d)-(%d%d)-(%d%d)"
--     local results = {args:match(pattern)}
--     if #results == 0 then return end
--     local year, month, day = table.unpack(results)
--     local today0 = os.time({year = year, month = month, day = day, hour = 0, min = 0, sec = 0})
--     role.daily_recharge:daily(today0)
--     return true
-- end

-- -- 豪华签到
-- function role_gm.luxury_check_in(role, args)
--     local utils = require("luxury_check_in_utils")
--     local all_obj = utils.all_obj_dict
--     local cur_obj = utils.cur_obj_dict
--     local cpy_dict = table.deep_copy(cur_obj)
--     for id, obj in pairs(cpy_dict) do
--         cur_obj[id] = nil
--         cur_obj[obj.next_id] = all_obj[obj.next_id]
--         local reset_cycle = excel_data.SingleRechargeData[id].reset_cycle
--         if reset_cycle == CSConst.LuxuryCheckInResetCycle.Daily then
--             cur_obj[obj.next_id].init_ts = obj.init_ts + CSConst.Time.Day
--         elseif reset_cycle == CSConst.LuxuryCheckInResetCycle.Weekly then
--             cur_obj[obj.next_id].init_ts = obj.init_ts + CSConst.Time.Day * CSConst.DaysInWeek
--         end
--     end
--     role.luxury_check_in:daily()
--     return true
-- end

-- -- 增加开服基金购买人数
-- function role_gm.add_fund_count(role, args)
--     local add_count = tonumber(args)
--     if not add_count then return end
--     require("fund_utils").add_count(nil, add_count)
--     return true
-- end

-- -- 更改定点体力活动状态
-- function role_gm.forward_action_point(role, args)
--     local id = tonumber(args)
--     if not id then return end
--     local utils = require("action_point_utils")
--     local obj = utils.action_point_dict[id]
--     if not obj then return end
--     local state = obj.state
--     local STATE = CSConst.ActivityState
--     if state == STATE.started then
--         obj:from_started_to_nostart()
--     elseif state == STATE.nostart then
--         obj:from_nostart_to_started()
--     end
--     return true
-- end

-- -- 更改限时活动状态
-- function role_gm.forward_activity(role, args)
--     local activity_id = tonumber(args) 
--     if not activity_id then return end
--     local activity_utils = require("activity_utils")
--     local activity_obj = activity_utils.activity_dict[activity_id]
--     if not activity_obj then return end
--     local activity_state = activity_obj.state
--     local STATE = CSConst.ActivityState
--     if activity_state == STATE.nostart or activity_state == STATE.invalid then
--         activity_obj:from_nostart_to_started()
--     elseif activity_state == STATE.started then
--         activity_obj:from_started_to_stopped()
--     elseif activity_state == STATE.stopped then
--         activity_obj:from_stopped_to_invalid()
--     end
--     return true
-- end

-- -- 更改冲榜活动状态
-- function role_gm.forward_rush_activity(role, args)
--     local activity_id = tonumber(args) 
--     if not activity_id then return end
--     local activity_utils = require("rush_activity_utils")
--     local activity_obj = activity_utils.activity_dict[activity_id]
--     if not activity_obj then return end
--     local activity_state = activity_obj.state
--     local STATE = CSConst.ActivityState
--     if activity_state == STATE.nostart then
--         activity_obj:from_nostart_to_started()
--     elseif activity_state == STATE.started then
--         activity_obj:from_started_to_stopped()
--     elseif activity_state == STATE.stopped then
--         activity_obj:from_stopped_to_nostart(true)
--     end
--     return true
-- end

-- -- 更改节日活动状态
-- function role_gm.forward_festival_activity(role, args)
--     local activity_id = tonumber(args) 
--     if not activity_id then return end
--     local activity_utils = require("festival_activity_utils")
--     local activity_obj = activity_utils.activity_dict[activity_id]
--     if not activity_obj then return end
--     local activity_state = activity_obj.state
--     local STATE = CSConst.ActivityState
--     if activity_state == STATE.nostart or activity_state == STATE.invalid then
--         activity_obj:from_nostart_to_started()
--     elseif activity_state == STATE.started then
--         activity_obj:from_started_to_stopped()
--     elseif activity_state == STATE.stopped then
--         activity_obj:from_stopped_to_reserve()
--     elseif activity_state == STATE.reserve then
--         activity_obj:from_reserve_to_invalid()
--     end
--     return true
-- end

function role_gm.add_traitor(role, args)
    local traitor_info = role.traitor:add_traitor()
    role:send_client("s_update_traitor_info", {traitor_info = traitor_info})
    return true
end

function role_gm.recharge(role, args)
    role.recharge:recharge(tonumber(args))
    return true
end

function role_gm.add_member(role, args)
    local count = tonumber(args)
    role.dynasty:send_dynasty("ls_add_member", count)
    return true
end

function role_gm.arena_rank(role, args)
    local arena = role.db.arena
    if not arena.history_rank then return end
    local rank = tonumber(args)
    local arena_utils = require("arena_utils")
    local fight_data = arena_utils.get_arena_rank_data(rank)
    arena_utils.swap_arena_rank(role.uuid, fight_data.uuid)
    if arena.history_rank > rank then
        arena.history_rank = rank
        role:send_client("s_update_arena_info", {arena_history_rank = rank})
    end
    return true
end

function role_gm.vitality(role, args)
    local num = tonumber(args)
    role.db.vitality = num
    role:send_client("s_update_vitality", {vitality = role.db.vitality, vitality_ts = role.db.vitality_ts , taoxin_vitality = role.db.taoxin_vitality})
    return true
end

function role_gm.action_point(role, args)
    local num = tonumber(args)
    local stage = role.db.stage
    stage.action_point = num
    role:send_client("s_update_action_point", {action_point = stage.action_point, action_point_ts = stage.fight_stage_ts})
    return true
end

function role_gm.daily_refresh(role, args)
    role.base:check_daily_zero_refresh(true)
    return true
end

function role_gm.daily_dynasty(role, args)
    require("msg_utils.cluster_utils").send_dynasty("ls_refresh_dynasty", role.uuid)
    return true
end

function role_gm.add_child(role, args)
    local child_num = 0
    for child_id, child in pairs(role.db.child) do
        if child.child_status ~= CSConst.ChildStatus.Adult and child.child_status ~= CSConst.ChildStatus.Married then
            child_num = child_num + 1
        end
    end
    if child_num >= role.db.child_grid_num then return end
    for mother_id in pairs(role.db.lover_dict) do
        role.child:add_child(mother_id)
        local item_id = excel_data.ParamData["child_baby_vitality_restore"].item_id
        role:add_item(item_id, 10, "gm")
        item_id = excel_data.ParamData["child_vitality_restore"].item_id
        role:add_item(item_id, 100, "gm")
        return true
    end
end

function role_gm.add_adult(role, args)
    local sex, grade = args:match("(%d+)%s+(%-?%d*)")
    sex = sex and tonumber(sex) or math.random(CSConst.Sex.Man, CSConst.Sex.Woman)
    grade = grade and tonumber(grade) or math.random(1, 6)
    for mother_id in pairs(role.db.lover_dict) do
        local data = excel_data.ChildExpData[#excel_data.ChildExpData]
        local attr_dict = {
            business = math.random(100, 300),
            management = math.random(100, 300),
            renown = math.random(100, 300),
            fight = math.random(100, 300)
        }
        local child_dict = role.db.child
        local child_id = #child_dict + 1
        child_dict[child_id] = {
            birth_time = date.time_second(),
            child_id = child_id,
            mother_id = mother_id,
            level = data.level,
            exp = data.total_exp,
            sex = sex,
            grade = grade,
            child_status = CSConst.ChildStatus.Adult,
            name = string.rand_string(5),
            vitality_num = 0,
            aptitude_dict = attr_dict,
            attr_dict = table.copy(attr_dict),
            display_id = role.child:get_display_id(mother_id)
        }
        role:send_client("s_update_child_info",{child = {[child_id] = child_dict[child_id]}})
        return true
    end
end

function role_gm.dare_tower(role, args)
    local tower_id = tonumber(args)
    local dare_tower = role.db.dare_tower
    dare_tower.dare_dict = {}
    dare_tower.treasure_dict = {}
    for i = 1, tower_id do
        local tower_config = excel_data.DareTowerData[i]
        if not tower_config then break end
        dare_tower.dare_dict[i] = true
        if tower_config.treasure_chest_reward then
            dare_tower.treasure_dict[i]  = true
        end
        dare_tower.max_tower = i + 1
    end
    role:send_client("s_update_dare_tower_info",{
        dare_dict = dare_tower.dare_dict,
        pass_num = dare_tower.pass_num,
        max_tower = dare_tower.max_tower,
        treasure_dict = dare_tower.treasure_dict,
    })
    return true
end

function role_gm.finish_task(role, args)
    local task = role.db.task
    local task_data = excel_data.TaskData[task.task_id]
    task.progress = task_data.total_progress
    task.is_finish = true
    role:send_client("s_update_task_info", task)
    return true
end

function role_gm.to_task(role, args)
    local task_id = tonumber(args)
    local task_data = excel_data.TaskData[task_id]
    if not task_data then return end
    local task = role.db.task
    task.task_id = task_id
    task.is_finish = false
    task.group_id = excel_data.TaskGroupData.task_to_group[task_id]
    role.task:update_task(task_data.task_type)
    role:send_client("s_update_task_info", task)
    return true
end

function role_gm.create_dynasty(role, args)
    local count = tonumber(args)
    for i=1, count do
        local role_info = role.dynasty:build_role_info()
        role_info.score = math.random(100, 1000)
        local dynasty_info = {
            dynasty_id = role.dynasty:build_dynasty_id(),
            dynasty_name = string.rand_string(5),
            apply_dict = {}
        }
        role.dynasty:call_dynasty("lc_create_dynasty", dynasty_info, role_info)
        skynet.sleep(20)
    end
    return true
end

function role_gm.add_dynasty_exp(role, args)
    local exp = tonumber(args)
    exp = math.floor(exp)
    if exp <= 0 then return end
    role.dynasty:send_dynasty("ls_add_dynasty_exp", exp)
    return true
end

function role_gm.add_lover_exp(role, args)
    local id, count = args:match("(%d+)%s+(%-?%d*)")
    count = tonumber(count)
    count = count or 100
    id = tonumber(id)
    role.lover:add_lover_exp(id, count)
    return true
end

function role_gm.add_lover_attr(role, args)
    local id, count = args:match("(%d+)%s+(%-?%d*)")
    count = tonumber(count)
    count = count or 100
    id = tonumber(id)
    local lover = role.db.lover_dict[id]
    if not lover then return end
    for k in pairs(lover.attr_dict) do
        lover.attr_dict[k] = lover.attr_dict[k] + count
    end
    role:send_client("s_update_lover_info", {
        lover_id = lover.lover_id,
        attr_dict = lover.attr_dict
    })
    return true
end

function role_gm.set_level(role, args)
    local level = tonumber(args)
    if level <= 0 then
        return false, "level must > 0"
    end
    role.base:set_level(level, "gm")
    return true
end

function role_gm.add_exp(role, args)
    local exp = tonumber(args)
    if exp <= 0 then
        return false, "exp must > 0"
    end
    role.base:add_exp(exp, "gm")
    return true
end

function role_gm.currency(role, args)
    for id, data in pairs(excel_data.ItemData) do
        if data.sub_type == CSConst.ItemSubType.Currency then
            role:add_item(id, 10000000, "gm")
        end
    end
    return true
end

function role_gm.add_hero(role, args)
    local hero_id = tonumber(args)
    role.hero:add_hero(hero_id)
    return true
end

function role_gm.add_all_hero(role, args)
    for _, data in pairs(excel_data.PlayerHeroData) do
        role.hero:add_hero(data.hero_id)
    end
    return true
end

function role_gm.add_hero_attr(role, args)
    local lineup_info = role:get_lineup_info()
    for _, v in pairs(lineup_info) do
        if v.hero_id then
            local hero_info = role:get_hero(v.hero_id)
            local attr_dict = {
                max_hp = 100000000,
                att = 100000,
                hit = 1000,
            }
            role.hero:modify_hero_attr(v.hero_id, nil, attr_dict, true)
        end
    end
    role:send_score_msg()
    return true
end

function role_gm.set_hero_level(role, args)
    local hero_id, level = args:match("(%d+)%s*(%d*)")
    level = tonumber(level)
    hero_id = tonumber(hero_id)
    local hero_info = role:get_hero(hero_id)
    if not hero_info then return end
    local old_level = hero_info.level
    hero_info.level = level
    role.hero:on_hero_level_up(hero_info, old_level, level)
    role:send_client("s_update_hero_info", {
        hero_id = hero_id,
        level = hero_info.level
    })
    return true
end

function role_gm.add_lover(role, args)
    local lover_id = tonumber(args)
    role.lover:add_lover(lover_id)
    return true
end

function role_gm.add_all_lover(role, args)
    for lover_id, data in pairs(excel_data.LoverData) do
        if data.sex == 2 then
            role.lover:add_lover(lover_id)
        end
    end
    return true
end

function role_gm.add_item(role, args)
    local item_id, count = args:match("(%d+)%s*(%-?%d*)")
    count = tonumber(count)
    item_id = tonumber(item_id)
    local item_config = excel_data.ItemData[item_id]
    if not item_config then return end
    if item_config.item_type == CSConst.ItemType.Equip then
        count = count > 100 and 100 or count
    end
    if count < 0 then
        local item_count = role:get_item_count(item_id)
        if item_count <= 0 then return end
        if -count > item_count then
            count = -item_count
        end
        role:consume_item(item_id, -count, "gm", nil, true)
    else
        if item_config.sub_type ~= CSConst.ItemSubType.Currency then
            count = count > 1000000 and 1000000 or count
        end
        role:add_item(item_id, count, "gm")
    end
end

function role_gm.stage(role, args)
    local stage_id = tonumber(args)
    if stage_id <= 0 then
        return false, "stage_id must > 0"
    end

    local stage = role.db.stage
    for i = stage.curr_stage, stage_id do
        local stage_data = excel_data.StageData[i]
        if not stage_data then break end
        stage.action_point = stage.action_point + 10
        if stage_data.is_boss then
            role_gm.add_hero_attr(role)
            role.stage:boss_stage_fight(i)
        else
            role.db.attr_dict["fight"] = role.db.attr_dict["fight"] + 10000
            role.db.currency[CSConst.Virtual.Soldier] = role.db.currency[CSConst.Virtual.Soldier] + 10000000
            for j=1, #stage_data.enemy_num do
                role.stage:stage_fight()
            end
        end
    end
    return true
end

function role_gm.to_stage(role, args)
    local stage_id = tonumber(args)
    if stage_id <= 0 then return end
    local stage = role.db.stage
    if stage_id < stage.curr_stage then return end
    for i = stage.curr_stage, stage_id do
        stage.stage_dict[i] = {
            state = CSConst.Stage.State.Pass,
            star_num = CSConst.Stage.MaxStar,
            victory_num = 1,
            first_reward = true
        }
        stage.curr_stage = i + 1
        local stage_data = excel_data.StageData[i]
        role.stage:add_city_star_num(stage_data.city_id, CSConst.Stage.MaxStar)
    end
    stage.curr_part = 1
    stage.remain_enemy = 1
    stage.stage_dict[stage.curr_stage] = {first_reward = false, state = CSConst.Stage.State.New}
    role.stage:online_stage()
    return true
end

function role_gm.add_mail(role, args)
    local mail_id = tonumber(args)
    role:add_mail({mail_id = mail_id})
end

function role_gm.lover_grade(role, args)
    local grade = tonumber(args)
    for lover_id, info in pairs(role.db.lover_dict) do
        role.db.lover_dict[lover_id].grade = grade
    end
    role.lover:online_lover()
    role:salon_lover_compute()
    return true
end

function role_gm.set_vip(role, args)
    local level = tonumber(args)
    if level < 0 or level > excel_data.VipData.max_vip_level then
        return false ,"level must > 0 and level < " .. excel_data.VipData.max_vip_level
    end
    local exp_info = excel_data.VipData
    local old_exp = role.db.vip.vip_exp
    if level ~= 0 then
        local new_exp = exp_info[level].exp
        local diff_exp = new_exp - old_exp
        role.vip:add_vip_exp(diff_exp, "gm")
    else
        role.vip:add_vip_exp(-old_exp, "gm")
    end
end

function role_gm.set_active_value(role, args)
    local value = tonumber(args)
    role.db.currency[CSConst.Virtual.ActivePoint] = value
    role.daily_active:update_state_info()
    role:send_client("s_update_daily_active_info", role.daily_active:get_daily_active_info())
end

function role_gm.archives_list(role, args)
    local schema = require("schema_game")
    local data = schema.Archives:load(role.uuid)
    local content = "已有档案："
    if data and #data.archives_list > 0 then
        for i, v in ipairs(data.archives_list) do
            content = content .. i .. "存档时间：" .. os.date("%Y-%m-%d %H:%M:%S", v.ts) .. " 等级：" .. v.level .."; "
        end
    else
        content = content .. "无"
    end
    local msg = {
        chat_type = CSConst.ChatType.Private,
        content = content,
        private_uuid = role.uuid,
        private_name = role:get_name(),
    }
    role.chat:send_chat_msg(msg)
    return true
end

function role_gm.save_archives(role, args)
    local schema = require("schema_game")
    local uuid = role.uuid
    local data = schema.Archives:load(uuid)
    local role_data = {
        ts = date.time_second(),
        level = role:get_level(),
        bin = require("skynet.crypt").base64encode(skynet.packstring(table.deep_copy(role.db)))
    }

    if not data then
        schema.Archives:insert(uuid, {uuid = uuid, archives_list = {role_data}})
    else
        if #data.archives_list >= 10 then
            table.remove(data.archives_list, 1)
        end
        table.insert(data.archives_list, role_data)
        schema.Archives:set_field({uuid = uuid}, data)
    end
    return true
end

function role_gm.delete_archives(role, args)
    local archives_index = tonumber(args)
    if not archives_index then return end
    local schema = require("schema_game")
    local data = schema.Archives:load(role.uuid)
    if not data then return end
    local role_data = data.archives_list[archives_index]
    if not role_data then return end

    table.remove(data.archives_list, archives_index)
    schema.Archives:set_field({uuid = role.uuid}, data)
    return true
end

function role_gm.load_archives(role, args)
    local archives_index = tonumber(args)
    if not archives_index then return end
    local schema = require("schema_game")
    local data = schema.Archives:load(role.uuid)
    if not data then return end
    local role_data = data.archives_list[archives_index]
    if not role_data then return end

    local arc_db = skynet.unpack(require("skynet.crypt").base64decode(role_data.bin))
    for k, v in pairs(arc_db) do
        role.db[k] = v
    end
    role:kick()
    return true
end

function agent_gm.offset_time(args)
    local offset = tonumber(args)
    require("sys_utils.date").set_offset(offset)
    return true
end

function agent_gm.on_gm(uuid, name, args)
    local status, result, resp
    if uuid and uuid ~= "" and uuid ~= "0" and role_gm[name] then
        local role = agent_utils.get_role(uuid)
        if not role then
            g_log:error("no role:" .. uuid)
            return
        end
        local func = role_gm[name]
        if not func then
            g_log:warn("no gm for role:" .. name)
            return
        end
        status, result, resp = xpcall(func, g_log.trace_handle, role, args)
    else
        local func = agent_gm[name]
        if not func then
            g_log:warn("no gm:" .. name)
            return
        end
        status, result, resp = xpcall(func, g_log.trace_handle, args)
    end
    if not status then
        result = false
        resp = 'server exception'
    end
    g_log:gm("DoGm", {name=name, uuid=uuid, args=args, result=result, resp=resp})
    return result, resp
end

return agent_gm