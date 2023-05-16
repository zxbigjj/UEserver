local skynet = require("skynet.manager")

local function service_start()
    local watcher_utils = require("watcher_utils")
    watcher_utils.start()
    
    skynet.register('.reload_watcher')
    -- 自己也可以reload
	require("srv_utils.reload").start(true)
    g_log:info("reload_watcher:", skynet.self())
end

local function init()
end

init()
skynet.start(service_start)
