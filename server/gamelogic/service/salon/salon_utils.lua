local salon_utils = DECLARE_MODULE("salon_utils")
local OfflineObjMgr = require("db.offline_db").OfflineObjMgr
local excel_data = require("excel_data")
local date = require("sys_utils.date")
local timer = require("timer")
local cluster_utils = require('msg_utils.cluster_utils')
local schema_cross = require("schema_cross")

local SalonCls = DECLARE_CLASS(salon_utils, "SalonCls")
DECLARE_RUNNING_ATTR(salon_utils, "salon_cls_list", {})
DECLARE_RUNNING_ATTR(salon_utils, "refresh_timer", nil)
DECLARE_RUNNING_ATTR(salon_utils, "save_timer", nil)
DECLARE_RUNNING_ATTR(salon_utils, "salon_pvp_record", {})

local _mgr = DECLARE_RUNNING_ATTR(salon_utils, "_mgr", nil, function()
    return OfflineObjMgr.new(schema_cross["Salon"])
end)

local function check_can_join(id)
    local salon_config = excel_data.SalonAreaData[id]
    local delay_seconds = date.get_day_time(nil, salon_config.start_time) - date.time_second()
    if delay_seconds < 0 then return end
    return delay_seconds
end

function SalonCls.new(id)
    local self = setmetatable({}, SalonCls)
    self.id = id
    self.timer = nil
    self.role_list = {}
    self.role_dict = {}
    self.robot_name = {}
    self.term_max_count = nil
    self.term_count = 0
    salon_utils.salon_cls_list[id] = self

    self:salon_start()
    return self
end

function SalonCls:salon_start()
    local delay_seconds = check_can_join(self.id)
    if not delay_seconds then return end
    self.timer = timer.once(delay_seconds, function()
        self.timer = nil
        self:pvp_start()
    end)
end

function SalonCls:add_role(role_info)
    if not role_info.lover or not role_info.uuid then return end
    if self.role_dict[role_info.uuid] then return end
    table.insert(self.role_list, role_info)
    self.role_dict[role_info.uuid] = role_info
    return true
end

