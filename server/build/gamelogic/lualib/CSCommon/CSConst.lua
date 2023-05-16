local CSConst = DECLARE_MODULE("CSCommon.CSConst")

CSConst.MaxIntNum = 2^54 - 1

CSConst.DefaultDiscount = 10

-- 参数定义和限制
CSConst.StCreateUnit = STRUCT(CSConst, "StCreateUnit", {
    "guid",
    "uuid",
    "unit_id",
    "unit_name",
    "position",
    "scale",
    "layer_name",
    "sorting_layer_name",
    "sort_order",
    "parent",
    "need_sync_load",
    "show_info",
    "hp",
    "max_hp",
    "anger",
    "is_flip_x",
    "color",
    "is_show_shadow",
    "is_3D_model",
    "is_stop_anim",
    "monster_id",
})

-- 系统解锁
CSConst.SystemId = {
    -- todo 增加不同系统id
    -- hunting = 1
}

-- 特效类型
CSConst.EffectType = {
    ET_UI = 1,
    ET_ToTarget = 2,
    ET_Bullet = 3,
    ET_3D = 4,
    ET_Line = 5,
}

CSConst.Virtual = {
    Exp = 101001,
    Money = 101002,
    Food = 101003,
    Soldier = 101004, -- 帮众
    Diamond = 101005,
    Potential = 101006, -- 潜能点
    HuntPoint = 101007,
    Prestige = 101008, -- 监狱 威望
    Intimacy = 101009, -- 亲密经验
    ArenaCoin = 101010, -- 竞技场货币
    ExperimentCoin = 101011, -- 试炼货币
    Dedicate = 101012, -- 王朝贡献
    TraitorCoin = 101016, -- 叛军货币(战功)
    GoldBar = 101017, -- 金条
    Crystal = 101019, -- 水晶
    ActivePoint = 101020, -- 日常活跃点 
    VIPExp = 101029, -- vip经验
    RechargeDrawIntegral = 101030, -- 充值抽奖活动积分
    Feats = 101031, -- 叛军功勋
}
--  行动力，精力等等
CSConst.CostValueItem = {
    ActionPoint = 101021,-- 行动点
    Vitality = 101022,  -- 竞技场 夺宝 消耗兴奋度
    Vigor    = 101023,  -- 精力值 宠爱翻牌子
    PhysicalPower = 101024,  -- 探访次数
    Mood = 101025,  -- 心情值 儿女教育
    Info = 101027,  -- 情报
    Cmd = 101028,  -- 命令
}

CSConst.UseItem = {
    ActionPoint = 201001,
    Vitality = 201002,
    Discuss = 201003,
}

-- 物品小类
CSConst.ItemSubType = {
    Exp = 101,              --经验
    Currency = 102,         --货币
    CostValue = 103,        --消耗数值
    CommonProp = 201,       --普通道具
    Present = 202,          --普通礼包
    SelectPresent = 203,    --多选一礼包
    RandomPresent = 204,    --随机礼包
    CommonStuff = 301,      --普通材料
    LoverStuff = 302,       --后宫材料
    AwakeStuff = 303,       --觉醒材料
    ActivityStuff = 304,    --活动材料
    Equipment = 401,        --装备
    EquipmentFragment = 402,--装备碎片
    Hero = 501,             --头目
    HeroFragment = 502,     --头目碎片
    PetProp = 601,          --宠物道具
    PetFragment = 602,      --宠物碎片
    Lover = 701,            --情人
    LoverFragment = 702,    --情人碎片
    RushActivityTitle = 801,-- 冲榜称号
    TimeLimitedTitle = 802, -- 限时称号
    PermanentTitle = 803,   -- 永久称号
}

-- 物品大类
CSConst.ItemType = {
    Default = 0,
    Virtual = 1,
    Prop = 2,
    Stuff = 3,
    Equip = 4,
    Hero = 5,
    Pet = 6,
    Lover = 7,
    Title = 8,
}

CSConst.HeroTag = {
    All = 0,
    Business = 1,
    Management = 2,
    Fame = 3,
    Fighting = 4,
    Power = 5,
}

CSConst.TrainEventState = {
    Finished = 1,
    Training = 2,
    Idle = 3,
}

CSConst.ChildSendRequest = {
    Service = 1,
    Assign = 2,
    Cross = 3,
}

