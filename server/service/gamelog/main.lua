local skynet = require("skynet")

local function start()
    require("log_utils").start()
    
    skynet.register('.gamelog')
    skynet.timeout(300, function()
        require("srv_utils.reload").start()
        g_log:info("gamelog start:", skynet.self())
    end)
end

local function init()
end

init()
skynet.start(start)