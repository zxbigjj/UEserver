local schema_game = require("schema_game")
local OfflineObjMgr = require("db.offline_db").OfflineObjMgr
local excel_data = require("excel_data")
local cache_utils = require("cache_utils")
local timer = require("timer")
local date = require("sys_utils.date")
local role_utils = require("role_utils")
local rank_utils = require("rank_utils")

local traitor_utils = DECLARE_MODULE("traitor_utils")
local TraitorCls = DECLARE_CLASS(traitor_utils, "TraitorCls")
DECLARE_RUNNING_ATTR(traitor_utils, "traitor_dict", {})

local CNAME = "Traitor"
local _mgr = DECLARE_RUNNING_ATTR(traitor_utils, "_mgr", nil, function()
    return OfflineObjMgr.new(schema_game[CNAME])
end)

function traitor_utils.start()
    _mgr:load_all()
    for _, traitor in pairs(_mgr:get_all()) do
        if traitor.appear_ts then
            TraitorCls.new(traitor)
        end
    end
end

function traitor_utils.add_traitor(traitor_info)
    local traitor = _mgr:get(traitor_info.traitor_guid)
    traitor.role_name = traitor_info.role_name
    traitor.traitor_id = traitor_info.traitor_id
    traitor.traitor_level = traitor_info.traitor_level
    traitor.appear_ts = date.time_second()
    traitor.quality = traitor_info.quality
    traitor.max_hp = traitor_info.max_hp
    traitor.hp_dict = traitor_info.hp_dict
    return TraitorCls.new(traitor)
end

function traitor_utils.get_traitor_cls(traitor_guid)
    local traitor_cls = traitor_utils.traitor_dict[traitor_guid]
    if not traitor_cls or not traitor_cls:is_appear() then return end
    return traitor_cls
end

function TraitorCls.new(traitor)
    local self = setmetatable({}, TraitorCls)
    self.guid = traitor.traitor_guid
    self.traitor = traitor
    self.delete_timer = nil
    self:init()
    traitor_utils.traitor_dict[self.guid] = self
    return self
end

function TraitorCls:save()
    _mgr:set(self.guid, self.traitor)
end

function TraitorCls:init()
    local traitor = self.traitor
    local data = excel_data.TraitorData[traitor.traitor_id]
    local run_time = data.run_time * CSConst.Time.Minute
    local now = date.time_second()
    if now - traitor.appear_ts >= run_time then
        self:delete()
    else
        -- 叛军过一段时间会自己消失
        local delay = run_time - (now - traitor.appear_ts)
        self.delete_timer = timer.once(delay, function()
            self.delete_timer = nil
            self:delete()
        end)
    end
end

function TraitorCls:delete(is_kill)
    if self.delete_timer then
        self.delete_timer:cancel()
        self.delete_timer = nil
    end
    local traitor = self.traitor
    local reward_list
    if is_kill then
        local traitor_data = excel_data.TraitorData[traitor.traitor_id]
        local index = traitor_data.quality_dict[traitor.quality]
        local discover_reward = traitor_data.discover_reward[index]
        reward_list = {{item_id = CSConst.Virtual.Diamond, count = discover_reward}}
    end
    agent_utils.delete_traitor(self.guid, reward_list)
    traitor.appear_ts = nil
    traitor.is_share = nil
    self:save()
end

function TraitorCls:is_appear()
    local traitor = self.traitor
    return traitor.appear_ts
end

function TraitorCls:share()
    local traitor = self.traitor
    if traitor.is_share then return end
    traitor.is_share = true
    self:save()
end

function TraitorCls:is_share()
    local traitor = self.traitor
    return traitor.is_share
end

function TraitorCls:get_traitor_info()
    return self.traitor
end
------------------ 排行榜 ---------------------------
-- 发放功勋榜奖励
function traitor_utils.give_feats_rank_reward()
    rank_utils.give_rank_reward("traitor_feats_rank")
    rank_utils.clear_rank_data("traitor_feats_rank")
end

-- 发放伤害榜奖励
function traitor_utils.give_hurt_rank_reward()
    rank_utils.give_rank_reward("traitor_hurt_rank")
    rank_utils.clear_rank_data("traitor_hurt_rank")
end

function traitor_utils.daily_refresh(last_give_ts)
    traitor_utils.give_feats_rank_reward()
    traitor_utils.give_hurt_rank_reward()
end

return traitor_utils