CSConst.ChildCrossRequestItemCountRate = 2
CSConst.ChildRequestItemCounGoBackRate = 2
CSConst.ClothAttrListCount = 4
CSConst.ClothAttrIndexTb ={
    ["Ceremony"] = 1,
    ["Culture"] = 2,
    ["Charm"] = 3,
    ["Plan"] = 4,
}

CSConst.Sex = {
    Man = 1,
    Woman = 2,
}

CSConst.Hunt = {
    Crit = 1.5,      -- 暴击
    Cooldown = 3,    -- 射击冷却时间
    RankLen = 100,
}

-- 奖励状态 (integer)
CSConst.RewardState = {
    unpick = 0,      --不可领取
    pick = 1,        --可以领取
    picked = 2,      --已经领取
    luck_picked = 3, --幸运领取
}

-- 奖励状态 (boolean)
CSConst.RewardStatus = {
    cannot_receive = false, -- 不可领取
    can_receive = true, -- 可以领取
    received = nil, -- 已领取过
}

CSConst.VipGift = {
    SellGift = 1,      -- 特权礼包
    DailyGift = 2,     --日常礼包
}

CSConst.ShootResult = {
    Miss = 1,
    Hit = 2,
    Crit = 3,
    Reload = 4,
}

CSConst.AreaPriority = {
    ["亚洲"] = 3,
    ["美洲"] = 2,
    ["欧洲"] = 1,
}

CSConst.ChildStatus = {
    New = 1,
    Baby = 2,
    Growing = 3,
    Child = 4,
    Adult = 5,
    Married = 6,
}

CSConst.FuncUnlockType = {
    Level = 1,
    Vip = 2,
    VipOrLevel = 3,
    Event = 4,
}

CSConst.ConfirmStatus = {
    No = 0,
    Yes = 1,
}

CSConst.CityUnlockStatus = {
    No = 0,
    Yes = 1,
}

CSConst.DailyDareStatus = {
    Unlock = 0,         -- 已开放未解锁
    Unlocked = 1,       -- 已解锁未通关
    Passing = 2,        -- 通关
}

CSConst.NameLenLimit = 21

CSConst.Salon = {
    PvPScore = {10, 8, 6, 5, 4, 3, 2, 1, 0},
    PvPIntegral = {200, 120, 80, 60, 50, 40, 30, 20, 10},
    PvPAttrListCmp = {
        {"etiquette", true},
        {"culture", true},
        {"charm",true},
        {"planning", true},
    },
    PvPLoverInfoCmp = {
        {"grade", true},
        {"level", true},
    },
    Today = 1,
    Yesterday = 0,
}

CSConst.LineupMaxCount = 6

CSConst.SpellType = {
    General = 1,   -- 普攻
    Low = 2,       -- 一般技能
    High = 3,      -- 合体技能
}

CSConst.Stage = {
    MaxStar = 3,
    State = {
        New = 1,          --从未打过
        UnPass = 2,       --打过但是未通关
        FirstPass = 3,    --第一次通关
        Pass = 4,         --第二次以上通关
    }
}

CSConst.CityManager = {
    Hero = 1,
    Child = 2,
}

CSConst.DayHour = 24
CSConst.Time = {
    Minute = 60,
    Hour = 3600,
    Day = 86400,
}

CSConst.ChatType = {
    System = 1,
    World = 2,
    Cross = 3,   -- 跨服
    Dynasty = 4,   -- 王朝
    Private = 5,   -- 私聊
}

CSConst.ForceGuideNameList = {
    "FirstPlayGame",
}

CSConst.ForceGuideNumList = {
    5,
}

CSConst.EquipPartType = {
    Equip = 1,        -- 普通装备
    Treasure = 2,     -- 宝物装备
}

CSConst.RefineSpellType = {
    Attr = 1,
    Buff = 2,
}

CSConst.MasterEquipCount = {
    Equip = 4,
    Treasure = 2,
}

CSConst.StrengthenLimitRate = 2  --强化上限是人物等级2倍
CSConst.EquipMaxQuality = 6  --暗金品质
CSConst.LowestQuality = 1

CSConst.HeroTalentType = {
    OwnAttr = 1,
    AllAttr = 2,
}

CSConst.SmeltCritRate1 = 1.5
CSConst.SmeltCritRate2 = 2

