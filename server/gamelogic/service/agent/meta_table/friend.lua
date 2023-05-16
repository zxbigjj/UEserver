local role_friend = DECLARE_MODULE("meta_table.friend")
local date = require("sys_utils.date")
local role_utils = require("role_utils")
local excel_data = require("excel_data")
local schema_game = require("schema_game")
local cache_utils = require("cache_utils")
local offline_cmd = require("offline_cmd")
local fight_game = require("CSCommon.Fight.Game")
local cluster_utils = require("msg_utils.cluster_utils")

local RANDOM_FIREND_LEN = 10
local MAX_RANDOM_NUM = 20
local LEVEL_DIFF = 5
local MAX_SEEK_TIME = 10
local DB_RANDOM_TIME = 5

function role_friend.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
        pre_random_list = {}
    }
    return setmetatable(self, role_friend)
end

function role_friend:online()
    self.pre_random_list = {}
    local friend_info = self.db.friend
    local receive_count_limit = excel_data.ParamData["max_gift_count"].f_value
    local vitality_limit = excel_data.ParamData["vitality_limit"].f_value
    self.role:send_client("s_update_receive_gift_count", {receive_gift_count = friend_info.receive_gift_count})
    self.role:send_client("s_update_friend_info", self:get_all_friend_info())
    local apply_bool = false
    local gift_bool = false
    if #friend_info.apply_dict > 0 then apply_bool = true end
    if #friend_info.receive_gift > 0 and friend_info.receive_gift_count < receive_count_limit then
        gift_bool = true
    end
    self.role:send_client("s_update_operation_info", {apply_bool = apply_bool, gift_bool = gift_bool})
end

function role_friend:daily_reset()
    local friend_info = self.db.friend.handsel_gift
    for uuid, value in pairs(friend_info) do
        friend_info[uuid] = false
    end
    self.db.friend.receive_gift_count = 0
    self.db.friend.today_send = {}
    self.role:send_client("s_update_receive_gift_count", {receive_gift_count = self.db.friend.receive_gift_count})
end

function role_friend.send_agent(uuid, cmd, ...)
    cluster_utils.send_agent(nil, uuid, cmd, ...)
end

function role_friend.call_agent(uuid, cmd, ...)
    return cluster_utils.call_agent(nil, uuid, cmd, ...)
end

function role_friend:get_friend_count()
    return #self.db.friend.handsel_gift
end

-- 获得所有好友信息
function role_friend:get_all_friend_info()
    local friend_info_dict = {}
    local friend = self.db.friend
    for uuid, value in pairs(friend.handsel_gift) do
        local friend_info = self.call_agent(uuid, "lc_get_friend_info")
        if friend_info then
            if friend.today_send[uuid] then
                friend.handsel_gift[uuid] = true
            end
            if friend.today_send[uuid] then
                friend_info.send_gift = true
            else
                friend_info.send_gift = friend.handsel_gift[uuid]
            end
            friend_info_dict[uuid] = friend_info
        end
    end
    return {friend_info_dict = friend_info_dict}
end

-- 获取所有好友赠送礼物列表
function role_friend:get_all_receive_gift_info()
    local receive_gift_dict = {}
    local friend = self.db.friend
    for _, uuid in ipairs(friend.receive_gift) do
        local friend_info = self.call_agent(uuid, "lc_get_friend_info")
        if friend_info then
            if friend.today_send[uuid] then
                friend_info.send_gift = true
            else
                friend_info.send_gift = friend.handsel_gift[uuid]
            end
            receive_gift_dict[uuid] = friend_info
        end
    end
    return {receive_gift_dict = receive_gift_dict}
end

-- 赠送所有好友礼物
function role_friend:send_all_gift()
    local handsel_gift = self.db.friend.handsel_gift
    for uuid, value in pairs(handsel_gift) do
        if handsel_gift[uuid] == false then
            self:send_gift(uuid)
        end
    end
    return true
end

-- 赠送单个好友礼物
function role_friend:send_gift(uuid)
    if not uuid or uuid == self.uuid then return end
    local friend = self.db.friend
    if friend.today_send[uuid] then
        friend.handsel_gift[uuid] = true
    end
    if friend.handsel_gift[uuid] ~= false then return end
    friend.handsel_gift[uuid] = true
    friend.today_send[uuid] = true
    self.send_agent(uuid, "ls_send_gift", self.uuid)
    self.role:update_daily_active(CSConst.DailyActiveTaskType.SendFriendGift, 1)
    return true
