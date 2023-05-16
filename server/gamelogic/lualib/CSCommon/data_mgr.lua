local data_mgr = DECLARE_MODULE("CSCommon.data_mgr")

data_mgr._excel_mapper = {
    AttributeData =         "AttributeData",
    EffectData =            "EffectData",
    ExpData =               "ExpData",
    GradeData =             "GradeData",
    HeroData =              "HeroData",
    IconData =              "IconData",
    InfoData =              "InfoData",
    InfoRewardData =        "InfoRewardData",
    ItemData =              "ItemData",
    ItemParentTypeData =    "ItemParentTypeData",
    QualityData =           "QualityData",
    ItemTypeData =          "ItemTypeData",
    LoverData =             "LoverData",
    LevelData =             "LevelData",
    LevyData =              "LevyData",
    SoundData =             "SoundData",
    SoundTempData =         "SoundTempData",
    UnitData =              "UnitData",
    PowerData =             "PowerData",
    LoverLevelData =        "LoverLevelData",
    LoverSpellData =        "LoverSpellData",
    SpellData =             "SpellData",
    AttributeItemData =     "AttributeItemData",
    TalentData =            "TalentData",
    ChildQualityData =      "ChildQualityData",
    ChildExpData =          "ChildExpData",
    ChildAptitudeDripData = "ChildAptitudeDripData",
    ChildGridData =         "ChildGridData",
    TrainEventData =        "TrainEventData",
    EventGridData =         "EventGridData",
    ParamData =             "ParamData",
    UIContentData =         "UIContentData",
    HuntGroundData =        "HuntGroundData",
    RareAnimalData =        "RareAnimalData",
    DropData =              "DropData",
    DropGroupData =         "DropGroupData",
    HuntShopData =          "HuntShopData",
    ServerData =            "ServerData",
    PartitionData =         "PartitionData",
    HuntInspireData =       "HuntInspireData",
    AddRareAnimalData =     "AddRareAnimalData",
    PrisonData =            "PrisonData",
    TortureData =           "TortureData",
    BuffData =              "BuffData",
    VictoryData =           "VictoryData",
    DialogData =            "DialogData",
    RewardData =            "RewardData",
    GrowData =              "GrowData",
    GrowConstData =         "GrowConstData",
    StageData =             "StageData",
    LineupUnlockData =      "LineupUnlockData",
    RoleLookData =          "RoleLookData",
    SoldierModelData =      "SoldierModelData",
    MapPosData =            "MapPosData",
    FateData =              "FateData",
    SuitData =              "SuitData",
    ItemAccessData =        "ItemAccessData",
    BagSortTypeData =       "BagSortTypeData",
    CityData =              "CityData",
    CountryData =           "CountryData",
    StageResetData =        "StageResetData",
    MonsterData =           "MonsterData",
    MonsterGroupData =      "MonsterGroupData",
    MonsterRateData =       "MonsterRateData",
    MonsterBaseAttr =       "MonsterBaseAttr",
    SoldierLostLevelData =  "SoldierLostLevelData",
    NameData =              "NameData",
    ForceGuideData =        "ForceGuideData",
    FuncGuideData =         "FuncGuideData",
    FuncUnlockData =        "FuncUnlockData",
    TagData =               "TagData",
    MailData =              "MailData",
    TravelAreaData =        "TravelAreaData",
    TravelEventData =       "TravelEventData",
    LuckValueIconData =     "LuckValueIconData",
    LoverMeetData =         "LoverMeetData",
    LuckDescData =          "LuckDescData",
    LuckData =              "LuckData",
    EquipPartData =         "EquipPartData",
    StrengthenLvData =      "StrengthenLvData",
    RefineLvData =          "RefineLvData",
    RefineSpellData =       "RefineSpellData",
    EquipSmeltData =        "EquipSmeltData",
    ESmasterData =          "ESmasterData",
    TSmasterData =          "TSmasterData",
    ERmasterData =          "ERmasterData",
    TRmasterData =          "TRmasterData",
    DailyDareData =         "DailyDareData",
    SalonAreaData =         "SalonAreaData",
    SalonRobotData =        "SalonRobotData",
    HeroBreakLvData =       "HeroBreakLvData",
    HeroDestinyData =       "HeroDestinyData",
    ChildNameData =         "ChildNameData",
    HeroRobotData =         "HeroRobotData",
    RobotLineupData =       "RobotLineupData",
    ArenaData =             "ArenaData",
    ArenaWinNumData =       "ArenaWinNumData",
    ArenaIntervalData =     "ArenaIntervalData",
    ArenaTalkData =         "ArenaTalkData",
    MarryExpendData =       "MarryExpendData",
    SysUnlockData =         "SysUnlockData",
    RobotNameData =         "RobotNameData",
    TrainData =             "TrainData",
    TrainLayerData =        "TrainLayerData",
    TrainItemData =         "TrainItemData",
    TrainResetData =        "TrainResetData",
    TrainCritData =         "TrainCritData",
    TrainAttrData =         "TrainAttrData",
    TrainWarData =          "TrainWarData",
    TrainWarNumData =       "TrainWarNumData",
    TrainTalkData =         "TrainTalkData",
    DareDifficultData =     "DareDifficultData",
    ChildDialogData =       "ChildDialogData",
    PartyData =             "PartyData",
    PartyGiftData =         "PartyGiftData",
    PartyGameData =         "PartyGameData",
    RateData =              "RateData",
    SmeltRateDescData =     "SmeltRateDescData",
    DynastyData =           "DynastyData",
    DynastyJobData =        "DynastyJobData",
    DynastyBadgeData =      "DynastyBadgeData",
    DareTowerData =         "DareTowerData",
    TrainShopData =         "TrainShopData",
    ArenaShopData =         "ArenaShopData",
    DynastyBuildData =      "DynastyBuildData",
    ProgressRewardData =    "ProgressRewardData",
    DynastyTaskData =       "DynastyTaskData",
    DynastyTaskTypeData =   "DynastyTaskTypeData",
    DynastyActiveRewardData = "DynastyActiveRewardData",
    DynastySpellData =      "DynastySpellData",
    DynastyChallengeData =  "DynastyChallengeData",
    ChallengeJanitorData =  "ChallengeJanitorData",
    ChallengeNumData =      "ChallengeNumData",
    DynastyBuildingData =   "DynastyBuildingData",
    CompeteNumData =        "CompeteNumData",
    CompeteRewardData =     "CompeteRewardData",
    CompeteRankData =       "CompeteRankData",
    MailTypeData =          "MailTypeData",
    TraitorData =           "TraitorData",
    TraitorRewardData =     "TraitorRewardData",
    TraitorShopData =       "TraitorShopData",
    TaskGroupData =         "TaskGroupData",
    TaskTypeData =          "TaskTypeData",
    TaskData =              "TaskData",
    AchievementData =       "AchievementData",
    AchievementTypeData =   "AchievementTypeData",
    CheckInMonthlyData =    "CheckInMonthlyData",
    CheckInWeeklyData =     "CheckInWeeklyData",
    BehaviorPointData =     "BehaviorPointData",
    CityMapTypeData =       "CityMapTypeData",
    PlayerHeroData =        "PlayerHeroData",
    ShopData =              "ShopData",
    SalonShopData =         "SalonShopData",
    PartyShopData =         "PartyShopData",
    EventTriggerData =      "EventTriggerData",
    ActivityData =          "ActivityData",
    ActivityGroupData =     "ActivityGroupData",
    ActivityDetailData =    "ActivityDetailData",
    ActivityRewardData =    "ActivityRewardData",
    DailyActiveData =       "DailyActiveData",
    DailyActiveTypeData =   "DailyActiveTypeData",
    DailyActiveChestData =  "DailyActiveChestData",
    FirstWeekData =         "FirstWeekData",
    FirstWeekTaskData =     "FirstWeekTaskData",
    FirstWeekSellData =     "FirstWeekSellData",
    TreasureBoxData =       "TreasureBoxData",
    RankData =              "RankData",
    TotalRankData =         "TotalRankData",
    RechargeData =          "RechargeData",
    VipData =               "VipData",
    VIPShopData =           "VIPShopData",
    VIPPrivilegeData =      "VIPPrivilegeData",
    NormalShopData =        "NormalShopData",
    TotalRankData =         "TotalRankData",
    VipData =               "VipData",
    RushActivityData =      "RushActivityData",
    RushRewardData =        "RushRewardData",
    RushItemData =          "RushItemData",
    CrystalShopData =       "CrystalShopData",
    BubbleDialogData =      "BubbleDialogData",
    LoverShopData =         "LoverShopData",
    FestivalGroupData =     "FestivalGroupData",
    FestivalActivityData =  "FestivalActivityData",
    FestivalContentData =   "FestivalContentData",
    FestivalContentTypeData = "FestivalContentTypeData",
    FestivalDiscountData =  "FestivalDiscountData",
    FestivalExchangeData =  "FestivalExchangeData",
    FestivalExchangeTypeData = "FestivalExchangeTypeData",
    FestivalRewardData =    "FestivalRewardData",
    InfiMapBuildNameData =  "InfiMapBuildNameData",
    DeinforcementsData =    "DeinforcementsData",
    HeroShopData =          "HeroShopData",
    RechargeActivityData =  "RechargeActivityData",
    SingleRechargeData =    "SingleRechargeData",
    WorthRechargeData =     "WorthRechargeData",
    RechargeDrawData =      "RechargeDrawData",
    ActionPointData =       "ActionPointData",
    OpenServiceFundData =   "OpenServiceFundData",
    OpenServiceRewardData = "OpenServiceRewardData",
    OpenServiceWelfareData= "OpenServiceWelfareData",
    MainScenceShopData =    "MainScenceShopData",
    TraitorBossData =       "TraitorBossData",
    TraitorBossCritData =   "TraitorBossCritData",
    TraitorBossRewardData = "TraitorBossRewardData",
    TraitorBossCNData =     "TraitorBossCNData",
    CrossTraitorBossData =  "CrossTraitorBossData",
    TLActivityData =        "TLActivityData",
    DynastyHonourRankData = "DynastyHonourRankData",
    RedPointControlData =   "RedPointControlData",
    RedPointData =          "RedPointData",
    RedPointTypeData =      "RedPointTypeData",
    UIGameObjectPathData =  "UIGameObjectPathData",
    TranslationData =       "TranslationData",
    GotoUIData =            "GotoUIData",
    CityBuildTypeData =     "CityBuildTypeData",
    SkinData =              "SkinData",
    CutSceneCaptionData =   "CutSceneCaptionData",
    -- LuxuryCheckInData =     "LuxuryCheckInData",
    LuxuryCheckInResetCycleData = "LuxuryCheckInResetCycleData",
    DailyRechargeData =     "DailyRechargeData",
    SalonDialogData =       "SalonDialogData",
    DynastyChallengeMapData = "DynastyChallengeMapData",
    BattleScenceData =      "BattleScenceData",
    BattleBgData =          "BattleBgData",
    DrawShopData =          "DrawShopData",
    BeforeGuideHideUIData = "BeforeGuideHideUIData",
    WelfareData =           "WelfareData",
    WelfareTypeData =       "WelfareTypeData",
    MonthlyCardData =       "MonthlyCardData",
    FlagData =              "FlagData",
    ChildDisplayData =      "ChildDisplayData",
    BarLoverData =          "BarLoverData",
    BarHeroData =           "BarHeroData",
    LanguageData =          "LanguageData",
    BadWordData =           "BadWordData",
    SpaceWordData =         "SpaceWordData",
}

