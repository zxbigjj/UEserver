local M = DECLARE_MODULE("msg_handles.child")

function M.c_child_give_name(role, args)
    if role.child:child_give_name(args.child_id, args.name) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_child_education(role, args)
    if role.child:child_education(args.child_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_child_canonized(role, args)
    if role.child:child_canonized(args.child_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_child_grid(role, args)
    if role.child:child_grid_unlock() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_child_rename(role, args)
    if role.child:child_rename(args.child_id, args.name) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_child_use_item(role, args)
    if role.child:child_use_item(args.child_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_child_send_request(role, args)
    if role.child:send_request(args.child_id, args.apply_type, args.uuid, args.item_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_child_cancel_request(role, args)
    if role.child:driving_cancel_request(args.child_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_child_refuse_request(role, args)
    if role.child:driving_refuse_request(args.uuid, args.child_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_child_refuse_all_request(role, args)
    if role.child:driving_refuse_all_request() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_child_marriage(role, args)
    if role.child:driving_marriage(args.child_id, args.apply_type, args.object_uuid, args.object_child_id, args.item_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_child_marriage_confirm(role, args)
    if role.child:marriage_confirm_status(args.child_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_open_joint_marriage(role, args)
    return role.child:get_request_tables(args.sex, args.page_id, args.grade)
end

return M