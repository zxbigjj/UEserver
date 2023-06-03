local MOD = DECLARE_MODULE("pay_order")
local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local json = require("json")
local schema_world = require("schema_world")
local cluster_utils = require("msg_utils.cluster_utils")
local httpc = require "http.httpc"
local md5 = require "md5"
local skynet_crypt = require("skynet.crypt")
local base64_to_bin = skynet_crypt.base64decode


--安卓
local Md5_Key= "epmmsj7wbqgomgj1y077u38e9wrqgr4k"
local callbackKey = "34477037442723932821589070372196"

local CONF_NAME = "transaction_id"

--ios 参数
local Md5_key_ios = "81740315100905102368857609511610"
local callbackKey_ios = "85976967478589410725549984181219"

local ROUTE = {
    ["/test"] = "on_test",
    ["/do_pay"] = "on_do_pay",
    ["/do_payios"] = "on_dopayios",
    ["/questionnaire"] = "on_questionnaire",
}

local ERR = {
    ok = 0,
    sign_error = 1001,
    args_error = 1002,
    server_error = 1003,
}


function MOD:quick_getByte(data, flag)
    local array = {}
    local lens = string.len(data)
    if (flag == false)
    then
        for i=1,lens do
            array[i] = string.byte(data, i)
        end
        return array
    else
        for i=1,lens do
            array[i-1] = string.byte(data, i)
        end
    end
    return array,lens
end

--function getChars(bytes)
--    local array = {}
--    for key, val in pairs(bytes) do
--        array[key] = string.char(val)
--    end
--    return array
--end

function MOD:quick_split( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

function MOD:encryptData(data, keys)
    local result = ""
    local dataArr = MOD:quick_getByte(data, false)
    local keyArr,keyLen = MOD:quick_getByte(keys, true)
    for index,value in pairs(dataArr) do
        result = result.."@"..tostring((0xFF and value) + (0xFF and keyArr[(index-1) % keyLen]))
    end
    return result
end

function MOD:decryptData(data, keys)
    local result = ""
    local dataArr = MOD:quick_split(data, '@')
    local keyArr,keyLen = MOD:quick_getByte(keys, true)
    for index,value in pairs(dataArr) do
          local bytes =  tonumber(value) - (0xFF and keyArr[(index-1) % keyLen])
          result = result..string.char(bytes)
    end
    return result
end


--校验签名
function MOD:checkSign(nt_data,sign,md5Sign,key)   
    local md5SignLocal = string.lower(md5.sumhexa(nt_data..sign..key))
    if md5SignLocal == md5Sign then
        return true
    else
        return false
    end
end

function MOD:getArgs(xml_data)
    local extras_params = MOD:getXMLValue(xml_data,"extras_params")
    print(extras_params)
    return MOD:getExtraValue(extras_params)--(base64_to_bin(extras_params))
end

--XML获取字段对应值
function MOD:getXMLValue(tempxml,key)
	local tag1 = "<"..key..">"
	local tag2 = "</"..key..">"
	local a,start_ =string.find(tempxml, tag1)
    local end_,b=string.find(tempxml, tag2)
    local value = string.sub(tempxml,start_+1,end_-1)
	return value
end

-- 获取参数
function MOD:getExtraValue(extra_params)
	local singleStrList = MOD:quick_split(extra_params,'&')
    local result = {}
    for i, v in ipairs(singleStrList) do
        local params = MOD:quick_split(v, '=')
        if #params == 2 then 
            local key = ""..params[1]
            result[key] = params[2]
        end
    end
    return result
end

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

-- 苹果商城
function MOD:on_dopayios(args)

    local sign = args["sign"]
    local md5Sign = args["md5Sign"]
    local ntdata = args["nt_data"]
    local isOK = MOD:checkSign(ntdata,sign,md5Sign,Md5_key_ios)
    if isOK  == false then
        return false --md5不通过
    end

    -- 解密
    local nXMLStr = MOD:decryptData(ntdata, callbackKey_ios)
    local jsonstr = MOD:getArgs(nXMLStr)
    print("pay ios order jsonstr : " .. json.encode(jsonstr))

    --发货
    return MOD:on_send_recharge(jsonstr)

end

function MOD:__on_do_pay(args)

    local sign = args["sign"]
    local md5Sign = args["md5Sign"]
    local ntdata = args["nt_data"]
    local isOK = MOD:checkSign(ntdata,sign,md5Sign,Md5_Key)
    if isOK  == false then
        return false --md5不通过
    end

    -- 解密
    local nXMLStr = MOD:decryptData(ntdata, callbackKey)
    local jsonstr = MOD:getArgs(nXMLStr)

    print("pay android order jsonstr : " .. json.encode(jsonstr))

    --发货
    return MOD:on_send_recharge(jsonstr)
end

function MOD:on_send_recharge(args)

    local type = args.type;
    local must_params = {}
    must_params["server_id"] = args.server_id
    must_params["uuid"] = args.uuid--user_id
    must_params["order_id"] = args.order_id--game_order
    if tostring(type) == tostring(1) then
        must_params["gm_name"] = "imitate_recharge"
    end

    if tostring(type) == tostring(2) then
        must_params["gm_name"] = "imitate_yueka_recharge"
    end

    if tostring(type) == tostring(3) then
        must_params["gm_name"] = "imitate_loverpackage_recharge"
    end

    if tostring(type) == tostring(4) then
        must_params["gm_name"] = "imitate_heropackage_recharge"
    end

    if tostring(type) == tostring(5) then
        must_params["gm_name"] = "imitate_giftpackage_recharge"
    end

    return MOD:imitate_recharge(must_params)
    
end

local function response(id, ...)
    local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
    if not ok then
        -- if err == sockethelper.socket_error , that means socket closed.
        print(string.format("fd = %d, %s", id, err))
    end
end

function MOD.start()
    local port = tonumber(40414)
    print("pay router listen port:" .. port)
    local id = socket.listen("0.0.0.0", port)
    print("pay router listen port:" .. port)
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
    if code then
        if code ~= 200 then
            response(id, code)
        else
            local ret = false--"非法请求"
            local res = "FAIL"
            local path, query = urllib.parse(url)
            local func = ROUTE[path]
            if func then
                local quickmessage
                if string.lower(method) == "post" then
                    if header["content-type"] == "application/json" then
                        quickmessage = body and json.decode(body) or {}
                    else
                        quickmessage = body and urllib.parse_query(body) or {}
                    end
                else
                    quickmessage = query and urllib.parse_query(query) or {}
                end

                ret = MOD[func](MOD, quickmessage)
            end

            if ret then
                res = "SUCCESS"
                response(id, code, res)
            else
                res = "FAIL"
                response(id, 110, res)
            end  
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

function MOD:savePayOrder(orderTable)
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

function MOD:imitate_recharge(must_params)
    print(must_params["server_id"])
    print("must_params"..json.encode(must_params))
    return MOD:call_game_server(must_params.server_id, must_params)
end

function MOD:validation_order(must_params)
    print(must_params["server_id"])
    return MOD:call_game_server(must_params.server_id, must_params)
end

-- 向指定游戏服务器发送pay指令
function MOD:call_game_server(server_id, args)
    return MOD:call_server(string.format("s%d_game", server_id),
            ".agent", 'lc_yunwei_gm', args)
end

function MOD:call_server(node_name, service_name, func_name, ...)
    local ok, is_success, data = pcall(cluster_utils.call,
            node_name, service_name, func_name, ...)
    print(data)
    if not ok then
        return false
    elseif not is_success then
        return false
    end
    return true
end

return MOD
