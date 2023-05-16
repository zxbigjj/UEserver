local cluster_utils = require("msg_utils.cluster_utils")
local timer = require("timer")
local json = require("json")

local ALL_GAME = {}

local addr_mgr = DECLARE_MODULE("addr_mgr")
DECLARE_RUNNING_ATTR(addr_mgr, "node_dict", {})
DECLARE_RUNNING_ATTR(addr_mgr, "_down_node_dict", {})
DECLARE_RUNNING_ATTR(addr_mgr, "_timer", nil, function()
    return timer.loop(3, function() addr_mgr.check_down_node() end) 
end)

function addr_mgr.broadcast_node_addr(node_name, addr)
    local data = {[node_name] = addr}
    for k, v in pairs(addr_mgr.node_dict) do
        if k~=node_name and v~="" then
            cluster_utils.send(k, ".clusterd", "ls_update_node_addr", data)
        end
    end
end

function addr_mgr.on_node_heartbreak(node_name, addr, refresh_all)
    addr_mgr._down_node_dict[node_name] = nil

    if addr_mgr.node_dict[node_name] == nil then
        -- 第一次心跳
        g_log:info("NodeUp", node_name, addr)
        addr_mgr.node_dict[node_name] = addr
        skynet.send(".clusterd", "lua", "ls_update_node_addr", {[node_name] = addr})
        addr_mgr.broadcast_node_addr(node_name, addr)
        cluster_utils.send(node_name, ".clusterd", "ls_update_node_addr", addr_mgr.node_dict)
        cluster_utils.send(node_name, ".clusterd", "ls_update_all_game", ALL_GAME)
        refresh_all = true
    else
        if addr_mgr.node_dict[node_name] ~= addr then
            -- 地址改变
            g_log:warn("NodeChange", node_name, addr_mgr.node_dict[node_name], addr)
            addr_mgr.node_dict[node_name] = addr
            skynet.send(".clusterd", "lua", "ls_update_node_addr", {[node_name] = addr})
            addr_mgr.broadcast_node_addr(node_name, addr)
        end
    end
    if refresh_all then
        cluster_utils.send(node_name, ".clusterd", "ls_update_node_addr", addr_mgr.node_dict)
        cluster_utils.send(node_name, ".clusterd", "ls_update_all_game", ALL_GAME)
    end
end

function addr_mgr.on_node_shutdown(node_name)
    addr_mgr._down_node_dict[node_name] = nil
    addr_mgr.node_dict[node_name] = ""
    g_log:warnf("NodeDown:%s", node_name)
    addr_mgr.broadcast_node_addr(node_name, "")
end

function addr_mgr.check_down_node()
    -- 3秒没收到心跳， 认为节点下线
    for k, v in pairs(addr_mgr._down_node_dict) do
        addr_mgr.node_dict[k] = ""
        g_log:errorf("NodeDown:%s", k)
    end
    if next(addr_mgr._down_node_dict) then
        for k, v in pairs(addr_mgr.node_dict) do
            if v~="" then
                cluster_utils.send(k, ".clusterd", "ls_update_node_addr", addr_mgr._down_node_dict)
            end
        end
    end

    -- 复位， 重新等待心跳
    addr_mgr._down_node_dict = {}
    for k, v in pairs(addr_mgr.node_dict) do
        if v~="" then
            addr_mgr._down_node_dict[k] = ""
        end
    end
end

function addr_mgr.start()
end

function addr_mgr.load_all_game()
    local file_path = skynet.getenv("config_path") .. "/all_game.json"
    local fobj = io.open(file_path)
    local json_str = fobj:read("a")
    fobj:close()
    ALL_GAME = json.decode(json_str)

    for k, v in pairs(addr_mgr.node_dict) do
        if v~="" then
            cluster_utils.send(k, ".clusterd", "ls_update_all_game", ALL_GAME)
        end
    end
end

skynet.timeout(1, function()
    addr_mgr.load_all_game()
end)


return addr_mgr