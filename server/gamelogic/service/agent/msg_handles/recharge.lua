local M = DECLARE_MODULE("msg_handles.recharge")
local json = require("json")
function M.c_recharge(role, args)
    if role.recharge:recharge(args.recharge_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_lover_recharge(role, args)
    print("c_lover_recharge :"..json.encode(args))
    if role.recharge:lover_recharge(args.package_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_hero_recharge(role, args)
    if role.recharge:hero_recharge(args.package_id) then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

--下单逻辑
function M.c_create_order(role, args)
    local ret = role.recharge:create_order(args.recharge_id)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

--下单逻辑
function M.c_create_yueka_order(role, args)
    local ret = role.recharge:create_yueka_order(args.card_id)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

--情人礼包下单逻辑
function M.create_lover_order(role, args)
    local ret = role.recharge:create_lover_order(args.package_id)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

--英雄礼包下单逻辑
function M.create_hero_order(role, args)
    local ret = role.recharge:create_hero_order(args.package_id)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

-- 创建礼包订单（每日礼包 ， 每周礼包 ， 终身礼包）
function M.c_create_gift_order(role, args)
    local ret = role.recharge:create_gift_order(args.gift_id)
    if ret then
        print( " c_create_gift_order data :"..json.encode(ret))
        return ret
    end
    return g_tips.error_resp
end


--订单查询
function M.c_query_order(role, args)
    local ret = role.recharge:query_order(args.order_id)
    if ret then
        return ret
    end
    return g_tips.error_resp
end

function M.c_receive_first_recharge_reward(role, args)
    if role.recharge:recive_first_recharge_gift() then
        return g_tips.ok_resp
    end
    return g_tips.error_resp
end

function M.c_receive_single_recharge_reward(role, args)
    if role.single_recharge:receive_reward(args.recharge_id, args.select_list) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

function M.c_recharge_worth_recharge(role, args)
    if role.worth_recharge:unlock_worth_recharge(args.recharge_id) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

function M.c_receive_worth_recharge_reward(role, args)
    if role.worth_recharge:receive_reward(args.recharge_id, args.select_list) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

function M.c_do_recharge_draw(role, args)
    local ret = role.recharge_draw:do_draw(args.activity_id, args.is_ten_draw)
    if ret then
        return ret
    else
        return g_tips.error_resp
    end
end

function M.c_get_recharge_draw_award_info(role, args)
    local ret = require("recharge_activity_utils").get_player_award(args.activity_id)
    return {award_list = ret}
end

function M.c_buy_recharge_draw_integral_shop(role, args)
    if role.recharge_draw:buy_integral_shop(args.shop_id, args.shop_num) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

return M