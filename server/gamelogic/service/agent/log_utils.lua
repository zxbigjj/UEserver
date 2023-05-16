local skynet = require("skynet")
local date = require "sys_utils.date"
local cluster_utils = require("msg_utils.cluster_utils")

local MOD = DECLARE_MODULE("log_utils")

local BASE_LEN = 15
function MOD.gaea_log(uuid, log_name, extra)
    if not log_name or not MOD[log_name] then
        g_log:error("invalid gaea_log tag:" .. log_name)
        return
    end
    local role
    local gata_param, vip, level, urs
    if uuid then
        role = require("agent_utils").get_role(uuid)
        if role then
            gata_param = role.db.gata_param
            vip = role:get_vip()
            level = role.db.level
            urs = role.db.urs
        else
            local info = require("cache_utils").get_role_info(uuid, {"gata_param", 'level', 'urs', 'vip'})
            gata_param = info.gata_param
            level = info.level
            vip = info.vip.vip_level
            urs = info.urs
        end
    else
        gata_param = {}
        vip = 0
        level = 0
        urs = ""
    end
    
    gata_param = gata_param or {}
    assert(g_const.LogDataType[log_name])
    local log_list = {
        g_const.LogDataType[log_name],
        gata_param.appId or "",
        gata_param.appVersion or "",
        gata_param.platform or "",
        gata_param.channel or "",
        gata_param.deviceId or "",
        gata_param.deviceId1 or "",
        gata_param.deviceId2 or "",
        gata_param.ip or "",
        date.time_millisecond(),
        gata_param.accountId or "",
        uuid or "",
        skynet.getenv("server_id"),
        vip,
        level,
    }

    local extra_length = MOD[log_name](uuid, log_list, extra)
    g_log:bdclog(log_name, {length=BASE_LEN+extra_length, data=log_list})
    if uuid then
        extra.uuid = uuid
        extra.urs = urs
        g_log:role(log_name, extra)
    end
end

--注册/登陆/登出
function MOD.RoleLogin(uuid, log_list, extra)
    table.insert(log_list, extra.loginType)
    table.insert(log_list, extra.duration)
    table.insert(log_list, extra.roleName)
    table.insert(log_list, extra.roleRace)
    return 4
end

-- 货币
function MOD.VirtualCoin(uuid, log_list, extra)
    table.insert(log_list, extra.coinNum)
    table.insert(log_list, extra.coinType)
    table.insert(log_list, extra.type)
    table.insert(log_list, extra.isGain)
    table.insert(log_list, extra.totalCoin)
    return 5
end

-- 获得道具
function MOD.AddItem(uuid, log_list, extra)
    table.insert(log_list, extra.itemId)
    table.insert(log_list, extra.itemType)
    table.insert(log_list, extra.itemCnt)
    table.insert(log_list, extra.itemTotal)
    table.insert(log_list, extra.reason)
    return 5
end

-- 消耗道具
function MOD.ConsumeItem(uuid, log_list, extra)
    table.insert(log_list, extra.itemId)
    table.insert(log_list, extra.itemType)
    table.insert(log_list, extra.itemCnt)
    table.insert(log_list, extra.itemTotal)
    table.insert(log_list, extra.reason)
    return 5
end

-- 签到
function MOD.CheckIn(uuid, log_list, extra)
    table.insert(log_list, extra.checkDay)
    table.insert(log_list, extra.rewardInfo)
    table.insert(log_list, extra.checkType)
    return 3
end

--角色经验
function MOD.RoleExp(uuid, log_list, extra)
    table.insert(log_list, extra.expNum)
    table.insert(log_list, extra.oldExp)
    table.insert(log_list, extra.newExp)
    table.insert(log_list, extra.reason)
    return 4
end

--聊天
function MOD.RoleChat(uuid, log_list, extra)
    table.insert(log_list, extra.chatType)
    table.insert(log_list, extra.content)
    table.insert(log_list, extra.privateUuid)
    return 3
end

--升级
function MOD.RoleLvlup(uuid, log_list, extra)
    table.insert(log_list, extra.oldLevel)
    table.insert(log_list, extra.newLevel)
    return 2
end

--改名
function MOD.RoleName(uuid, log_list, extra)
    table.insert(log_list, extra.oldName)
    table.insert(log_list, extra.newName)
    return 2
end

--商场消费
function MOD.ShopConsume(uuid, log_list, extra)
    table.insert(log_list, extra.itemId)
    table.insert(log_list, extra.itemCount)
    table.insert(log_list, extra.consume)
    return 3
end

--任务
function MOD.RoleTask(uuid, log_list, extra)
    table.insert(log_list, extra.taskType)
    table.insert(log_list, extra.taskId)
    table.insert(log_list, extra.status)
    return 3
end

--登出
function MOD.RoleLogout(uuid, log_list, extra)
    table.insert(log_list, extra.roleData)
    return 1
end

--好友
function MOD.FriendLog(uuid, log_list, extra)
    table.insert(log_list, extra.opType)
    table.insert(log_list, extra.friendId)
    return 2
end

--邮件
function MOD.RoleMail(uuid, log_list, extra)
    table.insert(log_list, extra.opType)
    table.insert(log_list, extra.mailId)
    table.insert(log_list, extra.content)
    table.insert(log_list, extra.attach)
    return 4
end

--修改形象
function MOD.RoleImage(uuid, log_list, extra)
    table.insert(log_list, extra.oldId)
    table.insert(log_list, extra.newId)
    return 2
end

return MOD