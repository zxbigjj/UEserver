local MOD = DECLARE_MODULE("pay_order")
local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local json = require("json")
local schema_game = require("schema_game")
local cluster_utils = require("msg_utils.cluster_utils")
local httpc = require "http.httpc"
local excel_data = require("excel_data")
local sha = require "sha2"
local agent_utils = require("agent_utils")
local role_cache_utils = require("cache_utils")
local lover_activities_utils = require("lover_activities_utils")
local hero_activities_utils = require("hero_activities_utils")
local mysql_db = require("db.mysql_db")
local crypt = require("skynet.crypt")

local  signature = "MIIBITANBgkqhkiG9w0BAQEFAAOCAQ4AMIIBCQKCAQBQQxM3UE0xWVqxnSfoYu4+XDICb+WTaZ87wGMFsSm7CizsniDVn0B+Xjptoz1PBSA7n0G5FOb7OPHpg8rH4gVoNcx9kZgBES5v7WX2Awr73wMHJiXMDR1KQA/iVRUzTXIz3k44U58qkkxljJ4SxKgxSmXmSJkK1vPSNdzvK9vN6zldqHV/iK7c/ZMiykWYUHUqwkQcCQM8+e4W+FJIGwHjiP6UOJRnQPsL5xCpTDkdzlJGyd6+cP8BCInWMrrWOvy1dJCl+Vl935/bU1bblApwEYUBh4SLsLEthbFPmXoqNUBKrWSrrcr486wpLq/FKM776LGiRt23DOCRY971AU1lAgMBAAE="

local CONF_NAME = "transaction_id"

local ROUTE = {
    ["/test"] = "on_test",
    ["/do_pay"] = "on_do_pay",
    ["/questionnaire"] = "on_questionnaire",
}

local ERR = {
    ok = 0,
    sign_error = 1001,
    args_error = 1002,
    server_error = 1003,
}

function MOD:on_do_pay(args)
    g_log:info("RecvPay", args)
    local ret = MOD:__on_do_pay(args)
    if ret then
        g_log:info("PaySuccess", ret)
    else
        g_log:info("PayFail", ret)
    end
    --return json.encode(ret)
    return ret
end
local function is_uuid_exist(uuid)
    if uuid then
        if role_cache_utils.get_role_info(uuid, {"uuid"}) then
            return true
        end
    end
    return false
end

function MOD:__on_do_pay(args)
    print(args.transactionId)
    print("pay order args : " .. json.encode(args))
    local db = schema_game.PayOrder:load(args.transactionId)
    if not db then
        --创建新的订单
        local orderTable = {}
        orderTable["transactionId"] = tostring(args.transactionId)
        print("hahhah")
        print("pay order args transactionId :" .. args.transactionId)
        orderTable["orderId"] = tostring(args.order_id)
        orderTable["userId"] = tostring(args.userId)
        orderTable["gameId"] = tostring(args.gameId)
        print(args.gameId)
        print(args.products)
        local products = args.products
        local info = products[1];
        print(info["itemId"])
        orderTable["itemId"] = tostring(info["itemId"])
        orderTable["itemName"] = tostring(info["itemName"])
        orderTable["unitPrice"] = info["unitPrice"]
        orderTable["quantity"] = info["quantity"]
        orderTable["imageUrl"] = tostring(info["imageUrl"])
        orderTable["description"] = tostring(info["description"])
        local type = args.type;
        local flag , msg  = MOD.checkOrder(orderTable , tostring(type))
        print("return msg :" ..msg)
        if not  flag  then
            return false , msg;
        end
        MOD.savePayOrder(orderTable)
        return true;
    else
        --local host = "https://api.jgg18.com"
        --local url = "/transaction/"..args.transactionId.."/status"
        --local form = {
        --    transactionId = args.transactionId
        --}
        --local code, ret_json = httpc.post(host, url, form)
        --print("code :"..code);
        --print("ret_json : "..json.encode(ret_json))
        --if code ~=200 then
        --    return false , "code error"
        --end
        --local retJson = json.decode(ret_json)
        --if retJson.status ~= "Completed" then
        --    return false , "status error"
        --end
        --更新订单状态
        db.status = args.status
        print(" db  info "..json.encode(db))
        schema_game.PayOrder:save(db);
        print(" args "..json.encode(args))
        local type = args.type;
        if tostring(type) == tostring(1) then
           local code , msg  =   MOD.sendRecharge(args , db)
            print("code "..json.encode(code))
            print("msg .." ..json.encode(msg))
            return code;
        end

        if tostring(type) == tostring(2) then
            local code , msg  = MOD.sendYueKa(args , db)
            print("code "..json.encode(code))
            print("msg .." ..json.encode(msg))
            return code;
        end
        if tostring(type) == tostring(3) then
            return   MOD.sendLoverPackage(args , db)
        end
        if tostring(type) == tostring(4) then
            return  MOD.sendHeroPackage(args , db)
        end
    end
end