end

-- 收到好友赠送的礼物
function role_friend:insert_gift(uuid)
    if not uuid or uuid == self.uuid then return end
    local receive_gift = self.db.friend.receive_gift
    for k, v in ipairs(receive_gift) do
        if v == uuid then return true end
    end
    table.insert(receive_gift, uuid)
    self.role:send_client("s_friend_send_gift", {})
end

-- 接收单个好友礼物
function role_friend:receive_gift(uuid)
    if not uuid or uuid == self.uuid then return end
    local receive_count_limit = excel_data.ParamData["max_gift_count"].f_value
    if self.db.friend.receive_gift_count >= receive_count_limit then return end
    local receive_gift = self.db.friend.receive_gift
    local vitality_limit = excel_data.ParamData["vitality_limit"].f_value

    if self.db.vitality >= vitality_limit then return end
    for k, v in ipairs(receive_gift) do
        if v == uuid then
            table.remove(receive_gift, k)
            self.role:change_vitality(excel_data.ParamData["gift_value"].f_value, true)
            self.db.friend.receive_gift_count = self.db.friend.receive_gift_count + 1
            self.role:send_client("s_update_receive_gift_count", {
                receive_gift_count = self.db.friend.receive_gift_count,
                this_time_receive = 1
            })
            return true
        end
    end
    return
end

-- 接收所有好友礼物
function role_friend:receive_all_gift()
    local receive_count_limit = excel_data.ParamData["max_gift_count"].f_value
    local receive_gift = self.db.friend.receive_gift
    local receive_gift_count = self.db.friend.receive_gift_count
    if #receive_gift <= 0 then return true end
    local vitality_limit = excel_data.ParamData["vitality_limit"].f_value

    if receive_gift_count >= receive_count_limit or self.db.vitality >= vitality_limit then return end
    local num = 0
    for i = 1, #receive_gift do
        table.remove(receive_gift, 1)
        num = num + 1
        self.role:change_vitality(excel_data.ParamData["gift_value"].f_value, true)
        self.db.friend.receive_gift_count = self.db.friend.receive_gift_count + 1
        if receive_gift_count >= receive_count_limit or self.db.vitality >= vitality_limit then break end
    end
    self.role:send_client("s_update_receive_gift_count", {
        receive_gift_count = self.db.friend.receive_gift_count,
        this_time_receive = num,
    })
    return true
end

-- 通过所有的好友请求
function role_friend:confirm_all_friend_apply()
    local max_friend_count = excel_data.ParamData["max_friend_count"].f_value
    local friend_count = self:get_friend_count()
    local apply_dict = self.db.friend.apply_dict
    if friend_count >= max_friend_count then
        return{
            errcode = g_tips.error,
            tips = CSConst.FriendError.MaxFriendCount
        }
    end

    local ret = nil
    for uuid, value in pairs(apply_dict) do
        self:confirm_friend_apply(uuid)
        friend_count = self:get_friend_count()
        if friend_count >= max_friend_count then
            return {
                errcode = g_tips.ok,
                tips = CSConst.FriendError.MaxFriendCount
            }
        end
    end
    return g_tips.ok_resp
end

-- 通过单个好友请求
function role_friend:confirm_friend_apply(uuid)
    if not uuid or uuid == self.uuid then return g_tips.error_resp end
    local max_friend_count = excel_data.ParamData["max_friend_count"].f_value
    local friend_dict = self.db.friend.handsel_gift
    local black_dict = self.db.friend.black_dict
    local apply_dict = self.db.friend.apply_dict
    if not apply_dict[uuid] then return g_tips.error_resp end
    local friend_count = self:get_friend_count()

    if friend_count >= max_friend_count then
        apply_dict[uuid] = nil
        return {
            errcode = g_tips.error,
            tips = CSConst.FriendError.MaxFriendCount
        }
    end
    if friend_dict[uuid] or black_dict[uuid] then
        apply_dict[uuid] = nil
        return {
            errcode = g_tips.error,
            tips = CSConst.FriendError.RepeatedFriend
        }
    end

    local ret = self.call_agent(uuid, "lc_confirm_friend_apply", self.uuid)
    if ret.errcode ~= g_tips.ok then
        apply_dict[uuid] = nil
        return ret
    end

    friend_dict[uuid] = false
    apply_dict[uuid] = nil
    self.role:gaea_log("FriendLog", {
        opType = g_const.FrinedOperate.add,
        friendId = uuid,
    })
    return g_tips.ok_resp
