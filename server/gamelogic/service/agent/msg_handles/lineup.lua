local M = DECLARE_MODULE("msg_handles.lineup")

function M.c_lineup_change_hero(role, args)
    if role.lineup:lineup_change_hero(args.hero_id, args.lineup_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_hero_adjust_pos_lineup(role, args)
    if role.lineup:adjust_pos_lineup(args.pos_dict) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_lineup_wear_equip(role, args)
    if role.lineup:lineup_wear_equip(args.lineup_id, args.part_index, args.item_guid) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_lineup_unwear_equip(role, args)
    if role.lineup:lineup_unwear_equip(args.lineup_id, args.part_index) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_lineup_strengthen_equip(role, args)
    if role.lineup:strengthen_equip(args.item_guid, args.cost_item_list) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_strengthen_equip_five_times(role, args)
    if role.lineup:strengthen_equip_five_times(args.item_guid) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_quick_strengthen_equip(role, args)
    if role.lineup:quick_strengthen_equip(args.lineup_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_lineup_refine_equip(role, args)
    if role.lineup:refine_equip(args.item_guid, args.cost_item_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_quick_refine_equip(role, args)
    if role.lineup:quick_refine_equip(args.item_guid, args.cost_item_dict) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_upgrade_equip_star_lv(role, args)
    if role.lineup:upgrade_equip_star_lv(args.item_guid) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_equip_smelt(role, args)
    local is_success, crit = role.lineup:equip_smelt(args.item_guid, args.cost_item_id)
    if is_success ~= nil then
        return {
            errcode = g_tips.ok,
            is_success = is_success,
            crit = crit
        }
    end
    return g_tips.error_resp
end

function M.c_equip_recover(role, args)
    if role.lineup:equip_recover(args.item_guid) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_reinforcements_change(role, args)
    if role.lineup:reinforcements_change(args.pos_id, args.hero_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

return M