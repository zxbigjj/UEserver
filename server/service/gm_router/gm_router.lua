local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local json = require("json")
local md5 = require("md5")
local cluster_utils = require("msg_utils.cluster_utils")

local gm_router = DECLARE_MODULE("gm_router")
local SIGN_MAX_TIME = 30
local SECRET_KEY = '8dFACTRDdNiAiYv6pV046UfJ147RzE37'

local ROUTE = {
    ["/test"] = "on_test",
    ["/do_gm"] = "on_do_gm",
    ["/questionnaire"] = "on_questionnaire",
}

local GMTYPE = {
    role = 'role',
    server = 'server',
    global = 'global',
}

local PTYPE = {
    int = 'int',
    str = 'str',
    float = 'float',
    list = 'list',
    dict = 'dict',
    bool = 'bool',
}

local GM_HANDLE = {
    -- 测试
    test = {
        type = GMTYPE.server,
        handle = 'gm_test',
        must_params = {
            server_id = PTYPE.int,
            content = PTYPE.str,
        },
    },

    -- 禁言
    forbid_speak = {
        type = GMTYPE.role,
        handle = 'gm_forbid_speak',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            duration = PTYPE.int,
        },
        opt_params = {'reason'},
    },

    -- 解除禁言
    undo_forbid_speak = {
        type = GMTYPE.role,
        handle = 'gm_undo_forbid_speak',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
        },
    },

    -- 查询禁言
    -- query_forbid_speak = {
    --     type = GMTYPE.role,
    --     handle = 'gm_query_forbid_speak',
    --     must_params = {
    --         server_id = PTYPE.int,
    --         uuid = PTYPE.str,
    --     },
    -- },

    -- 禁止登陆
    forbid_login = {
        type = GMTYPE.role,
        handle = 'gm_forbid_login',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            duration = PTYPE.int,
        },
        opt_params = {'reason'},
    },

    -- 解除禁止登陆
    undo_forbid_login = {
        type = GMTYPE.role,
        handle = 'gm_undo_forbid_login',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
        },
    },

    -- 查询禁止登陆状态
    -- query_forbid_login = {
    --     type = GMTYPE.role,
    --     handle = 'gm_query_forbid_login',
    --     must_params = {
    --         server_id = PTYPE.int,
    --         uuid = PTYPE.str,
    --     },
    -- },

    -- kick
    kick_role = {
        type = GMTYPE.role,
        handle = 'gm_kick_role',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
        },
    },

    -- 个人邮件
    role_mail = {
        type = GMTYPE.server,
        handle = 'gm_role_mail',
        must_params = {
            server_id = PTYPE.int,
            uuid_list = PTYPE.list,
            title = PTYPE.dict,
            content = PTYPE.dict,
            expire_ts = PTYPE.int,
        },
        opt_params = {'item_list'},
    },

    -- 全服邮件
    global_mail = {
        type = GMTYPE.server,
        handle = 'gm_global_mail',
        must_params = {
            server_id = PTYPE.int,
            title = PTYPE.dict,
            content = PTYPE.dict,
            expire_ts = PTYPE.int,
            role_create_ts1 = PTYPE.int,
            role_create_ts2 = PTYPE.int,
            channel = PTYPE.str,
            is_all_channel = PTYPE.bool,
            start_ts = PTYPE.int,
            end_ts = PTYPE.int,
        },
        opt_params = {'item_list'},
    },

    -- 查询邮件
    query_mail = {
        type = GMTYPE.role,
        handle = 'gm_query_mail',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
        },
    },

    -- 删除邮件
    delete_mail = {
        type = GMTYPE.role,
        handle = 'gm_delete_mail',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            mail_guid = PTYPE.str,
        },
    },

    -- 添加跑马灯公告
    add_roll_notice = {
        type = GMTYPE.server,
        handle = 'gm_add_roll_notice',
        must_params = {
            server_id = PTYPE.int,
            content = PTYPE.str,
            start_ts = PTYPE.int,
            end_ts = PTYPE.int,
            interval = PTYPE.int,
        },
    },

    -- 查询跑马灯公告
    query_roll_notice = {
        type = GMTYPE.server,
        handle = 'gm_query_roll_notice',
        must_params = {
            server_id = PTYPE.int,
        },
    },

    -- 修改服务器时间
    set_serverTimes = {
        type = GMTYPE.server,
        handle = 'gm_set_server_times',
        must_params = {
            server_id = PTYPE.int,
            servertime = PTYPE.int,
        },
    },

    -- 编辑跑马灯公告
    edit_roll_notice = {
        type = GMTYPE.server,
        handle = 'gm_query_roll_notice',
        must_params = {
            server_id = PTYPE.int,
            notice_id = PTYPE.int,
            content = PTYPE.str,
            start_ts = PTYPE.int,
            end_ts = PTYPE.int,
            interval = PTYPE.int,
        },
    },

    -- 删除跑马灯公告
    delete_roll_notice = {
        type = GMTYPE.server,
        handle = 'gm_delete_roll_notice',
        must_params = {
            server_id = PTYPE.int,
            notice_id = PTYPE.int,
        },
    },

    -- 改名
    rename_role = {
        type = GMTYPE.role,
        handle = 'gm_rename_role',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            new_name = PTYPE.str,
        },
    },

    -- 添加货币
    add_currency = {
        type = GMTYPE.role,
        handle = 'gm_add_currency',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            currency_id = PTYPE.int,
            count = PTYPE.int,
        },
    },

    -- 删除货币
    delete_currency = {
        type = GMTYPE.role,
        handle = 'gm_delete_currency',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            currency_id = PTYPE.int,
            count = PTYPE.int,
        },
    },

    -- 添加道具
    add_item = {
        type = GMTYPE.role,
        handle = 'gm_add_item',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            item_id = PTYPE.int,
            count = PTYPE.int,
        },
    },

    -- 查询所有服务器信息
    query_all_servers = {
        type = GMTYPE.global,
        handle = 'gm_query_all_servers',
        must_params = {
        },
    },

    -- 删除道具
    delete_item = {
        type = GMTYPE.server,
        handle = 'gm_delete_item',
        must_params = {
            server_id = PTYPE.int,
            guid = PTYPE.str,
            count = PTYPE.int,
        },
        opt_params = { 'uuid', 'name' }
    },

    -- 查询背包
    query_bag = {
        type = GMTYPE.role,
        handle = 'gm_query_bag',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
        },
    },

    -- 修改角色vip
    set_role_vip = {
        type = GMTYPE.role,
        handle = 'gm_set_role_vip',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            vip_level = PTYPE.int,
        },
    },

    -- 查询角色等级和经验
    query_role_level = {
        type = GMTYPE.role,
        handle = 'gm_query_role_level',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
        },
    },

    -- 修改角色等级
    set_role_level = {
        type = GMTYPE.role,
        handle = 'gm_set_role_level',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            level = PTYPE.int,
        },
    },

    -- 增加角色经验
    add_role_exp = {
        type = GMTYPE.role,
        handle = 'gm_add_role_exp',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            count = PTYPE.int,
        },
    },

    -- 扣除角色经验
    delete_role_exp = {
        type = GMTYPE.role,
        handle = 'gm_delete_role_exp',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            count = PTYPE.int,
        },
    },

    -- 排行版黑名单
    add_rank_forbid = {
        type = GMTYPE.role,
        handle = 'gm_add_rank_forbid',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            rank_id = PTYPE.str,
        },
    },

    -- 查询排行榜黑名单
    query_rank_forbid = {
        type = GMTYPE.server,
        handle = 'gm_query_rank_forbid',
        must_params = {
            server_id = PTYPE.int,
        },
    },

    -- 查询角色uuid
    query_uuid = {
        type = GMTYPE.server,
        handle = 'gm_query_uuid',
        must_params = {
            server_id = PTYPE.int,
            name = PTYPE.str,
        },
    },

    -- 复制角色
    copy_role = {
        type = GMTYPE.uuid,
        handle = 'gm_copy_role',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            from_server_id = PTYPE.int,
            from_uuid = PTYPE.str,
            name = PTYPE.str,
        },
    },

    -- 模拟充值
    imitate_recharge = {
        type = GMTYPE.role,
        handle = 'gm_imitate_recharge',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            recharge_id = PTYPE.int,
            count = PTYPE.int,
        },
    },

    -- 生成礼包码
    make_gift_key = {
        type = GMTYPE.global,
        handle = 'gm_make_gift_key',
        must_params = {
            --group_name = PTYPE.str,
            total_use_count = PTYPE.int,
            total_count = PTYPE.int,
            start_ts = PTYPE.int,
            end_ts = PTYPE.int,
            item_list = PTYPE.list,
        },
    },

    -- 查询礼包码
    query_gift_key = {
        type = GMTYPE.global,
        handle = 'gm_query_gift_key',
        must_params = {
            key = PTYPE.str,
        },
    },


    -- 插入订单
    save_pay_order = {
        type = GMTYPE.global,
        handle = 'gm_save_pay_order',
        must_params = {
            transactionId = PTYPE.str,
            userId = PTYPE.str,
            gameId = PTYPE.str,
            products = PTYPE.list,
        },
    },

    -- 关闭/打开礼包码兑换
    switch_gift_key = {
        type = GMTYPE.global,
        handle = 'gm_switch_gift_key',
        must_params = {
            channel = PTYPE.str,
            is_close = PTYPE.bool,
        },
    },

    -- 查询礼包码关闭状态
    query_gift_key_close = {
        type = GMTYPE.global,
        handle = 'gm_query_gift_key_close',
        must_params = {
        },
    },

    -- 查询所有道具信息
    query_all_item = {
        type = GMTYPE.global,
        handle = 'gm_query_all_item',
        must_params = {
        },
    },

    -- 查询玩家信息
    query_user_info = {
        type = GMTYPE.server,
        handle = 'gm_query_user_info',
        must_params = {
            server_id = PTYPE.int,
        },
        opt_params = { 'uuid', 'name' }
    },

    -- 添加调查问卷
    add_questionnaire = {
        type = GMTYPE.server,
        handle = 'gm_add_questionnaire',
        must_params = {
            server_id = PTYPE.int,
            activity_id = PTYPE.int,
            title = PTYPE.str,
            start_ts = PTYPE.int,
            end_ts = PTYPE.int,
            role_minlv = PTYPE.int,
        },
    },

    -----------------------------------------------------
    -- 添加情人礼包
    add_lover_activities = {
        type = GMTYPE.server,
        handle = 'gm_add_lover_activities',
        must_params = {
            server_id = PTYPE.int,
            activity_name_fir = PTYPE.str,
            activity_name_sec = PTYPE.str,
            status = PTYPE.str,
            lover_fashion = PTYPE.int, lover_piece = PTYPE.int,
            lover_id = PTYPE.int, lover_type = PTYPE.int,
            price = PTYPE.int, discount = PTYPE.int,
            icon = PTYPE.str, face_time = PTYPE.str,
            purchase_count = PTYPE.int,
            refresh_interval = PTYPE.int,
        },
        opt_params = { 'item_list' }
    },

    -- 修改情人礼包
    edit_lover_activities = {
        type = GMTYPE.server,
        handle = 'gm_edit_lover_activities',
        must_params = {
            server_id = PTYPE.int, id = PTYPE.int,
            activity_name_fir = PTYPE.str,
            activity_name_sec = PTYPE.str,
            status = PTYPE.str,
            lover_fashion = PTYPE.int, lover_piece = PTYPE.int,
            lover_id = PTYPE.int, lover_type = PTYPE.int,
            price = PTYPE.int, discount = PTYPE.int,
            icon = PTYPE.str, face_time = PTYPE.str,
            purchase_count = PTYPE.int,
            refresh_interval = PTYPE.int,
        },
        opt_params = { 'item_list' }
    },

    -- 查询情人礼包
    query_lover_activities = {
        type = GMTYPE.server,
        handle = 'gm_query_lover_activities',
        must_params = {}
    },

    -- 删除情人礼包
    del_lover_activities = {
        type = GMTYPE.server,
        handle = 'gm_del_lover_activities',
        must_params = {id = PTYPE.int, server_id = PTYPE.int}
    },

    -- set_lover_activities = {
    --     type = GMTYPE.server,
    --     handle = 'gm_set_lover_activities',
    --     must_params = {
    --         id = PTYPE.int, server_id = PTYPE.int,
    --         refresh_interval = PTYPE.int,
    --         status = PTYPE.str,
    --     }
    -- },

    -----------------------------------------------------
    -- 通过SQL语句查询
    query_by_sql = {
        type = GMTYPE.server,
        handle = 'gm_query_by_sql',
        must_params = {
            server_id = PTYPE.int, 
            cmd = PTYPE.str
        }
    },

    -----------------------------------------------------
    -- 添加英雄礼包
    add_hero_activities = {
        type = GMTYPE.server,
        handle = 'gm_add_hero_activities',
        must_params = {
            server_id = PTYPE.int,
            price = PTYPE.int,
            discount = PTYPE.int,
            hero_id = PTYPE.int,
            hero_left_id = PTYPE.int,
            hero_right_id = PTYPE.int,
            icon = PTYPE.str, status = PTYPE.str,
            purchase_count = PTYPE.int,
            refresh_interval = PTYPE.int,
            activity_name_fir = PTYPE.str,
            activity_name_sec = PTYPE.str,
        },
        opt_params = {'item_list'}
    },

    -- 修改英雄礼包
    edit_hero_activities = {
        type = GMTYPE.server,
        handle = 'gm_edit_hero_activities',
        must_params = {
            id = PTYPE.int,
            server_id = PTYPE.int,
            price = PTYPE.int,
            discount = PTYPE.int,
            hero_id = PTYPE.int,
            hero_left_id = PTYPE.int,
            hero_right_id = PTYPE.int,
            icon = PTYPE.str, status = PTYPE.str,
            -- purchase_count = PTYPE.int,
            refresh_interval = PTYPE.int,
            activity_name_fir = PTYPE.str,
            activity_name_sec = PTYPE.str,
        },
        opt_params = {'item_list'}
    },

    -- 查询英雄礼包
    query_hero_activities = {
        type = GMTYPE.server,
        handle = 'gm_query_hero_activities',
        must_params = {}
    },

    -- 删除英雄礼包
    del_hero_activities = {
        type = GMTYPE.server,
        handle = 'gm_del_hero_activities',
        must_params = {id = PTYPE.int, server_id = PTYPE.int}
    },

    -- set_hero_activities = {
    --     type = GMTYPE.server,
    --     handle = 'gm_set_hero_activities',
    --     must_params = {
    --         id = PTYPE.int,
    --         server_id = PTYPE.int,
    --         status = PTYPE.str,
    --         refresh_interval = PTYPE.int,
    --     }
    -- },

    -----------------------------------------------------
    -- 跳关
    set_role_stage_to = {
        type = GMTYPE.server,
        handle = 'gm_set_role_stage_to',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            stage = PTYPE.str,
        }
    },

    -----------------------------------------------------
    -- 王朝
    seek_dynasty = {
        type = GMTYPE.server,
        handle = 'gm_seek_dynasty',
        must_params = {
            server_id = PTYPE.int,
            dynasty_name = PTYPE.str,
        }
    },

    add_dynasty_exp = {
        type = GMTYPE.server,
        handle = 'gm_add_dynasty_exp',
        must_params = {
            server_id = PTYPE.int,
            uuid = PTYPE.str,
            dynasty_id = PTYPE.int,
            dynasty_exp = PTYPE.int,
        }
    },

    -----------------------------------------------------   Server
    get_charge_info = {
        type = GMTYPE.server,
        handle = 'gm_get_charge_info',
        must_params = {server_id = PTYPE.int,}
    },

    get_server_info_role_online = {
        type = GMTYPE.server,
        handle = 'gm_get_server_info_role_online',
        must_params = {server_id = PTYPE.int,}
    },

    get_server_list = {
        type = GMTYPE.global,
        handle = 'gm_get_server_list',
        must_params = {}
    },
}

