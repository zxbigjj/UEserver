local M = DECLARE_MODULE("msg_handles.bag")

function M.c_use_bag_item(role, args)
    local ret = role.bag:use_bag_item(args.item_guid, args.item_count, args.index)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_decompose_item(role, args)
    if role.bag:decompose_item(args.decompose_item_list) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_item_compose(role, args)
    if role.bag:item_compose(args.item_id, args.compose_count) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

return M