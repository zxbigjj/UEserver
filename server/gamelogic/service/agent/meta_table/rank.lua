local excel_data = require("excel_data")
local rank_utils = require("rank_utils")
local cluster_utils = require("msg_utils.cluster_utils")

local role_rank = DECLARE_MODULE("meta_table.rank")

local RankMapper = {
    [CSConst.RankId.Hunt] = "get_hunt_rank_list",
    [CSConst.RankId.Arena] = "get_arena_rank_list",
    [CSConst.RankId.Party] = "get_party_rank_list",
    [CSConst.RankId.Salon] = "get_salon_rank_list",
    [CSConst.RankId.Train] = "get_train_rank_list",
    [CSConst.RankId.TraitorHurt] = "get_traitor_hurt_rank_list",
    [CSConst.RankId.TraitorFeats] = "get_traitor_feats_rank_list",
    [CSConst.RankId.FightScore] = "get_fight_score_rank_list",
    [CSConst.RankId.Score] = "get_score_rank_list",
    [CSConst.RankId.Level] = "get_level_rank_list",
    [CSConst.RankId.StageStar] = "get_stage_star_rank_list",
    [CSConst.RankId.TraitorBossHonour] = "get_traitor_boss_honour_rank_list",
    [CSConst.RankId.TraitorBossHurt] = "get_traitor_boss_hurt_rank_list",
    [CSConst.RankId.CrossTraitorHonour] = "get_cross_traitor_honour_rank_list",
    [CSConst.RankId.CrossTraitorHurt] = "get_cross_traitor_hurt_rank_list",
    -- [CSC] = "get_cross_hunt_rank",
}

function role_rank.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
    }
    return setmetatable(self, role_rank)
end

function role_rank:get_rank_role_info()
    return {
        uuid = self.uuid,
        level = self.role:get_level(),
        role_id = self.role:get_role_id(),
        vip = self.role:get_vip(),
        name = self.role:get_name(),
        dynasty_name = self.role:get_dynasty_name()
    }
end

-- 更新玩家排行榜排名
function role_rank:update_role_rank(rank_name, rank_score)
    local role_info = self:get_rank_role_info()
    role_info.rank_score = rank_score
    rank_utils.update_role_rank(rank_name, role_info)
end

-- 更新玩家跨服排行榜排名
function role_rank:update_cross_role_rank(rank_name, rank_score)
    local role_info = self:get_rank_role_info()
    role_info.rank_score = rank_score
    cluster_utils.send_cross_rank("ls_update_role_rank", rank_name, role_info)
end

-- 更新排名玩家信息
function role_rank:update_role_info(role_info)
    role_info.uuid = self.uuid
    rank_utils.update_role_info(role_info)
    cluster_utils.send_cross_rank("ls_update_role_info", role_info)
end

function role_rank:get_rank_list(rank_id)
    if not excel_data.TotalRankData[rank_id] then return end
    local func = RankMapper[rank_id]
    if func then
        return self[func](self)
    end
end

-- 狩猎积分排行
function role_rank:get_hunt_rank_list()
    return self.role:get_hunt_rank_list()
end

-- 竞技场排行
function role_rank:get_arena_rank_list()
    return self.role:get_arena_rank_list()
end

-- 派对积分排行
function role_rank:get_party_rank_list()
    return self.role:get_party_rank_list()
end

-- 沙龙积分排行
function role_rank:get_salon_rank_list()
    return self.role:get_salon_rank_list()
end

-- 试炼排行
function role_rank:get_train_rank_list()
    return self.role:get_train_rank_list()
end

-- 叛军伤害排行
function role_rank:get_traitor_hurt_rank_list()
    return self.role:get_traitor_hurt_rank_list()
end

-- 叛军功勋排行
function role_rank:get_traitor_feats_rank_list()
    return self.role:get_traitor_feats_rank_list()
end

-- 战力排行
function role_rank:get_fight_score_rank_list()
    local rank_info = rank_utils.get_rank_list("fight_score_rank", self.uuid)
    rank_info.self_rank_score = self.role:get_fight_score()
    return rank_info
end

-- 帮力排行
function role_rank:get_score_rank_list()
    local rank_info = rank_utils.get_rank_list("score_rank", self.uuid)
    rank_info.self_rank_score = self.role:get_score()
    return rank_info
end

-- 等级排行
function role_rank:get_level_rank_list()
    local rank_info = rank_utils.get_rank_list("level_rank", self.uuid)
    rank_info.self_rank_score = self.role:get_level()
    return rank_info
end

-- 关卡星数排行
function role_rank:get_stage_star_rank_list()
    local rank_info = rank_utils.get_rank_list("stage_star_rank", self.uuid)
    rank_info.self_rank_score = self.role:get_stage_star()
    return rank_info
end

-- 叛军boss荣誉排行
function role_rank:get_traitor_boss_honour_rank_list()
    local rank_info = rank_utils.get_rank_list("traitor_boss_honour_rank", self.uuid)
    rank_info.self_rank_score = self.role:get_traitor_honour()
    return rank_info
end

-- 叛军boss最大伤害排行
function role_rank:get_traitor_boss_hurt_rank_list()
    local rank_info = rank_utils.get_rank_list("traitor_boss_hurt_rank", self.uuid)
    rank_info.self_rank_score = self.role:get_traitor_boss_hurt()
    return rank_info
end

-- 跨服叛军boss荣誉排行
function role_rank:get_cross_traitor_honour_rank_list()
    local rank_info = cluster_utils.call_cross_rank("lc_get_rank_list", "cross_traitor_honour_rank", self.uuid)
    rank_info.self_rank_score = self.role:get_traitor_honour()
    return rank_info
end

-- 跨服叛军boss最大伤害排行
function role_rank:get_cross_traitor_hurt_rank_list()
    local rank_info = cluster_utils.call_cross_rank("lc_get_rank_list", "cross_traitor_hurt_rank", self.uuid)
    rank_info.self_rank_score = self.role:get_traitor_boss_hurt()
    return rank_info
end

-- 跨服狩猎
function role_rank:get_cross_hunt_rank_list()
    local rank_info = cluster_utils.call_cross_rank("lc_get_rank_list", "cross_hunt_rank", self.uuid)
    rank_info.self_rank_score = self.role:get_hunting_hurt()
    return rank_info
end

-- 跨服地下黑拳
function role_rank:get_cross_train_rank_list()
    local rank_info = cluster_utils.call_cross_rank("lc_get_rank_list", "cross_train_rank", self.uuid)
    rank_info.self_rank_score = self.role:get_train_history_star()
    return rank_info
end

return role_rank