local skynet = require('skynet')
local ExcelData = require('excel_data')
local lua_handles_utils = require("msg_utils.lua_handles_utils")
local handle_modules = {
    'gate',
    'event',
    'child',
    'salon',
    'party',
    'role',
    'dynasty',
    'friend',
    'traitor',
    'gm',
}

local lua_handles = DECLARE_MODULE("lua_handles")

for _, mod_name in ipairs(handle_modules) do
    lua_handles_utils.add_handle_module('lua_handles.' .. mod_name)
end
lua_handles_utils.add_call_handle("lc_x_shutdown", function()
    agent_utils.shutdown()
end)
lua_handles_utils.add_call_handle("lc_x_gm", function(uuid, name, ...)
    local agent_gm = require("agent_gm")
    return agent_gm.on_gm(tonumber(uuid), name, table.concat({...}, " "))
end)

return lua_handles