end

-- 已被确认的好友请求，加入到自己好友表
function role_friend:insert_friend(uuid)
    if not uuid or uuid == self.uuid then return end
    local friend_dict = self.db.friend.handsel_gift
    local apply_dict = self.db.friend.apply_dict
    if friend_dict[uuid] ~= nil then return true end
    if apply_dict[uuid] then
        apply_dict[uuid] = nil
    end
    friend_dict[uuid] = false
    self.role:gaea_log("FriendLog", {
        opType = g_const.FrinedOperate.add,
        friendId = uuid,
    })
end

-- 好友申请操作
function role_friend:add_friend_apply(uuid)
    if not uuid or uuid == self.uuid then return end
    if self.db.friend.handsel_gift[uuid] ~= nil or self.db.friend.black_dict[uuid] ~= nil then
        return {
            errcode = g_tips.error,
            tips = CSConst.FriendError.RepeatedFriend
        }
    end
    self.send_agent(uuid, "ls_add_friend_apply", self.uuid)
    self.role:gaea_log("FriendLog", {
        opType = g_const.FrinedOperate.apply,
        friendId = uuid,
    })
    return g_tips.ok_resp
end

-- 添加好友申请
function role_friend:insert_friend_apply(uuid)
    if not uuid or uuid == self.uuid then return end
    local friend_info = self.db.friend
    if friend_info.handsel_gift[uuid] ~= nil or friend_info.black_dict[uuid] ~= nil then return end
    local index = table.contains(friend_info.apply_dict, uuid)
    if not friend_info.apply_dict[uuid] then
        friend_info.apply_dict[uuid] = date.time_second()
        self.role:send_client("s_user_add_friend_apply", {})
    end
    self.role:gaea_log("FriendLog", {
        opType = g_const.FrinedOperate.applied,
        friendId = uuid,
    })
    return true
end
-- 获取所有好友申请列表信息
function role_friend:get_all_friend_apply_list()
    local friend_apply_dict = {}
    for uuid, apply_time in pairs(self.db.friend.apply_dict) do
        local friend_info = self.call_agent(uuid, "lc_get_friend_info")
        if friend_info then
            friend_info.apply_time = apply_time
            friend_apply_dict[uuid] = friend_info
        end
    end
    return {friend_apply_dict = friend_apply_dict}
end

-- 删除好友操作
function role_friend:delete_friend_operat(uuid)
    if not uuid or uuid == self.uuid then return end
    local friend_info = self.db.friend
    if friend_info.handsel_gift[uuid] == nil and friend_info.black_dict[uuid] == nil then return end
    self:delete_friend(uuid)
    if not self.call_agent(uuid, "lc_delete_friend", self.uuid) then
        self:insert_friend(uuid)
        return
    end
    return true
end

-- 删除单个好友
function role_friend:delete_friend(uuid)
    if not uuid or uuid == self.uuid then return end
    if self.db.friend.handsel_gift[uuid] == nil and self.db.friend.black_dict[uuid] == nil then return true end
    self.db.friend.handsel_gift[uuid] = nil
    self.db.friend.black_dict[uuid] = nil
    self.role:gaea_log("FriendLog", {
        opType = g_const.FrinedOperate.delete,
        friendId = uuid,
    })
    return true
end

-- 添加好友到黑名单
function role_friend:add_friend_to_blacklist(uuid)
    if not uuid or uuid == self.uuid then return end
    if self.db.friend.handsel_gift[uuid] == nil then return end
    local black_dict = self.db.friend.black_dict
    if not black_dict[uuid] then
        black_dict[uuid] = true
        self.db.friend.handsel_gift[uuid] = nil
    end
    return true
end

