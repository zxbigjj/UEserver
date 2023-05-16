local skynet = require("skynet.manager")

local function clusterd()
    skynet.register(".clusterd")
    require("clusterd_utils").start()
    require("srv_utils.reload").start()
    g_log:info("clusterd start:", skynet.self())
end

local function init()
    require("skynet.sharedata")
end

init()
skynet.start(clusterd)