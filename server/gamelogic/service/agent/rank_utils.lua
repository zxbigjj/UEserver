local schema_game = require("schema_game")
local excel_data = require("excel_data")
local cache_utils = require("cache_utils")
local date = require("sys_utils.date")
local timer = require("timer")
local role_utils = require("role_utils")

local rank_utils = DECLARE_MODULE("rank_utils")
local RankCls = DECLARE_CLASS(rank_utils, "RankCls")
DECLARE_RUNNING_ATTR(rank_utils, "rank_dict", {})
DECLARE_RUNNING_ATTR(rank_utils, "save_timer", nil)

local MAX_RANK_LEN = 100

function rank_utils.start()
    for rank_name, data in pairs(excel_data.RankData.role_rank) do
        if not data.is_cross then
            local rank_data = schema_game.Rank:load(rank_name)
            if not rank_data then
                rank_data = schema_game.Rank:insert(rank_name, {rank_name = rank_name, role_list = {}})
            end
            RankCls.new({
                rank_name = rank_name,
                max_len = data.max_len,
                role_list = rank_data.role_list,
                forbid_dict = rank_data.forbid_dict
            })
        end
    end
    rank_utils.save_timer = timer.loop(600, function() rank_utils.save_rank() end, 600)
end

function rank_utils.save_rank()
   for _, rank_cls in pairs(rank_utils.rank_dict) do
        rank_cls:save()
   end
end

-- 更新排名
function rank_utils.update_role_rank(rank_name, role_data)
    local rank_cls = rank_utils.rank_dict[rank_name]
    if not rank_cls then return end
    rank_cls:update_role_rank(role_data)
end

-- 更新排名玩家信息
function rank_utils.update_role_info(role_data)
    for _, rank_cls in pairs(rank_utils.rank_dict) do
        rank_cls:update_role_info(role_data)
    end
end

-- 获取排行
function rank_utils.get_rank_list(rank_name, self_uuid)
    local rank_cls = rank_utils.rank_dict[rank_name]
    if not rank_cls then return end
    return rank_cls:get_rank_list(self_uuid)
end

function rank_utils.get_role_list(rank_name)
    local rank_cls = rank_utils.rank_dict[rank_name]
    if not rank_cls then return end
    return rank_cls:get_role_list()
end

function rank_utils.get_role_rank(rank_name, uuid)
    local rank_cls = rank_utils.rank_dict[rank_name]
    if not rank_cls then return end
    return rank_cls:get_role_rank(uuid)
end

-- 发放排行奖励
function rank_utils.give_rank_reward(rank_name)
    local rank_cls = rank_utils.rank_dict[rank_name]
    if not rank_cls then return end
    rank_cls:give_rank_reward()
end

-- 清除排行数据
function rank_utils.clear_rank_data(rank_name)
    local rank_cls = rank_utils.rank_dict[rank_name]
    if not rank_cls then return end
    rank_cls:clear_rank_data()
end

function rank_utils.save_as_history(rank_name)
    local rank_cls = rank_utils.rank_dict[rank_name]
    if not rank_cls then return end
    rank_cls:save_as_history()
end

-- 排行榜黑名单
function rank_utils.add_rank_forbid(rank_id, uuid)
    local data = excel_data.RankData[rank_id]
    if data.is_cross then
        require("msg_utils.cluster_utils").send_cross_rank("ls_add_rank_forbid", rank_id, uuid)
        return
    end
    local rank_cls = rank_utils.rank_dict[rank_id]
    if not rank_cls then return end
    rank_cls:add_rank_forbid(uuid)
end

-- 查询排行榜黑名单
function rank_utils.query_forbid_list()
    local all_forbid = {}
    for _, rank_cls in pairs(rank_utils.rank_dict) do
        table.insert(all_forbid, rank_cls:query_forbid_list())
    end
    table.extend(all_forbid, require("msg_utils.cluster_utils").call_cross_rank("lc_query_forbid_list"))
    return all_forbid
end

function RankCls.new(data)
    local self = setmetatable({}, RankCls)
    self.role_dict = {}
    self.role_list = {}
    self.rank_name =  data.rank_name
    self.max_len = data.max_len or MAX_RANK_LEN
    self.forbid_dict = data.forbid_dict
    self:init(data.role_list)
    rank_utils.rank_dict[self.rank_name] = self
    return self
end

