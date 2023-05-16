local FConst = DECLARE_MODULE("CSCommon.Fight.FConst")

-- 最大回合数
FConst.MaxRound = 20

FConst.SpellTypeNum = 4

FConst.AttackRandomNum = 3

FConst.InitAnger = 2
FConst.MaxAngerNum = 3

-- 暴击增加伤害比率
FConst.CritHurtRate = 1.5

-- 阵营
FConst.Side = {
    Own = 1,
    Enemy = 2,
}

FConst.SpellAttackType = {
    All = 1,
    AngerNum = 2,
    Column = 3,
    FrontRow = 4,
    BackRow = 5,
    BackOne = 6,
    FrontOne = 7,
    RandomNum = 8,
    ColumnOne = 9,
    Neighbor = 10,
    CureOne = 11,
    ExtraCure = 12,
}

FConst.AddBuffType = {
    Own = 1,
    AttackTarget = 2,
    OwnAll = 3,
    EnemyAll = 4,
    RandomOwnOne = 5,
    RandomOwnTwo = 6,
    RandomOwnThree = 7,
    RandomEnemyOne = 8,
    RandomEnemyTwo = 9,
    RandomEnemyThree = 10,
}

-- 处理Buff时间
FConst.ComputeBuffTime = {
    BeginRound = 1,     -- 回合开始前
    EndRound = 2,       -- 回合开始后
    BeginBuff = 3,      -- 中buff时
    EndBuff = 4         -- buff消失时
}

-- Buff状态类型
FConst.BuffStateType = {
    Unmatched = 1,       -- 无敌
    Vertigo = 2,         -- 眩晕
    ReduceAnger = 3,     -- 减怒气
}

-- Buff类型
FConst.BuffType = {
    Add = 1,         -- 增益
    Sub = 2,         -- 减益
}

-- 技能作用阵营
FConst.SpellSideType = {
    Enemy = 1,
    Own = 2,
}

FConst.FightResult = {
    Win = 1,
    Fail = 2,
}

FConst.BattleGround = {
    ColumnNum = 3,
    RowNum = 2,
}

FConst.EventType = {
    RoundStart = "RoundStart",
    TriggerBuff = "TriggerBuff",
    RemoveBuff = "RemoveBuff",
    AddBuff = "AddBuff",
    RoundEnd = "RoundEnd",
    GameEnd = "GameEnd",
    SpellStart = "SpellStart",
    SpellHit = "SpellHit",
    SpellEnd = "SpellEnd",
    ComputeBuffStart = "ComputeBuffStart",
    ComputeBuffEnd = "ComputeBuffEnd",
}

FConst.SpellType = {
    Attack = 1,
    Spell = 2,
    TogetherSpell = 3,
    SuperTogetherSpell = 4,
}


return FConst