CSConst.CultivateOperation = {
    Upgrade = 1,    -- 升级
    Break = 2,      -- 突破
    AddStar = 3,    -- 升星
    Destiny = 4,    -- 天命
    Cultivate = 5,  -- 培养
}

CSConst.EquipCultivateOperation = {
    Strengthen = 1, -- 强化
    Refine = 2,     -- 精炼
    LianHua = 3,    -- 炼化
    AddStar = 4,    -- 升星
}

CSConst.TreasureCultivateOperation = {
    Strengthen = 1, -- 强化
    Refine = 2,     -- 精炼
}

-- 指引类型type
CSConst.GuideType = {
    NewbieGuide = 1, -- 新手指引
    UnlockGuide = 2, -- 解锁指引
    EventGuide  = 3, -- 事件指引
}

-- 功能解锁id
CSConst.FuncUnlockId = {
    EquipIntensify = 6,
    HeroBreak = 8,
    EquipAddStar = 9,
    Travel = 10,                -- 秘密出行
    Hunting = 11,               -- 狩猎
    GodfatherHall = 14,         -- 教父殿堂
    Chat = 15,
    HeroAddStar = 18,
    DareTower = 21,             -- 挑战塔
    EquipRefine = 23,           -- 装备精炼
    HeroDestiny = 24,
    Traitor = 25,               -- 叛军系统
    TreasureRefine = 28,
    EquipSmelt = 32,
    HeroBattleThreeSpeed = 36,  -- 3倍速
    HeroBattleSkip = 43,        -- 跳过头目战斗
    OneKeyTurnCard = 45,        -- 一键翻牌
    BarQuickChallenge = 53,     -- 酒吧快速挑战
}

CSConst.ArenaRobotNum = 3000
CSConst.ArenaRankLen = 30
CSConst.ArenaTenRank = 10
CSConst.ArenaFrontNum = 8
CSConst.ArenaBackNum = 2
CSConst.ArenaChallengeLimit = 20

CSConst.SalonAreaState = {
    Idle = 1,   -- 等待游园
    Start = 2,  -- 游园开始
    End = 3,    -- 游园结束
}

CSConst.MailId = {
    Gm = 0,
    Hunt = 1,
    Hunt1 = 2,
    Arena = 3,
    DynastyOut = 4,
    DynastyIn = 5,
    DynastyJob = 6,
    CompeteDynasty = 7,
    CompeteRole = 8,
    Friend = 9,
    TraitorFeats = 10,
    TraitorHurt = 11,
    RushActivity = 12,
    TraitorBossDynastyRank = 13,
    CrossBossDynastyRank = 14,
    TraitorBossHonourRank = 15,
    TraitorBossHurtRank = 16,
    TraitorDiscover = 17,
    LuxuryCheckIn = 18,
    MonthlyCardReward = 19,
    AccumRechargeReward = 20,
    Questionnaire = 21,
    VipGiftReward = 22, -- vip礼包奖励
}

--提示类型
CSConst.NotifyType = {
    FloatWord = 1,    --飘字
    DialogBox = 2,    --弹框
}

CSConst.DynastyListPageNum = 10
CSConst.DynastyRankLen = 30
CSConst.DynastyJob = {
    GodFather = 1,
    SecondChief = 2,
    Member = 3
}
CSConst.DynastyChallenge = {
    Unopen = 1,
    Open = 2,
    Close = 3
}
CSConst.ChallengeSetting = {  -- 王朝挑战设置
    Reset = 1,         -- 重置
    Back = 2,          -- 回退
}
CSConst.DynastyTaskType = {
    Challenge = 1,
    Build = 2,
    DailyActive = 3,
    Compete = 4,
}
CSConst.CompeteRewardCondition = {
    One = 1,
    Two = 2,
    Three = 3
}
CSConst.CompeteDynastyRankLen = 20
CSConst.CompeteRoleRankLen = 100
CSConst.DynastyExpSpellId = 8
CSConst.DynastyBattleCompetiorCount = 3

CSConst.RoleRelation = {
    Stranger = 1,
    Friend = 2,
    Dynasty = 3, -- 王朝盟友
    Enemy = 4,
}

CSConst.Party = {
    InviteStatus = { -- nil 表示从未邀请​
        Wait = 1,
        No = 2,
        Yes = 3,
        RefuseNoNotice = 4,
    },
    PageSize = 5,
    EndType = {
        Normal = 1, -- 时间到了自动结束包括人数满了自动结束的10分钟
        HostEnd = 2, -- 玩家主动结束
        EnemyEnd = 3, -- 砸场子
    },
    InviteTarget = {
        Friend = 1, -- 好友
        Ally = 2, -- 盟友
    },
    FreeGiftId = 1
}
CSConst.PageRefreshTime = 5

