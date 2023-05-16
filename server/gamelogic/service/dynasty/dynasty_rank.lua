local json = require("cjson")
local timer = require("timer")
local excel_data = require("excel_data")
local launch_utils = require("launch_utils")
local schema_dynasty = require("schema_dynasty")
local cluster_utils = require("msg_utils.cluster_utils")

local dynasty_rank = DECLARE_MODULE("dynasty_rank")
local RankCls = DECLARE_CLASS(dynasty_rank, "RankCls")
DECLARE_RUNNING_ATTR(dynasty_rank, "rank_dict", {})
DECLARE_RUNNING_ATTR(dynasty_rank, "save_timer", nil)

local MAX_RANK_LEN = 100

function dynasty_rank.init(is_cross)
    for rank_name, data in pairs(excel_data.RankData.dynasty_rank) do
        if (not is_cross and not data.is_cross) or (is_cross and data.is_cross) then
            local rank_data = schema_dynasty.DynastyRank:load(rank_name)
            if not rank_data then
                rank_data = schema_dynasty.DynastyRank:insert(rank_name, {rank_name = rank_name, dynasty_list = {}})
            end
            RankCls.new({
                rank_name = rank_name,
                max_len = data.max_len,
                dynasty_list = rank_data.dynasty_list
            })
        end
    end
    dynasty_rank.save_timer = timer.loop(600, function() dynasty_rank.save_rank() end, 600)
end

function dynasty_rank.save_rank()
    for _, rank_cls in pairs(dynasty_rank.rank_dict) do
        -- print("-- is save")
        rank_cls:save()
    end
end

-- 更新排名
function dynasty_rank.update_dynasty_rank(rank_name, dynasty_info)
    local rank_cls = dynasty_rank.rank_dict[rank_name]
    if not rank_cls then return end
    rank_cls:update_dynasty_rank(dynasty_info)
end

-- 更新排名王朝信息
function dynasty_rank.update_dynasty_info(dynasty_info)
    for _, rank_cls in pairs(dynasty_rank.rank_dict) do
        rank_cls:update_dynasty_info(dynasty_info)
    end
end

-- 获取排行
function dynasty_rank.get_rank_list(rank_name, self_dynasty_id)
    local rank_cls = dynasty_rank.rank_dict[rank_name]
    if not rank_cls then return end
    return rank_cls:get_rank_list(self_dynasty_id)
end

function dynasty_rank.get_dynasty_rank(rank_name, dynasty_id)
    local rank_cls = dynasty_rank.rank_dict[rank_name]
    if not rank_cls then return end
    return rank_cls:get_dynasty_rank(dynasty_id)
end

function dynasty_rank.get_dynasty_list(rank_name)
    local rank_cls = dynasty_rank.rank_dict[rank_name]
    if not rank_cls then return end
    return rank_cls:get_dynasty_list()
end

-- 清除排行数据
function dynasty_rank.clear_rank_data(rank_name)
    local rank_cls = dynasty_rank.rank_dict[rank_name]
    if not rank_cls then return end
    rank_cls:clear_rank_data()
end

-- 发放排行奖励
function dynasty_rank.give_rank_reward(rank_name)
    local rank_cls = dynasty_rank.rank_dict[rank_name]
    if not rank_cls then return end
    rank_cls:give_rank_reward()
end

-- 王朝解散
function dynasty_rank.on_dissolve_dynasty(dynasty_id)
    for _, rank_cls in pairs(dynasty_rank.rank_dict) do
        rank_cls:delete_dynasty(dynasty_id)
    end
end

function RankCls.new(data)
    local self = setmetatable({}, RankCls)
    self.dynasty_dict = {}
    self.dynasty_list = {}
    self.rank_name = data.rank_name
    self.max_len = data.max_len or MAX_RANK_LEN
    self:init(data.dynasty_list)
    dynasty_rank.rank_dict[self.rank_name] = self
    return self
end

function RankCls:init(dynasty_list)
    for rank, dynasty_info in ipairs(dynasty_list) do
        self.dynasty_dict[dynasty_info.dynasty_id] = dynasty_info
        self.dynasty_list[rank] = self.dynasty_dict[dynasty_info.dynasty_id]
    end
end

function RankCls:update_dynasty_rank(dynasty_info)
    local dynasty_id = dynasty_info.dynasty_id
    local rank_score = dynasty_info.rank_score
    local info = self.dynasty_dict[dynasty_id]
    if info and info.rank_score == rank_score then return end
    if not info then
        local len = #self.dynasty_list
        if len >= self.max_len then
            local last_dynasty = self.dynasty_list[len]
            if last_dynasty.rank_score >= rank_score then return end
            self.dynasty_dict[last_dynasty.dynasty_id] = nil
            table.remove(self.dynasty_list)
        end
        self.dynasty_dict[dynasty_id] = dynasty_info
        info = self.dynasty_dict[dynasty_id]
    end
    local is_add
    print("rank_score, info.rank_score")
    print(rank_score, json.encode(info.rank_score))
    if rank_score >= info.rank_score then
        is_add = true
    end
    info.rank_score = rank_score
    update_sorted_list(self.dynasty_list, info, "rank_score", is_add)
end

function RankCls:update_dynasty_info(dynasty_info)
    local info = self.dynasty_dict[dynasty_info.dynasty_id]
    if not info then return end
    for k, v in pairs(dynasty_info) do
        if info[k] then
            info[k] = v
        end
    end
end

function RankCls:get_rank_list(self_dynasty_id)
    local rank_list = {}
    local rank_data = excel_data.RankData[self.rank_name]
    print("dynasty name : "..self.rank_name)
    local score_name = rank_data.score_name or "rank_score"
    for rank, dynasty_info in ipairs(self.dynasty_list) do
        print("dynasty server_id : "..cluster_utils.get_server_id_by_dynasty(dynasty_info.dynasty_id))
        local dynasty_data = {
            [score_name] = dynasty_info.rank_score,
            dynasty_id = dynasty_info.dynasty_id,
            dynasty_name = dynasty_info.dynasty_name,
            dynasty_level = dynasty_info.dynasty_level,
            dynasty_badge = dynasty_info.dynasty_badge,
            server_id = cluster_utils.get_server_id_by_dynasty(dynasty_info.dynasty_id)
        }
        rank_list[rank] = dynasty_data
    end

    local info = self_dynasty_id and self.dynasty_dict[self_dynasty_id]
    return {
        rank_list = rank_list,
        self_rank = info and info.rank,
        self_rank_score = info and info.rank_score
    }
end

function RankCls:get_dynasty_rank(dynasty_id)
    local info = self.dynasty_dict[dynasty_id]
    return info and info.rank
end

function RankCls:get_dynasty_list()
    return self.dynasty_list
end

function RankCls:clear_rank_data()
    self.dynasty_dict = {}
    self.dynasty_list = {}
end

function RankCls:delete_dynasty(dynasty_id)
    if not self.dynasty_dict[dynasty_id] then return end
    self:update_dynasty_rank({dynasty_id = dynasty_id, rank_score = -1})
    if self.dynasty_dict[dynasty_id].rank ~= #self.dynasty_list then
        error("delete dynasty rank error")
    end
    self.dynasty_dict[dynasty_id] = nil
    table.remove(self.dynasty_list)
end

function RankCls:save()
    schema_dynasty.DynastyRank:set_field({rank_name = self.rank_name}, {dynasty_list = self.dynasty_list})
end

return dynasty_rank
