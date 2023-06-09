local role_recharge = DECLARE_MODULE("meta_table.recharge")
local excel_data = require("excel_data")
local date = require("sys_utils.date")
local schema_game = require("schema_game")
local skynet = require("skynet")
local json = require("json")
local lover_activities_utils = require("lover_activities_utils")
local hero_activities_utils = require("hero_activities_utils")
local skynet_crypt = require("skynet.crypt")
local daily_gift_package_activities_utils =  require("daily_gift_package_activities_utils")
local bin_to_base64 = skynet_crypt.base64encode
function role_recharge.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
    }
    return setmetatable(self, role_recharge)
end

function role_recharge:init()
    local recharge_dict = self.db.recharge
    local recharge_info = excel_data.RechargeData
    for k,v in ipairs(recharge_info) do
        recharge_dict[k] = true
    end
    self.db.first_recharge = false
end

function role_recharge:online()
    self.role:send_client("s_update_recharge_info", {recharge_info = self.db.recharge})
    self.role:send_client("s_update_first_recharge_info", {first_recharge = self.db.first_recharge})
end

-- 充值
function role_recharge:recharge(recharge_id)
    if not recharge_id then return end
    local recharge_info = excel_data.RechargeData[recharge_id]
    if not recharge_info then return end

    local reason = g_reason.recharge
    local recharge_dict = self.db.recharge
    local diamond_count = recharge_info.diamond_count
    if recharge_dict[recharge_id] == true then
        recharge_dict[recharge_id] = nil
        reason = g_reason.first_recharge
        diamond_count = recharge_info.first_diamond_count
        self.role:add_item(recharge_info.first_gift, 1, reason)
    end
    self:on_recharge(recharge_id, recharge_info.recharge_count, recharge_info.diamond_count)
    self.role:add_item(CSConst.Virtual.Diamond, diamond_count, reason)
    print("role_recharge Diamond: "..diamond_count)
    self.role:add_item(CSConst.Virtual.Crystal, recharge_info.gold_count, g_reason.recharge)
    self.role:send_client("s_update_recharge_info", {recharge_info = self.db.recharge})
    return true
end

function role_recharge:lover_recharge(package_id)

    local  lover_activities_info = schema_game.LoverActivities:load(package_id)

    local item_list = lover_activities_info.item_list

    local reward_dict = {}
    for k, v in ipairs(item_list) do
        print("lover_recharge k"..json.encode(k))
        print("lover_recharge v"..json.encode(v))
        reward_dict[v.item_id] = v.count
    end
    local reason = g_reason.lover_package
    self.role:add_item_dict(reward_dict, reason)
    local  args =  {
        ['uuid'] = self.uuid,
         ['id']  =  package_id
    }
    local flag , info = lover_activities_utils.buy_ongoing_lover_activities(args)
    print("activityInfo :"..json.encode(info))
    if flag then
        local times =  info.deal_count
        local lover_activity_id = info.lover_activity_id
        local status = 1
        if info.deal_count >=  info.purchase_count then
            status =  0
        end
        local activityInfo = {
            ['times'] = times;
            ['lover_activity_id'] =lover_activity_id ,
            ['status'] = status
        }

        print("activityInfo :"..json.encode(activityInfo))
        self.role:send_client("s_update_lover_activity", activityInfo)
    end
    
    print('====== is in add lover pack exp')
    self.role:add_vip_exp(math.floor(lover_activities_info.price) * 10, g_reason.recharge)
    local ongoing_activities = lover_activities_utils.get_ongoing_lover_activities(self.role)
    self.role:send_client("s_update_ongoing_lover_activities", ongoing_activities)

    return true
end

function role_recharge:hero_recharge(package_id)
    local  hero_activities_info = schema_game.HeroActivities:load(package_id)

    local item_list = hero_activities_info.item_list

    local reward_dict = {}
    for k, v in ipairs(item_list) do
        print("hero_recharge k"..json.encode(k))
        print("hero_recharge v"..json.encode(v))
        reward_dict[v.item_id] = v.count
    end
    local reason = g_reason.hero_package
    self.role:add_item_dict(reward_dict, reason)

    local  args =  {
        ['uuid'] = self.uuid,
        ['id']  =  package_id
    }
    local flag , info = hero_activities_utils.buy_ongoing_hero_activities(args)

    print("activityInfo :"..json.encode(info))
    if flag then
        local times =  info.deal_count
        local hero_activity_id = info.hero_activity_id
        local status = 1
        if info.deal_count >=  info.purchase_count then
            status =  0
        end
        local activityInfo = {
            ['times'] = times;
            ['hero_activity_id'] =hero_activity_id ,
            ['status'] = status
        }
        print("activityInfo :"..json.encode(activityInfo))
        self.role:send_client("s_update_hero_activity", activityInfo)
    end
    
    -- self.role:add_vip_exp(math.floor(lover_activities_info.price) * 10, g_reason.recharge)
    local ongoing_activities = hero_activities_utils.get_ongoing_hero_activities(self.role)
    self.role:send_client("s_update_ongoing_hero_activities", ongoing_activities)

    return true