CSConst.TraitorCostHalf = 0.5   -- 叛军消耗减半
CSConst.TraitorRewardDouble = 2   -- 叛军奖励翻倍
CSConst.TraitorAttackType = {  -- 叛军攻击类型
    One = 1,         -- 普通攻击
    Two = 2,         -- 全力一击
}
CSConst.TraitorBossThreeRank = 3
CSConst.TraitorBossButton = {
    Ok = 0,
    ServerDay = 1,
    FightScoreHurt = 2
}
CSConst.CrossTraitorBossPosNum = 5

CSConst.JumpUIId = {
    StrategyMap = 8,
}

CSConst.TaskType = {
    Cmd = 1,
    Info = 2,
    LoverNum = 3,
    LoverLevel = 4,
    LoverGrade = 5,
    Discuss = 6,
    Dote = 7,
    Stage = 8,
    StageStar = 9,
    Score = 10,
    FightScore = 11,
    Level = 12,
    HeroNum = 13,
    HeroLevel = 14,
    HeroBreak = 15,
    HeroDestiny = 16,
    LineUpHero = 17,
    ChildNum = 18,
    ChildTeach = 19,
    Marry = 20,
    HuntGround = 21,
    HuntNum = 22,
    RandomTravel = 23,
    AssignTravel = 24,
    ItemConsume = 25,
    WearEquipNum = 26,
    WearEquipStrengthen = 27,
    WearTreasureNum = 28,
    WearTreasureStrengthen = 29,
    ManageCity = 30,
    GrabTreasure = 31,
    TreasureCompose = 32,
    TrainStar = 33,
    DailyDare = 34,
    ArenaNum = 35,
    MoneyCmd = 36,
    FoodCmd = 37,
    SoldierCmd = 38,
    HeroBook = 39,
    HeroAllBook = 40,
    TorturePrison = 41,
}

CSConst.DailyActiveTaskType = {
   BuyEnergyNum = 1,            -- 商城中的啤酒购买
   BuyVitalityNum = 2,          -- 商城中的兴奋药购买
   TeachChildrenNum = 3,        -- 教导孩子
   HandleInfoNum = 4,           -- 处理情报
   PublishCmdConscriptNum = 5,  -- 征兵
   PublishCmdFoodNum = 6,       -- 征粮
   PublishCmdMoneyNum = 7,      -- 征钱
   HuntRareAnimalNum = 8,       -- 狩猎猛兽
   PunishPrisonerNum = 9,       -- 教育犯人
   DareTowerNum = 10,           -- 挑战塔通关
   TravelNum = 11,              -- 秘密探访
   DailyDareNum = 12,           -- 日常挑战
   StageNum = 13,               -- 黑帮混战
   TreasureNum = 14,            -- 黑市夺宝
   ResetTrialNum = 15,          -- 重置试炼
   ArenaNum = 16,               -- 地下黑拳
   WorshipNum = 17,             -- 教父殿堂膜拜
   DoteLoverNum = 18,           -- 宠幸情人
   TrainLoverNum = 19,          -- 培训中心
   JoinPartyNum = 20,           -- 参加宴会
   LevelUpNero = 21,            -- 升级英雄
   RandomDoteLoverNum = 22,     -- 情人随机约会
   ComposeTreasure = 23,        -- 宝物合成
   EquipStrength = 24,          -- 装备强化
   TreasureStrength = 25,       -- 宝物强化
   EquipRefine = 26,            -- 装备精炼
   SendFriendGift = 27,         -- 好友送兴奋度
   ChallengeTraitor = 28,       -- 叛军攻打
   ShareTraitor = 29,           -- 叛军分享
}

