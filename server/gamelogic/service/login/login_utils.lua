local login_utils = DECLARE_MODULE("login_utils")

local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local schema_login = require("schema_login")
local httpc = require "http.httpc"
local md5 = require "md5"
local json = require("cjson")
local cluster_utils = require("msg_utils.cluster_utils")

local http_route = {
    ["/test"] = "handle_test",
    ["/query_roles"] = "handle_query_roles",
    ["/query_server"] = "handle_query_server",
}

local function response(sock_id, ...)
    local ok, err = httpd.write_response(sockethelper.writefunc(sock_id), ...)
    if not ok then
        -- if err == sockethelper.socket_error , that means socket closed.
        skynet.error(string.format("http response fd = %d, %s", sock_id, err))
    end
end

function login_utils:listen_http()
    local port = skynet.getenv("http_port")
    local id = socket.listen("0.0.0.0", port)
    skynet.error("Listen web port:" .. port)
    socket.start(id , function(sock_id, addr)
        skynet.fork(function()
            login_utils:process_http(sock_id)
        end)
    end)
end

function login_utils:process_http(sock_id)
    socket.start(sock_id)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(sock_id), 8192*1024)
    if code then
        if code ~= 200 then
            response(sock_id, code)
        else
            local ret = "Error"
            local path, query = urllib.parse(url)
            if query then
                local func = http_route[path]
                if func then
                    ret = login_utils[func](login_utils, urllib.parse_query(query))
                end
            end
            response(sock_id, code, ret)
        end
    else
        if url == sockethelper.socket_error then
            skynet.error("socket closed")
        else
            skynet.error(url)
        end
    end
    socket.close(sock_id)
end

function login_utils.db_init()
    require("db.schema").check_refresh_schema('schema_login')
end

function login_utils.update_role_info(urs, uuid, key, value)
    schema_login.LoginRolesInfo:set_field({urs=urs, uuid=uuid}, {[key] = (value==nil and SQL_NULL or value)})
end

function login_utils.insert_role_info(urs, uuid, role_info)
    role_info.uuid = uuid
    role_info.urs = urs
    schema_login.LoginRolesInfo:insert(nil, role_info)
end

function login_utils:handle_test(query)
    return "test ok"
end

function login_utils:handle_query_roles(query)
    local json = require("json")
    local role_list = schema_login.LoginRolesInfo:load_many({urs=query.urs})
    return json.encode(role_list or {})
end

function login_utils.delete_role(uuid, urs)
    login_utils.update_role_info(urs, uuid, "is_hide", true)
    return true
end

local SDK_CHECK = {
    ["gaea"] = "gaea_sdk_check_login",
    ["dev"] = "dev_test_check_login",
    ["hj"] = "hj_sdk_check_login",
}

function login_utils.create_gaea_sign(data, secretKey)
    local key_list = {}
    for k, v in pairs(data) do
        if type(k) == 'string' and v ~= '' then
            table.insert(key_list, k)
        end
    end
    table.sort(key_list)
    local str = ''
    for i, key in ipairs(key_list) do
        str = str .. key .. "=" .. data[key] .. "&"
    end
    str = str .."key=" .. secretKey
    local sign = string.lower(md5.sumhexa(str))
    return sign
end

function login_utils.create_hj_sign(data, secretKey)
    local key_list = {}
    for k, v in pairs(data) do
        if type(k) == 'string' and v ~= '' then
            table.insert(key_list, k)
        end
    end
    table.sort(key_list)
    local str = ''
    for i, key in ipairs(key_list) do
        str = str .. data[key] .. "#"
    end
    str = str .. secretKey
    local sign = string.lower(md5.sumhexa(str))
    return sign
end

