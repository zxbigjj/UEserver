local M = DECLARE_MODULE("const")

M.Logout_Max_Time = 30 * 60
M.Max_Random_Num = 1000000
M.Fight_Random_Num = 2000000000
M.Max_Role_Num = 1000000
M.Max_Dynasty_Num = 100000

M.LoverHappyType = {
    Flop = 1,
    Dote = 2,
}

M.AddItem = 1
M.SubItem = 0
------------------------------------------------------------------------
M.StLoverAttr = STRUCT(M, "StLoverAttr",
{
    "etiquette",
    "culture",
    "charm",
    "planning",
    "max_hp",
    "att",
    "def",
})

M.StLoginRoleInfo = STRUCT(M, "StLoginRoleInfo",
{
    'name',
    'server_id',
    'level',
    'role_id',
})

M.ChatChannelName = {
    World = "world",
    Cross = "cross",
    Dynasty = "dynasty",
}

M.StMailInfo = STRUCT(M, "StMailInfo",
{
    "mail_id",
    "mail_args",
    "content",
    "title",
    "item_list",
    "send_ts",
    "deadline_ts",
})
-------------------------------log----------------------------------------
M.LogDataType = {
    RoleLogin = 1003,       -- 登陆退出创建
    VirtualCoin = 1201,     -- 虚拟币
    AddItem = 1203,         -- 获得道具
    ConsumeItem = 1204,     -- 消耗道具
    RoleExp = 2001,         -- 角色经验
    RoleChat = 2002,        -- 聊天
    RoleLvlup = 2003,       -- 角色升级
    RoleName = 2004,        -- 改名
    ShopConsume = 2006,     -- 商场消费
    CheckIn = 2007,         -- 签到
    RoleTask = 2008,        -- 任务
    RoleLogout = 2009,      -- 角色退出
    FriendLog = 2010,       -- 好友
    RoleMail = 2011,        -- 邮件
    RoleImage = 2012,       -- 修改形象
}

M.LogloginType = {
    create = 0,
    login = 1,
    logout = 2,
}

M.LogTaskType = {
    Main = 1,
    Daily = 2,
    Achievement = 3,
}

M.LogTaskStatus = {
    Pick = 1,
    Finish = 2,
    Fail = 3,
    Reset = 4,
}

M.LogMailOpType = {
    recv = 1,
    pick = 2,
    delete = 3,
}

M.CheckInType = {
    week = 1,
    month = 2,
}

M.FrinedOperate = {
    add = 1,
    delete = 2,
    apply = 3,
    applied = 4,
}

return M