-- 解除黑名单好友，添到好友列表
function role_friend:remove_friend_in_blacklist(uuid)
    if not uuid or uuid == self.uuid then return end
    local black_dict = self.db.friend.black_dict
    if not black_dict[uuid] then return end
    local max_friend_count = excel_data.ParamData["max_friend_count"].f_value
    local friend_dict = self.db.friend.handsel_gift
    if friend_dict[uuid] ~= nil then return end
    local friend_count = self:get_friend_count()
    if friend_count >= max_friend_count then
        return {
            errcode = g_tips.error,
            tips = CSConst.FriendError.MaxFriendCount
        }
    end
    black_dict[uuid] = nil
    friend_dict[uuid] = false
    if self.db.friend.today_send[uuid] then
        self.db.friend.handsel_gift[uuid] = true
    end
    return g_tips.ok_resp
end

-- 解除所有黑名单好友，添到好友列表
function role_friend:remove_all_friend_in_blacklist()
    local max_friend_count = excel_data.ParamData["max_friend_count"].f_value
    local friend_dict = self.db.friend.handsel_gift
    local friend_count = self:get_friend_count()
    if friend_count >= max_friend_count then return end
    local black_dict = self.db.friend.black_dict
    for uuid in pairs(black_dict) do
        if friend_dict[uuid] == nil then
            friend_dict[uuid] = false
        end
        if self.db.friend.today_send[uuid] then
            self.db.friend.handsel_gift[uuid] = true
        end
        black_dict[uuid] = nil
        friend_count = self:get_friend_count()
        if friend_count >= max_friend_count then break end
    end
    return true
end

-- 删除黑名单好友
function role_friend:delete_friend_in_blacklist(uuid)
    if not uuid or uuid == self.uuid then return end
    local black_dict = self.db.friend.black_dict
    if not black_dict[uuid] then return end
    black_dict[uuid] = nil
    self.db.friend.handsel_gift[uuid] = false
    if not self:delete_friend_operat(uuid) then
        black_dict[uuid] = true
        return
    end
    return true
end

-- 删除所有黑名单好友
function role_friend:delete_all_friend_in_blacklist()
    local black_dict = self.db.friend.black_dict
    for uuid in pairs(black_dict) do
        black_dict[uuid] = nil
        self.db.friend.handsel_gift[uuid] = false
        if not self:delete_friend_operat(uuid) then
            black_dict[uuid] = true
            return
        end
    end
    return true
end

-- 获取所有黑名单好友信息
function role_friend:get_all_blacklist_friend()
    local friend_info_dict = {}
    for uuid in pairs(self.db.friend.black_dict) do
        local friend_info = self.call_agent(uuid, "lc_get_friend_info")
        if friend_info then
            friend_info_dict[uuid] = friend_info
        end
    end
    return {blacklist_friend_dict = friend_info_dict}
end

-- 拒绝单个好友申请
function role_friend:refuse_friend_apply(uuid)
    if not uuid or uuid == self.uuid then return end
    local apply_dict = self.db.friend.apply_dict
    if not apply_dict[uuid] then return end
    apply_dict[uuid] = nil
    return true
end

-- 拒绝所有好友申请
function role_friend:refuse_all_friend_apply()
    self.db.friend.apply_dict = {}
    return true
end

-- 获取推荐好友列表
function role_friend:get_recommend_friend()
    local max_friend_count = excel_data.ParamData["max_friend_count"].f_value
    local friend = self.db.friend
    local friend_count = self:get_friend_count()
    if friend_count >= max_friend_count then return {} end

    local len = RANDOM_FIREND_LEN
    local server_data = require("server_data")
    local last_role_num = server_data.get_server_core("last_role_num")
    local num = last_role_num - #friend.black_dict - #friend.handsel_gift - 1
    if len + MAX_RANDOM_NUM >= num then self.pre_random_list = {} end
    if len >= num then len = num end
    local min_level = self.role:get_level()
    local max_level = min_level
    local uuid_list = {}
    for i = 1, MAX_SEEK_TIME do
        min_level = min_level - LEVEL_DIFF
        max_level = max_level + LEVEL_DIFF
        if min_level < 0 then min_level = 0 end
        uuid_list = self:random_recommend(min_level, max_level, len)
        if #uuid_list >= len then break end
    end

    local friend_info_dict = {}
    for k, uuid in ipairs(uuid_list) do
        local user_info = self.call_agent(uuid, "lc_get_friend_info")
        if user_info then friend_info_dict[uuid] = user_info end
        table.insert(self.pre_random_list, uuid)
        if #self.pre_random_list > MAX_RANDOM_NUM then
            table.remove(self.pre_random_list, 1)
        end
    end
    return {friend_info_dict = friend_info_dict}