data_mgr.IS_CLIENT = false

function data_mgr:ClearAll()
end

function data_mgr:DoDestroy()
    self:ClearAll()
end

function data_mgr:GetAllHeroDataWithTag()
    return self:GetHeroData("hero_list")
end

function data_mgr:GetAllHeroDataWithPower()
    return self:GetHeroData("power_list")
end

function data_mgr:GetPowerList()
    return self:GetPowerData("power_list")
end

-- 通过大区表中的大区id获取该大区的服务器列表
function data_mgr:GetServerListByPartitionId(partition_id)
    return self:GetServerData("server_list")[partition_id]
end
-- 获取大洲的所有大区信息
function data_mgr:GetPartitionListByArea(area)
    return self:GetPartitionData("partition_list")[area]
end
-- 获取所有洲的大区信息
function data_mgr:GetAreaData()
    return self:GetPartitionData("partition_list")
end

-- 获取对话内容
function data_mgr:GetDialogGroupData(dialog_group_id)
    return self:GetDialogData("dialog_group")[dialog_group_id]
end

-- 获取 该国家下的所有城市
function data_mgr:GetCityListByCountryId(country_id)
    return self:GetCityData("country_dict")[country_id]
end

function data_mgr:GetAllCityNum()
    return #self:GetAllCityData()
