local M = DECLARE_MODULE("msg_handles.title")

function M.c_wearing_title(role, args)
    if role.title:wearing_title(args.title_id) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

function M.c_unwearing_title(role, args)
    if role.title:unwearing_title() then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

function M.c_worship_godfather(role, args)
    if role.title:worship_godfather() then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

function M.c_get_godfather_hall_data(role, args)
    local data = role.title:get_godfather_hall_data()
    if data then
        data.errcode = g_tips.ok
    else
        data = g_tips.error_resp
    end
    return data
end

return M