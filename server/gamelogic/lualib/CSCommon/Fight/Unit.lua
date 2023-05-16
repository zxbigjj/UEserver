local Unit = DECLARE_MODULE("CSCommon.Fight.Unit")

local DataMgr = require("CSCommon.data_mgr")
local FConst = require("CSCommon.Fight.FConst")
local Buff = require("CSCommon.Fight.Buff")

local AttackTypeMap = {
    [FConst.SpellAttackType.All] = "GetAttackTargetAll",
    [FConst.SpellAttackType.AngerNum] = "GetAttackTargetAngerNum",
    [FConst.SpellAttackType.Column] = "GetAttackTargetColumn",
    [FConst.SpellAttackType.FrontRow] = "GetAttackTargetFrontRow",
    [FConst.SpellAttackType.BackRow] = "GetAttackTargetBackRow",
    [FConst.SpellAttackType.BackOne] = "GetAttackTargetBackOne",
    [FConst.SpellAttackType.FrontOne] = "GetAttackTargetFrontOne",
    [FConst.SpellAttackType.RandomNum] = "GetAttackTargetRandomNum",
    [FConst.SpellAttackType.ColumnOne] = "GetAttackTargetColumnOne",
    [FConst.SpellAttackType.Neighbor] = "GetAttackTargetNeighbor",
    [FConst.SpellAttackType.CureOne] = "GetAttackTargetCureOne",
    [FConst.SpellAttackType.ExtraCure] = "GetAttackTargetAll",
}

function Unit.New(data, side, pos, game)
    local self = setmetatable({}, Unit)
    self.unit_id = data.unit_id
    self.side = side
    self.pos = pos
    self.game = game
    self.anger = FConst.InitAnger + (data.add_anger or 0)
    self.total_hurt = 0
    self.buff_list = {}
    self.state_dict = {}
    self.attr_dict = {}
    for k, v in pairs(data.fight_attr_dict) do
        self.attr_dict[k] = v
    end
    self.attr_dict["hp"] = self.attr_dict["hp"] or self.attr_dict["max_hp"]
    self.spell_dict_by_type = {}
    for spell_id, spell_level in pairs(data.spell_dict) do
        local spell_data = DataMgr:GetSpellData(spell_id)
        self.spell_dict_by_type[spell_data.spell_type] = {
            spell_id = spell_id,
            spell_level = spell_level
        }
    end
    -- 临时属性
    self.temp_attr_dict = {}
    if data.buff_list then
        for _, buff_id in ipairs(data.buff_list) do
            self:AddBuff(buff_id, self)
        end
    end
    self.monster_id = data.monster_id
    return self
end

function Unit:SendEvent(event_type, ...)
    if self.game.send_event_func then
        self.game:SendEvent(event_type, self.side, self.pos, ...)
    end
end

function Unit:RoundStart()
    self:BeginRound()
    if self:CanAttack() then
        self:Attack()
    end
    self:EndRound()
end

-- 回合开始前
function Unit:BeginRound()
    self:ComputeBuff(FConst.ComputeBuffTime.BeginRound)
end

-- 回合结束后
function Unit:EndRound()
    self:ComputeBuff(FConst.ComputeBuffTime.EndRound)
    local remove_buff_list = {}
    for _, buff in ipairs(self.buff_list) do
        buff.round_num = buff.round_num - 1
        if buff.round_num <= 0 then
            table.insert(remove_buff_list, buff.buff_id)
        end
    end
    if next(remove_buff_list) then
        self:RemoveBuff(remove_buff_list)
    end
    self:AngerRecover()
end

-- 怒气恢复
function Unit:AngerRecover()
    local anger_recover_value = self.attr_dict["anger_recover"]
    if anger_recover_value then
        self:ChangeAnger(anger_recover_value)
    end
end

-- 是否可以攻击
function Unit:CanAttack()
    if self:IsDeath() then
        return false
    elseif self.state_dict[FConst.BuffStateType.Vertigo] then
        -- 眩晕
        return false
    end
    return true
end

function Unit:Attack()
    -- 从高等技能判断是否满足释放条件（合体技能->普通攻击）
    for spell_type = FConst.SpellTypeNum, 1, -1 do
        local spell = self.spell_dict_by_type[spell_type]
        if spell then
            if self:CanCastSpell(spell.spell_id) then
                self:CastSpell(spell)
                return
            end
        end
    end
end