end

function role_recharge:create_order(recharge_id,channel)
    if not recharge_id then return end
    print("order recharge id : "..recharge_id)
    print("order recharge id : "..tostring(recharge_id))
    local recharge_info = excel_data.RechargeData[recharge_id]
    if not recharge_info then return end
    local order = {
        order_id = date.time_second()..self.uuid,
        uuid = self.uuid,
        recharge_id = tostring(recharge_id),
        status = 0,
        pay_channel = channel,
        local_price = recharge_info.recharge_count,
        product_number = 1,
        start_ts = tostring(date.time_second()),
        end_ts = tostring(date.time_second()),
        pay_ts = tostring(date.time_second()),
        refund_ts = tostring(date.time_second()),
    }
    print("order  id : "..order.order_id)
    schema_game.order:insert(order.order_id, order)
    print("order  id 1: "..order.order_id)
    local order_id =  order.order_id
    local server_id = skynet.getenv("server_id")
    local uuid = self.uuid
    --g_log:info(bin_to_base64("call_back_url = order_id="..order_id.."&uuid="..uuid.."&server_id="..server_id.."&type=1"))
    g_log:info("call_back_url = order_id="..order_id.."&uuid="..uuid.."&server_id="..server_id.."&type=1")
    return {
        errcode = g_tips.ok,
        order_id =  order_id,
        --call_back_url = "https://server.jgg-tianyou-zuiecheng.com:404"..server_id.."/do_pay?order_id="..order_id.."&uuid="..uuid.."&server_id="..server_id.."&type=1",
        call_back_url = "order_id="..order_id.."&uuid="..uuid.."&server_id="..server_id.."&type=1",
    }
end

function role_recharge:create_yueka_order(card_id,channel)
    if not card_id then return end
    print("order recharge id : "..card_id)
    print("order recharge id : "..tostring(card_id))
    local exldata = excel_data.MonthlyCardData[card_id]
    if not exldata then return end
    local order = {
        order_id = date.time_second()..self.uuid,
        uuid = self.uuid,
        card_id = tostring(card_id),
        status = 0,
        pay_channel = channel,
        local_price = exldata.price,
        product_number = 1,
        start_ts = tostring(date.time_second()),
        end_ts = tostring(date.time_second()),
        pay_ts = tostring(date.time_second()),
        refund_ts = tostring(date.time_second()),
    }
    print("order  id : "..order.order_id)
    schema_game.CardOrder:insert(order.order_id, order)
    print("order  id 1: "..order.order_id)
    local order_id =  order.order_id
    local server_id = skynet.getenv("server_id")
    local uuid = self.uuid
    g_log:info("call_back_url = order_id="..order_id.."&uuid="..uuid.."&server_id="..server_id.."&type=2")
    return {
        errcode = g_tips.ok,
        order_id =  order_id,
        --call_back_url = "https://server.jgg-tianyou-zuiecheng.com:404"..server_id.."/do_pay?order_id="..order_id.."&uuid="..uuid.."&server_id="..server_id.."&type=2"
        call_back_url = "order_id="..order_id.."&uuid="..uuid.."&server_id="..server_id.."&type=2",
    }
end

function role_recharge:create_lover_order(package_id,channel)
    if not package_id then return end
    print("order recharge id : "..tostring(package_id))
    local  loverpackage = schema_game.LoverActivities:get_db_client():query_one("select  * from t_loveractivities where id = "..package_id)

    if not loverpackage then return end
    print("loverpackage :"..json.encode(loverpackage))
    local order = {
        order_id = date.time_second()..self.uuid,
        uuid = self.uuid,
        package_id = tostring(package_id),
        status = 0,
        pay_channel = channel,
        local_price = loverpackage.discount,
        product_number = 1,
        start_ts = tostring(date.time_second()),
        end_ts = tostring(date.time_second()),
        pay_ts = tostring(date.time_second()),
        refund_ts = tostring(date.time_second()),
    }
    print("order  id : "..order.order_id)
    schema_game.LoverPackageOrder:insert(order.order_id, order)

    print("order  id 1: "..order.order_id)
    local order_id =  order.order_id
    local server_id = skynet.getenv("server_id")
    local uuid = self.uuid
   -- local url = skynet.getenv("call_back_url")
   -- print("call_back_url : "..url)
    g_log:info("call_back_url = order_id="..order_id.."&uuid="..uuid.."&server_id="..server_id.."&type=3")
    
    return {
        errcode = g_tips.ok,
        order_id =  order_id,
        --call_back_url = "https://server.jgg-tianyou-zuiecheng.com:404"..server_id.."/do_pay?order_id="..order_id.."&uuid="..uuid.."&server_id="..server_id.."&type=3"
        call_back_url = "order_id="..order_id.."&uuid="..uuid.."&server_id="..server_id.."&type=3",
        goods_id = "lover_ios_daheng_" .. loverpackage.price, --ios传个商品ID,
        goods_name = loverpackage.goods_name,
    }
