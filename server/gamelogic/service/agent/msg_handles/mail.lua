local M = DECLARE_MODULE("msg_handles.mail")

function M.c_delete_mail(role, args)
    local ret = role.mail:quick_delete_mail(args.mail_type)
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_read_mail(role, args)
    if role.mail:read_mail(args.mail_guid) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_mail_item(role, args)
    local ret
    if args.mail_guid then
        ret = role.mail:get_mail_item(args.mail_guid)
    else
        ret = role.mail:quick_get_mail_item(args.mail_type)
    end
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

function M.c_get_all_mail(role, args)
    local ret = role.mail:get_all_mail()
    if ret then
        ret.errcode = g_tips.ok
        return ret
    end
    return g_tips.error_resp
end

return M