function Unit:CanCastSpell(spell_id)
    local spell_data = DataMgr:GetSpellData(spell_id)
    if self.anger < spell_data.cost_anger then return end
    if spell_data.spell_unit_list then
        -- 判断合体技能条件
        local count = 0
        local unit_list = self.game.unit_dict_by_side[self.side]
        for _, unit_id in ipairs(spell_data.spell_unit_list) do
            for _, unit in ipairs(unit_list) do
                if next(unit) and unit.unit_id == unit_id and not unit:IsDeath() then
                    count = count + 1
                    break
                end
            end
        end
        if count ~= #spell_data.spell_unit_list then return end
    end
    return true
end

function Unit:CastSpell(spell)
    local spell_data = DataMgr:GetSpellData(spell.spell_id)
    local old_anger = self.anger
    self.anger = self.anger - spell_data.cost_anger
    if spell_data.add_anger then
        self.anger = self.anger + spell_data.add_anger
    end
    local anger_diff = self.anger - old_anger
    self:SendEvent("SpellStart", spell.spell_id, anger_diff)

    local other_side = self.game.battle_ground:GetOtherSide(self.side)
    local unit_dict_by_side = self.game.unit_dict_by_side
    local unit_list_by_pos = unit_dict_by_side[other_side]
    local attack_side = other_side
    if spell_data.side_type == FConst.SpellSideType.Own then
        -- 技能攻击阵营为己方（如治疗）
        unit_list_by_pos = unit_dict_by_side[self.side]
        attack_side = self.side
    end
    local attack_target_list = self:GetAttackTarget(unit_list_by_pos, spell_data.attack_type)
    if spell_data.buff_clear_level then
        -- 技能清除buff
        if self.game.random:Random() <= spell_data.buff_clear_ratio then
            self:SpellClearBuff(attack_target_list, spell_data.buff_clear_level)
        end
    end
    local buff_info = self:CheckIsTriggerBuff(attack_target_list)
    local attack_obj_by_pos = {}
    local spell_attr_dict = spell_data.modify_attr_dict or {}
    local total_hurt = 0
    local rebound_hurt_list = {}
    local miss_unit_dict = {}
    for _, target_unit in ipairs(attack_target_list) do
        attack_obj_by_pos[target_unit.pos] = target_unit
        local hp_diff = 0
        local is_miss, is_crit
        if target_unit:CanHurt() then
            -- 先算技能总伤害
            local spell_hurt_ratio = 0.01 * (spell_data.spell_hurt_pct + (spell_data.hurt_grow_rate or 0) * (spell.spell_level - 1))
            local fixed_hurt = spell_data.fixed_hurt or 0
            if attack_side == self.side then
                hp_diff, is_crit = self:ComputeCure(target_unit, spell_hurt_ratio, fixed_hurt, spell_attr_dict)
                if spell_data.attack_type == FConst.SpellAttackType.ExtraCure then
                    -- 对生命低于XX%的友军额外治疗N%
                    if target_unit.attr_dict["hp"]/target_unit.attr_dict["max_hp"] < 0.01 * spell_data.cure_param[1] then
                        hp_diff = math.floor(hp_diff * (1 + 0.01 * spell_data.cure_param[2]))
                    end
                end
            else
                hp_diff, is_miss, is_crit = self:ComputeHurt(target_unit, spell_hurt_ratio, fixed_hurt, spell_attr_dict)
                if buff_info.hurt_ratio then
                    -- 多倍伤害
                    hp_diff = hp_diff * buff_info.hurt_ratio
                end
            end
        end
        local single_hurt = 0
        for i, hit_info in ipairs(spell_data.hit_tb) do
            -- 单位分段伤害
            if target_unit:CanHurt() then
                local hurt, is_second_kill
                if not spell_data.is_second_kill then
                    if attack_side == self.side then
                        hurt = math.floor(hp_diff * hit_info.hurt_rate)
                        hurt = hurt == 0 and 1 or hurt
                        target_unit:Cure(hurt)
                    else
                        hurt = math.ceil(hp_diff * hit_info.hurt_rate)
                        if not is_miss then
                            hurt = hurt == 0 and -1 or hurt
                            local real_hurt = target_unit:Hurt(hurt, self)
                            single_hurt = single_hurt + real_hurt
                        end
                    end
                else
                    -- 秒杀技能
                    is_second_kill = true
                    hurt = -target_unit.attr_dict["hp"]
                    hurt = hurt == 0 and -1 or hurt
                    local real_hurt = target_unit:Hurt(hurt, self)
                    single_hurt = single_hurt + real_hurt
                    is_miss = false
                    is_crit = false
                end
                target_unit:SendEvent("SpellHit", i, hurt, is_crit, is_miss, is_second_kill)
            else
                target_unit:SendEvent("SpellHit", i, 0, is_crit, is_miss)
            end
        end
        total_hurt = total_hurt + single_hurt
        local rebound_hurt = target_unit:OnHit(-single_hurt)
        if rebound_hurt then
            -- 反伤
            table.insert(rebound_hurt_list, {rebound_hurt = rebound_hurt, unit = target_unit})
        end
        if is_miss then
            miss_unit_dict[target_unit.pos] = true
        end
    end
    if buff_info.suck_blood then
        -- 吸血
        local cure = math.floor(-total_hurt * buff_info.suck_blood * 0.01)
        cure = cure == 0 and 1 or cure
        self:Cure(cure)
        self:SendEvent("SpellHit", 1, cure)
    end
    for i, v in ipairs(rebound_hurt_list) do
        if not self:IsDeath() then
            self:Hurt(-v.rebound_hurt, v.unit)
            self:SendEvent("SpellHit", i, -v.rebound_hurt)
        end
    end
    self:ClearTempAttr(attack_target_list)

    if spell_data.add_buff_list then
        for i, buff_id in ipairs(spell_data.add_buff_list) do
            local add_buff_target_list = self:GetAddBuffTarget(spell_data.buff_object_list[i], attack_obj_by_pos)
            for _, target_unit in ipairs(add_buff_target_list) do
                if not miss_unit_dict[target_unit.pos] and (self.game.random:Random() <= spell_data.buff_random_list[i]) then
                    target_unit:AddBuff(buff_id, self)
                end
            end
        end
    end
    self:SendEvent("SpellEnd", spell.spell_id)

    if spell_data.reduce_anger then
        -- 技能减少怒气
        self:SpellReduceAnger(attack_target_list, spell_data)
    end
