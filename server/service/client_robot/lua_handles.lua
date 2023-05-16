local lua_handles = DECLARE_MODULE("lua_handles")

function lua_handles.lc_start(conc, robot_name, func_name, index_start, index_end)
    require("robot_mgr").start(conc, robot_name, func_name, index_start, index_end)
end

return lua_handles