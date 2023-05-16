local role_party = DECLARE_MODULE("meta_table.party")
local excel_data = require("excel_data")
local cluster_utils = require("msg_utils.cluster_utils")
local date = require("sys_utils.date")
local CSFunction = require("CSCommon.CSFunction")

function role_party.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
        free_gift_timer = nil
    }
    return setmetatable(self, role_party)
end

function role_party:load_party()
    local party_db = self.db.party
    if party_db.free_ts ~= 0 then
        local now = date.time_second()
        if now >= party_db.free_ts then
            party_db.free_ts = 0
        else
            self.free_gift_timer = self.role:timer_once(party_db.free_ts - now, function()
                self.free_gift_timer = nil
                party_db.free_ts = 0
                self.role:send_client("s_update_party_info", { free_ts = party_db.free_ts })
            end)
        end
    end
    local uuid_list = {}
    for uuid, party_id in pairs(party_db.receive_invite_dict) do
        local party_info = cluster_utils.call_cross_party("lc_get_party_info", { party_id = party_id })
        if not party_info then
            table.insert(uuid_list, uuid)
        end
    end
    for _, uuid in ipairs(uuid_list) do
        party_db.receive_invite_dict[uuid] = nil
    end
end

function role_party:online()
    local party_db = self.db.party
    local party_info, join_party_info = {}, {}
    -- 上线时更新party_info和join_info
    if party_db.party_id then
        party_info = cluster_utils.call_cross_party("lc_get_party_info", {
            party_id = party_db.party_id,
        })
    end
    if party_db.join_info.party_id then
        join_party_info = cluster_utils.call_cross_party("lc_get_party_info", {
            party_id = party_db.join_info.party_id,
        })
    end
    self.role:send_client("s_update_party_info", {
        party_info = party_info or {},
        not_receive_invite = party_db.not_receive_invite,
        open_dict = party_db.open_dict,
        join_party_info = join_party_info or {},
        join_dict = party_db.join_dict,
        invite_dict = party_db.invite_dict,
        free_ts = party_db.free_ts,
        receive_invite_dict = party_db.receive_invite_dict
    })
    self.role:send_client("s_update_party_shop", {
        party_shop = party_db.shop_dict,
        refresh_ts = self.db.last_hourly_ts
    })
end

function role_party:daily_refresh()
    local party_db = self.db.party
    local record_list = {}
    local index = 1
    -- 数据保存时长限制
    local time_limit = excel_data.ParamData["party_storage_time_limit"].f_value * CSConst.Time.Hour
    for i, party_info in ipairs(self.db.party_record_list) do
        if date.time_second() - party_info.end_time < time_limit then
            record_list[index] = party_info
            index = index + 1
        end
    end
    local enemy_dict = {}
    for uuid, info in ipairs(self.db.party_enemy_dict) do
        if date.time_second() - info.interrupt_time < time_limit then
            enemy_dict[uuid] = info
        end
    end
    self.db.party_record_list = record_list
    self.db.party_enemy_dict = enemy_dict
    party_db.open_dict = {}
    party_db.join_dict = {}

    self.role:send_client("s_update_party_info", {
        open_dict = party_db.open_dict,
        join_dict = party_db.join_dict,
    })
end

