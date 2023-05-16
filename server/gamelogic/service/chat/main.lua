local skynet = require("skynet")

local function start()
    local cluster_utils = require("msg_utils.cluster_utils")
    cluster_utils.start()

    local lua_handles_utils = require('msg_utils.lua_handles_utils')
    lua_handles_utils.add_handle_module("lua_handles")

    skynet.register('.chat')

    if skynet.getenv("server_type") == "game" then
        while true do
            local ok = pcall(function() cluster_utils.call_agent(nil, nil, "lc_set_agent_start", "chat") end)
            if ok then break end
            skynet.sleep(10)
        end
    end
    require("srv_utils.reload").start()
    g_log:info("chat start:", skynet.self())
end

local function init()
end

init()
skynet.start(start)