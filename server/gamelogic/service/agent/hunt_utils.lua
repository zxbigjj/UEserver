local hunt_utils = DECLARE_MODULE("hunt_utils")

local excel_data = require("excel_data")
local date = require("sys_utils.date")
local timer = require("timer")
local cluster_utils = require('msg_utils.cluster_utils')
local schema_game = require("schema_game")
local drop_utils = require("drop_utils")
local cache_utils = require("cache_utils")

local AnimalCls = DECLARE_CLASS(hunt_utils, "AnimalCls")
DECLARE_RUNNING_ATTR(hunt_utils, "animal_dict", {})

-- 珍兽血量百分比表示
local PercentHp = 1

-- 检查珍兽是否能复活
local function check_can_revive(ts)
    local hunt_ts = excel_data.ParamData["hunt_rare_animal_ts"].tb_int
    local start_ts = date.get_day_time(ts, hunt_ts[1])
    local close_ts = date.get_day_time(ts, hunt_ts[2])
    if ts >= start_ts and ts <= close_ts then
        return true
    end
end

function AnimalCls.new(id)
    local self = setmetatable({}, AnimalCls)
    self.id = id
    self.percent_hp = PercentHp
    self.kill_ts = nil
    self.revive_ts = nil
    self.hurt_rank = {}
    self.role_dict = {}
    self.revive_timer = nil
    self.reduce_hp_timer = nil
    hunt_utils.animal_dict[id] = self
    return self
end

-- 狩猎开始
function AnimalCls:hunt_star(role_data)
    if self:is_death() then return end
    if not self.reduce_hp_timer then
        self.reduce_hp_timer = timer.loop(1, function()
            -- 开始猎杀后，珍兽每秒都会掉血
            self:reduce_hp()
        end)
    end

    -- 记录狩猎玩家数据
    if not self.role_dict[role_data.uuid] then
        self.role_dict[role_data.uuid] = {
            uuid = role_data.uuid,
            hurt = 0,
            rank = nil,
            inspire_num = 0,
            role_name = role_data.name,
            role_level = role_data.level,
            role_id = role_data.role_id,
            vip = role_data.vip
        }
    end
end

-- 珍兽只每秒百分比掉血，玩家伤害不掉血
function AnimalCls:reduce_hp()
    local animal_data = excel_data.RareAnimalData[self.id]
    self.percent_hp = self.percent_hp - animal_data.percent_hp
    if self.percent_hp <= 0 then
        self:on_kill()
    end
end

-- 获取珍兽复活时间
function AnimalCls:set_revive_ts()
    local animal_data = excel_data.RareAnimalData[self.id]
    local now = date.time_second()
    local ts = now + animal_data.revive_ts
    if not check_can_revive(ts) then
        local hunt_ts = excel_data.ParamData["hunt_rare_animal_ts"].tb_int
        local start_ts = date.get_day_time(now, hunt_ts[1])
        if start_ts < now then
            local one_day = CSConst.Time.Day
            start_ts = start_ts + one_day
        end
        self.revive_ts = start_ts
    else
        self.revive_ts = ts
    end
end

-- 珍兽被击杀
function AnimalCls:on_kill()
    if self:is_death() then return end

    self.reduce_hp_timer:cancel()
    self.reduce_hp_timer = nil
    self.kill_ts = date.time_second()
    self:set_revive_ts()
    self:give_reward()
    self.percent_hp = 0
    self.hurt_rank = {}
    self.role_dict = {}

    local animal_data = excel_data.RareAnimalData[self.id]
    local notice_time = excel_data.ParamData["oversee_rare_animal_time"].f_value
    local delay = animal_data.revive_ts - notice_time
    self.revive_timer = timer.once(delay, function()
        self.revive_timer = nil
        -- 起复活通知定时器，复活前5秒通知
        self:notice()
    end)
end