CSConst.FirstWeekTaskType = {
    LoginNum = 1,               -- 登陆
    HeroAttrScoreNum = 2,       -- 帮力达到
    PassCityNum = 3,            -- 通关关卡数
    EquipStrengthLevel = 4,     -- 玩家装备强化等级
    EquipRefineLevel = 5,       -- 玩家装备精炼等级
    TreasureStrengthNum = 6,    -- 玩家宝物强化
    TreasureRefineLevel = 7,    -- 玩家宝物精炼
    GrabNum = 8,                -- 夺宝次数
    TrainStarNum = 9,           -- 试炼累计获得星数
    ArenaNum = 10,              -- 竞技场次数
    DailyDareNum = 11,          -- 日常挑战次数
    DoteLoverNum = 12,          -- 情人约会次数
    ChildrenNum = 13,           -- 子女数量
    RandomDoteLoverNum = 14,    -- 随机约会次数
    PlayerLevel = 15,           -- 玩家等级达到
    FightScoreNum = 16,         -- 玩家战力达到
    DestinyLevel = 17,          -- 天命最高到达
    TraitorDamage = 18,         -- 叛军最高伤害
    TraitorFeats = 19,          -- 叛军累计最高功勋
    JoinDynasty = 20,           -- 进入或创建王朝
    DynastyBuild = 21,          -- 王朝高级建设
    DynastyChallenge = 22,      -- 王朝挑战次数
    HuntRareAnimal = 23,        -- 狩猎猛兽
    PassHuntStage = 24,         -- 通关狩猎场
    LoverTrain = 25,            -- 情人培训事件
    TravelNum = 26,             -- 出行次数
    ChildMarry = 27,            -- 儿女联姻
    LoverGrade = 28,            -- 情人妃位达到
}

CSConst.AchievementType = {
    RoleLevel = 1,
    StageStar = 2,
    FightScore = 3,
    HandleInfo = 4,
    PublishCmd = 5,
    Torture = 6,
    LoverNum = 7,
    LoverLevel = 8,
    HeroNum = 9,
    TravelNum = 10,
    HeroLevel = 11,
    HeroDestiny = 12,
    HeroEquip = 13,
    HeroTreasure = 14,
    TrainStar = 15,
    Vip = 16,
    TraitorKill = 17,
    Stage = 18,
    Marry = 19,
    Score = 20,
    Discuss = 21,
    Dote = 22,
    ChildNum = 23,
}

CSConst.RankId = {
    Hunt = 1,
    Arena = 2,
    Party = 3,
    Salon = 4,
    Train = 5,
    TraitorHurt = 6,
    TraitorFeats = 7,
    FightScore = 8,
    Score = 9,
    Level = 10,
    StageStar = 11,
    TraitorBossHonour = 13,
    TraitorBossHurt = 14,
    CrossTraitorHonour = 15,
    CrossTraitorHurt = 16,
    CrossHunt = 17,
}

CSConst.RankGroupId = {
    Traitor = 6,
}

CSConst.DaysInWeek = 7           -- 一个周最大7天

-- 新手指引，触发的事件类型
CSConst.GuideEventTriggerType = {
    GetFirstChild      = 1, -- 第一次生孩子
    GetFirstAdultChild = 2, -- 第一个儿女长大成人
    GetFirstPrisoner   = 4, -- 抓了第一个犯人
    GetFirstBeauty     = 5, -- 拥有第一个美人
}

-- 限时活动的类型 (ActivityDetailData，与 id 相同，物品消耗不用写)
CSConst.ActivityType = {
    LoginDays          = 1, -- 登录天数
    ConsumptionStamina = 2, -- 体力消耗
    GrowthScore        = 3, -- 帮力增长
    GrowthIntimacy     = 4, -- 亲密度增长
    ParticipateBanquet = 5, -- 宴会小游戏
    GrowthFightScore   = 9, -- 战力增长
}

CSConst.FriendError = {
    RepeatedFriend = 1,                   -- "已拥有的好友"
    MaxFriendCount = 2,                   -- "好友数量已达上限"
    MaxOtherFriendCount = 3,              -- "对方好友数量已达上限"
    MatchFailedFriendName = 4,            -- "没有找到名字匹配的好友"
}

CSConst.DynastyBattleRankListCode = {
    DynastyRank = 1,
    PersonalRank = 2,
    DynastyReward = 3,
    PersonalReward = 4,
}

CSConst.DynastybuildType = {
    Junior = 1,    -- 初级建设
    Middle = 2,    -- 中级建设
    High = 3,      -- 高级建设
}

-- 冲榜活动类型, 与 id 相同
CSConst.RushActivityType = {
    recharge   = 1,  -- 充值冲榜
    score      = 2,  -- 帮力冲榜
    ringleader = 6,  -- 头目冲榜
    checkpoint = 7,  -- 关卡冲榜
    intimacy   = 8,  -- 情人冲榜
    dynasty    = 11, -- 王朝冲榜
}

