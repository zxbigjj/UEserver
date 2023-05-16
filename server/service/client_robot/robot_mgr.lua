local robot_mgr = DECLARE_MODULE("robot_mgr")

DECLARE_RUNNING_ATTR(robot_mgr, "robot_dict", {})
DECLARE_RUNNING_ATTR(robot_mgr, "sock_mapper", {})
DECLARE_RUNNING_ATTR(robot_mgr, "total_count", 0)
DECLARE_RUNNING_ATTR(robot_mgr, "robot_account_list", {})

local host = skynet.getenv("test_host") or '127.0.0.1'
local port = tonumber(skynet.getenv("test_port") or 10315)

function robot_mgr.start(conc, robot_name, robot_func, index_start, index_end)
    local gate_utils = require("srv_utils.gate_utils")
    gate_utils.start(nil, 999999, 'M')

    gate_utils.set_recv_data_handle(robot_mgr.handle_c2s_msg)
    gate_utils.set_accept_sock_handle(robot_mgr.handle_accept_sock)
    gate_utils.set_close_sock_handle(robot_mgr.handle_close_sock)

    robot_mgr.add_robot_group(robot_name, index_start, index_end, robot_func)
    for i=1, conc do
        skynet.fork(function() robot_mgr.login_worker() end)
    end
end

function robot_mgr.handle_c2s_msg(sock_id, data)
    local robot = robot_mgr.sock_mapper[sock_id]
    if robot then
        robot:on_recv(data)
    end
end

function robot_mgr.handle_close_sock(sock_id)
    local robot = robot_mgr.sock_mapper[sock_id]
    if robot then
        robot_mgr.sock_mapper[sock_id] = nil
        robot_mgr.robot_dict[robot.account] = nil
        robot_mgr.total_count = robot_mgr.total_count - 1
        robot:close()
    end
end

function robot_mgr:handle_accept_sock(sock_id)
    -- never get here
end

function robot_mgr.login_worker()
    while true do
        if #robot_mgr.robot_account_list == 0 then break end
        local info = robot_mgr.robot_account_list[1]
        local index = info.index_start

        info.index_start = index + 1
        if index > info.index_end then
            table.remove(robot_mgr.robot_account_list, 1)
        else
            local account = info.account .. "_" .. index
            local robot = require("robot").new(account, info.index_end)
            robot_mgr.robot_dict[account] = robot
            local ok, err = pcall(function()
                local sock_id = robot:connect(host, port)
                robot_mgr.sock_mapper[sock_id] = robot
                robot:login()
            end)
            if not ok then
                print('*************************************', err)
            end
            robot_mgr.total_count = robot_mgr.total_count + 1
            robot:log("LoginCount", robot_mgr.total_count)
            skynet.fork(function() robot[info.test_func](robot) end)
        end
    end
end

function robot_mgr.add_robot_group(account, index_start, index_end, test_func)
    table.insert(robot_mgr.robot_account_list, {
        account = account,
        index_start = index_start,
        index_end = index_end,
        test_func = test_func,
    })
end

return robot_mgr