end
-- 获取随机列表
function role_friend:random_recommend(min_level, max_level, len)
    local uuid_list = {}
    -- 从在线玩家随机
    for _, uuid in pairs(agent_utils.get_online_uuid()) do
        local role = agent_utils.get_role(uuid)
        if role then
            local level = role:get_level()
            if level >= min_level and level <= max_level then
                if self:correct_random_uuid(uuid) then
                    table.insert(uuid_list, uuid)
                    if #uuid_list >= len then
                        return uuid_list
                    end
                end
            end
        end
    end

    -- 从数据库随机
    uuid_list = {}
    local uuid_dict = {}
    for i = 1, DB_RANDOM_TIME do
        local condition = string.format("random_num >= %d and level >= %d and level <= %d",
            math.random(1, g_const.Max_Random_Num),
            min_level,
            max_level
        )
        local data_list = schema_game.Role:load_many(condition, {"uuid"}, {random_num = 1}, len + 1)
        for _, data in ipairs(data_list) do
            if self:correct_random_uuid(data.uuid) then
                if not uuid_dict[data.uuid] then
                    table.insert(uuid_list, data.uuid)
                    uuid_dict[data.uuid] = true
                    if #uuid_list >= len then
                        return uuid_list
                    end
                end
            end
        end
    end
    return uuid_list
end
-- 随机的玩家id是否符合条件
function role_friend:correct_random_uuid(uuid)
    if not uuid or uuid == self.uuid then return false end
    local friend = self.db.friend
    local index = table.contains(self.pre_random_list, uuid)
    if index then return false end
    if friend.black_dict[uuid] then return false end
    if friend.handsel_gift[uuid] ~= nil then return false end
    return true
end

-- 获取好友阵容
function role_friend:get_role_lineup(uuid)
    if not uuid or uuid == self.uuid then return end
    local hero_lineup_dict = self.call_agent(uuid, "lc_get_role_lineup", uuid)
    if not hero_lineup_dict then return end
    return {errcode = g_tips.ok, lineup_dict = hero_lineup_dict}
end

-- 切磋好友
function role_friend:fight_with_friend(uuid)
    if not uuid or uuid == self.uuid then return end
    if self.db.friend.handsel_gift[uuid] == nil then return true end
    local friend_fight_data = self.call_agent(uuid, "lc_get_friend_fight_data")
    local own_fight_data = self.role:get_role_fight_data()
    if not own_fight_data or not friend_fight_data then return end

    local fight_data = {
        seed = math.random(1, g_const.Fight_Random_Num),
        own_fight_data = own_fight_data,
        enemy_fight_data = friend_fight_data,
        is_pvp = true,
    }

    local game = fight_game.New(fight_data)
    local is_win = game:GoToFight()
    return {errcode = g_tips.ok, is_win = is_win, fight_data = fight_data}
end
-- 向好友发送邮件
function role_friend:send_mail_to_friend(uuid, msg)
    if not uuid or uuid == self.uuid then return end
    local friend_dict = self.db.friend.handsel_gift
    if friend_dict[uuid] == nil then return true end
    self.send_agent(uuid, "ls_send_friend_mail", self.uuid, {name = self.role:get_name(), content = msg})
    return true
end

-- 查找好友
function role_friend:search_friend(uuid)
    if not uuid or not cluster_utils.is_player_uuid_valid(uuid) then return end
    return {
        errcode = g_tips.ok,
        friend_info = self.call_agent(uuid, "lc_get_friend_info"),
    }
end
-- 检查是否能够进行私聊
function role_friend:can_private_chat(friend_uuid)
    if self.db.friend.black_dict[friend_uuid] then return end
    return self.call_agent(friend_uuid, "lc_can_private_chat", self.uuid)
end

return role_friend