-- 冲榜活动排行榜nil替代值
CSConst.RushListActivityRankNil = -1

-- vip特权额外次数id
CSConst.VipPrivilege = {
    StageResetNum = 1,          -- boss关卡重置次数
    DareTowerNum = 2,           -- 名将副本
    DateLoverNum = 3,           -- 后宫翻牌子存储上限
    TravelNum = 4,              -- 出行次数存储上限
    ChildMaxVitalityNum = 5,    -- 儿女活力存储上限
    AssignTravelNum = 6,        -- 定向寻访次数
    GetChildPre = 7,            -- 生孩子概率
    LovershopRefresh = 8,       -- 情人商店刷新次数
    HeroshopRefresh = 9,        -- 头目商店刷新次数
}

-- 节日活动类型 (type_id)
CSConst.FestivalActivityType = {
    recharge      = 1,  -- 单笔充值
    login         = 2,  -- 每日登录
    train         = 3,  -- 试炼精英
    arena         = 4,  -- 竞技场
    stage         = 5,  -- 关卡boss
    dynasty       = 6,  -- 王朝挑战
    treasure      = 7,  -- 夺宝次数
    traitor       = 8,  -- 消灭叛军
    appointment   = 9,  -- 随机约会
    pettingLover  = 10, -- 宠幸次数
    loverTraining = 11, -- 情人培训
    travel        = 12, -- 出行次数
    educate       = 13, -- 儿女教育
}

-- 节日活动材料类型 (stuff_type)
CSConst.FestivalStuffType = {
    welfare = 1, -- 福利兑换材料
    luxury  = 2, -- 豪华兑换材料
}

CSConst.RoleAttrName = {
    Business = "business",
    Management = "management",
    Renown = "renown",
    Fight = "fight",
}

CSConst.NameLegalityErrorCode = {
    LengthLimit = 1,       -- 长度限制
    SpaceInBothEnd = 2,    -- 首尾空格
    SpaceInRow = 3,        -- 连续空格
    HasBadWord = 4,        -- 包含敏感字
}

CSConst.SalonActiveLoverGrade = 2

CSConst.TravelLuckType = {
    Weight_1 = 1,
    Weight_2 = 2,
}

CSConst.RechargeActivity = {
    SingleRecharge = 1,       -- 每日单冲活动
    WorthRecharge = 2,        -- 超值单冲活动
    RechargeDraw = 3,         -- 充值抽奖活动
    LuxuryCheckin = 4,        -- 豪华签到
    AccumeRecharge = 5,       -- 累充
}

CSConst.LimitActivityType = {
    Activity = 1,
    FirstRecharge = 2,
    DailyRecharge = 3,
    FestivalActivity = 4,
    FestivalExchange = 5,
    RechargeDraw = 6,
}

CSConst.kWelfareIndexDict = {
    StrengthenRecover = 1,  -- 定点体力
    ServerFund = 2,         -- 开服基金
    FirstWeekReward = 3,    -- 首周签到
    DailySell = 4,          -- 每日热卖
    WeekCheck = 5,          -- 每周签到
    MonthCheck = 6,         -- 每月签到
    MonthCard = 7,          -- 月卡
}

-- 活动状态，4 个时间点，5 个时间段，按时间顺序
-- start_ts -> stop_ts -> reserve_ts -> end_ts
CSConst.ActivityState = {
    nostart = 0, -- 未开始, start_ts 之前
    started = 1, -- 已开始, start_ts 和 stop_ts 之间
    stopped = 2, -- 已停止, stop_ts 和 reserve_ts 之间
    reserve = 3, -- 保留的, reserve_ts 和 end_ts 之间
    invalid = 4, -- 无效的, end_ts 之后
}

CSConst.ChatTips = {
    PlayerNotExist = 1,     -- 玩家不存在
    PlayerOffline = 2,      -- 玩家不在线
    BlackListFriend = 3,    -- 黑名单好友
    ForbidSpeak = 4,        -- 禁言
}
CSConst.AgreeApplyDynastyTips = {
    HasDynasty = 1,         -- 该成员已有王朝"
    NotInApplyDict = 2,     -- 玩家不在申请列表
    NotManager = 3,         -- 权限不足
}
CSConst.DynastyCompeteFightTips = {
    BuildingHasDestroy = 1,      -- 建筑已被攻破
    FightRoleHasKilled = 2,      -- 改玩家已被击杀
}
CSConst.TraitorTips = {
    HasDeath = 1,               -- 叛军已被击杀
}

