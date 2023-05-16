local Game = DECLARE_MODULE("CSCommon.Fight.Game")

local RandomMgr = require("CSCommon.Fight.RandomMgr")
local FConst = require("CSCommon.Fight.FConst")
local DataMgr = require("CSCommon.data_mgr")
local Unit = require("CSCommon.Fight.Unit")
local BattleGround = require("CSCommon.Fight.BattleGround")

-- 客户端需要传send_event_func参数，服务端不需要
function Game.New(fight_data, send_event_func)
    local self = setmetatable({}, Game)
    if send_event_func then
        self.send_event_func = send_event_func
    end
    self.seed = fight_data.seed
    self.random = RandomMgr.New(self.seed)
    self.battle_ground = BattleGround.New(self.random)
    self.unit_dict_by_side = {}
    local total_score = {}
    local fight_pos_data = {
        [FConst.Side.Own] = fight_data.own_fight_data,
        [FConst.Side.Enemy] = fight_data.enemy_fight_data
    }
    for side, pos_data in pairs(fight_pos_data) do
        self.unit_dict_by_side[side] = {}
        for pos, data in ipairs(pos_data) do
            if next(data) then
                self.unit_dict_by_side[side][pos] = Unit.New(data, side, pos, self)
                total_score[side] = (total_score[side] or 0) + (data.score or 0)
            else
                self.unit_dict_by_side[side][pos] = {}
            end
        end
    end
    self.attack_side_list = {FConst.Side.Own, FConst.Side.Enemy}
    if fight_data.is_pvp then
        -- pvp战力高的先手
        if total_score[FConst.Side.Enemy] > total_score[FConst.Side.Own] then
            self.attack_side_list = {FConst.Side.Enemy, FConst.Side.Own}
        end
    end
    self.victory_id = fight_data.victory_id
    self.max_round_num = FConst.MaxRound
    self.curr_round_num = nil
    if self.victory_id then
        -- 存在胜利条件
        local victory_data = DataMgr:GetVictoryData(self.victory_id)
        if victory_data.round_num then
            -- 条件为一定回合内通关
            self.max_round_num = victory_data.round_num[1]
        end
    end
    return self
end

-- 发送战斗事件
function Game:SendEvent(event_type, ...)
    if self.send_event_func then
        self.send_event_func(event_type, ...)
    end
end

-- 进入战斗
function Game:GoToFight()
    for i = 1, self.max_round_num do
        self.curr_round_num = i
        self:SendEvent("RoundStart", self.curr_round_num)
        if self:Start() then break end
        self:SendEvent("RoundEnd", self.curr_round_num)
    end
    local is_win = self:JudgeResult()
    self:SendEvent("GameEnd", is_win)
    return is_win
end

function Game:Start()
    local max_pos = self.battle_ground:GetMaxPos()
    for pos = 1, max_pos do
        for _, side in ipairs(self.attack_side_list) do
            local unit = self.unit_dict_by_side[side][pos]
            if next(unit) and not unit:IsDeath() then
                unit:RoundStart(self.unit_dict_by_side, self.random)
            end
            if self:CheckResult() then return true end
        end
    end
end

-- 检查战斗结果
function Game:CheckResult()
    for side, unit_list_by_pos in pairs(self.unit_dict_by_side) do
        local total_num = 0
        local death_num = 0
        for pos, unit in pairs(unit_list_by_pos) do
            if next(unit) then
                total_num = total_num + 1
                if unit:IsDeath() then
                    death_num = death_num + 1
                end
            end
        end
        if total_num == death_num then
            -- 有一方全部死亡，则结束战斗
            return true
        end
    end
end

-- 获取战斗结果信息
function Game:GetFightResultInfo(side)
    local ret = {
        round_num = self.curr_round_num,
        total_num = 0,
        death_num = 0,
        total_hp = 0,
        remain_hp = 0,
        hp_dict = {}
    }
    for pos, unit in ipairs(self.unit_dict_by_side[side]) do
        if next(unit) then
            ret.total_num = ret.total_num + 1
            if unit:IsDeath() then
                ret.death_num = ret.death_num + 1
            end
            ret.total_hp = ret.total_hp + unit.attr_dict["max_hp"]
            ret.remain_hp = ret.remain_hp + unit.attr_dict["hp"]
            ret.hp_dict[pos] = unit.attr_dict["hp"]
        end
    end
    return ret
end

-- 判断胜利方
function Game:JudgeResult()
    local ret = self:GetFightResultInfo(FConst.Side.Own)
    if ret.total_num == ret.death_num then
        -- 我方全死，敌方胜利
        return false
    end
    local enemy_ret = self:GetFightResultInfo(FConst.Side.Enemy)
    if enemy_ret.total_num == enemy_ret.death_num then
        -- 敌方全死，还要判断胜利条件
        if self.victory_id then
            local victory_data = DataMgr:GetVictoryData(self.victory_id)
            if victory_data.remian_hp then
                -- 条件为剩余一定的百分比血量
                if ret.remain_hp/ret.total_hp < victory_data.remian_hp[1] then
                    return false
                end
            elseif victory_data.death_num then
                -- 条件为死亡人数
                if ret.death_num > victory_data.death_num[1] then
                    return false
                end
            end
        end
        return true
    end
    return false
end

--  获取战斗结束后单位状态
function Game:GetFightResultUnitInfo(side)
    local ret = {}
    for pos, unit in ipairs(self.unit_dict_by_side[side]) do
        if next(unit) then
            ret[pos] = {}
            ret[pos].hp = unit.attr_dict["hp"] or 0
            ret[pos].max_hp = unit.attr_dict["max_hp"] or 0
            ret[pos].cur_anger = unit.anger or 0
        end
    end
    return ret
end

-- 获取战斗伤害信息
function Game:GetFightHurtInfo()
    local hurt_info = {}
    for side, unit_list in ipairs(self.unit_dict_by_side) do
        hurt_info[side] = {}
        for _, unit in ipairs(unit_list) do
            if next(unit) then
                hurt_info[side][unit.pos] = unit.total_hurt
            end
        end
    end
    return hurt_info
end

return Game