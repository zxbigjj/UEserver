local excel_data = require("excel_data")
local date = require("sys_utils.date")
local timer = require("timer")
local cluster_utils = require("msg_utils.cluster_utils")

local flash_event_utils = DECLARE_MODULE("flash_event_utils")
local EventCls = DECLARE_CLASS(flash_event_utils, "EventCls")
DECLARE_RUNNING_ATTR(flash_event_utils, "flash_event_dict", {})

PERCENT_HP = 1

--------------------------------------------------------------------------------------------
function EventCls.new(boss_id)
    local self = setmetatable({}, EventCls)
    self.boss_id = boss_id
    self.notify_start_time = nil
    self.timer = nil
    self.start_time = nil
    self.end_time = nil
    self.reward_end_time = nil
    self.revive_ts = nil
    self.kill_ts = nil
    self.boss_data = nil

    flash_event_utils.flash_event_dict[boss_id] = self
    return self
end

-- 活动开始
-- 活动开始后，玩家开始点击出征，开始行军，到达后开始战斗
-- 活动开始后，能看到前50个玩家新军速度，速度最快最先开始攻击
-- Boss活动开始在主城出现，活动开始，玩家开始布置上阵的英雄，点准备开始

-- 在boss出现的时间段内，只会同时出现一只boss，（boss出现的数量后台可配）
-- 新的boss属性不同，boss有多个数值属性配置在表格中，活动开始时，填写id及权重以控制每次刷新

-- 在End time时，boss立即消失，如果boss正处于刷新cd中，则不再刷出。

function EventCls:event_star(role_data)
    g_log:warn("event_star is run...")
    local now = date.time_second()
    if self:over_end_time(now) then return end

    -- 记录参加玩家数据
    if not self.role_dict[role_data.uuid] then
        self.role_dict[role_data.uuid] = {
            uuid = role_data.uuid,
            hurt = 0,
            rank = nil,
            role_name = role_data.name,
            role_level = role_data.level,
            role_id = role_data.role_id
        }
    end
end

-- Boss被击杀
-- 如果boss被击杀死亡，5min后刷新一只新的boss（刷新间隔后台可配置，单位为秒）
-- 击杀奖励会直接存入玩家背包，并邮件通知
-- 获得分数奖励

function EventCls:on_kill()
    g_log:warn("on_kill is run...")
    if self:over_end_time() then
        return -- 缺少,超时信息
    end

    self.kill_ts = date.time_second()
    self:set_revive_ts() -- 设定下次刷新时间
    self:give_reward() -- 发放奖励
    self.percent_hp = 0
    self.hurt_rank = {}
    self.role_dict = {}

    local revive_wait_ts = 300
    local notice_time_ahead = 10
    local delay = revive_wait_ts - notice_time_ahead

    if self:over_end_time() then
        self.revive_timer = timer.once(delay, function()
            self.revive_timer = nil
            -- 起复活通知定时器，复活前5秒通知
            self:notice()
        end)
    else
        return -- 缺少,超时信息
    end
end

-- 通知玩家BOSS即将复活
-- 在聊天系统中进行通告，并发送到聊天系统中。内容：玩家{0}击杀了世界boss，力敌千钧
function EventCls:notice()
    g_log:warn("notice is run...")
    cluster_utils.broad_client_msg(nil, nil, "s_chat", "args")

end

-- function EventCls:notice()
--     -- 用世界聊天通知玩家
--     cluster_utils.broad_client_msg(nil, nil, nil, "args")
--     -- 用Notice通知玩家

--     local notice_time_ahead = 10
--     self.revive_timer = timer.once(notice_time_ahead, function()
--         self.revive_timer = nil
--         self:revive()
--     end)
-- end