function role_party:hourly_party(pre_hourly_ts)
    local now = date.time_second()
    if now - pre_hourly_ts >= CSConst.Time.Day then
        return self:refresh_party_shop(true)
    end
    local now_date = os.date("*t", now)
    local pre_date = os.date("*t", pre_hourly_ts)
    local shop_data = excel_data.ShopData["PartyShop"]
    if pre_date.day < now_date.day then
        if pre_date.hour < shop_data.refresh_time[#shop_data.refresh_time]
            or now_date.hour >= shop_data.refresh_time[1] then
            return self:refresh_party_shop(true)
        end
    else
        for i, refresh_hour in ipairs(shop_data.refresh_time) do
            if pre_date.hour < refresh_hour and now_date.hour >= refresh_hour then
                return self:refresh_party_shop(true)
            end
        end
    end
end

-- 玩家设置是否接收派对邀请信息
function role_party:set_receive_invite(set_value)
    local party_db = self.db.party
    party_db.not_receive_invite = set_value
    self.role:send_client("s_update_party_info", {
        not_receive_invite = party_db.not_receive_invite,
    })
    return true
end

-- 开启派对
function role_party:start_party(lover_id, party_type_id, is_private)
    print("--- start_party ---")
    local party_db = self.db.party
    if party_db.party_id then print("---- 1 ----") return end
    local party_config = excel_data.PartyData[party_type_id]
    if not party_config then print("---- 2 ----") return end
    if party_db.open_dict[lover_id] then print("---- 3 ----") return end
    local lover_db = self.role:get_lover(lover_id)
    if not lover_db then print("---- 4 ----") return end
    if not self.role:consume_item_list(party_config.consume_item_list, g_reason.open_party) then print("---- 5 ----") return end

    local host_info = self.role:get_role_info()
    host_info.server_id = cluster_utils.get_server_id(self.uuid)
    local party_info = cluster_utils.call_cross_party("lc_add_party", {
        party_info = {
            host_info = host_info,
            lover_id = lover_id,
            lover_level = lover_db.level,
            party_type_id = party_type_id,
        },
        is_private = is_private,
    })
    if not party_info then
        -- 开启派对失败，消耗的物品返还
        self.role:add_item_list(party_config.consume_item_list, g_reason.open_party)
        return
    end
    party_db.invite_dict = {}
    party_db.party_id = party_info.party_id
    party_db.lover_id = lover_id
    party_db.open_dict[lover_id] = true
    self.role:send_client("s_update_party_info", {
        party_info  = party_info or {},
        open_dict   = party_db.open_dict,
        invite_dict = party_db.invite_dict,
    })
    return true
end

-- 更新情人等级
function role_party:update_lover_level(lover_id, level)
    local party_db = self.db.party
    if not party_db.party_id or not party_db.lover_id then return end
    if party_db.lover_id ~= lover_id then return end
    cluster_utils.send_cross_party("ls_update_lover_level", {
        party_id = party_db.party_id,
        value = level,
    })
end

-- 邀请好友,朝友
function role_party:invite_friend(role_dict)
    local party_db = self.db.party
    if not party_db.party_id then return end
    if not role_dict then return end
    local invite_info = {
        uuid = self.uuid,
        name = self.role:get_name(),
        party_id = party_db.party_id,
    }
    for uuid in pairs(role_dict) do
        if not party_db.invite_dict[uuid] or party_db.invite_dict[uuid] == CSConst.Party.InviteStatus.No then
            party_db.invite_dict[uuid] = cluster_utils.call_agent(nil, uuid, "lc_party_invite", { invite_info = invite_info })
        end
    end
    self.role:send_client("s_update_party_info", {
        invite_dict = party_db.invite_dict,
    })
    return true
end

-- 接收邀请
function role_party:receive_invite(invite_info)
    local party_db = self.db.party
    if party_db.not_receive_invite then
        return CSConst.Party.InviteStatus.RefuseNoNotice
    end
    if not cluster_utils.call_cross_party("lc_get_party_info", { party_id = invite_info.party_id }) then
        return
    end
    party_db.receive_invite_dict[invite_info.uuid] = invite_info.party_id
    self.role:send_client("s_update_party_info", {
        new_invite = invite_info,
        receive_invite_dict = party_db.receive_invite_dict,
    })
    return CSConst.Party.InviteStatus.Yes
end

-- 拒绝邀请
function role_party:refuse_invite(uuid)
    local party_db = self.db.party
    local refuse_info = {
        uuid = self.uuid,
        name = self.role:get_name(),
    }
    if uuid then
        party_db.receive_invite_dict[uuid] = nil
        cluster_utils.send_agent(nil, uuid, "ls_party_refuse_invite", { refuse_info = refuse_info })
    else
        -- 全部拒绝
        for uuid in pairs(party_db.receive_invite_dict) do
            cluster_utils.send_agent(nil, uuid, "ls_party_refuse_invite", { refuse_info = refuse_info })
        end
        party_db.receive_invite_dict = {}
    end
    self.role:send_client("s_update_party_info", { receive_invite_dict = party_db.receive_invite_dict })
    return true
end

-- 接收拒绝邀请
function role_party:receive_refuse_invite(refuse_info)
    if not refuse_info.uuid then return end
    local party_db = self.db.party
    party_db.invite_dict[refuse_info.uuid] = CSConst.Party.InviteStatus.No
    self.role:send_client("s_update_party_info", {
        new_refuse_invite = refuse_info,
        invite_dict = party_db.invite_dict,
    })
    return true
end

-- 招待宾客
function role_party:add_guests(party_info)
    self.role:send_client("s_update_party_info", {
        party_info = party_info,
    })
    return true
end

function role_party:host_end_party()
    local party_db = self.db.party
    if not party_db.party_id then return end
    local party_info = cluster_utils.call_cross_party("lc_end_party", {
        party_id = party_db.party_id,
        end_type = CSConst.Party.EndType.HostEnd,
    })
    if not party_info then return end
    return true
end

-- 派对结束，数据已由cross处理。
-- 结束类型   |    消息流向
-- Normal    |    cross → agent(此函数).
-- HostEnd   |    agent(host_end_party) → cross → agent(此函数).
-- EnemyEnd  |    agent(interrupt_party) → cross → agent(此函数).
function role_party:end_party(party_info)
    local party_db = self.db.party
    for uuid in pairs(party_db.invite_dict) do
        cluster_utils.send_agent(nil, uuid, "ls_clear_party_invite", self.uuid)
    end
    party_db.invite_dict = {}
    self.role:send_client("s_update_party_info", {
        party_info = party_info or {},
        invite_dict = party_db.invite_dict,
    })
    return true
end

function role_party:clear_party_invite(host_uuid)
    local party_db = self.db.party
    party_db.receive_invite_dict[host_uuid] = nil
    self.role:send_client("s_update_party_info", { receive_invite_dict = party_db.receive_invite_dict })
end

-- 参加派对
function role_party:join_party(party_id, lover_id, gift_id)
    local party_db = self.db.party
    if party_db.join_dict[lover_id] then return end
    local lover_db = self.role:get_lover(lover_id)
    if not lover_db then return end
    for _, id in pairs(party_db.join_dict) do -- 不允许同一派对参加多次
        if party_id == id then return end
    end
    local gift_config = excel_data.PartyGiftData[gift_id]
    if not gift_config then return end
    if gift_id == CSConst.Party.FreeGiftId and party_db.free_ts == 0 then
        local recover_time = excel_data.ParamData["party_free_gift_time"].f_value * CSConst.Time.Hour
        party_db.free_ts = date.time_second() + recover_time
        self.free_gift_timer = self.role:timer_once(recover_time, function()
            self.free_gift_timer = nil
            party_db.free_ts = 0
            self.role:send_client("s_update_party_info", { free_ts = party_db.free_ts })
        end)
    else
        if not self.role:consume_item_list(gift_config.consume_item_list, g_reason.join_party) then return end
    end

    local add_ratio = CSFunction.get_add_ratio(lover_db.level)
    local add_count = math.floor(gift_config.init_party_point * (1 + add_ratio))

    local role_info = self.role:get_role_info()
    role_info.server_id = cluster_utils.get_server_id(self.uuid)
    local join_party_info = cluster_utils.call_cross_party("lc_join_party", {
        party_id = party_id,
        guests_info = {
            role_info = role_info,
            lover_id = lover_id,
            gift_id = gift_id,
            integral = add_count,
            games_num = gift_config.games_num,
        },
    })
    if not join_party_info or join_party_info.end_type then
        self.role:add_item_list(gift_config.consume_item_list, g_reason.join_party, true)
        local end_type = join_party_info and join_party_info.end_type or CSConst.Party.EndType.Normal
        return { errcode = g_tips.ok, end_type = end_type }
    end

    party_db.receive_invite_dict[join_party_info.host_info.uuid] = nil
    party_db.join_dict[lover_id] = party_id
    local item_id = excel_data.ParamData["party_integral"].item_id
    self.role:add_item(item_id, add_count, g_reason.join_party)
    self.role:add_item_list(gift_config.reward_item_list, g_reason.join_party)
    party_db.history_integral = party_db.history_integral + add_count
    self.role:update_cross_role_rank("party_rank", party_db.history_integral)
    party_db.join_info = {
        party_id = party_id,
        lover_id = lover_id,
        gift_id = gift_id,
        games_num = gift_config.games_num,
    }
    self.role:send_client("s_update_party_info", {
        join_dict = party_db.join_dict,
        join_party_info = join_party_info,
        free_ts = party_db.free_ts,
        receive_invite_dict = party_db.receive_invite_dict
    })

    self.role:update_daily_active(CSConst.DailyActiveTaskType.JoinPartyNum, 1)
    return g_tips.ok_resp
end

-- 砸场子
function role_party:interrupt_party(party_id)
    local party_info = cluster_utils.call_cross_party("lc_get_party_info", { party_id = party_id })
    if not party_info or party_info.end_type then
        local end_type = party_info and party_info.end_type or CSConst.Party.EndType.Normal
        return { errcode = g_tips.ok, end_type = end_type }
    end
    local config = excel_data.PartyData[party_info.party_type_id]
    if not self.role:consume_item(config.break_cost_item, config.break_cost_num, g_reason.interrupt_party) then return end

    local role_info = self.role:get_role_info()
    role_info.server_id = cluster_utils.get_server_id(self.uuid)
    local party_info = cluster_utils.call_cross_party("lc_end_party", {
        party_id = party_id,
        end_type = CSConst.Party.EndType.EnemyEnd,
        enemy_info = {
            role_info = role_info,
            interrupt_time = date.time_second(),
        },
    })
    local ratio = excel_data.ParamData["party_buster_get_point_ratio"].f_value
    -- 砸场子获得积分，根据参数表的数据，计算折损。
    local count = (party_info.integral_count * ratio) / (1 - ratio)
    count = math.floor(count)
    local item_id = excel_data.ParamData["party_integral"].item_id
    self.role:add_item(item_id, count, g_reason.interrupt_party)
    local party_db = self.db.party
    party_db.history_integral = party_db.history_integral + count
    self.role:update_cross_role_rank("party_rank", party_db.history_integral)
    return { errcode = g_tips.ok, reward_dict = { [item_id] = count } }
end

-- 小游戏
function role_party:games(score)
    local score_limit = excel_data.ParamData["party_game_score_limit"].f_value
    if score < 0 or score > score_limit then return end
    local party_db = self.db.party
    local join_info = party_db.join_info
    if not join_info.games_num or join_info.games_num <= 0 then return end
    local lover_db = self.role:get_lover(join_info.lover_id)
    if not lover_db then return end

    join_info.games_num = join_info.games_num - 1
    local add_ratio = CSFunction.get_add_ratio(lover_db.level)
    local add_count = math.floor((1 + add_ratio) * score)
    local item_id = excel_data.ParamData["party_integral"].item_id
    self.role:add_item(item_id, add_count, g_reason.games_party)
    party_db.history_integral = party_db.history_integral + add_count
    self.role:update_cross_role_rank("party_rank", party_db.history_integral)
    -- 保存游戏记录
    local ret = cluster_utils.call_cross_party("lc_games_score", {
        party_id = party_db.join_info.party_id,
        uuid = self.uuid,
        integral = score
    })
    if join_info.games_num <= 0 then
        party_db.join_info = {}
        ret = {}
    end
    self.role:send_client("s_update_party_info", {
        join_party_info = ret,
    })
    self.role:update_activity_data(CSConst.ActivityType.ParticipateBanquet, 1) -- 限时活动-宴会小游戏统计
    return {
        errcode = g_tips.ok,
        integral = add_count,
    }
end

-- 小游戏结束, cross → agent
function role_party:games_end(party_info)
    local party_db = self.db.party
    party_db.join_info = {}
    self.role:send_client("s_update_party_info", {
        join_party_info = party_info,
    })
    return true
end

-- 领取积分
function role_party:receive_integral()
    local party_db = self.db.party
    if not party_db.party_id then return end
    local party_info = cluster_utils.call_cross_party("lc_party_receive_integral", { party_id = party_db.party_id })
    if not party_info then return end
    local item_id = excel_data.ParamData["party_integral"].item_id
    self.role:add_item(item_id, party_info.integral_count, g_reason.end_party)
    party_db.history_integral = party_db.history_integral + party_info.integral_count
    self.role:update_cross_role_rank("party_rank", party_db.history_integral)
    -- record 相关, 必须领取完后才能清空并保存记录
    if party_info.enemy_info and party_info.enemy_info.role_info then
        local uuid = party_info.enemy_info.role_info.uuid
        self.db.party_enemy_dict[uuid] = {
            uuid = uuid,
            interrupt_time = party_info.enemy_info.interrupt_time,
        }
    end
    table.insert(self.db.party_record_list, party_info)
    party_db.party_id = nil
    party_db.lover_id = nil
    self.role:send_client("s_update_party_info", {
        party_info = {},
    })
    return true
end

-- 随机获取party
function role_party:get_random_party()
    local party_list = cluster_utils.call_cross_party("lc_random_get_party", { uuid = self.uuid })
    return {
        errcode = g_tips.ok,
        party_list = party_list or {},
    }
end

-- 获取指定party
function role_party:get_party_info(party_id)
    local party_db = self.db.party
    if not party_id then return end
    local party_info = cluster_utils.call_cross_party("lc_get_party_info", {
        party_id = party_id or party_db.party_id,
    })
    if not party_info then return end
    return {
        errcode = g_tips.ok,
        party_info = party_info,
    }
end

-- 获取派对积分排行榜
function role_party:get_rank()
    local rank_info = cluster_utils.call_cross_rank("lc_get_rank_list", "party_rank", self.uuid)
    rank_info.self_rank_score = self.db.party.history_integral
    return rank_info
end

-- 获取仇人列表
function role_party:get_enemy_list()
    local enemy_list = {}
    for uuid, info in pairs(self.db.party_enemy_dict) do
        local role_info = cluster_utils.call_agent(nil, uuid, "lc_get_role_info")
        if role_info then
            table.insert(enemy_list, {
                role_info = role_info,
                interrupt_time = info.interrupt_time,
            })
        end
    end
    return {
        errcode = g_tips.ok,
        enemy_list = enemy_list,
    }
end

-- 获取派对记录
function role_party:get_record_list()
    return {
        errcode = g_tips.ok,
        record_list = self.db.party_record_list,
    }
end

-- 根据uuid查找派对
function role_party.find_party(uuid)
    local party_info = cluster_utils.call_cross_party("lc_find_party", {
        uuid = uuid or self.uuid,
    })
    return {
        errcode = g_tips.ok,
        party_info = party_info,
    }
end

-- 获取派对邀请信息列表
function role_party:get_receive_invite_list()
    local party_db = self.db.party
    local receive_invite_list = {}
    for uuid, party_id in ipairs(party_db.receive_invite_dict) do
        local party_info = cluster_utils.call_cross_party("lc_get_party_info", {
            party_id = party_id,
        })
        if party_info then
            table.insert(receive_invite_list, { party_info = party_info })
        end
    end
    return {
        errcode = g_tips.ok,
        invite_list = receive_invite_list,
    }
end

-- 购买物品（只能买一次）
function role_party:buy_party_shop_item(shop_id)
    if not shop_id then return end
    local data = excel_data.PartyShopData[shop_id]
    if not data then return end
    local shop_dict = self.db.party.shop_dict
    if not shop_dict[shop_id] or shop_dict[shop_id] >= 1 then return end

    if not self.role:consume_item_list(data.cost_item_list, g_reason.party_shop) then return end
    shop_dict[shop_id] = shop_dict[shop_id] + 1
    self.role:add_item(data.item_id, data.item_count, g_reason.party_shop)
    self.role:send_client("s_update_party_shop", { party_shop = shop_dict, refresh_ts = self.db.last_hourly_ts })
    self.role:gaea_log("ShopConsume", {
        itemId = data.item_id,
        itemCount = data.item_count,
        consume = data.cost_item_list
    })
    return true
end

-- 刷新商店（重置购买次数）
function role_party:refresh_party_shop(is_auto_refresh)
    local shop_data = excel_data.ShopData["PartyShop"]
    if not is_auto_refresh then
        if not self.role:consume_item(shop_data.refresh_item, shop_data.refresh_price, g_reason.refresh_party_shop) then return end
    end
    local party_db = self.db.party
    party_db.shop_dict = {}
    local weight_table = {}
    for key, data in pairs(excel_data.PartyShopData) do
        weight_table[key] = data.weight
    end
    for i = 1, shop_data.refresh_item_num do
        local shop_id = math.roll(weight_table)
        party_db.shop_dict[shop_id] = 0
        weight_table[shop_id] = nil
    end
    self.role:send_client("s_update_party_shop", { party_shop = party_db.shop_dict, refresh_ts = self.db.last_hourly_ts })
    return true
end

return role_party