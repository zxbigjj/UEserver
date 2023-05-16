local M = DECLARE_MODULE("msg_handles.lover")

function M.c_lover_discuss(role, args)
    local ret = role.lover:lover_discuss()
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_recover_energy(role, args)
    if role.lover:recover_energy(args.item_count) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_upgrade_lover_spell(role, args)
    if role.lover:upgrade_lover_spell(args.lover_id, args.spell_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_give_lover_item(role, args)
    local ret
    if args.is_ten then
        ret = role.lover:give_ten_lover_item(args.lover_id, args.item_id)
    else
        ret = role.lover:give_lover_item(args.lover_id, args.item_id)
    end
    if ret then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_dote_lover(role, args)
    local ret = role.lover:dote_lover(args.lover_id)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_change_lover_fashion(role, args)
    if role.lover:change_lover_fashion(args.lover_id, args.fashion_id) then
        print("change lover fashion is success!")
        return g_tips.ok_resp
    end
    print("fail")
    return g_tips.error_resp
end

function M.c_change_lover_sex(role, args)
    local new_lover = role.lover:change_lover_sex(args.lover_id)
    if not new_lover then
        return g_tips.error_resp
    end
    return {errcode = g_tips.ok, new_lover = new_lover}
end

function M.c_change_lover_grade(role, args)
    if role.lover:change_lover_grade(args.lover_id, args.grade) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_lover_train(role, args)
    if role.lover:lover_train(args.lover_id, args.event_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_lover_train_quicken(role, args)
    if role.lover:lover_train_quicken(args.event_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_get_lover_train_reward(role, args)
    if role.lover:get_lover_train_reward(args.event_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_lover_unlock_event_grid(role, args)
    if role.lover:lover_unlock_event_grid() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_upgrade_lover_star_lv(role, args)
    if role.lover:upgrade_lover_star_lv(args.lover_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_query_lover_info(role, args)
    print("args:"..json.encode(args))
    local ret = role.lover:query_lover_info(args.lover_id)
    if ret then
        return ret
    end
    return  {errcode = g_tips.error}

    --print("test msg 2")
    --local msg_2 = {chat_type = 2,
    --               content = "test msg linhe",
    --               sender_uuid = 0
    --}
    --local launch_utils = require('launch_utils')
    --local cluster_utils = require("msg_utils.cluster_utils")
    --local node_name = launch_utils.get_service_node_name('.chat', 55)
    --print("node name  :"..node_name)
    --cluster_utils.lua_send(node_name, '.chat', "ls_broad_chat", "world",
    --        msg_2)
end

function M.c_buy_lover_shop_item(role, args)
    if role.lover:buy_lover_shop_item(args.shop_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_refresh_lover_shop(role, args)
    if role.lover:refresh_lover_shop() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_total_lover_discuss(role, args)
    local ret = role.lover:total_lover_discuss()
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_fondle_lover(role, args)
    local ret = role.lover:fondle_lover()
    if ret then
        return ret
    end
    return g_tips.error_resp
end

return M
