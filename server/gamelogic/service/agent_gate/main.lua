local skynet = require("skynet")

local function start()
    require("msg_utils.cluster_utils").start()
    -- 启动gate
    local port = assert(tonumber(skynet.getenv('login_port')))
    local max_connect_num = assert(tonumber(skynet.getenv('LOGIN_MAX_CONNECTION')))
    require("srv_utils.gate_utils").start(port, max_connect_num, "S", 4)
    require("msg_handles")

    local lua_handles_utils = require('msg_utils.lua_handles_utils')
    lua_handles_utils.add_handle_module("lua_handles")
    
    skynet.register('.agent_gate')
    require("srv_utils.reload").start()
    g_log:info("agent_gate start:", skynet.self())
end

local function init()
end

init()
skynet.start(start)