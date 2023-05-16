local skynet = require("skynet.manager")

local function start_func()
    require("exceldataloader").start()
    require("srv_utils.reload").start()
    skynet.register('.share_game_data')
end

local function init()
    require("skynet.sharedata")
end
init()
skynet.start(start_func)