end

function role_recharge:create_hero_order(package_id,channel)
    if not package_id then return end
    print("order recharge id : "..tostring(package_id))
    local  heropackage = schema_game.HeroActivities:get_db_client():query_one("select  * from t_heroactivities where id = "..package_id)

    if not heropackage then return end

    local order = {
        order_id = date.time_second()..self.uuid,
        uuid = self.uuid,
        package_id = tostring(package_id),
        status = 0,
        pay_channel = channel,
        local_price = heropackage.discount,
        product_number = 1,
        start_ts = tostring(date.time_second()),
        end_ts = tostring(date.time_second()),
        pay_ts = tostring(date.time_second()),
        refund_ts = tostring(date.time_second()),
    }
    print("order  id : "..order.order_id)
    schema_game.HeroPackageOrder:insert(order.order_id, order)
    print("order  id 1: "..order.order_id)
    local order_id =  order.order_id
    local server_id = skynet.getenv("server_id")
   -- local url = skynet.getenv("call_back_url")
   -- print("call_back_url : "..url)
    g_log:info("call_back_url = order_id="..order_id.."&uuid="..self.uuid.."&server_id="..server_id.."&type=4")
    local uuid = self.uuid

    local returnData = {
        errcode = g_tips.ok,
        order_id =  order_id,
       -- call_back_url = "https://server.jgg-tianyou-zuiecheng.com:404"..server_id.."/do_pay?order_id="..order_id.."&uuid="..uuid.."&server_id="..server_id.."&type=4"
        call_back_url = "order_id="..order_id.."&uuid="..uuid.."&server_id="..server_id.."&type=4",
        goods_id = "hero_ios_daheng_" .. heropackage.price, --ios传个商品ID,
        goods_name = heropackage.goods_name,
    }

    print( " data :"..json.encode(returnData))
    return returnData
end