function MOD.sendLoverPackage(args, db)
    local uuid       = args.uuid
    local count      = db["quantity"]
    local package_id = db["item_id"]
    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    if count <= 0 then
        return false, "count is wrong"
    end

    local role = agent_utils.get_role(uuid)

    if role then
        for i = 1, count do
            local lover_activities_info = schema_game.LoverActivities:load(package_id)
            local item_list = lover_activities_info.item_list

            local reward_dict = {}
            for k, v in ipairs(item_list) do
                reward_dict[v.item_id] = v.count
            end

            local reason = g_reason.lover_package
            role:add_item_dict(reward_dict, reason)

            local args = {
                ['uuid'] = uuid,
                ['id']   = package_id
            }
            local flag, info = lover_activities_utils.buy_ongoing_lover_activities(args)
            print("activityInfo :" .. json.encode(info))
            if flag then
                local times = info.deal_count
                local lover_activity_id = info.lover_activity_id
                local status = 1
                if info.deal_count >= info.purchase_count then
                    status = 0
                end
                local activityInfo = {
                    ['times'] = times;
                    ['lover_activity_id'] = lover_activity_id,
                    ['status'] = status
                }

                local recharge_count = lover_activities_info.price
                if lover_activities_info.discount then recharge_count = lover_activities_info.discount end

                print("----------")
                role.accum_recharge:on_recharge(recharge_count)
                role.recharge:upadate_first_recharge_gift_state()
                -- role:add_vip_exp(math.floor(lover_activities_info.price) * 10, g_reason.recharge)
                local result = lover_activities_utils.get_ongoing_lover_activities(role)
                role:send_client("s_update_ongoing_lover_activities", result)

                --print("s_update_lover_activity :"..json.encode(activityInfo))
                --role:send_client("s_update_lover_activity", activityInfo)
            end
        end
    end
    return true
end