local ERR = {
    ok = 0,
    sign_error = 1001,
    args_error = 1002,
    server_error = 1003,
}

local function response(id, ...)
    local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
    if not ok then
        -- if err == sockethelper.socket_error , that means socket closed.
        print(string.format("fd = %d, %s", id, err))
    end
end

function gm_router.start()
    local port = tonumber(skynet.getenv('gm_router_port'))
    local id = socket.listen("0.0.0.0", port)
    print("gm router listen port:" .. port)
    socket.start(id , function(id, addr)
        local hostname, port = addr:match"([^:]+):?(%d*)$"
        skynet.fork(function()
            gm_router.process(id)
        end)
    end)
end

function gm_router.process(id)
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
                    else
                        args = body and urllib.parse_query(body) or {}
                    end
                else
                    args = query and urllib.parse_query(query) or {}
                end
                ret = gm_router[func](gm_router, args)
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

function gm_router:on_test(args)
	local list = {}
	for k,v in pairs(args) do
		table.insert(list, string.format("%s=%s",k, v))
	end
	return table.concat(list, "\n")
end

function check_sign(args)
    local ts = tonumber(args.ts)
    if not ts then
        return false, "时间戳为空"
    end
    if ts < os.time() - SIGN_MAX_TIME then
        return false, "时间戳过期"
    end
    if not args.sign then
        return false, "签名为空"
    end
    local text = string.format("ts=%s&key=%s&data=%s", args.ts, SECRET_KEY, args.data)
    if md5.sumhexa(text) ~= args.sign then
        return false, "签名错误"
    end
    return true