end
-- 获取 该城市下的所有关卡
function data_mgr:GetStageListByCityId(city_id)
    return self:GetStageData("city_dict")[city_id]
end
-- 获取 城市最大星星数
function data_mgr:GetCityMaxStarNumByCityId(city_id)
    return self:GetStageData("city_max_star_num")[city_id]
end

-- 获取 城市下所有头目关卡列表
function data_mgr:GetCityBossStageListByCityId(city_id)
    return self:GetStageData("city_boss_stage")[city_id]
end

-- 获取 强制指引 指引id列表
function data_mgr:GetForceGuideIdListByGuideGroupId(group_id)
    return self:GetForceGuideData("guide_group_list")[group_id]
end

-- 获取 功能指引 指引id列表
function data_mgr:GetFuncGuideIdListByGuideGroupId(group_id)
    return self:GetFuncGuideData("func_guide")[group_id]
end

function data_mgr:GetCityTravelEventList(city_id)
    return self:GetTravelEventData("city_event")[city_id]
end

function data_mgr:GetLoverMeetEventList(lover_id)
    return self:GetLoverMeetData("meet_list")[lover_id]
end

function data_mgr:GetRecoverLuckCostData(item_id)
    return self:GetLuckData("cost_list")[item_id]
end

function data_mgr:GetAIData(ai_name)
    return require("Data.AI.ai_" .. ai_name)