-- 创建礼包订单
function role_recharge:create_gift_order(gift_id,channel)
    if not gift_id then return end
    print("order recharge id : "..tostring(gift_id))
    local gift_info = daily_gift_package_activities_utils.get_excel_info_by_id(gift_id)
    if(gift_info ==  nil) then
        return
    end

    if gift_info.reset_cycle == 1 then
        local cur_date = date.format_day_time(nil)
        print("gift_id .."..gift_id)
        local sql1= "select * from t_dailygiftpackage where reward_id = "..gift_id.." and user_id = "..self.uuid .. " and reset_cycle = 1 and reward_date ='"..cur_date.."'"
        print("sql1 .."..sql1)
        --获取玩家今天购买每日礼包的全部记录
        local day_count = schema_game.DailyGiftPackage:get_db_client():query(sql1)
        print("day_count .."..#day_count)
        print("gift_info .."..json.encode(gift_info))
        if tonumber(#day_count) >= tonumber(gift_info.limit_num) then
            return
        end

    elseif gift_info.reset_cycle == 7 then
        local week_count = schema_game.DailyGiftPackage:get_db_client():query("select * from t_dailygiftpackage where reward_id = "..gift_id.." and user_id = "..self.uuid .. " and reset_cycle = 7 and reward_date >='" .. tostring(date.get_week_start_time()).."' and reward_date <'" ..tostring(date.get_week_end_time()).."'")

        if tonumber(#week_count) >= tonumber(gift_info.limit_num) then
            return
        end
    elseif gift_info.reset_cycle == 36500 then
        local sql365= "select * from t_dailygiftpackage where reward_id = "..gift_id.." and user_id = "..self.uuid
        local count = schema_game.DailyGiftPackage:get_db_client():query(sql365)
        if tonumber(#count) >= tonumber(gift_info.limit_num) then
            return
        end
    end
    local order = {
        order_id = date.time_second()..self.uuid,
        uuid = self.uuid,
        gift_id = tostring(gift_id),
        status = 0,
        pay_channel = channel,
        local_price = tonumber(gift_info.recharge_rank),
        product_number = 1,
        start_ts = tostring(date.time_second()),
        end_ts = tostring(date.time_second()),
        pay_ts = tostring(date.time_second()),
        refund_ts = tostring(date.time_second()),
    }
    print("order  id : "..order.order_id)
    schema_game.GiftPackageOrder:insert(order.order_id, order)
    print("order  id 1: "..order.order_id)
    local order_id =  order.order_id
    local server_id = skynet.getenv("server_id")
    -- local url = skynet.getenv("call_back_url")
    -- print("call_back_url : "..url)
    g_log:info("call_back_url = order_id="..order_id.."&uuid="..self.uuid.."&server_id="..server_id.."&type=5")
    local uuid = self.uuid

    local returnData = {
        errcode = g_tips.ok,
        order_id =  order_id,
        -- call_back_url = "https://server.jgg-tianyou-zuiecheng.com:404"..server_id.."/do_pay?order_id="..order_id.."&uuid="..uuid.."&server_id="..server_id.."&type=4"
        call_back_url = "order_id="..order_id.."&uuid="..uuid.."&server_id="..server_id.."&type=5",
    }

    print( " data :"..json.encode(returnData))

    return returnData
end

--查询订单状态进行发货
function role_recharge:query_order(order_id)
    local status = cluster_utils.call_world("lc_query_pay_order", order_id)
    local order_info = schema_game.order.load(order_id)
    local  recharge_id = order_info.recharge_id
    if status == 1 then
        if not recharge_id then return end
        local recharge_info = excel_data.RechargeData[recharge_id]
        if not recharge_info then return end

        local reason = g_reason.recharge
        local recharge_dict = self.db.recharge
        local diamond_count = recharge_info.diamond_count
        if recharge_dict[recharge_id] == true then
            recharge_dict[recharge_id] = nil
            reason = g_reason.first_recharge
            diamond_count = recharge_info.first_diamond_count
            self.role:add_item(recharge_info.first_gift, 1, reason)
        end
        self:on_recharge(recharge_id, recharge_info.recharge_count, recharge_info.diamond_count)
        self.role:add_item(CSConst.Virtual.Diamond, diamond_count, reason)
        self.role:add_item(CSConst.Virtual.Crystal, recharge_info.gold_count, g_reason.recharge)
        return {
            errcode = g_tips.ok,
            order_status = status,
            order_id = order_id,
        }
    end
    return {
        errcode = g_tips.error,
        order_status = status,
        order_id = order_id,
    }
end

-- 充值事件，recharge_id为充值档位，recharge_count为充值金额，diamond_count为非首冲钻石数量
    function role_recharge:on_recharge(recharge_id, recharge_count, diamond_count)
        if not recharge_count or recharge_count <= 0 then return end
        self.role.accum_recharge:on_recharge(recharge_count) -- 限时累充
        self.role:get_replenish_count_by_recharge(recharge_count)
        self.role:daily_recharge_recharge_event(recharge_id) -- 天天充值送好礼
        self.role:luxury_check_in_recharge(recharge_id) -- 豪华签到充值事件
        self.role:update_rush_activity_data(CSConst.RushActivityType.recharge, recharge_count) -- 冲榜活动
        self.role:update_festival_activity_data(CSConst.FestivalActivityType.recharge, {recharge_id = recharge_id}) -- 节日活动
        self:upadate_first_recharge_gift_state()
        self.role:add_vip_exp(math.floor(diamond_count), g_reason.recharge)
        self.role:unlock_single_recharge(recharge_id)
        self.role:get_recharge_addition_draw_num(recharge_count)
    end

-- 激活充值的活动
function role_recharge:activation_recharge_activities(recharge_count)
    self.role.accum_recharge:on_recharge(recharge_count) -- 限时累充
    self:upadate_first_recharge_gift_state()
    self.role:add_vip_exp(math.floor(recharge_count * 10), g_reason.recharge)
    -- 转盘数量
    self.role:get_recharge_addition_draw_num(recharge_count)

    local result = hero_activities_utils.get_ongoing_hero_activities(self.role)
    self.role:send_client("s_update_ongoing_hero_activities", result)
    local lover_result = lover_activities_utils.get_ongoing_lover_activities(self.role)
    self.role:send_client("s_update_ongoing_lover_activities", lover_result)
end

-- 更新首冲状态
function role_recharge:upadate_first_recharge_gift_state()
    print("------ sc")
    if self.db.first_recharge == nil then return end
    self.db.first_recharge = true
    self.role:send_client("s_update_first_recharge_info", {first_recharge = self.db.first_recharge})
end

-- 领取首冲礼包
function role_recharge:recive_first_recharge_gift()
    if self.db.first_recharge ~= true then return end
    local item_list = excel_data.ParamData["first_rechage_reward"].item_list
    local count_list = excel_data.ParamData["first_rechage_reward"].count_list
    local reward_dict = {}
    for k, v in ipairs(item_list) do
        reward_dict[v] = count_list[k]
    end
    local reason = g_reason.first_recharge_gift
    self.role:add_item_dict(reward_dict, reason)
    self.db.first_recharge = nil
    return true
end

return role_recharge