end

local type_checker = {}
function type_checker.int(args, name)
    local value = math.floor(tonumber(args[name]))
    if value then
        args[name] = value
        return true
    end
    return false
end
function type_checker.str(args, name)
    args[name] = tostring(args[name])
    return true
end
function type_checker.float(args, name)
    local value = tonumber(args[name])
    if value then
        args[name] = value
        return true
    end
    return false
end
function type_checker.bool(args, name)
    if type(args[name]) == 'boolean' then return true end
    return false
end
function type_checker.list(args, name)
    if type(args[name]) == 'table' then return true end
    return false
end
function type_checker.dict(args, name)
    if type(args[name]) == 'table' then return true end
    return false
end
-- 执行Gm指令
-- 请求：ts=1552722348&data={"content": "hello", "server_id": 3, "gm_name": "test"}&sign=9720a0ae9e336b83e09a214c964a2a70
-- 回应：{'code': 0, 'data': 'test ok:hello'}
function gm_router:on_do_gm(args)
    g_log:info("RecvGm", args)
    local ret = gm_router:__on_do_gm(args)
    g_log:info("ret", ret)
    if ret and ret.code == ERR.ok then
        g_log:info("GmSuccess", ret)
    else
        g_log:info("GmFail", ret)
    end
    return json.encode(ret)
