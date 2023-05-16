local party_utils = DECLARE_MODULE("party_utils")
local OfflineObjMgr = require("db.offline_db").OfflineObjMgr
local excel_data = require("excel_data")
local date = require("sys_utils.date")
local timer = require("timer")
local cluster_utils = require('msg_utils.cluster_utils')
local schema_cross = require("schema_cross")
local CSFunction = require("CSCommon.CSFunction")
local server_env = require("srv_utils.server_env")

local PartyCls = DECLARE_CLASS(party_utils, "PartyCls")
DECLARE_RUNNING_ATTR(party_utils, "party_cls_dict", {})

DECLARE_RUNNING_ATTR(party_utils, "save_timer", nil)
DECLARE_RUNNING_ATTR(party_utils, "party_id", nil)

DECLARE_RUNNING_ATTR(party_utils, "party_integral_rank", {})
DECLARE_RUNNING_ATTR(party_utils, "party_integral_dict", {})

local _mgr = DECLARE_RUNNING_ATTR(party_utils, "_mgr", nil, function()
    return OfflineObjMgr.new(schema_cross["Party"], 10000)
end)

function PartyCls.new(info)
    local self = setmetatable({}, PartyCls)
    self.id = info.party_info.party_id
    self.info = info
    self.timer = nil
    party_utils.party_cls_dict[self.id] = self
    self:update_party_cls()
    self:party_start()
    return self
end

function PartyCls:party_start()
    local party_info = self.info.party_info
    local party_config = excel_data.PartyData[party_info.party_type_id]
    if not party_config then return end
    local delay_time = party_config.time - (date.time_second() - party_info.start_time)
    if delay_time > 0 then
        self.timer = timer.once(delay_time , function()
            self.timer = nil
            self:party_end(CSConst.Party.EndType.Normal)
        end)
    else
        self:party_end(CSConst.Party.EndType.Normal)
    end
end

function PartyCls:add_guests(guests_info)
    local party_info = self.info.party_info
    if party_info.end_type then
        return {end_type = party_info.end_type}
    end
    local party_config = excel_data.PartyData[party_info.party_type_id]
    if not party_config then return end
    if #party_info.guests_list >= party_config.guests_max_num then return end
    table.insert(party_info.guests_list, guests_info)
    if #party_info.guests_list >= party_config.guests_max_num then
        local cd = excel_data.ParamData["party_end_cd"].f_value
        -- 宾客满。清除原始定时器，起一个时长为cd的。
        if date.time_second() - party_info.start_time > cd then
            if self.timer then
                self.timer:cancel()
                self.timer = nil
            end
            self.timer = timer.once(cd, function()
                self:party_end(CSConst.Party.EndType.Normal)
            end)
        end
    end
    local uuid = party_info.host_info.uuid
    cluster_utils.send_agent(nil, uuid, "ls_party_add_guests", {
        party_info = party_info,
    })
    self:update_party_cls()
    return party_info
end

function PartyCls:games_score(uuid, integral)
    local guests_list = self.info.party_info.guests_list
    for i, guests_info in ipairs(guests_list) do
        if guests_info.role_info.uuid == uuid and guests_info.games_num then
            guests_info.integral = guests_info.integral + integral
            if guests_info.games_num <= 1 then
                guests_info.games_num = nil
            else
                guests_info.games_num = guests_info.games_num - 1
            end
            self:update_party_cls()
            return self.info.party_info
        end
    end
end

function PartyCls:update_lover_level(value)
    self.info.party_info.lover_level = value
    self:update_party_cls()
end

function PartyCls:party_end(end_type, enemy_info)
    local party_info = self.info.party_info
    if party_info.end_type then return end
    party_info.end_type = end_type
    party_info.enemy_info = enemy_info
    party_info.end_time = date.time_second()
    local count_sum, count, add_count = CSFunction.get_party_point(party_info)
    if end_type == CSConst.Party.EndType.EnemyEnd then
        count_sum = math.floor(count_sum * (1 - excel_data.ParamData["party_buster_get_point_ratio"].f_value))
    end
    party_info.add_ratio = CSFunction.get_add_ratio(party_info.lover_level)
    party_info.integral_count = count_sum
    for i, guests_info in ipairs(party_info.guests_list) do
        if guests_info.games_num then
            cluster_utils.send_agent(nil, guests_info.role_info.uuid, "ls_party_games_end", party_info)
        end
    end
    local uuid = party_info.host_info.uuid
    cluster_utils.send_agent(nil, uuid, "ls_party_end", {
        party_info = party_info,
    })
    self:update_party_cls()
    return party_info
end

function PartyCls:receive_integral()
    local party_info = self.info.party_info
    if not party_info.host_info.uuid or not party_info.integral_count then return end
    return party_info
end

function PartyCls:update_party_cls(is_delete)
    if not is_delete then
        _mgr:set(self.id, self.info)
    else
        _mgr:delete(self.id)
        party_utils.party_cls_dict[self.id] = nil
    end
end

-------------------- PartyCls end -------------------------

function party_utils.get_party_cls(party_id)
    return party_utils.party_cls_dict[party_id]
end

function party_utils.find_party(uuid)
    for id, party_cls in pairs(party_utils.party_cls_dict) do
        if party_cls.info.party_info.host_info.uuid == uuid then
            return party_cls.info.party_info
        end
    end
end

function party_utils.add_party(party_info ,is_private)
    if not party_info.party_id then
        party_info.guests_list = {}
        party_info.enemy_info = {}
        party_info.start_time = date.time_second()
        party_info.party_id = party_utils.party_id
        party_utils.party_id = party_utils.party_id + 1
    end

    local info = _mgr:get(party_info.party_id)
    info.party_info = party_info
    info.is_private = is_private
    PartyCls.new(info)
    return party_info
end

function party_utils.random_get_party(uuid)
    local sign_list = {}
    for id, party_cls in pairs(party_utils.party_cls_dict) do
        local party_info = party_cls.info.party_info
        if not party_cls.info.is_private and not party_info.end_type and party_info.host_info.uuid ~= uuid then
            table.insert(sign_list, id)
        end
    end
    local len = #sign_list
    if len <= 0 then return end
    local party_list = {}
    for i = 1, len do
        local index = math.random(1, #sign_list)
        local party_cls = party_utils.party_cls_dict[sign_list[index]]
        table.insert(party_list, party_cls.info.party_info)
        table.remove(sign_list, index)
        if i >= CSConst.Party.PageSize then break end
    end
    return party_list
end

function party_utils.start()
    _mgr:load_all()
    for id, info in ipairs(_mgr:get_all()) do
        PartyCls.new(info)
    end

    local server_id = "s"..server_env.get_server_id()
    local server_data = schema_cross.ServerCore:load(server_id)
    if not server_data then
        server_data = schema_cross.ServerCore:insert(server_id, {
            server_name = server_id,
            party_id = 1,
        })
    end
    party_utils.party_id = server_data.party_id

    -- 十分钟保存一次数据
    party_utils.save_timer = timer.loop(600, function()
        party_utils.save_party()
    end, 600)
end

function party_utils.save_party()
    local server_id = "s"..server_env.get_server_id()
    schema_cross.ServerCore:set_field({server_name = server_id}, {
        party_id = party_utils.party_id,
    })
end

return party_utils