end

function data_mgr:GetParentTypeListInBag()
    return self:GetBagSortTypeData("bag_sort_type_list")
end

function data_mgr:GetChildNameListBySex(sex)
    if sex == CSConst.Sex.Man then
        return self:GetChildNameData("boy_name_list")
    elseif sex == CSConst.Sex.Woman then
        return self:GetChildNameData("girl_name_list")
    end
end

function data_mgr:GetHeroBreakLvList()
    return self:GetHeroBreakLvData("break_lv_list")
end

function data_mgr:GetHeroDestinyLvList()
    return self:GetHeroDestinyData("destiny_lv_list")
end

function data_mgr:GetUnlockFeatureList(level)
    return self:GetFuncUnlockData("sys_unlock_list")
end

function data_mgr:GetEquipmentRefineLvList()
    return self:GetRefineLvData("equipment_refine_list")
end

function data_mgr:GetTreasureRefineLvList()
    return self:GetRefineLvData("treasure_refine_list")
end

function data_mgr:GetDyanstyTaskList()
    return self:GetDynastyTaskData("dynasty_task_list")
end

function data_mgr:GetShowActivityList()
    return self:GetActivityData("show_activity_list")
end

function data_mgr:GetChildSystemData(parent)
    return self:GetBubbleDialogData("child_system_dict")[parent]
end

function data_mgr:GetRoleInfoItemList()
    return self:GetItemData("info_item_list")
end

function data_mgr:GetMaleRoleList()
    return self:GetRoleLookData("male_role_list")
end