function login_utils.gaea_sdk_check_login(data)
    local sdk_type = "gaea"
    local host = "account.gaeamobile.net"
    local url = "/api/check-login"
    local channel = "gameserver"
    local secretKey = "44a0336f92764a3a7b043a2a94daf027"
    local form = {
        loginToken = data.loginToken,
        channel = channel,
        isUserInfo = 1,
        sign = nil,
    }
    form.sign = login_utils.create_gaea_sign(form, secretKey)
    local code, ret_json = httpc.post(host, url, form)

    if code ~= 200 then
        return {ret_code = g_tips.error}
    end
    local ret_dict = json.decode(ret_json)
    if ret_dict.retCode ~= 0 or ret_dict.data.guid ~= data.guid then
        local err_msg = string.render(g_tips.login_fail, {err_num = ret_dict.retCode, err_msg = ret_dict.retCn})
        return {ret_code = g_tips.error, err_msg = err_msg}
    end
    return {ret_code = ret_dict.retCode, urs = sdk_type .. ":" .. ret_dict.data.guid, accountId = ret_dict.data.guid}
end

function login_utils.hj_sdk_check_login(data)
    local sdk_type = "hj"
    local host = "hj0.gaeamobile.net"
    local url = "/verify_new.php"
    local secretKey = "a1f4355ea0bc75b0d717c624971a6545"
    local form = {
        HJAppId = data.appId,
        HJChannel = data.channel,
        HJUid = data.userId,
        HJToken = data.token,
        HJSign = nil,
    }
    form.HJSign = login_utils.create_hj_sign(form, secretKey)
    local code, ret_json = httpc.post(host, url, form)
    if code ~= 200 then
        return {ret_code = g_tips.error}
    end
    local ret_dict = json.decode(ret_json)
    if ret_dict.retCode ~= 0 then
        local err_msg = string.render(g_tips.login_fail, {err_num = ret_dict.retCode, err_msg = ret_dict.retMsg})
        return {ret_code = g_tips.error, err_msg = err_msg}
    end
    return {ret_code = ret_dict.retCode, urs = sdk_type .. ":" .. form.HJUid, accountId = form.HJUid}
end

function login_utils.dev_test_check_login(data)
    if not data.guid then
        return {ret_code = g_tips.error, err_msg = "missing guid"}
    end
    return {ret_code = g_tips.ok, urs = "dev:" .. data.guid, accountId=data.guid}
end

function login_utils.check_login(data)
    local status, data = pcall(json.decode, data)
    local err_msg = nil
    if not status then
        err_msg = data
    elseif type(data) ~= "table" then
        err_msg = "param decode result is not table"
    elseif not data.type then
        err_msg = "param miss sdk type"
    elseif not SDK_CHECK[data.type] then
        err_msg = "param sdk type is error"
    end
    local check_result = nil
    if not err_msg then
        local check_func = SDK_CHECK[data.type]
        -- 注意各种SDK类型必须返回: {ret_code=?, err_msg=?}
        check_result = login_utils[check_func](data.param)
    else
        check_result = {ret_code = g_tips.error, err_msg = err_msg}
    end
    g_log:login("LoginCheck", {result = check_result})
    return check_result
end

function login_utils:handle_query_server(data)
    if not data.urs then
        return json.encode({status = 0, ["error"] = "missing urs"})
    end
    local role_list = schema_login.LoginRolesInfo:load_many({urs = data.urs})
    local server_list = {}
    for _, info in pairs(cluster_utils.get_game_server_dict()) do
        local game_info = {
            area = info.area_id,
            area_name = info.area_name,
            server_id = info.server_id,
            server_name = info.name,
            open_time = info.open_time,
            recommend_status = info.recommend_status,
            recommend_priority = info.recommend_priority,
            allow_login = info.allow_login,
            state = info.state,
            enable_ssl = info.enable_ssl,
        }
        if info.enable_ssl then
            game_info.addr = (info.ssh_ip or info.ip) .. ":" .. tostring(info.ssl_login_port)
        else
            game_info.addr = (info.ssh_ip or info.ip) .. ":" .. tostring(info.login_port)
        end
        table.insert(server_list, game_info)
    end
    --插入外服
    if false then
        table.insert(server_list, {
            area = 21,
            area_name = "外服区",
            server_id = 1,
            server_name = "外服1",
            open_time = '2023-03-01 00:00:00',
            recommend_status = 0,
            recommend_priority = 1,
            allow_login = 1,
            enable_ssl = false,
            state = 'free',
            addr = "182.61.57.26:10108",
        })
    end
    return json.encode({status = 0, data = {role_list = role_list, server_list = server_list}})
end

return login_utils
