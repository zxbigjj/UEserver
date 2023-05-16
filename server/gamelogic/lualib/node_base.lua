local server_env = require('srv_utils.server_env')

local node_base = DECLARE_MODULE("node_base")

require('msg_utils.sproto_msg_env').init()

function node_base.launch_common_service()
    -- 小心，每个节点只能调用一次
    require("share_dict").init()
    
    local status, err = pcall(function()
        skynet.newservice('gamelog')
    end)
    if not status then
        print("gamelog start error!!!" .. err)
        skynet.abort()
    end

    status = xpcall(function()
        skynet.newservice('reload_watcher')
        local debug_console_port = tonumber(skynet.getenv('debug_console_port'))
        if debug_console_port then
            skynet.newservice('debug_console', debug_console_port)
        end
        -- skynet.newservice('share_game_data')
        skynet.newservice('common_init')
        skynet.newservice('clusterd')
    end, g_log.trace_handle)
    if not status then
        g_log:flush()
        skynet.abort()
    end
end

if node_base.__RELOADING then
    skynet.timeout(1, function() 
        skynet.send(".reload_watcher", "lua", "ls_x_reload_file", 
            {'./lualib/msg_utils/sproto_msg_utils.lua'})
    end)
end

return node_base