end

-- 根据攻击类型获取攻击目标
function Unit:GetAttackTarget(unit_list_by_pos, attack_type)
    local func = AttackTypeMap[attack_type]
    if func then
        return self[func](self, unit_list_by_pos)
    else
        error("unknown attack type :" .. attack_type)
    end
end

-- 全体攻击
function Unit:GetAttackTargetAll(unit_list_by_pos)
    local target_list = {}
    for pos, unit in ipairs(unit_list_by_pos) do
        if next(unit) and not unit:IsDeath() then
            table.insert(target_list, unit)
        end
    end
    return target_list
end

-- 怒气最高的N名敌人, 同怒气N名以上，优先同列
function Unit:GetAttackTargetAngerNum(unit_list_by_pos)
    local all_target_list = self:GetAttackTargetAll(unit_list_by_pos)
    if #all_target_list <= FConst.MaxAngerNum then
        return all_target_list
    end

    local unit_dict_by_anger = {}
    local max_anger = 0
    for _, unit in ipairs(unit_list_by_pos) do
        if next(unit) then
            if unit.anger > max_anger then
                max_anger = unit.anger
            end
            unit_dict_by_anger[unit.anger] = unit_dict_by_anger[unit.anger] or {}
            table.insert(unit_dict_by_anger[unit.anger], unit)
        end
    end
    local target_list = {}
    for anger = max_anger, 0, -1 do
        if unit_dict_by_anger[anger] then
            if #target_list + #unit_dict_by_anger[anger] > FConst.MaxAngerNum then
                local pos_list = self.game.battle_ground:GetColumnAttackPos(self.pos)
                for _, pos in ipairs(pos_list) do
                    local unit = unit_list_by_pos[pos]
                    if next(unit) and not unit:IsDeath() and unit.anger == anger then
                        table.insert(target_list, unit)
                        if #target_list >= FConst.MaxAngerNum then break end
                    end
                end
            else
                for _, unit in ipairs(unit_dict_by_anger[anger]) do
                    table.insert(target_list, unit)
                end
            end
            if #target_list >= FConst.MaxAngerNum then break end
        end
    end
    return target_list
end

-- 同列攻击
function Unit:GetAttackTargetColumn(unit_list_by_pos)
    local target_list = {}
    for _, pos in ipairs(self.game.battle_ground:GetTheSameColumn(self.pos)) do
        local unit = unit_list_by_pos[pos]
        if next(unit) and not unit:IsDeath() then
            table.insert(target_list, unit)
        end
    end

    if not next(target_list) then
        -- 同列全部死亡，随机相邻列
        local pos_list = self.game.battle_ground:GetNeighborColumn(self.pos)
        for _, pos in ipairs(pos_list) do
            local unit = unit_list_by_pos[pos]
            if next(unit) and not unit:IsDeath() then
                table.insert(target_list, unit)
            end
        end
        if not next(target_list) then
            -- 相邻列也全死亡，则取剩余的
            for _, unit in ipairs(unit_list_by_pos) do
                if next(unit) and not unit:IsDeath() then
                    table.insert(target_list, unit)
                end
            end
        end
    end
    return target_list