function RankCls:init(role_list)
    for rank, role_info in ipairs(role_list) do
        self.role_dict[role_info.uuid] = role_info
        self.role_list[rank] = self.role_dict[role_info.uuid]
    end
end

function RankCls:update_role_rank(role_data)
    local uuid = role_data.uuid
    if not uuid or self.forbid_dict[uuid] then return end
    local rank_score = role_data.rank_score
    local role_info = self.role_dict[uuid]
    if role_info and role_info.rank_score == rank_score then return end
    if not role_info then
        local len = #self.role_list
        if len >= self.max_len then
            local last_role = self.role_list[len]
            if last_role.rank_score >= rank_score then return end
            self.role_dict[last_role.uuid] = nil
            table.remove(self.role_list)
        end
        self.role_dict[uuid] = role_data
        role_info = self.role_dict[uuid]
    end
    local is_add
    if rank_score > (role_info.rank_score or 0) then
        is_add = true
    end
    role_info.rank_score = rank_score
    update_sorted_list(self.role_list, role_info, "rank_score", is_add)
end

function RankCls:update_role_info(role_data)
    local uuid = role_data.uuid
    if not uuid or self.forbid_dict[uuid] then return end
    local role_info = self.role_dict[uuid]
    if not role_info then return end
    for k, v in pairs(role_data) do
        if k == "dynasty_name" then
            if type(v) == "table" then
                role_info[k] = nil
            else
                role_info[k] = v
            end
        else
            if role_info[k] then
                role_info[k] = v
            end
        end
    end
end

function RankCls:get_rank_list(self_uuid)
    local rank_list = {}
    local rank_data = excel_data.RankData[self.rank_name]
    local score_name = rank_data.score_name or "rank_score"
    for rank, role_info in ipairs(self.role_list) do
        local role_data = {
            [score_name] = role_info.rank_score,
            uuid = role_info.uuid,
            dynasty_name = role_info.dynasty_name,
            name = role_info.name,
            level = role_info.level,
            role_id = role_info.role_id,
            vip = role_info.vip
        }
        rank_list[rank] = role_data
    end

    local info = self.role_dict[self_uuid]
    return {
        rank_list = rank_list,
        self_rank = info and info.rank
    }
end

function RankCls:get_role_list()
    return self.role_list
end

function RankCls:get_role_rank(uuid)
    local info = self.role_dict[uuid]
    return info and info.rank
end

function RankCls:give_rank_reward()
    if not next(self.role_list) then return end
    local rank_id = excel_data.RankData[self.rank_name].total_rank
    if not rank_id then return end
    local rank_data = excel_data.TotalRankData[rank_id]
    if not rank_data.reward_tier then return end
    local role_dict = {}
    for rank, role_data in ipairs(self.role_list) do
        local reward_id = role_utils.get_rank_reward(rank_data, rank)
        if not reward_id then break end
        local item_list = excel_data.RewardData[reward_id].item_list
        role_dict[role_data.uuid] = {rank = rank, item_list = table.deep_copy(item_list)}
    end

    local count = 0
    for uuid, data in pairs(role_dict) do
        agent_utils.add_mail(uuid, {
            mail_id = rank_data.mail_id,
            mail_args = {rank = data.rank},
            item_list = data.item_list
        })
        count = count + 1
        if count == 10 then
            skynet.sleep(1)
            count = 0
        end
    end
end

function RankCls:add_rank_forbid(uuid)
    self.forbid_dict[uuid] = true
    if not self.role_dict[uuid] then return end
    self:update_role_rank({uuid = uuid, rank_score = -1})
    if self.role_dict[uuid].rank ~= #self.role_list then
        error("add_rank_forbid error")
    end
    self.role_dict[uuid] = nil
    table.remove(self.role_list)
end

function RankCls:query_forbid_list()
    local uuid_list = {}
    for uuid in pairs(self.forbid_dict) do
        table.insert(uuid_list, uuid)
    end
    return {rank_id = self.rank_name, uuid_list = uuid_list}
end

function RankCls:clear_rank_data()
    self.role_dict = {}
    self.role_list = {}
end

function RankCls:save()
    schema_game.Rank:set_field({rank_name=self.rank_name}, {role_list=self.role_list, forbid_dict=self.forbid_dict})
end

function RankCls:save_as_history()
    schema_game.RankHistory:insert(nil, {
        rank_name=self.rank_name,
        end_ts = date.time_second(),
        role_list = self.role_list,
        forbid_dict = self.forbid_dict
    })
end

return rank_utils
