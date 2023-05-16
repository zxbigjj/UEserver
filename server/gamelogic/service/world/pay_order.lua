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
local signature = "MIIBITANBgkqhkiG9w0BAQEFAAOCAQ4AMIIBCQKCAQBQQxM3UE0xWVqxnSfoYu4+XDICb+WTaZ87wGMFsSm7CizsniDVn0B+Xjptoz1PBSA7n0G5FOb7OPHpg8rH4gVoNcx9kZgBES5v7WX2Awr73wMHJiXMDR1KQA/iVRUzTXIz3k44U58qkkxljJ4SxKgxSmXmSJkK1vPSNdzvK9vN6zldqHV/iK7c/ZMiykWYUHUqwkQcCQM8+e4W+FJIGwHjiP6UOJRnQPsL5xCpTDkdzlJGyd6+cP8BCInWMrrWOvy1dJCl+Vl935/bU1bblApwEYUBh4SLsLEthbFPmXoqNUBKrWSrrcr486wpLq/FKM776LGiRt23DOCRY971AU1lAgMBAAE="

local Md5_Key= "epmmsj7wbqgomgj1y077u38e9wrqgr4k"
--测试
local callbackKey = "34477037442723932821589070372196"--test --"08682213938316890715589277849869"--
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
function MOD:__on_do_pay(args)
    print(args.transactionId)
    print("pay order args : " .. json.encode(args))
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
--XML获取字段对应值
local function getXMLValue(tempxml,key)
    g_log:info(tempxml)
	local tag1 = "<"..key..">"
	local tag2 = "</"..key..">"
	local a,start_ =string.find(tempxml, tag1)
    local end_,b=string.find(tempxml, tag2)
    g_log:info(""..start_..","..end_)
    local value = string.sub(tempxml,start_+1,end_-1)
	return value
end

--字符串分割函数 & 分隔
local function split(str, pattern)
    local result = {}
    string.gsub(str, pattern, function(w) table.insert(result, w) end)
    return result
end
-- 获取参数
local function getExtraValue(extra_params)
    g_log:info(string.format("[TEST_getExtraValue]:%s",extra_params))
	local singleStrList = split(extra_params,'[^&]+')
    local result = {}
    for i, v in ipairs(singleStrList) do
        g_log:info("[TEST_getExtraValue]:"..i..","..v)
        local params = split(v, '[^=]+')
      --  g_log:info("[TEST_getExtraValue]:#params"..#params)
        if #params == 2 then 
            local key = ""..params[1]
            result[key] = params[2]
            g_log:info(string.format("[TEST_getExtraValue]:%d,%s,%s",i,key,result[key]))
        end
    end
    return result
end
--校验签名
local function checkSign(nt_data,sign,md5Sign,key)   
    local md5SignLocal = string.lower(md5.sumhexa(nt_data..sign..key))
   -- local md5SignLocal_1 = string.lower(md5.sumhexa(nt_data..sign))
    g_log:info("[TEST checkSign]"..md5SignLocal)
    --g_log:info("[TEST checkSign]"..md5SignLocal_1)
    if md5SignLocal == md5Sign then
        return true
    else
        return false
    end
end
local function GetNumber(str)
	for s in string.gmatch(str, "%-?%d+%.?%d?") do 
		local i, j = string.find(str, s)
		if j>0 and j+1 < string.len(str)  then
			str = string.sub(str, j+1)
		else
			str =""
		end
		return s*1, str
	end
	return 0, ""
end
local function decodeString(str,key)
    if string.len(str) <1 then
		return '';
	end

	local list = {};
    local n = 0;
    while string.len(str) >0 do
        n,str = GetNumber(str)
       -- g_log:info("get number"..n)
        table.insert(list,n);
    end

    local keysByte = {}
   -- g_log:info("string.len(key)"..string.len(key)..","..key)
	for i= 1,string.len(key) do
        keysByte[i] = string.byte(key,i)
    end
	
    
	local dataByte = {};
    local parseStr = '';
	for i = 1 ,#list do
    --    g_log:info("tonumber(list[i])"..tonumber(list[i]))
    --    g_log:info("i % (#keysByte)"..(i % (#keysByte)))
        local index = (i % (#keysByte))
        if index <1 then
            index = #keysByte
        end
    --    g_log:info("keysByte[i % (#keysByte)]"..keysByte[index])
		dataByte[i] = tonumber(list[i]) - (0xff & tonumber(keysByte[index]));
        parseStr = parseStr ..string.char(dataByte[i])
    end

	if #dataByte < 1 then
		return '';
    end

	--local parseStr = bytesToString(dataByte);
	return parseStr;
end
local function getArgs(nt_data)
    -- nt_data 为xml字符串
  --  quicksdk_message = getXMLValue(nt_data,"quicksdk_message")
    g_log:info("nt_data:"..nt_data)
    --local message = getXMLValue(nt_data,"message")
    --g_log:info("message:"..message)
    local extras_params = getXMLValue(nt_data,"extras_params")
    g_log:info("extra_params:"..extras_params)
   -- g_log:info("extra_params:"..base64_to_bin(extras_params))

    local result = getExtraValue(extras_params)--(base64_to_bin(extras_params))
    return result
end
--test
local function testgetArgs()
    local call_back_url = "order_id=167645512455000002&uuid=55000002&server_id=55&type=4"
    local result = getExtraValue(call_back_url)
    return result
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

                --test
--[[                 g_log:info("Start test")
                local testargs = testgetArgs()
              --  g_log:info("order_id:",tonumber(testargs["order_id"]))
                ret = MOD[func](MOD, testargs)
                
                if  ret then
                    res = "SUCCESS"
                    response(id, code, "SUCCESS")
                else
                    res = "FAIL"
                    response(id, 110, "FAIL")
                end
                g_log:info("End test:"..res) ]]

                local args

                -- quick sdk
               
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
                    local nt_data_org = quickmessage["nt_data"]
                   -- g_log:info(string.format("[TEST_process]:ntdata=%s",nt_data_org))
                    local nt_data 
                    if nt_data_org ~=nil then
                        nt_data = decodeString(nt_data_org,callbackKey)
                    end

                    args = getArgs(nt_data)  

                    local sign_org = quickmessage["sign"]
--[[                     local sign
                    if sign_org ~= nil then
                        sign = decodeString(sign_org,callbackKey)
                    end ]]
                    local md5Sign = quickmessage["md5Sign"]
                   -- g_log:info(string.format("[TEST_process]:ntdata=%s",nt_data_org))
                --    g_log:info(string.format("[TEST_process]:ntdata=%s",nt_data))
                  --  g_log:info(string.format("[TEST_process]:sign=%s",sign))
                    g_log:info(string.format("[TEST_process]:md5Sign=%s",md5Sign))
                    if not checkSign(nt_data_org,sign_org,md5Sign,Md5_Key) then
                        g_log:warn("[TEST_process] check sign fail")                        
                        response(id, code, "FAIL")
                        socket.close(id)
                        return
                    end  
                                     
                
                --local  sign = header["X-Signature"]
                --print("pay order sign :"..sign)
                ret = MOD[func](MOD, args)
            end

            if  ret then
                res = "SUCCESS"
                response(id, code, "SUCCESS")
            else
                res = "FAIL"
                response(id, 110, "FAIL")
            end
            g_log:info("End test:"..res)
            
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
        return false--,"FAIL"--({ code = ERR.server_error, err_msg = "服务器出错" })
    elseif not is_success then
        return false--,"FAIL"({ code = ERR.server_error, err_msg = data or "" })
    end
    return true--,"SUCCESS"--({ code = ERR.ok, data = data or {} })
end

return MOD
