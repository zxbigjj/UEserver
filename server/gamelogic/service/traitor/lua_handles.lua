local lua_handles = DECLARE_MODULE("lua_handles")
local traitor_utils = require("traitor_utils")

function lua_handles.lc_get_traitor_data(...)
    return traitor_utils.get_traitor_data(...)
end

function lua_handles.lc_get_traitor_record(...)
    return traitor_utils.get_traitor_record(...)
end

function lua_handles.ls_enter_traitor(...)
    traitor_utils.enter_traitor(...)
end

function lua_handles.ls_quit_traitor(...)
    traitor_utils.quit_traitor(...)
end

function lua_handles.lc_occupy_pos(...)
    return traitor_utils.occupy_pos(...)
end

function lua_handles.ls_traitor_boss_open(...)
    traitor_utils.open()
end

function lua_handles.ls_traitor_boss_close(...)
    traitor_utils.close()
end

return lua_handles