local skynet = require('skynet')
local server_env = require('srv_utils.server_env')

local game_srv = {
    [".agent"] =            'game',
    [".agent_gate"] =       'game',
    [".chat"] =             'chat',
    [".dynasty"] =          'dynasty',
}

local cross_srv = {

}

local min_cross_server_id = tonumber(skynet.getenv('min_cross_server_id'))
local self_server_id = tonumber(skynet.getenv("server_id"))

local utils = DECLARE_MODULE("launch_utils")

function utils.get_service_node_name(service, server_id)
    server_id = server_id or self_server_id
    if server_id < min_cross_server_id then
        return string.format("s%d_%s", server_id, game_srv[service])
    else
        return string.format("s%d_%s", server_id, cross_srv[service])
    end
end

return utils