end
function gm_router:__on_do_gm(args)
    local ok, err_msg = check_sign(args)
    if not ok then
        return ({code=ERR.sign_error, err_msg=err_msg})
    end
    if not args.data or args.data == "" then
        return ({code=ERR.args_error, err_msg="data不能为空"})
    end

    local gm_args
    ok, gm_args = pcall(json.decode, args.data)
    if not ok then
        return ({code=ERR.args_error, err_msg="data的json格式错误"})
    end
    if type(gm_args) ~= 'table' then
        return ({code=ERR.args_error, err_msg="data必须是个字典"})
    end
    local gm_name = gm_args.gm_name
    if not gm_name or gm_name == "" then
        return ({code=ERR.args_error, err_msg="gm_name不能为空"})
    end
    if not GM_HANDLE[gm_name] then
        return ({code=ERR.args_error, err_msg="gm_name错误"})
    end

    local config = GM_HANDLE[gm_name]
    -- 必要参数
    for args_name, ty in pairs(config.must_params) do
        if gm_args[args_name] == nil then
            return ({code=ERR.args_error, err_msg="参数缺失：" .. args_name})
        end
        if not type_checker[ty](gm_args, args_name) then
            return ({code=ERR.args_error, err_msg="参数错误：" .. args_name})
        end
    end
    if config.type == GMTYPE.role then
        local server_id = cluster_utils.map_game_server_id(gm_args['server_id'])
        if not server_id then
            return ({code=ERR.args_error, err_msg="server_id错误"})
        end
        gm_args['server_id'] = server_id
        gm_args['uuid'] = tostring(gm_args['uuid'])
        if server_id ~= cluster_utils.get_role_server_id(gm_args['uuid']) then
            return ({code=ERR.args_error, err_msg="uuid与server_id不对应"})
        end
    elseif config.type == GMTYPE.server then
        local server_id = cluster_utils.map_game_server_id(gm_args['server_id'])
        if not server_id then
            return ({code=ERR.args_error, err_msg="server_id错误"})
        end
        gm_args['server_id'] = server_id
    end
    return self[config.handle](self, gm_args)
