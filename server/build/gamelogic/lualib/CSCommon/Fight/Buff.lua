local Buff = DECLARE_MODULE("CSCommon.Fight.Buff")

local DataMgr = require("CSCommon.data_mgr")
local FConst = require("CSCommon.Fight.FConst")

local ComputeBuffMap = {
    [FConst.ComputeBuffTime.BeginRound] = "ComputeBuffBeginRound",
    [FConst.ComputeBuffTime.EndRound] = "ComputeBuffEndRound",
    [FConst.ComputeBuffTime.BeginBuff] = "ComputeBuffBeginBuff",
    [FConst.ComputeBuffTime.EndBuff] = "ComputeBuffEndBuff",
}

function Buff.New(buff_id, unit, caster)
    local self = setmetatable({}, Buff)
    self.unit = unit
    self.caster = caster
    self.buff_id = buff_id
    local buff_data = DataMgr:GetBuffData(self.buff_id)
    self.round_num = buff_data.keep_round
    -- 用于记录buff修改的属性
    self.attr_dict = {}
    self.state = nil
    return self
end

-- buff生效
function Buff:BecomeEffective(compute_time)
    local func = ComputeBuffMap[compute_time]
    if func then
        return self[func](self)
    else
        error("unknown buff compute time :" .. compute_time)
    end
end

-- 回合前生效
function Buff:ComputeBuffBeginRound()
    local buff_data = DataMgr:GetBuffData(self.buff_id)
    local buff_info = buff_data.begin_round_do
    if buff_info then
        return self:ComputeBuff(buff_info)
    end
end

-- 回合后生效
function Buff:ComputeBuffEndRound()
    local buff_data = DataMgr:GetBuffData(self.buff_id)
    local buff_info = buff_data.end_round_do
    if buff_info then
        return self:ComputeBuff(buff_info)
    end
end

-- 中buff时即生效
function Buff:ComputeBuffBeginBuff()
    local buff_data = DataMgr:GetBuffData(self.buff_id)
    local buff_info = buff_data.begin_buff_do
    if buff_info then
        return self:ComputeBuff(buff_info)
    end
end

-- buff消失时生效
function Buff:ComputeBuffEndBuff()
    local buff_data = DataMgr:GetBuffData(self.buff_id)
    local buff_info = buff_data.end_buff_do
    if buff_info then
        return self:ComputeBuff(buff_info)
    end
end

-- 结算buff
function Buff:ComputeBuff(buff_info)
    local buff_data = DataMgr:GetBuffData(self.buff_id)
    local hp_diff, add_state
    local attr_name = buff_info.attr_name
    if attr_name then
        local value
        if attr_name == "hp" then
            -- 伤害要与攻击力相关
            value = self.caster.attr_dict["att"] * buff_info.att_pct_hurt * 0.01 + self.unit.attr_dict["max_hp"] * 0.01 * (buff_info.attr_value_pct or 0)
        elseif attr_name == "anger" then
            value = buff_info.attr_value
        else
            value = (buff_info.attr_value or 0) + (self.unit.attr_dict[attr_name] or 0) * 0.01 * (buff_info.attr_value_pct or 0)
        end
        value = math.floor(value)
        if buff_data.buff_type == FConst.BuffType.Sub then
            value = -value
        end

        if attr_name == "hp" then
            if value < 0 then
                self.unit:Hurt(value, self.caster)
            else
                self.unit:Cure(value)
            end
            hp_diff = value
        elseif attr_name == "anger" then
            self.unit:ChangeAnger(value)
        else
            self.unit.attr_dict[attr_name] = (self.unit.attr_dict[attr_name] or 0) + value
            self.attr_dict[attr_name] = (self.attr_dict[attr_name] or 0) + value
        end
    end
    if buff_info.state then
        self.unit.state_dict[buff_info.state] = (self.unit.state_dict[buff_info.state] or 0) + 1
        self.state = buff_info.state
        add_state = self.state
    end
    return true, hp_diff, add_state
end

-- buff失效
function Buff:BecomeInvalid()
    for attr_name, value in pairs(self.attr_dict) do
        if attr_name ~= "hp" then
            -- 清除Buff修改属性
            self.unit.attr_dict[attr_name] = self.unit.attr_dict[attr_name] - value
        end
    end
    if self.state then
        -- 清除Buff附加状态
        self.unit.state_dict[self.state] = self.unit.state_dict[self.state] - 1
        if self.unit.state_dict[self.state] <= 0 then
            self.unit.state_dict[self.state] = nil
            return self.state
        end
    end
end

return Buff