function SalonCls:get_robot_name()
    local name
    local RobotNameData = excel_data.RobotNameData[1]
    while true do
        name = RobotNameData.name[math.random(1, #RobotNameData.name)]
        if not self.robot_name[name] then
            self.robot_name[name] = true
            return name
        end
    end
end

function SalonCls:get_robot(index)
    local role_data = excel_data.RoleLookData
    local role_id = math.random(1, #role_data)
    local players_num = excel_data.ParamData["salon_pvp_term_player_num"].f_value
    local robot_config = excel_data.SalonRobotData[math.random(1, #excel_data.SalonRobotData)]

    local role_info = {
        uuid = tostring(index),
        role_id = role_id,
        name = self:get_robot_name(),
        level = math.random(robot_config.role_level[1], robot_config.role_level[2]),
        vip = math.random(robot_config.vip[1], robot_config.vip[2]),
        attr_point_dict = {},
    }
    local lover_list = excel_data.LoverData.lover_list
    role_info.lover = {
        grade = math.random(robot_config.lover_grade[1], robot_config.lover_grade[2]),
        level = math.random(robot_config.lover_level[1], robot_config.lover_level[2]),
        lover_id = lover_list[math.random(1, #lover_list)],
        attr_dict = {},
    }
    for index, name in ipairs(robot_config.attr_list) do
        if name ~= "planning" then
            role_info.attr_point_dict[name] = math.random(robot_config[name][1], robot_config[name][2])
        end
        role_info.lover.attr_dict[name] = math.random(robot_config[name][1], robot_config[name][2])
    end
    return role_info
end

function SalonCls:pvp_start()
    if #self.role_list <= 0 then return end
    local players_num = excel_data.ParamData["salon_pvp_term_player_num"].f_value
    self.term_max_count = math.ceil((#self.role_list) / players_num)
    local ratio = excel_data.ParamData["salon_attr_point_ratio"].f_value
    for i = 1, self.term_max_count do
        local pvp_term = {}
        local pvp_record = {
            salon_id = self.id,
            pvp_id = i,
            role_dict = {},
            round = {},
            total_rank = {},
        }
        for j = 1, players_num do
            local len = #self.role_list
            local role_info
            if len < 1 then
                -- 玩家数量不够，加机器人
                role_info = self:get_robot(j)
                self.role_dict[role_info.uuid] = role_info
            else
                local rand_index = math.random(1, len)
                role_info = self.role_list[rand_index]
                table.remove(self.role_list, rand_index)
                role_info.server_id = cluster_utils.get_server_id(role_info.uuid)
            end
            for name, value in pairs(role_info.lover.attr_dict) do
                if name ~= "planning" then
                    local add_count = value * ratio * (role_info.attr_point_dict[name] or 0)
                    role_info.lover.attr_dict[name] = value + add_count
                end
            end
            role_info.round = {}
            pvp_record.role_dict[role_info.uuid] = self.role_dict[role_info.uuid]
            pvp_record.role_dict[role_info.uuid].index = j
            table.insert(pvp_term, role_info)
        end
        self:pvp_run(i, pvp_term, pvp_record)
    end
end

function SalonCls:pvp_run(pvp_id, pvp_term, pvp_record)
    for i, attr in ipairs (CSConst.Salon.PvPAttrListCmp) do
        -- attr[1]:字段名, attr[2]:是否降序
        local cmp = function(a, b)
            local a_attr_value = a.lover.attr_dict[attr[1]]
            local b_attr_value = b.lover.attr_dict[attr[1]]
            if a_attr_value == b_attr_value then
                for j, param in ipairs(CSConst.Salon.PvPLoverInfoCmp) do
                    local a_value = a.lover[param[1]]
                    local b_value = b.lover[param[1]]
                    if a_value ~= b_value then
                        local ret = a_value > b_value
                        return ret == param[2]
                    end
                end
            else
                local ret = a_attr_value > b_attr_value
                return ret == attr[2]
            end
            return a.level > b.level
        end
        table.sort(pvp_term, cmp)

        -- 当前回合结束，累加pvp得分
        local add_score = 0
        pvp_record.round[i] = {
            rank_list = {},
        }
        for index = #pvp_term, 1, -1 do
            local role_info = pvp_term[index]
            pvp_term[index].round[i] = pvp_term[index].round[i] or {}
            pvp_term[index].round[i].rank = index
            if i == #CSConst.Salon.PvPAttrListCmp then
                -- 最后一回合特殊处理
                if index > 1 then
                    if pvp_term[index].round.total_score ~= 0 then
                        pvp_term[index].round[i].score = -1
                        add_score = add_score + 1
                    else
                        pvp_term[index].round[i].score = 0
                    end
                else
                    pvp_term[index].round[i].score = add_score
                end
            else
                pvp_term[index].round[i].score = CSConst.Salon.PvPScore[index]
            end
            pvp_term[index].round.total_score = (pvp_term[index].round.total_score or 0) + pvp_term[index].round[i].score

            pvp_record.round[i].rank_list[index] = {
                uuid = role_info.uuid,
                score = pvp_term[index].round[i].score,
            }
        end
    end

    local cmp = function(a, b)
        return a.round.total_score > b.round.total_score
    end
    table.sort(pvp_term, cmp)

    -- pvp结束，排序发放奖励积分
    for index, info in ipairs(pvp_term) do
        pvp_record.total_rank[index] = {
            uuid = info.uuid,
            score = info.round.total_score,
        }
    end

    local salon_config = excel_data.SalonAreaData[self.id]
    local delay_seconds = (salon_config.start_time + excel_data.ParamData["salon_pvp_run_time"].f_value) - date.time_second()
    self.timer = timer.once(delay_seconds, function()
        self.timer = nil
        self:pvp_end(pvp_record)
    end)
end

function SalonCls:pvp_end(pvp_record)
    for index, info in ipairs(pvp_record.total_rank) do
        local pvp_info = {
            salon_id = pvp_record.salon_id,
            pvp_id = pvp_record.pvp_id,
            rank = index,
        }
        if string.len(info.uuid) > 1 then
            -- 通知玩家, 排除机器人
            cluster_utils.send_agent(nil, info.uuid, "ls_salon_pvp_results", {pvp_info = pvp_info})
        end
    end
    salon_utils.add_salon_pvp_record(pvp_record)
    self.term_count = self.term_count + 1
    if self.term_count >= self.term_max_count then
        salon_utils.salon_cls_list[self.id] = nil
    end
end

--------------------------------------------------------
function salon_utils.get_salon_cls(salon_id)
    if not salon_utils.salon_cls_list[salon_id] then return end
    return salon_utils.salon_cls_list[salon_id]
end

function salon_utils.daily_refresh()
    salon_utils.salon_pvp_record[CSConst.Salon.Yesterday] = table.deep_copy(salon_utils.salon_pvp_record[CSConst.Salon.Today])
    salon_utils.salon_pvp_record[CSConst.Salon.Today] = {}
    salon_utils.save_salon_pvp_record()
    for salon_id, data in pairs(excel_data.SalonAreaData) do
        SalonCls.new(salon_id)
    end
end

function salon_utils.add_salon_pvp_record(pvp_record)
    if not salon_utils.salon_pvp_record[CSConst.Salon.Today] then
        salon_utils.salon_pvp_record[CSConst.Salon.Today] = {}
    end
    table.insert(salon_utils.salon_pvp_record[CSConst.Salon.Today], pvp_record)
    salon_utils.save_salon_pvp_record()
end

function salon_utils.get_salon_pvp_record(day, salon_id, pvp_id)
    local pvp_list = salon_utils.salon_pvp_record[day]
    if not pvp_list then return end
    for index, pvp_info in ipairs(pvp_list) do
        if pvp_info.salon_id == salon_id and pvp_info.pvp_id == pvp_id then
            return pvp_info
        end
    end
end

function salon_utils.start()
    _mgr:load_all()
    for day_index, data in pairs(_mgr:get_all()) do
        salon_utils.salon_pvp_record[day_index] = data.record_list
    end
    for salon_id, data in ipairs(excel_data.SalonAreaData) do
        SalonCls.new(salon_id)
    end

    local delay_seconds = (date.get_day_time(nil, 0) - date.time_second()) + CSConst.Time.Day
    salon_utils.refresh_timer = timer.loop(CSConst.Time.Day, function()
        salon_utils.daily_refresh()
    end, delay_seconds)
end

function salon_utils.save_salon_pvp_record()
    for day_index, record_list in pairs(salon_utils.salon_pvp_record) do
        local data = _mgr:get(day_index)
        data.record_list = table.deep_copy(record_list)
        _mgr:set(day_index, data)
    end
end

return salon_utils