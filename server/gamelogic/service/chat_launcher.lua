local skynet = require "skynet"
require 'skynet.manager'

local ServerEnv = require 'srv_utils.server_env'

local node_base = require 'node_base'

skynet.start(function()
    local node_name = ServerEnv.get_node_name()
    assert(node_name, "no cluster node name")
    g_log:warn(string.format("[node %s]start begin", node_name))

    node_base.launch_common_service()
    require("excel_data").load()

    local cluster_utils = require("msg_utils.cluster_utils")
    cluster_utils.register_shutdown(function()
    end)
    while not cluster_utils.probe(nil, ".agent") do
        skynet.sleep(10)
    end
    skynet.uniqueservice("chat")

    require("srv_utils.reload").start()
    g_log:warnf('[node %s]all service booted', node_name)
    os.execute("rm status/" .. node_name .. ".starting")
end)