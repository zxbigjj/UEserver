local skynet = require("skynet")
local lua_handles = DECLARE_MODULE("lua_handles")

function lua_handles.ls_node_heartbreak(node_name, addr, refresh_all)
    require("addr_mgr").on_node_heartbreak(node_name, addr, refresh_all)
end

function lua_handles.lc_node_shutdown(node_name)
    require("addr_mgr").on_node_shutdown(node_name)
end

return lua_handles