function data_mgr:GetFemaleRoleList()
    return self:GetRoleLookData("female_role_list")
end

function data_mgr:GetAllAttrItemList()
    return self:GetItemData("attr_item_list")
end

function data_mgr:GetAttrItemListWithType(attr_type)
    return self:GetItemData("attr_item_list")[attr_type]
end

function data_mgr:GetPlaymentList()
    return self:GetFuncUnlockData("playment_list")
end

function data_mgr:GetSoundId(sound_name)
    return self:GetParamData(sound_name).sound_id
end

function data_mgr:GetCityIncomeAttrList()
    return self:GetAttributeData("city_income_attr_list")
end

function data_mgr:GetFuncUnlockVipLevel(func_id)
    return self:GetFuncUnlockData("func_to_vip_level")[func_id] or 0
end

function data_mgr:GetCutSceneCaptionList()
    return self:GetCutSceneCaptionData("cut_scene_caption_list")
end

function data_mgr:GetDynastyChallengeMapList()
    return self:GetDynastyChallengeMapData("challenge_map_list")
end

-- 敏感字屏蔽
function data_mgr:CheckHasBadWord(str)
    if not data_mgr.IS_CLIENT then return end
    self:CheckProcessBadWord()
    local word_list = UTF8.Split(str)
    local n = #word_list
    for i = 1, n do
        if self:_MatchBarWord(word_list, i, n) then
            return true
        end
    end
    return false
end

function data_mgr:FilterBadWord(str)
    self:CheckProcessBadWord()
    local replace_str = "***"
    local word_list = UTF8.Split(str)
    local n = #word_list
    local new_word_list = {}
    local i = 1
    while i <= n do
        local match_index = self:_MatchBarWord(word_list, i ,n)
        if match_index then
            table.insert(new_word_list, replace_str)
            i = match_index + 1
        else
            table.insert(new_word_list, word_list[i])
            i = i + 1
        end
    end
    return table.concat(new_word_list)
end

function data_mgr:_MatchBarWord(word_list, from, to)
    local tree = self.bad_word_tree
    local node = tree
    local i = from
    local match_index
    while i <= to do
        local word = string.lower(word_list[i])
        if node[word] then
            node = node[word]
            if node.word_end then
                match_index = i
            end
            i = i + 1
        else
            local j = self:_MatchSpaceWord(word_list, i, to)
            if j then
                i = j + 1
            else
                break
            end
        end
    end
    return match_index
end

function data_mgr:_MatchSpaceWord(word_list, from, to)
    local tree = self.space_word_tree
    local node = tree
    local i = from
    while i <= to do
        node = node[word_list[i]]
        if not node then return end
        if node.word_end then return i end
        i = i + 1
    end
end

function data_mgr:CheckProcessBadWord()
    if not self.bad_word_tree then
        local tree = {}
        for _, word in ipairs(self:GetAllBadWordData()) do
            local node = tree
            for _, char in ipairs(UTF8.Split(word)) do
                if not node[char] then node[char] = {} end
                node = node[char]
            end
            node.word_end = true
        end
        self.bad_word_tree = tree
    end
    if not self.space_word_tree then
        local tree = {}
        for _, word in ipairs(self:GetAllSpaceWordData()) do
            local node = tree
            for _, char in ipairs(UTF8.Split(word)) do
                if not node[char] then node[char] = {} end
                node = node[char]
            end
            node.word_end = true
        end
        self.space_word_tree = tree
    end
end

for k, v in pairs(data_mgr._excel_mapper) do
    if not data_mgr["GetAll" .. k] then
        data_mgr["GetAll" .. k] = function(_)
            if data_mgr.IS_CLIENT then
                return require("Data." .. v)
            else
                return require("excel_data")[v]
            end
        end
    end
    if not data_mgr["Get" .. k] then
        data_mgr["Get" .. k] = function(_, key)
            if data_mgr.IS_CLIENT then
                return require("Data." .. v)[key]
            else
                return require("excel_data")[v][key]
            end
        end
    end
end

return data_mgr