-- 发放击杀Boss奖励
-- 对boss进行最后一击的玩家获得额外奖励,Score+20
function EventCls:give_reward()
    g_log:warn("give_reward is run...")
    local data = 12
    local role_reward_dict = {}

    for uuid, role_data in pairs(self.role_dict) do
        local item_list = {}
        -- 必得奖励，只有前几名不一样，后面的都一样
        local len = #data.must_item
        local rank = role_data.rank or 0
        local must_item = data.must_item[rank] or data.must_item[len]
        local reward_list = excel_data.RewardData[must_item].item_list
        table.extend(item_list, table.deep_copy(reward_list))

        -- 随机掉落，只有前几名不一样，后面的都一样
        -- local drop_id = data.drop_id[rank] or data.drop_id[len]
        -- table.extend(item_list, drop_utils.roll_drop(drop_id))
        -- role_reward_dict[uuid] = {rank = role_data.rank, item_list = item_list}
        -- local role = agent_utils.get_role(uuid)
        -- if role then
        --     role:send_client("s_hunt_rare_animal_kill_reward", {
        --         animal_id = self.id,
        --         item_list = item_list,
        --         self_rank = role_data.rank
        --     })
        -- end
    end

    -- 发邮件
    local count = 0
    for uuid, data in pairs(role_reward_dict) do
        local mail_info
        if data.rank then
            mail_info = {
                mail_id = CSConst.MailId.Hunt,
                mail_args = {rank = data.rank},
                item_list = data.item_list
            }
        else
            mail_info = {
                mail_id = CSConst.MailId.Hunt1,
                item_list = data.item_list
            }
        end
        agent_utils.add_mail(uuid, mail_info)
        count = count + 1
        if count == 10 then
            skynet.sleep(1)
            count = 0
        end
    end
end

--------------------------------------
-- 超过结束时间
function EventCls:over_end_time(ts)
    g_log:warn("over_end_time is run...")
    if ts <= self.end_time then
        return true
    else
        return false
    end
end

-- 设置BOSS复活时间
function EventCls:set_revive_ts()
    g_log:warn("set_revive_ts is run...")
    local wait_ts = 300
    local now = date.time_second()
    local ts = now + wait_ts

    if self.start_time <= ts and self.end_time >= ts then
        self.revive_ts = ts
    else
        return
    end
end

-- BOSS复活
function EventCls:revive()
    g_log:warn("revive is run...")
    self.kill_ts = nil
    self.revive_ts = nil
    self.boss_data = nil -- 缺少,添加boss info
    self.percent_hp = PERCENT_HP
end

--------------------------------------
-- 获取参与活动的总人数
function EventCls:get_join_num() return table.length(self.role_dict) end

-- 获取参与玩家
function EventCls:get_hunt_role(uuid) return self.role_dict[uuid] end

function flash_event_utils.get_event_cls(event_id)
    
end

--------------------------------------
local function test_msg()
    local msg_3 = {chat_type = 3, content = "这里是跨服消息测试"}
    local msg_2 = {chat_type = 2, content = "这里是世界消息测试"}
    local msg_1 = {chat_type = 1, content = "这里是系统消息测试"}

    local launch_utils = require('launch_utils')
    g_log:warn("is in loop")
    timer.loop(30, function()
        -- cluster_utils.broad_client_msg(nil, nil, "s_chat", msg)
        -- cluster_utils.lua_send(node_name, '.chat', "ls_broad_chat", channel_name, msg)
        g_log:warn("msg is send")
        local node_name = launch_utils.get_service_node_name('.chat', 55)
        cluster_utils.lua_send(node_name, '.chat', "ls_broad_chat", "world",
                               msg_1)
        cluster_utils.lua_send(node_name, '.chat', "ls_broad_chat", "world",
                               msg_2)
        cluster_utils.lua_send(node_name, '.chat', "ls_broad_chat", "world",
                               msg_3)
    end, 10)
end

local function test_msg_2()
    print("test msg 2")
    local msg_2 = {chat_type = 2,
                   content = "这里是世界消息测试"
    }


    local launch_utils = require('launch_utils')
    timer.once(30, function()
        local node_name = launch_utils.get_service_node_name('.chat', 55)
        print("node name  :"..node_name)
        --cluster_utils.lua_send(node_name, '.chat', "ls_enter_chat", 55000018,
        --                       "world")
        cluster_utils.lua_send(node_name, '.chat', "ls_broad_chat", "world",
                               msg_2)
    end)
end

local function test_rank() local event = EventCls:event_star() end

-- test
function EventCls:test()
    
end



function flash_event_utils.start()
    -- local id = 2
    -- EventCls:new(id)
    test_msg_2()
end

return flash_event_utils
