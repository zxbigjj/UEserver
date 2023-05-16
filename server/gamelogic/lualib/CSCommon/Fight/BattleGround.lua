local BattleGround = DECLARE_MODULE("CSCommon.Fight.BattleGround")

local FConst = require("CSCommon.Fight.FConst")

function BattleGround.New(random)
    local self = setmetatable({}, BattleGround)
    self.random = random
    self.column_num = FConst.BattleGround.ColumnNum
    self.row_num = FConst.BattleGround.RowNum
    return self
end

function BattleGround:GetMaxPos()
    return self.column_num * self.row_num
end

function BattleGround:GetColumnNum()
    return self.column_num
end

function BattleGround:GetRowNum()
    return self.row_num
end

-- 获取另一方阵营
function BattleGround:GetOtherSide(side)
    if side == FConst.Side.Own then
        return FConst.Side.Enemy
    else
        return FConst.Side.Own
    end
end

-- 获取相同列位置
function BattleGround:GetTheSameColumn(pos)
    local column_num = self.column_num
    if pos > column_num then
        return {pos - column_num, pos}
    else
        return {pos, pos + column_num}
    end
end

-- 随机获取相邻列位置
function BattleGround:GetNeighborColumn(pos)
    local column_num = self.column_num
    local random_pos
    if pos % column_num == 0 then
        random_pos = pos - 1
    elseif pos % column_num == 1 then
        random_pos = pos + 1
    else
        random_pos = self.random:RandomSelect({pos - 1, pos + 1})
    end
    return self:GetTheSameColumn(random_pos)
end

-- 获取列攻击位置顺序（先同列，再相邻）
function BattleGround:GetColumnAttackPos(pos)
    local temp_dict = {}
    local pos_list = {}
    for _, _pos in ipairs(self:GetTheSameColumn(pos)) do
        table.insert(pos_list, _pos)
        temp_dict[_pos] = true
    end
    for _, _pos in ipairs(self:GetNeighborColumn(pos)) do
        table.insert(pos_list, _pos)
        temp_dict[_pos] = true
    end
    local max_pos = self:GetMaxPos()
    for _pos = 1, max_pos do
        if not temp_dict[_pos] then
            table.insert(pos_list, _pos)
        end
    end
    return pos_list
end

-- 获取单体攻击位置顺序
function BattleGround:GetOneAttackPos(pos)
    local front_row_dict = {}
    local front_row_list = {}
    -- 同列
    local column_pos_list = self:GetTheSameColumn(pos)
    table.insert(front_row_list, column_pos_list[1])
    front_row_dict[column_pos_list[1]] = true
    -- 相邻
    local neighbor_pos_list = self:GetNeighborColumn(pos)
    table.insert(front_row_list, neighbor_pos_list[1])
    front_row_dict[neighbor_pos_list[1]] = true
    -- 取前排剩下的最后一个
    local column_num = self.column_num
    for _pos = 1, column_num do
        if not front_row_dict[_pos] then
            table.insert(front_row_list, _pos)
        end
    end

    local back_row_list = {}
    for i, _pos in ipairs(front_row_list) do
        back_row_list[i] = _pos + column_num
    end

    return {front_row_list, back_row_list}
end

-- 获取相邻列位置
function BattleGround:GetNeighborPos(pos)
    local pos_list = self:GetTheSameColumn(pos)
    local column_num = self.column_num
    local max_pos = self:GetMaxPos()
    if pos + 1 ~= column_num + 1 and pos + 1 ~= max_pos + 1 then
        table.insert(pos_list, pos + 1)
    end
    if pos - 1 ~= 0 and pos - 1 ~= column_num then
        table.insert(pos_list, pos - 1)
    end
    return pos_list
end

return BattleGround