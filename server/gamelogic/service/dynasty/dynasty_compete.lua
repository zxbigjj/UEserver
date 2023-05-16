local schema_cross = require("schema_cross")
local cluster_utils = require("msg_utils.cluster_utils")
local excel_data = require("excel_data")
local date = require("sys_utils.date")
local timer = require("timer")

local dynasty_compete = DECLARE_MODULE("dynasty_compete")
DECLARE_RUNNING_ATTR(dynasty_compete, "is_close", nil)
DECLARE_RUNNING_ATTR(dynasty_compete, "open_timer", nil)

local DynastyCompeteNum = 4

function dynasty_compete.send_dynasty(cmd, dynasty_id, ...)
    local server_id = cluster_utils.get_server_id_by_dynasty(dynasty_id)
    local node_name = require("launch_utils").get_service_node_name('.dynasty', server_id)
    cluster_utils.lua_send(node_name, '.dynasty', cmd, dynasty_id, ...)
end

-- 加入王朝争霸
function dynasty_compete.add_dynasty_compete(data)
    schema_cross.DynastyCompete:insert(data.dynasty_id, data)
end

-- 王朝争霸开启
function dynasty_compete.dynasty_compete_open()
    if dynasty_compete.open_timer then
        dynasty_compete.open_timer:cancel()
        dynasty_compete.open_timer = nil
    end
    -- 等待10分钟，等所有服务器开启完毕
    dynasty_compete.is_close = nil
    dynasty_compete.open_timer = timer.once(600, function()
        dynasty_compete.open_timer = nil
        dynasty_compete.set_dynasty_compete_group()
    end)
end

-- 王朝争霸结束
function dynasty_compete.dynasty_compete_close()
    if dynasty_compete.is_close then return end
    dynasty_compete.is_close = true
    dynasty_compete.clear_dynasty_compete_data()
end

-- 清除王朝争霸数据
function dynasty_compete.clear_dynasty_compete_data()
    local data_list = schema_cross.DynastyCompete:load_many()
    for _, v in ipairs(data_list) do
        schema_cross.DynastyCompete:delete(v.dynasty_id)
    end
    dynasty_compete.give_dynasty_rank_reward()
    dynasty_compete.give_role_rank_reward()
end

-- 王朝争霸分组
function dynasty_compete.set_dynasty_compete_group()
    local data_list = schema_cross.DynastyCompete:load_many()
    local dynasty_list = {}
    for _, v in ipairs(data_list) do
        table.insert(dynasty_list, v.dynasty_id)
    end
    local group_dict = {}
    local group_id = 1
    group_dict[group_id] = {}
    local len = #dynasty_list
    for i = 1, len do
        local index = math.random(1, #dynasty_list)
        table.insert(group_dict[group_id], dynasty_list[index])
        table.remove(dynasty_list, index)
        if #group_dict[group_id] == DynastyCompeteNum then
            group_id = group_id + 1
            group_dict[group_id] = {}
        end
    end

    for group_id, dynasty_list in pairs(group_dict) do
        for _, dynasty_id in ipairs(dynasty_list) do
            local enemy_dict = {}
            for _, id in ipairs(dynasty_list) do
                if dynasty_id ~= id then
                    local dynasty = schema_cross.DynastyCompete:load(id)
                    enemy_dict[id] = dynasty
                end
            end
            dynasty_compete.send_dynasty("ls_set_dynasty_compete_enemy", dynasty_id, enemy_dict)
        end
    end
end

-- 发放王朝排名奖励
function dynasty_compete.give_dynasty_rank_reward()
    local dynasty_list = cluster_utils.call_cross_dynasty("lc_get_rank_dynasty_list", "compete_mark_dynasty_rank")
    if not dynasty_list or not next(dynasty_list) then return end
    for _, data in ipairs(excel_data.CompeteRankData) do
        for rank = data.rank_range[1], data.rank_range[2] do
            local dynasty_data = dynasty_list[rank]
            if dynasty_data then
                dynasty_compete.send_dynasty(
                    "ls_give_dynasty_rank_reward",
                    dynasty_data.dynasty_id,
                    CSConst.MailId.CompeteDynasty,
                    rank,
                    data.dynasty_reward_list
                )
            end
        end
    end
    cluster_utils.send_cross_dynasty("ls_clear_dynasty_rank", "compete_mark_dynasty_rank")
end

-- 发放个人排名奖励
function dynasty_compete.give_role_rank_reward()
    local role_list = cluster_utils.call_cross_rank("lc_get_role_list", "compete_mark_role_rank")
    if not role_list or not next(role_list) then return end
    local role_dict = {}
    for _, data in ipairs(excel_data.CompeteRankData) do
        for rank = data.rank_range[1], data.rank_range[2] do
            local role_data = role_list[rank]
            if role_data then
                cluster_utils.send_agent(
                    nil,
                    role_data.uuid,
                    "ls_give_rank_reward",
                    CSConst.MailId.CompeteRole,
                    {rank = rank},
                    role_data.role_reward_list
                )
            end
        end
    end
    cluster_utils.send_cross_rank("ls_clear_rank_data", "compete_mark_role_rank")
end

return dynasty_compete