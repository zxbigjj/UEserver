local lua_handles = DECLARE_MODULE("lua_handles")
local rank_utils = require("rank_utils")

function lua_handles.ls_update_role_rank(...)
    rank_utils.update_role_rank(...)
end

function lua_handles.ls_update_role_info(...)
    rank_utils.update_role_info(...)
end

function lua_handles.lc_get_rank_list(...)
    return rank_utils.get_rank_list(...)
end

function lua_handles.lc_get_role_rank(...)
    return rank_utils.get_role_rank(...)
end

function lua_handles.lc_get_role_list(...)
    return rank_utils.get_role_list(...)
end

function lua_handles.ls_clear_rank_data(...)
    rank_utils.clear_rank_data(...)
end

function lua_handles.ls_add_rank_forbid(...)
    rank_utils.add_rank_forbid(...)
end

function lua_handles.lc_query_forbid_list(...)
    return rank_utils.query_forbid_list(...)
end

return lua_handles