end

-- 前排攻击
function Unit:GetAttackTargetFrontRow(unit_list_by_pos)
    local target_list = {}
    local column_num = self.game.battle_ground:GetColumnNum()
    for pos = 1, column_num do
        local unit = unit_list_by_pos[pos]
        if next(unit) and not unit:IsDeath() then
            table.insert(target_list, unit)
        end
    end
    if not next(target_list) then
        -- 前排全部死亡，取后排
        for pos = column_num + 1, column_num + column_num do
            local unit = unit_list_by_pos[pos]
            if next(unit) and not unit:IsDeath() then
                table.insert(target_list, unit)
            end
        end
    end
    return target_list
end

-- 后排攻击
function Unit:GetAttackTargetBackRow(unit_list_by_pos)
    local target_list = {}
    local column_num = self.game.battle_ground:GetColumnNum()
    for pos = column_num + 1, column_num + column_num do
        local unit = unit_list_by_pos[pos]
        if next(unit) and not unit:IsDeath() then
            table.insert(target_list, unit)
        end
    end
    if not next(target_list) then
        -- 后排全部死亡，取前排
        for pos = 1, column_num do
            local unit = unit_list_by_pos[pos]
            if next(unit) and not unit:IsDeath() then
                table.insert(target_list, unit)
            end
        end
    end
    return target_list
end

-- 后排单体攻击
function Unit:GetAttackTargetBackOne(unit_list_by_pos)
    local pos_list = self.game.battle_ground:GetOneAttackPos(self.pos)
    for i = #pos_list, 1, -1 do
        for _, pos in ipairs(pos_list[i]) do
            local unit = unit_list_by_pos[pos]
            if next(unit) and not unit:IsDeath() then
                return {unit}
            end
        end
    end
    return {}
end

-- 前排单体攻击
function Unit:GetAttackTargetFrontOne(unit_list_by_pos)
    local pos_list = self.game.battle_ground:GetOneAttackPos(self.pos)
    for i = 1, #pos_list do
        for _, pos in ipairs(pos_list[i]) do
            local unit = unit_list_by_pos[pos]
            if next(unit) and not unit:IsDeath() then
                return {unit}
            end
        end
    end
    return {}
end