-- 通知玩家珍兽即将复活
function AnimalCls:notice()
    local notice_time = excel_data.ParamData["oversee_rare_animal_time"].f_value
    local now = date.time_second()
    local ts = now + notice_time
    if not check_can_revive(ts) then
        local hunt_ts = excel_data.ParamData["hunt_rare_animal_ts"].tb_int
        local start_ts = date.get_day_time(now, hunt_ts[1])
        if start_ts < now then
            local one_day = CSConst.Time.Day
            start_ts = start_ts + one_day
        end
        local delay = start_ts - now - notice_time
        self.revive_timer = timer.once(delay, function()
            self.revive_timer = nil
            self:notice()
        end)
        return
    end

    self.revive_timer = timer.once(notice_time, function()
        self.revive_timer = nil
        self:revive()
    end)
    -- 通知监视本珍兽的玩家，珍兽即将复活
    for _, uuid in pairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        if role then
            local listen_animal = role:get_listen_animal()
            if listen_animal == self.id then
                role:send_client("s_rare_animal_appear", {animal_id = self.id})
            end
        end
    end
end

-- 珍兽复活
function AnimalCls:revive()
    self.kill_ts = nil
    self.revive_ts = nil
    local animal_data = excel_data.RareAnimalData[self.id]
    self.percent_hp = PercentHp
end

-- 发放击杀珍兽奖励
function AnimalCls:give_reward()
    local data = excel_data.RareAnimalData[self.id]
    local role_reward_dict = {}
    for uuid, role_data in pairs(self.role_dict) do
        local item_list = {}
        -- 必得奖励，只有前几名不一样，后面的都一样
        local len = #data.must_item
        local rank = role_data.rank or 0
        local must_item = data.must_item[rank] or data.must_item[len]
        local reward_list = excel_data.RewardData[must_item].item_list
        table.extend(item_list, table.deep_copy(reward_list))
        -- 随机掉落，只有前几名不一样，后面的都一样
        local drop_id = data.drop_id[rank] or data.drop_id[len]
        table.extend(item_list, drop_utils.roll_drop(drop_id))
        role_reward_dict[uuid] = {rank = role_data.rank, item_list = item_list}
        local role = agent_utils.get_role(uuid)
        if role then
            role:send_client("s_hunt_rare_animal_kill_reward", {
                animal_id = self.id,
                item_list = item_list,
                self_rank = role_data.rank
            })
        end
    end

    local count = 0
    for uuid, data in pairs(role_reward_dict) do
        local mail_info
        if data.rank then
            mail_info = {mail_id=CSConst.MailId.Hunt, mail_args={rank = data.rank}, item_list=data.item_list}
        else
            mail_info = {mail_id=CSConst.MailId.Hunt1, item_list=data.item_list}
        end
        agent_utils.add_mail(uuid, mail_info)
        count = count + 1
        if count == 10 then
            skynet.sleep(1)
            count = 0
        end
    end
end

-- 玩家造成伤害
function AnimalCls:on_hunt(uuid, hurt)
    if self:is_death() then return end
    local role_data = self.role_dict[uuid]
    if not role_data then return end

    role_data.hurt = role_data.hurt + hurt
    -- 加入伤害排行榜
    if not role_data.rank then
        local len = #self.hurt_rank
        if len >= CSConst.Hunt.RankLen then
            local last_role = self.hurt_rank[len]
            if last_role.hurt >= hurt then return end
            last_role.rank = nil
            table.remove(self.hurt_rank)
        end
    end
    update_sorted_list(self.hurt_rank, role_data, "hurt", true)
end

function AnimalCls:is_death()
    return self.kill_ts and true
end

-- 获取参与狩猎的总人数
function AnimalCls:get_join_num()
    return table.length(self.role_dict)
end

-- 获取参与玩家的狩猎数据
function AnimalCls:get_hunt_role(uuid)
    return self.role_dict[uuid]
end
-------------------------------------------------------------------
function hunt_utils.get_animal_cls(animal_id)
    return hunt_utils.animal_dict[animal_id]
end

function hunt_utils.start()
    for animal_id, data in pairs(excel_data.RareAnimalData) do
        AnimalCls.new(animal_id)
    end
end

return hunt_utils