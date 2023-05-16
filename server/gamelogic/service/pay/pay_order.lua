local pay_order = DECLARE_MODULE("pay_order")
local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local json = require("json")
local schema_world = require("schema_world")
local cluster_utils = require("msg_utils.cluster_utils")

local signature = "MIIBITANBgkqhkiG9w0BAQEFAAOCAQ4AMIIBCQKCAQBQQxM3UE0xWVqxnSfoYu4+XDICb+WTaZ87wGMFsSm7CizsniDVn0B+Xjptoz1PBSA7n0G5FOb7OPHpg8rH4gVoNcx9kZgBES5v7WX2Awr73wMHJiXMDR1KQA/iVRUzTXIz3k44U58qkkxljJ4SxKgxSmXmSJkK1vPSNdzvK9vN6zldqHV/iK7c/ZMiykWYUHUqwkQcCQM8+e4W+FJIGwHjiP6UOJRnQPsL5xCpTDkdzlJGyd6+cP8BCInWMrrWOvy1dJCl+Vl935/bU1bblApwEYUBh4SLsLEthbFPmXoqNUBKrWSrrcr486wpLq/FKM776LGiRt23DOCRY971AU1lAgMBAAE="

local ROUTE = {
    ["/do_pay"] = "on_do_pay",
}

local ERR = {
    ok = 0,
    sign_error = 1001,
    args_error = 1002,
    server_error = 1003,
}

function pay_order:on_do_pay(args)
    g_log:info("RecvPay", args)
    local ret = pay_order:__on_do_pay(args)
    if ret and ret.code == ERR.ok then
        g_log:info("PaySuccess", ret)
    else
        g_log:info("PayFail", ret)
    end
    return json.encode(ret)
end
function pay_order:__on_do_pay(args)
    print(args.transactionId)
    local db = schema_world.PayOrder:load(args.transactionId)
    if not db then
        --创建新的订单
        local orderTable = {}
        orderTable["transactionId"] = args.transactionId
        print("hahhah")
        print(args.transactionId)
        orderTable["userId"] = args.userId
        orderTable["gameId"] = args.gameId
        print(args.gameId)
        print(args.products)
        local  products = args.products
        local  info = products[1];
        print(info["itemId"])
        orderTable["itemId"] = info["itemId"]
        orderTable["itemName"] = info["itemName"]
        orderTable["unitPrice"]= info["unitPrice"]
        orderTable["quantity"]= info["quantity"]
        orderTable["imageUrl"]= info["imageUrl"]
        orderTable["description"]= info["description"]
        return  pay_order.savePayOrder(orderTable)
    else
        --更新订单状态
        db["status"] = args.status
         schema_world.PayOrder:save(db);

    local  must_params = {}
    must_params["server_id"] = 55
    must_params["uuid"] = db["user_id"]
    must_params["recharge_id"] = db["item_id"]
    must_params["count"] = db["quantity"]
    must_params["gm_name"] = "imitate_recharge"
    return pay_order:imitate_recharge(must_params)
    end
end


local function response(id, ...)
    local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
    if not ok then
        -- if err == sockethelper.socket_error , that means socket closed.
        print(string.format("fd = %d, %s", id, err))
    end
end

function pay_order.start()
    local port = tonumber(40414)
    print("pay router listen port:" .. port)
    local id = socket.listen("0.0.0.0", port)
    print("pay router listen port:" .. port)
    socket.start(id , function(id, addr)
        local hostname, port = addr:match"([^:]+):?(%d*)$"
        skynet.fork(function()
            pay_order.process(id)
        end)
    end)
end

function pay_order.process(id)
    socket.start(id)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 64*1024)
    if code then
        if code ~= 200 then
            response(id, code)
        else
            local ret = "非法请求"
            local path, query = urllib.parse(url)
            local func = ROUTE[path]
            if func then
                local args
                if string.lower(method) == "post" then
                    if header["content-type"] == "application/json" then
                        args = body and json.decode(body) or {}
                        local argsUrl = query and urllib.parse_query(query) or {}
                        args["order_id"] = argsUrl.order_id
                    else
                        args = body and urllib.parse_query(body) or {}
                        local argsUrl = query and urllib.parse_query(query) or {}
                        args["order_id"] = argsUrl.order_id
                    end
                else
                    args = query and urllib.parse_query(query) or {}
                end
                local  sign = header["X-Signature"]
                ret = pay_order[func](pay_order, args)
            end
            response(id, code, ret)
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


function   pay_order.savePayOrder(orderTable)
    local db = {
        transaction_id = orderTable["transactionId"],
        order_id = orderTable["orderId"],
        user_id = orderTable["userId"],
        game_id = orderTable["gameId"],
        item_id = orderTable["itemId"],
        item_name = orderTable["itemName"],
        unit_price = orderTable["unitPrice"],
        quantity = orderTable["quantity"],
        image_url = orderTable["imageUrl"],
        description = orderTable["description"],
    }
    return schema_world.PayOrder:insert(db["transaction_id"], db);
end


function   pay_order.queryPayOrder(orderId)
    local status  =  0 ;
    local result = chema_world.PayOrder:load(db["transaction_id"], orderId);
    status = result.status;
    if  result then
        status = result.status;
    end
    return status;
end

function pay_order:imitate_recharge(must_params)
    print(must_params["server_id"])
    return pay_order:call_game_server(must_params.server_id, must_params)
end

-- 向指定游戏服务器发送pay指令
function pay_order:call_game_server(server_id, args)
    return pay_order:call_server(string.format("s%d_game", server_id),
            ".agent", 'lc_yunwei_gm', args)
end

function pay_order:call_server(node_name, service_name, func_name, ...)
    local ok, is_success, data = pcall(cluster_utils.call,
            node_name, service_name, func_name, ...)
    print(data)
    if not ok then
        return ({code=ERR.server_error, err_msg="服务器出错"})
    elseif not is_success then
        return ({code=ERR.server_error, err_msg=data or ""})
    end
    return ({code=ERR.ok, data=data or {}})
end

return pay_order
