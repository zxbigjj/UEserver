local lua_handles = DECLARE_MODULE("lua_handles")
local login_utils = require("login_utils")

function lua_handles.ls_insert_role_info(...)
    return login_utils.insert_role_info(...)
end

function lua_handles.ls_update_role_info(...)
    return login_utils.update_role_info(...)
end

function lua_handles.ls_delete_role(...)
	return login_utils.delete_role(...)
end

function lua_handles.lc_check_login(...)
    return login_utils.check_login(...)
end

return lua_handles