-- 随机N名敌人
function Unit:GetAttackTargetRandomNum(unit_list_by_pos)
    local all_target_list = self:GetAttackTargetAll(unit_list_by_pos)
    if #all_target_list <= FConst.AttackRandomNum then
        return all_target_list
    end

    local target_list = {}
    for i=1, FConst.AttackRandomNum do
        local index = self.game.random:RandomInt(1, #all_target_list)
        table.insert(target_list, all_target_list[index])
        table.remove(all_target_list, index)
    end
    return target_list
end

-- 同列单体攻击
function Unit:GetAttackTargetColumnOne(unit_list_by_pos)
    local pos_list = self.game.battle_ground:GetColumnAttackPos(self.pos)
    for _, pos in ipairs(pos_list) do
        local unit = unit_list_by_pos[pos]
        if next(unit) and not unit:IsDeath() then
            return {unit}
        end
    end
    return {}
end

-- 相邻攻击
function Unit:GetAttackTargetNeighbor(unit_list_by_pos)
    local unit_list = {}
    local pos = self.pos
    local column_num = self.game.battle_ground:GetColumnNum()
    pos = pos > column_num and pos - column_num or pos
    local pos_list = self.game.battle_ground:GetNeighborPos(pos)
    for _, pos_index in ipairs(pos_list) do
        local unit = unit_list_by_pos[pos_index]
        if next(unit) and not unit:IsDeath() then
            table.insert(unit_list, unit)
        end
    end
    if not next(unit_list) then
        -- 相邻位置全死，按顺序取下一个
        pos_list = nil
        local max_pos = self.game.battle_ground:GetMaxPos()
        for i = pos + 1, max_pos do
            local unit = unit_list_by_pos[i]
            if next(unit) and not unit:IsDeath() then
                pos_list = self.game.battle_ground:GetNeighborPos(i)
                break
            end
        end
        if not pos_list then
            -- 取剩余位置
            for i = 1, pos do
                local unit = unit_list_by_pos[i]
                if next(unit) and not unit:IsDeath() then
                    pos_list = self.game.battle_ground:GetNeighborPos(i)
                    break
                end
            end
        end
        for _, pos_index in ipairs(pos_list) do
            local unit = unit_list_by_pos[pos_index]
            if next(unit) and not unit:IsDeath() then
                table.insert(unit_list, unit)
            end
        end
    end
    return unit_list
end

-- 治疗我方生命最少的一个友军
function Unit:GetAttackTargetCureOne(unit_list_by_pos)
    local first_unit, target_unit
    for _, unit in ipairs(unit_list_by_pos) do
        if next(unit) and not unit:IsDeath() then
            if not first_unit then
                first_unit = unit
            end
            if unit.attr_dict["hp"] < unit.attr_dict["max_hp"] then
                -- 优先治疗不满血的
                if not target_unit or unit.attr_dict["hp"] < target_unit.attr_dict["hp"] then
                    target_unit = unit
                end
            end
        end
    end
    if target_unit then
        return {target_unit}
    else
        -- 全部满血则治疗第一个
        return {first_unit}
    end
end

-- 清除临时属性
function Unit:ClearTempAttr(attack_target_list)
    self.temp_attr_dict = {}
    for _, target_unit in pairs(attack_target_list) do
        target_unit.temp_attr_dict = {}
    end
end

-- 受击
function Unit:OnHit(hurt)
    local rebound_hurt
    for _, buff in pairs(self.buff_list) do
        local buff_data = DataMgr:GetBuffData(buff.buff_id)
        local buff_info = buff_data.attacked_do
        if buff_info then
            if self.game.random:Random() <= buff_data.trigger_rate then
                if buff_info.hp_recover then
                    -- 恢复生命
                    local cure = math.floor(self.attr_dict["max_hp"] * buff_info.hp_recover * 0.01)
                    cure = cure == 0 and 1 or cure
                    self:Cure(cure)
                    self:SendEvent("SpellHit", 1, cure)
                elseif buff_info.rebound_hurt then
                    -- 反弹伤害
                    rebound_hurt = math.floor(hurt * buff_info.rebound_hurt * 0.01)
                    rebound_hurt = rebound_hurt == 0 and 1 or rebound_hurt
                end
                self:SendEvent("TriggerBuff", buff.buff_id)
            end
        end
    end
    return rebound_hurt
end

-- 技能减少怒气
function Unit:SpellReduceAnger(attack_target_list, spell_data)
    for _, unit in pairs(attack_target_list) do
        if unit:IsImmune(FConst.BuffStateType.ReduceAnger, spell_data.reduce_anger_level) then
            -- 免疫减怒气
            unit:SendEvent("Immune", FConst.BuffStateType.ReduceAnger)
        else
            if not unit:IsDeath() and self.game.random:Random() <= spell_data.reduce_anger_ratio then
                unit:ChangeAnger(-spell_data.reduce_anger)
            end
        end
    end
end

-- 改变怒气
function Unit:ChangeAnger(anger_diff)
    self.anger = self.anger + anger_diff
    self.anger = self.anger < 0 and 0 or self.anger
    self:SendEvent("AngerChange", anger_diff)
end

-- 是否免疫
function Unit:IsImmune(state, reduce_anger_level)
    if state == FConst.BuffStateType.Vertigo then
        if self.monster_id and DataMgr:GetMonsterData(self.monster_id).is_immune then
            return true
        end
    elseif state == FConst.BuffStateType.ReduceAnger then
        if not self.monster_id then return end
        local data = DataMgr:GetMonsterData(self.monster_id)
        if data.is_immune and (data.reduce_anger_level or 0) >= (reduce_anger_level or 0) then
            return true
        end
    end
end
---------------------- 伤害相关 --------------------------------
function Unit:CanHurt()
    if self.state_dict[FConst.BuffStateType.Unmatched] then
        -- 存在无敌状态
        return false
    end
    return true
end

-- 计算伤害
function Unit:ComputeHurt(target_unit, hurt_rate, fixed_hurt, spell_attr_dict)
    local hit = self.attr_dict["hit"] + (spell_attr_dict["hit"] or 0) + (self.temp_attr_dict["hit"] or 0)
    local miss = target_unit.attr_dict["miss"] + (target_unit.temp_attr_dict["miss"] or 0)
    if miss >= hit or self.game.random:Random() > 0.01 * (hit - miss) then
        -- 未命中
        return 0, true, false
    end
    local att = self.attr_dict["att"] + (spell_attr_dict["att"] or 0) + (self.temp_attr_dict["att"] or 0)
    local add_hurt = 0.01 * ((self.attr_dict["add_hurt"] or 0) + (spell_attr_dict["add_hurt"] or 0) + (self.temp_attr_dict["add_hurt"] or 0))
    local add_final_hurt = 0.01 * ((self.attr_dict["add_final_hurt"] or 0) + (spell_attr_dict["add_final_hurt"] or 0) + (self.temp_attr_dict["add_final_hurt"] or 0))
    local def = target_unit.attr_dict["def"] + (target_unit.temp_attr_dict["def"] or 0)
    local hurt_def = 0.01 * ((target_unit.attr_dict["hurt_def"] or 0) + (target_unit.temp_attr_dict["hurt_def"] or 0))
    local final_hurt_def = 0.01 * ((target_unit.attr_dict["final_hurt_def"] or 0) + (target_unit.temp_attr_dict["final_hurt_def"] or 0))
    local hurt = (att - def) * (1 + add_hurt - hurt_def) * (1 + add_final_hurt - final_hurt_def) * hurt_rate + fixed_hurt
    local crit = self.attr_dict["crit"] + (spell_attr_dict["crit"] or 0) + (self.temp_attr_dict["crit"] or 0)
    local crit_def = target_unit.attr_dict["crit_def"] + (target_unit.temp_attr_dict["crit_def"] or 0)
    local is_crit = false
    if self.game.random:Random() <= 0.01 * (crit - crit_def) then
        -- 暴击
        is_crit = true
        hurt = hurt * FConst.CritHurtRate
    end
    hurt = math.floor(hurt)
    if hurt <= 1 then
        hurt = 1
    end
    return - hurt, false, is_crit
end

function Unit:Hurt(hp_diff, caster)
    hp_diff = math.floor(hp_diff)
    if hp_diff >= 0 then
        error("Hurt error")
    end
    local real_hurt = - hp_diff
    if self.attr_dict["hp"] + hp_diff < 0 then
        real_hurt = self.attr_dict["hp"]
    end
    self.attr_dict["hp"] = self.attr_dict["hp"] + hp_diff
    if self:IsDeath() then
        self.attr_dict["hp"] = 0
        self.buff_list = {}
        self.state_dict = {}
        self.anger = 0
    end
    caster.total_hurt = caster.total_hurt + real_hurt
    return -real_hurt
end

function Unit:IsDeath()
    return self.attr_dict["hp"] <= 0 and true or false
end

-- 计算治疗
function Unit:ComputeCure(target_unit, hurt_rate, fixed_hurt, spell_attr_dict)
    local att = self.attr_dict["att"] + (spell_attr_dict["att"] or 0) + (self.temp_attr_dict["att"] or 0)
    local add_hurt = 0.01 * ((self.attr_dict["add_hurt"] or 0) + (spell_attr_dict["add_hurt"] or 0) + (self.temp_attr_dict["add_hurt"] or 0))
    local add_final_hurt = 0.01 * ((self.attr_dict["add_final_hurt"] or 0) + (spell_attr_dict["add_final_hurt"] or 0) + (self.temp_attr_dict["add_final_hurt"] or 0))
    local cure = att * (1 + add_hurt) * (1 + add_final_hurt) * hurt_rate + fixed_hurt
    local crit = self.attr_dict["crit"] + (spell_attr_dict["crit"] or 0) + (self.temp_attr_dict["crit"] or 0)
    local is_crit = false
    if self.game.random:Random() <= 0.01 * crit then
        -- 暴击
        is_crit = true
        cure = cure * FConst.CritHurtRate
    end
    cure = math.floor(cure)
    if cure <= 1 then
        cure = 1
    end
    return cure, is_crit
end

function Unit:Cure(hp_diff)
    hp_diff = math.floor(hp_diff)
    if hp_diff <= 0 then
        error("Cure error")
    end
    local real_cure
    local max_hp = self.attr_dict["max_hp"]
    if self.attr_dict["hp"] + hp_diff > max_hp then
        real_cure = max_hp - self.attr_dict["hp"]
        self.attr_dict["hp"] = max_hp
    else
        real_cure = hp_diff
        self.attr_dict["hp"] = self.attr_dict["hp"] + hp_diff
    end
    return real_cure
end
-----------------------------------------------------------

---------------------- Buff相关 ---------------------------
local AddBuffMap = {
    [FConst.AddBuffType.Own] = "GetAddBuffTargetOwn",
    [FConst.AddBuffType.AttackTarget] = "GetAddBuffTargetAttack",
    [FConst.AddBuffType.OwnAll] = "GetAddBuffTargetOwnAll",
    [FConst.AddBuffType.EnemyAll] = "GetAddBuffTargetEnemyAll",
    [FConst.AddBuffType.RandomOwnOne] = "GetAddBuffTargetRandomOwnOne",
    [FConst.AddBuffType.RandomOwnTwo] = "GetAddBuffTargetRandomOwnTwo",
    [FConst.AddBuffType.RandomOwnThree] = "GetAddBuffTargetRandomOwnThree",
    [FConst.AddBuffType.RandomEnemyOne] = "GetAddBuffTargetRandomEnemyOne",
    [FConst.AddBuffType.RandomEnemyTwo] = "GetAddBuffTargetRandomEnemyTwo",
    [FConst.AddBuffType.RandomEnemyThree] = "GetAddBuffTargetRandomEnemyThree",
}

-- 获取Buff作用目标
function Unit:GetAddBuffTarget(object_type, attack_obj_by_pos)
    local func = AddBuffMap[object_type]
    if func then
        return self[func](self, attack_obj_by_pos)
    else
        error("unknown add buff object type :" .. object_type)
    end
end

-- Buff作用目标为自己
function Unit:GetAddBuffTargetOwn()
    if self:IsDeath() then
        return {}
    end
    return {self}
end

-- Buff作用目标为技能攻击目标
function Unit:GetAddBuffTargetAttack(attack_obj_by_pos)
    local target_list = {}
    local max_pos = self.game.battle_ground:GetMaxPos()
    for pos = 1, max_pos do
        local unit = attack_obj_by_pos[pos]
        if unit and not unit:IsDeath() then
            table.insert(target_list, unit)
        end
    end
    return target_list
end

-- Buff作用目标为己方全部对象
function Unit:GetAddBuffTargetOwnAll()
    local target_list = {}
    local unit_dict_by_side = self.game.unit_dict_by_side
    for pos, unit in ipairs(unit_dict_by_side[self.side]) do
        if next(unit) and not unit:IsDeath() then
            table.insert(target_list, unit)
        end
    end
    return target_list
end

-- Buff作用目标为敌方全部对象
function Unit:GetAddBuffTargetEnemyAll()
    local target_list = {}
    local other_side = self.game.battle_ground:GetOtherSide(self.side)
    local unit_dict_by_side = self.game.unit_dict_by_side
    for pos, unit in ipairs(unit_dict_by_side[other_side]) do
        if next(unit) and not unit:IsDeath() then
            table.insert(target_list, unit)
        end
    end
    return target_list
end

-- 随机己方N个目标
function Unit:GetAddBuffTargetRandomOwnN(num)
    local unit_list = self:GetAddBuffTargetOwnAll()
    if #unit_list <= num then
        return unit_list
    end
    local target_list = {}
    for i=1, num do
        local index = self.game.random:RandomInt(1, #unit_list)
        target_list[i] = unit_list[index]
        table.remove(unit_list, index)
    end
    return target_list
end

-- 随机己方1个目标
function Unit:GetAddBuffTargetRandomOwnOne()
    return self:GetAddBuffTargetRandomOwnN(1)
end

-- 随机己方2个目标
function Unit:GetAddBuffTargetRandomOwnTwo()
    return self:GetAddBuffTargetRandomOwnN(2)
end

-- 随机己方3个目标
function Unit:GetAddBuffTargetRandomOwnThree()
    return self:GetAddBuffTargetRandomOwnN(3)
end

-- 随机敌方N个目标
function Unit:GetAddBuffTargetRandomEnemyN(num)
    local unit_list = self:GetAddBuffTargetEnemyAll()
    if #unit_list <= num then
        return unit_list
    end
    local target_list = {}
    for i=1, num do
        local index = self.game.random:RandomInt(1, #unit_list)
        target_list[i] = unit_list[index]
        table.remove(unit_list, index)
    end
    return target_list
end

-- 随机敌方1个目标
function Unit:GetAddBuffTargetRandomEnemyOne()
    return self:GetAddBuffTargetRandomEnemyN(1)
end

-- 随机敌方2个目标
function Unit:GetAddBuffTargetRandomEnemyTwo()
    return self:GetAddBuffTargetRandomEnemyN(2)
end

-- 随机敌方3个目标
function Unit:GetAddBuffTargetRandomEnemyThree()
    return self:GetAddBuffTargetRandomEnemyN(3)
end

function Unit:AddBuff(buff_id, caster)
    if self:IsDeath() then return end
    local buff_data = DataMgr:GetBuffData(buff_id)
    local state = buff_data.begin_buff_do and buff_data.begin_buff_do.state
    if state and self:IsImmune(state) then
        -- 免疫该状态
        self:SendEvent("Immune", state)
        return
    end
    local remove_buff_list = {}
    if buff_data.override_id then
        -- 根据优先级去掉旧的同类buff
        for _, buff in ipairs(self.buff_list) do
            local data = DataMgr:GetBuffData(buff.buff_id)
            if buff_data.override_id == data.override_id then
                if buff_data.clear_level < data.clear_level then return end
                table.insert(remove_buff_list, buff.buff_id)
                break
            end
        end
    end
    if next(remove_buff_list) then
        self:RemoveBuff(remove_buff_list)
    end
    if not self:HasTheSameBuff(buff_id) then
        self:SendEvent("AddBuff", buff_id)
    end
    local new_buff = Buff.New(buff_id, self, caster)
    table.insert(self.buff_list, new_buff)
    local result, hp_diff, add_state = new_buff:BecomeEffective(FConst.ComputeBuffTime.BeginBuff)
    if result then
        self:SendEvent("TriggerBuff", new_buff.buff_id, hp_diff, add_state)
    end
end

-- 移除buff
function Unit:RemoveBuff(remove_buff_list)
    for _, buff_id in ipairs(remove_buff_list) do
        for i, buff in ipairs(self.buff_list) do
            if buff.buff_id == buff_id then
                local result, hp_diff, add_state = buff:BecomeEffective(FConst.ComputeBuffTime.EndBuff)
                if result then
                    self:SendEvent("TriggerBuff", buff.buff_id, hp_diff, add_state)
                end

                local remove_state = buff:BecomeInvalid()
                table.remove(self.buff_list, i)
                if not self:HasTheSameBuff(buff_id) then
                    self:SendEvent("RemoveBuff", buff.buff_id, remove_state)
                end
                break
            end
        end
    end
end

-- 结算buff
function Unit:ComputeBuff(compute_time)
    local remove_buff_list = {}
    for i, buff in ipairs(self.buff_list) do
        local result, hp_diff, add_state = buff:BecomeEffective(compute_time)
        if result then
            self:SendEvent("TriggerBuff", buff.buff_id, hp_diff, add_state)
            local buff_data = DataMgr:GetBuffData(buff.buff_id)
            if buff_data.do_and_remove and buff.round_num == 1 then
                -- 触发就移除
                table.insert(remove_buff_list, buff.buff_id)
            end
        end
        if self:IsDeath() then return end
    end
    if next(remove_buff_list) then
        self:RemoveBuff(remove_buff_list)
    end
end

-- 检查是否含有相同buff
function Unit:HasTheSameBuff(buff_id)
    for i, buff in ipairs(self.buff_list) do
        if buff_id == buff.buff_id then
            return true
        end
    end
    return false
end

-- 技能清除buff
function Unit:SpellClearBuff(attack_target_list, buff_clear_level)
    for _, unit in pairs(attack_target_list) do
        local remove_buff_list = {}
        for i, buff in ipairs(unit.buff_list) do
            local buff_data = DataMgr:GetBuffData(buff.buff_id)
            if buff_clear_level >= buff_data.clear_level then
                table.insert(remove_buff_list, buff.buff_id)
            end
        end
        if next(remove_buff_list) then
            unit:RemoveBuff(remove_buff_list)
        end
    end
end

-- 检查是否触发buff
function Unit:CheckIsTriggerBuff(attack_target_list)
    local ret = {}
    for _, buff in pairs(self.buff_list) do
        local buff_data = DataMgr:GetBuffData(buff.buff_id)
        local buff_info = buff_data.begin_attack_do
        if buff_info then
            if self.game.random:Random() <= buff_data.trigger_rate then
                local attr_name = buff_info.attr_name
                if attr_name then
                    -- 修改属性
                    if buff_info.object == FConst.Side.Own then
                        local value = (buff_info.attr_value or 0) + (self.unit.attr_dict[attr_name] or 0) * 0.01*(buff_info.attr_value_pct or 0)
                        self.temp_attr_dict[attr_name] = (self.temp_attr_dict[attr_name] or 0) + value
                    elseif buff_data.object_type == FConst.Side.Enemy then
                        for _, target_unit in ipairs(attack_target_list) do
                            local value = (buff_info.attr_value or 0) + (target_unit.attr_dict[attr_name] or 0) * 0.01*(buff_info.attr_value_pct or 0)
                            target_unit.temp_attr_dict[attr_name] = (target_unit.temp_attr_dict[attr_name] or 0) - value
                        end
                    end
                elseif buff_info.hurt_ratio then
                    -- 触发多倍伤害
                    ret.hurt_ratio = buff_info.hurt_ratio
                elseif buff_info.suck_blood then
                    -- 触发吸血
                    ret.suck_blood = buff_info.suck_blood
                end
                self:SendEvent("TriggerBuff", buff.buff_id)
            end
        end
    end
    return ret
end
-----------------------------------------------------------

return Unit