-- 豪华签到重置周期, 1/7
CSConst.LuxuryCheckInResetCycle = {
    Daily  = 1, -- 每日重置
    Weekly = 7, -- 每周重置
}

-- 教父殿堂，称号历史获得者，最大记录数
CSConst.TitleMaxHistorySize = 20

CSConst.LogCoinName = {
    [CSConst.Virtual.Money] = "gold",
    [CSConst.Virtual.Diamond] = "diamond",
}

CSConst.CmdType = {
    Money = 1,
    Food = 2,
    Soldier = 3,
}

CSConst.HyperLinkType = {
    BattleReport = 1,
}

-- 月卡类型
CSConst.MonthlyCardType = {
    MonthlyCard = 1, -- 月卡
    PermanentCard = 2, -- 永久卡
}

CSConst.OperateType = {
    Add = 1,
    Del = 2,
    Clear = 3,
    Update = 4,
    Init = 5,
}

CSConst.CilentProcessType = {
    STARTTRAN_SDKINIT_SUCCEED = "START_TRAN_SDKINIT_SUCCEED",                                  --SDK初始化成功
    STARTTRAN_REQUEST_VERSION_CONTROL_SUCCEED = "STARTTRAN_REQUEST_VERSION_CONTROL_SUCCEED",   --请求版控文件成功
    STARTTRAN_REQUEST_VERSION_CONTROL_FAIL = "STARTTRAN_REQUEST_VERSION_CONTROL_FAIL",         --请求版控文件失败
    STARTTRAN_START_HOT_UPDATE = "STARTTRAN_START_HOT_UPDATE",                                 --开始热更新
    STARTTRAN_UPDATE_SUCCEED_RESTART = "STARTTRAN_UPDATE_SUCCEED_RESTART",                     --更新完成重启
    STARTTRAN_INIT_SUCCEED = "STARTTRAN_INIT_SUCCEED",                                         --初始化完成
    STARTTRAN_GET_SERVER_LIST = "STARTTRAN_GET_SERVER_LIST",                                   --获取服务器列表
    STARTTRAN_GET_SERVER_LIST_SUCCEED = "STARTTRAN_GET_SERVER_LIST_SUCCEED",                   --获取服务器列表成功
    STARTTRAN_GET_SERVER_LIST_FAIL = "STARTTRAN_GET_SERVER_LIST_FAIL",                         --获取服务器列表失败
    STARTTRAN_SDK_LOGIN = "STARTTRAN_SDK_LOGIN",                                               --SUPERSDK开始登陆
    STARTTRAN_SDK_LOGIN_SUCCEED = "STARTTRAN_SDK_LOGIN_SUCCEED",                               --SUPERSDK登陆成功
    STARTTRAN_SDK_LOGIN_FAIL = "STARTTRAN_SSDK_LOGIN_FAIL",                                    --SUPERSDK登陆失败


    NOVICE_GET_PET = "NOVICE_GET_PET",
    NOVICE_GUESSING_RIDDLE = "NOVICE_GUESSING_RIDDLE",
    NOVICE_INLAY_GUIDE_BEGIN = "NOVICE_INLAY_GUIDE_BEGIN",                 --妖魂引导开始
    NOVICE_INLAY_GUIDE_END = "NOVICE_INLAY_GUIDE_END",                     --妖魂引导结束

    NOVICE_CUTSCENES_RUCHANG = "1_NOVICE_CUTSCENES_RUCHANG",                 --入场过场动画
    NOVICE_CUTSCENES_XUANCHONG = "2_NOVICE_CUTSCENES_XUANCHONG",             --选宠过场动画
    NOVICE_CUTSCENES_CHUANSONG = "3_NOVICE_CUTSCENES_CHUANSONG",             --传送过场动画
    NOVICE_CUTSCENES_JIUJIUCHUCHANG = "4_NOVICE_CUTSCENES_JIUJIUCHUCHANG",   --青鸾出场动画
    NOVICE_CUTSCENES_CHAKANYIFU = "5_NOVICE_CUTSCENES_CHAKANYIFU",           --查看衣服过场动画
    NOVICE_CUTSCENES_YAOHUNLAIXI = "6_NOVICE_CUTSCENES_YAOHUNLAIXI",         --妖鲲来袭过场动画
    NOVICE_CUTSCENES_SHENGQIAO = "7_NOVICE_CUTSCENES_SHENGQIAO",             --升桥过场动画
    NOVICE_CUTSCENES_DIAOXIAQIAO = "8_NOVICE_CUTSCENES_DIAOXIAQIAO",         --妖鲲袭击，掉下桥过场动画
    NOVICE_CUTSCENES_CHURU_JITAN = "9_NOVICE_CUTSCENES_CHURU_JITAN",         --进入祭坛过场动画
    NOVICE_CUTSCENES_SHENRU_JITAN = "10_NOVICE_CUTSCENES_SHENRU_JITAN",       --深入祭坛过场动画
    NOVICE_CUTSCENES_JIESHU = "11_NOVICE_CUTSCENES_JIESHU",                   --结束新手场景过场动画

    NOVICE_CAPTURE_HUANGNIU = "NOVICE_CAPTURE_HUANGNIU",                   --吸妖黄牛怪
    NOVICE_CAPTURE_TAOTIE = "NOVICE_CAPTURE_TAOTIE",                       --吸妖饕餮
}