function MOD.sendHeroPackage(args, db)
    local uuid       = args.uuid
    local count      = db["quantity"]
    local package_id = db["item_id"]
    if not is_uuid_exist(uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end

    if count <= 0 then
        return false, "count is wrong"
    end

    local role = agent_utils.get_role(uuid)

    if role then
        for i = 1, count do
            local hero_activities_info = schema_game.HeroActivities:load(package_id)
            local item_list = hero_activities_info.item_list

            local reward_dict = {}
            for k, v in ipairs(item_list) do
                reward_dict[v.item_id] = v.count
            end

            local reason = g_reason.hero_package
            role:add_item_dict(reward_dict, reason)
            local args = {
                ['uuid'] = uuid,
                ['id']   = package_id
            }
            local flag, info = hero_activities_utils.buy_ongoing_hero_activities(args)
            print("activityInfo :" .. json.encode(info))
            if flag then
                local times = info.deal_count
                local hero_activity_id = info.hero_activity_id
                local status = 1
                if info.deal_count >= info.purchase_count then
                    status = 0
                end
                local activityInfo = {
                    ['times'] = times;
                    ['hero_activity_id'] = hero_activity_id,
                    ['status'] = status
                }

                local recharge_count = hero_activities_info.price
                if hero_activities_info.discount then recharge_count = hero_activities_info.discount end

                print("----------")
                role.accum_recharge:on_recharge(recharge_count)
                role.recharge:upadate_first_recharge_gift_state()
                local result = hero_activities_utils.get_ongoing_hero_activities(role)
                role:send_client("s_update_ongoing_hero_activities", result)
                --print("s_update_hero_activity :"..json.encode(activityInfo))
                --role:send_client("s_update_hero_activity", activityInfo)
            end
        end
    end
    return true
end


function MOD.sendRecharge(args , db)
    if not is_uuid_exist(args.uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    local recharge_id = db.item_id
    print("recharge_id : "..recharge_id)
    local data = excel_data.RechargeData[tonumber(recharge_id)]
    print("data"..json.encode(data))
    if not data then
        return false, "recharge_id is wrong"
    end
    if db["quantity"] <= 0 then
        return false, "count is wrong"
    end

    local role = agent_utils.get_role(args.uuid)
    if role then
        for i = 1, db["quantity"] do
            role:role_recharge( tonumber(recharge_id) )
        end
        role.recharge:online()
    end
    return true , "ok"
end

function MOD.sendYueKa(args , db)
    if not is_uuid_exist(args.uuid) then
        return false, g_tips.yunwei_uuid_not_exist
    end
    local card_id = db.item_id
    if db["quantity"] <= 0 then
        return false, "count is wrong"
    end
    local role = agent_utils.get_role(args.uuid)

    if role then
        for i = 1, db["quantity"] do
            role.monthly_card:buy_card(tonumber(card_id))
        end
        role.monthly_card:on_online()
    end
    return true
end

local function response(id, ...)
    local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
    if not ok then
        -- if err == sockethelper.socket_error , that means socket closed.
        print(string.format("fd = %d, %s", id, err))
    end
end

function MOD.checkOrder(appOrder , type)
    local  serverOrder
    print(" type  :" ..type)
    print(" order info  "..json.encode(appOrder))
    print(" order id  "..appOrder.orderId)
    local order_id = appOrder.orderId ;
    if tonumber(type) == 1 then
        print(" order_id   "..order_id)
        serverOrder  = schema_game.order:get_db_client():query_one("select * from t_order where order_id = "..order_id)
        print("order info  : "..json.encode(serverOrder))
        print("recharge  id : "..serverOrder.recharge_id)
        print("item  id : "..appOrder.itemId)
        if tonumber(serverOrder.recharge_id) ~= tonumber(appOrder.itemId) then
            return false , "道具不对"
        end
    end

    if tonumber(type )== 2 then
        serverOrder  = schema_game.CardOrder:get_db_client():query_one("select * from t_cardorder where order_id = "..order_id)
        if serverOrder.card_id ~= appOrder.itemId then
            return false , "道具不对"
        end
    end

    if tonumber(type) == 3 then
        serverOrder  = schema_game.LoverPackageOrder:get_db_client():query_one("select * from t_loverpackageorder where order_id = "..order_id)
        if serverOrder.package_id ~= appOrder.itemId then
            return false , "道具不对"
        end
    end

    if tonumber(type) == 4 then
         serverOrder = schema_game.HeroPackageOrder:get_db_client():query_one("select * from t_heropackageorder where order_id = "..order_id)
        if serverOrder.package_id ~= appOrder.itemId then
            return false , "道具不对"
        end
    end
    if  not serverOrder  then
        return false , "订单不存在"
    end
    if serverOrder.status == 1 then
        return false , "订单已经结束"
    end

    print("local_price:" .. serverOrder.local_price)
    print("unitPrice:" .. appOrder.unitPrice)
    if tonumber(serverOrder.local_price) ~= tonumber(appOrder.unitPrice) then
        return false, "价格不对"
    end

    if tonumber(serverOrder.product_number) ~= tonumber(appOrder.quantity) then
        return false , "道具数量不对"
    end
     return  true  , "ok"
end

function MOD.start()
    local server_id = skynet.getenv("server_id")
    local port = tonumber("405" ..tostring(server_id))
    print("pay router listen port:" .. port)
    local id = socket.listen("0.0.0.0", port)
    print("pay router listen id:" .. id)
    socket.start(id, function(id, addr)
        local hostname, port = addr:match "([^:]+):?(%d*)$"
        skynet.fork(function()
            MOD.process(id)
        end)
    end)
end

function MOD.process(id)
    socket.start(id)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 64 * 1024)
    
    print("解析url ==========")
    print(code, url, method, header, body)
    if code then
        if code ~= 200 then
            response(id, code)
        else
            local ret = "非法请求"
            local path, query = urllib.parse(url)
            local func = ROUTE[path]
            if func then
                local args
                local signData
                if string.lower(method) == "post" then
                    if header["content-type"] == "application/json" then
                        args = body and json.decode(body) or {}
                        print("pay order body :"..tostring(body))
                        local hmac = sha.hmac
                        local bin_to_base64 = sha.bin2base64
                        local sign = hmac(sha.sha256 ,signature ,  body)
                        print("pay order signature :"..json.encode(header["x-signature"]))
                        print("pay order sign :"..bin_to_base64(sign))
--                         if sign ~= header["x-signature"] then
--                            response(id, 110, {true})
--                         end
                        local argsUrl = query and urllib.parse_query(query) or {}
                        signData = args
                        args["order_id"] = argsUrl.order_id
                        args["uuid"] = argsUrl.uuid
                        args["server_id"] = argsUrl.server_id
                        args["type"] = argsUrl.type
                    else
                        args = body and urllib.parse_query(body) or {}
                        print("pay order signData2 :"..json.encode(args))
                        signData = args
                        local argsUrl = query and urllib.parse_query(query) or {}
                        args["order_id"] = argsUrl.order_id
                        args["uuid"] = argsUrl.uuid
                        args["server_id"] = argsUrl.server_id
                        args["type"] = argsUrl.type
                    end
                else
                    args = query and urllib.parse_query(query) or {}
                    signData = args
                end
                --print("heard :"..json.encode(header))
                --local  sign = header["x-signature"]
                --print("pay order sign :"..json.encode(sign))
                ret = MOD[func](MOD, args)
            end
            print("call back ret :"..json.encode(ret))
            if ret then
                response(id, code, json.encode(ret))
            end
            response(id, 110, json.encode(ret))
        end
    else
        if url == sockethelper.socket_error then
            skynet.error("socket closed")
        else
            skynet.error(url)
        end
    end
    socket.close(id)
end

function MOD.savePayOrder(orderTable)
    local db = {
        transaction_id = orderTable["transactionId"],
        order_id = orderTable["orderId"],
        user_id = orderTable["userId"],
        game_id = orderTable["gameId"],
        item_id = orderTable["itemId"],
        item_name = orderTable["itemName"],
        unit_price = tonumber(orderTable["unitPrice"]),
        quantity = tonumber(orderTable["quantity"]),
        image_url = orderTable["imageUrl"],
        description = orderTable["description"],
    }
    return schema_game.PayOrder:insert(db["transaction_id"], db);
end

return MOD