end

function gm_router:call_server(node_name, service_name, func_name, ...)
    local ok, is_success, data = pcall(cluster_utils.call,
        node_name, service_name, func_name, ...)
    if not ok then
        return ({code=ERR.server_error, err_msg="服务器出错"})
    elseif not is_success then
        return ({code=ERR.server_error, err_msg=data or ""})
    end
    return ({code=ERR.ok, data=data or {}})
end

-- 向指定游戏服务器发送GM指令
function gm_router:call_game_server(server_id, args)
    return gm_router:call_server(string.format("s%d_game", server_id),
        ".agent", 'lc_yunwei_gm', args)
end

------------------------------------------------handle---------------------
function gm_router:gm_test(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_forbid_speak(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_undo_forbid_speak(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_query_forbid_speak(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_forbid_login(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_undo_forbid_login(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_query_forbid_login(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_kick_role(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_role_mail(args)
    local uuid_list = args.uuid_list
    if not uuid_list or type(uuid_list) ~= 'table' then
        return ({code=ERR.args_error, err_msg="uuid_list错误"})
    end
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_global_mail(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_query_mail(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_delete_mail(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_add_roll_notice(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_query_roll_notice(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_edit_roll_notice(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_delete_roll_notice(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_rename_role(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_add_currency(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_delete_currency(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_add_item(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_query_all_servers(args)
    local servers = {
        [ 50 ] = {
            [ "build_time" ] = 20211101,
            [ "id" ] = 50,
            [ "ip" ] = "52.74.143.82",
            [ "name" ] = "内部服",
            [ "partition" ] = 100001,
            [ "port" ] = 15015,
        },
        [ 55 ] = {
            [ "build_time" ] = 20211101,
            [ "id" ] = 55,
            [ "ip" ] = "52.74.143.82",
            [ "name" ] = "外服",
            [ "partition" ] = 100001,
            [ "port" ] = 15515,
        }
    }
    local result  = {
        [ "code" ] = 0,
        [ "data" ] = servers,
    }
    return result
end

function gm_router:gm_delete_item(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_query_bag(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_query_uuid(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_add_rank_forbid(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_query_rank_forbid(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_make_gift_key(args)
    return self:call_server("s2801_world", ".world", 'lc_make_gift_key', args)
end

function gm_router:gm_query_gift_key(args)
    return self:call_server("s2801_world", ".world", 'lc_query_gift_key', args)
end

function gm_router:gm_save_pay_order(args)
    return self:call_server("s2801_world", ".world", 'lc_save_pay_order', args)
end

function gm_router:gm_query_gift_key_close(args)
    return self:call_server("s2801_world", ".world", 'lc_query_gift_key_close', args)
end

function gm_router:gm_switch_gift_key(args)
    return self:call_server("s2801_world", ".world", 'lc_switch_gift_key', args)
end

function gm_router:gm_set_role_vip(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_set_role_stage_to(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_query_role_level(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_query_user_info(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_set_role_level(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_add_role_exp(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_delete_role_exp(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_query_all_item(args)
    local item_list = {}
    for item_id, config in pairs(require("excel_data").ItemData) do
        if type(item_id) == 'number' then
            table.insert(item_list, {item_id=item_id, name=config.name})
        end
    end
    return ({code=ERR.ok, data={item_list=item_list}})
end

function gm_router:gm_copy_role(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_imitate_recharge(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_add_questionnaire(args)
    return self:call_game_server(args.server_id, args)
end

--修改服务器时间
function gm_router:gm_set_server_times(args)
    return self:call_game_server(args.server_id, args)
end

----------------------------------------------------- 情人礼包
function gm_router:gm_add_lover_activities(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_edit_lover_activities(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_del_lover_activities(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_query_lover_activities(args)
    return self:call_game_server(args.server_id, args)
end

-- function gm_router:gm_set_lover_activities(args)
--     return self:call_game_server(args.server_id, args)
-- end

----------------------------------------------------- 查询工具
function gm_router:gm_query_by_sql(args)
    return self:call_game_server(args.server_id, args)
end

----------------------------------------------------- 英雄礼包
function gm_router:gm_add_hero_activities(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_edit_hero_activities(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_del_hero_activities(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_query_hero_activities(args)
    return self:call_game_server(args.server_id, args)
end

-- function gm_router:gm_set_hero_activities(args)
--     return self:call_game_server(args.server_id, args)
-- end

----------------------------------------------------- 王朝
function gm_router:gm_seek_dynasty(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_add_dynasty_exp(args)
    return self:call_game_server(args.server_id, args)
end

-----------------------------------------------------   服务器信息
function gm_router:gm_get_charge_info(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_get_server_info_role_online(args)
    return self:call_game_server(args.server_id, args)
end

function gm_router:gm_get_server_list(args)
    return cluster_utils.get_game_server_dict()
end
-----------------------------------------------------

-------------------------- questionnaire callback
local function check_questionnaire_sign(args)
    if not args.sign then
        return false, "签名为空"
    end
    local key_list = {}
    for k, v in pairs(args) do
        if k ~= "sign" and type(k) == 'string' and v ~= '' then
            table.insert(key_list, k)
        end
    end
    table.sort(key_list)
    local str = ''
    for i, key in ipairs(key_list) do
        str = str .. key .. "=" .. args[key] .. "&"
    end
    local secret_key = 'b729d39fd6f4f4a0f10652d2bf5bb9b5'
    str = str .."key=" .. secret_key
    if args.sign ~= string.lower(md5.sumhexa(str)) then
        return false, "签名错误"
    end
    return true
end

function gm_router:on_questionnaire(args)
    local ok, err_msg = check_questionnaire_sign(args)
    local ret, server_id
    if not ok then
        ret = {code=ERR.sign_error, err_msg=err_msg}
    elseif not args.roleId then
        ret = {code=ERR.args_error, err_msg="参数缺失：roleId"}
    elseif not args.activityId then
        ret = {code=ERR.args_error, err_msg="参数缺失：activityId"}
    else
        server_id = cluster_utils.map_game_server_id(cluster_utils.get_role_server_id(args.roleId))
        if not server_id then
            ret = {code=ERR.args_error, err_msg="roleId错误"}
        end
    end
    if not ret then
        args = {
            gm_name = "questionnaire_reward",
            uuid = args.roleId,
            activity_id = tonumber(args.activityId),
        }
        ret = self:call_game_server(server_id, args)
    end
    if ret.code == ERR.ok then
        ret = {retCode = 0, retMsg = "ok"}
    else
        ret = {retCode = ret.code, retMsg = ret.err_msg}
    end
    return json.encode(ret)
end

return gm_router