-- 酒吧类型
CSConst.BarType = {
    Hero  = 1, -- 英雄
    Lover = 2, -- 情人
}

CSConst.RedPointType = {
    Normal = 1,
    Number = 2,
    Bubble = 3,
    HighLight = 4
}

CSConst.RedPointControlIdDict = {
    NightClub = {
        Break = 3,          --突破
        LevelUp = 20,       --升级
        Destiny = 21,       --潜能（天命）
        AddStar = 22,       --升星
    },
    LoverRandomDate = 13,   --情人随机约会
    LoverSkill = 18,        --情人技能可升级
    LoverStar = 19,         --情人可升星
    LineUp = 23,            --阵容
    ReplaceEquip = 24,      --有更高品质的装备可以替换
    DailyActiveTask = 25,   --每日目标任务完成
    DailyActiveChest = 26,  --每日目标宝箱可领取
    Achievement = 27,       --成就完成
    Welfare = {             --福利
        Strength = 28,      --定点体力
        ServerFund = 29,    --开服基金
        FundWelfare = 30,   --全民福利
        FirstWeek = 31,     --首周签到
        MonthCheck = 32,    --每月签到
        WeekCheck = 33,     --每周签到
        MonthCard = 34,     --月卡
    },
    Dynasty = {
        Apply = 17,         --王朝申请
        Build = 35,         --王朝建设
        Active = 36,        --王朝活跃
        Learn = 37,         --科研所学习
        Challenge = 50,     --王朝挑战
        Battle = 51,        --王朝争霸
        BattleReward = 52,  --王朝争霸奖励
    },
    Friend = {
        Apply = 6,          --好友申请
        Present = 7,        --好友赠送兴奋度
    },
    Decompose = {           --分解
        Equipment = 8,      --装备
        HeroFragment = 9,   --头目碎片
        LoverFragment = 10, --情人碎片
    },
    ManagementCenter = 11,  --情人册封
    TrainingCenter = 15,    --情人交际
    Salon = 16,             --沙龙
    Child = {
        Marry = 12,         --提亲请求
        Raising = 14,       --抚养孩子
    },
    Prison = 38,            --监狱
    Travel = 39,            --出行
    Playment = {            --黑道挑战玩法
        GrabTreasure = 40,  --黑市夺宝
        DareTower = 41,     --挑战塔
        DaliyBattle = 42,   --混乱区域
        Traitor = 43,       --对抗特工
        TraitorReward = 44, --特工奖励
        TraitorBoss = 45,   --王牌特工
        BossReward = 46,    --王牌特工奖励
    },
    Hunting = {
        Reward = 47,        --首通奖励可领取
        Rare = 48,          --猎杀猛兽
    },
    VIPGift = 53,           --VIP日常礼包
}

CSConst.Activities = {
    Pack = {
        Lover = 1,          -- 情人礼包
        Hero = 2,           -- 英雄礼包
    },
    LoverPack = {           -- 情人礼包礼物类型
        Video = 0,          -- 写真
        Pieces = 1,         -- 碎片(时装)
    }
}

return CSConst