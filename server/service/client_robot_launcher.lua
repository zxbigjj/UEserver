local skynet = require "skynet"
require 'skynet.manager'

skynet.start(function()
    -- 小心，每个节点只能调用一次
    require("share_dict").init()
    require("excel_data").load()

    local debug_console_port = tonumber(skynet.getenv('debug_console_port'))
    if debug_console_port then
        skynet.newservice('debug_console', debug_console_port)
    end

    require('msg_utils.sproto_msg_env').init()

    local robot_name = skynet.getenv("robot_name") or "rha"
    local robot_count = tonumber(skynet.getenv("robot_count") or 10)
    local robot_func = skynet.getenv("robot_func") or 'test_fight'
    local concurrency = tonumber(skynet.getenv("concurrency") or 10)

    local per_count = math.ceil(robot_count / 8)
    for i=1, 8 do
        local addr = skynet.newservice("client_robot")
        
        local index_start = (i-1) * per_count + 1
        local index_end = i * per_count
        if index_end > robot_count then
            index_end = robot_count
        end

        skynet.call(addr, 'lua', "lc_start", math.floor(concurrency/8), 
            robot_name, robot_func, index_start, index_end)
    end
    -- skynet.newservice('debug_console', 9001)
    print('client_robot start')
end)