local M = DECLARE_MODULE("msg_handles.activity")

-- 领取限时活动奖励
function M.c_activity_get_reward(role, args)
    if role.activity:get_activity_reward(args.reward_id) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

-- 获取限时活动排行
function M.c_activity_get_rank(role, args)
    local rank = role.activity:get_activity_rank(args.rank_name)
    if not rank then return g_tips.error_resp end
    return rank
end

-- 获取冲榜活动排行
function M.c_rush_activity_get_rank(role, args)
    local rank = role.rush_activity:get_activity_rank(args.rank_name)
    if not rank then return g_tips.error_resp end
    return rank
end

-- 获取王朝冲榜排行
function M.c_rush_activity_get_dynasty_rank(role, args)
    local rank_data = role.rush_activity:get_dynasty_rank()
    if rank_data then
        rank_data.errcode = g_tips.ok
    else
        rank_data = g_tips.error_resp
    end
    return rank_data
end

-- 获取冲榜活动排行(定时刷新)
function M.c_rush_activity_get_self_rank(role, args)
    local ret_data = role.rush_activity:get_self_rank(args.activity_id)
    if ret_data then
        ret_data.errcode = g_tips.ok
    else
        ret_data = g_tips.error_resp
    end
    return ret_data
end

-- 领取节日活动奖励
function M.c_pick_festival_activity_reward(role, args)
    if role.festival_activity:pick_reward(args.reward_id) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

-- 节日活动限时折扣
function M.c_buy_festival_activity_discount(role, args)
    if role.festival_activity:buy_discount(args.discount_id, args.discount_cnt) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

-- 兑换节日活动商品
function M.c_get_festival_activity_exchange(role, args)
    if role.festival_activity:get_exchange(args.exchange_id, args.exchange_cnt) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

-- 领取定点体力奖励
function M.c_get_fixed_action_point_reward(role, args)
    return role.action_point:pick_reward() or g_tips.error_resp
end

-- 购买开服基金
function M.c_buy_openservice_fund(role, args)
    if role.fund:buy_fund() then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

-- 领取基金奖励
function M.c_get_openservice_fund_reward(role, args)
    if role.fund:get_fund_reward(args.id) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

-- 领取全民奖励
function M.c_get_openservice_welfare_reward(role, args)
    if role.fund:get_welfare_reward(args.id) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

-- 领取豪华签到奖励
function M.c_receiving_luxurycheckin_reward(role, args)
    if role.luxury_check_in:receiving_reward(args.id) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

-- 领取天天充值奖励
function M.c_receiving_daily_recharge_reward(role, args)
    if role.daily_recharge:receiving_reward(args.reward_id) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

-- 购买月卡
function M.c_buy_monthly_card(role, args)
    if role.monthly_card:buy_card(args.card_id) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

-- 领取月卡奖励
function M.c_receiving_monthly_card_reward(role, args)
    if role.monthly_card:receiving_reward(args.card_id) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

-- 领取限时累充奖励
function M.c_receiving_accum_recharge_reward(role, args)
    if role.accum_recharge:receiving_reward(args.activity_id, args.select_index) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

-- 能否玩酒吧游戏
function M.c_can_play_bar_game(role, args)
    if role.bar:can_play_game(args.hero_id, args.lover_id) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

-- 酒吧普通挑战
function M.c_bar_general_challenge(role, args)
    local ret = role.bar:general_challenge(args.hero_id, args.lover_id,
                                           args.result)
    if ret then
        ret.errcode = g_tips.ok
    else
        ret = g_tips.error_resp
    end
    return ret
end

-- 酒吧快速挑战
function M.c_bar_quick_challenge(role, args)
    local ret = role.bar:quick_challenge(args.hero_id, args.lover_id)
    if ret then
        ret.errcode = g_tips.ok
    else
        ret = g_tips.error_resp
    end
    return ret
end

-- 购买酒吧挑战次数
function M.c_buy_bar_challenge_count(role, args)
    if role.bar:buy_challenge_count(args.bar_type, args.count) then
        return g_tips.ok_resp
    else
        return g_tips.error_resp
    end
end

-- 刷新酒吧英雄或情人
function M.c_refresh_bar_unit(role, args)
    if args.bar_type == CSConst.BarType.Hero then
        if role.bar:refresh_hero() then
            return g_tips.ok_resp
        else
            return g_tips.error_resp
        end
    elseif args.bar_type == CSConst.BarType.Lover then
        if role.bar:refresh_lover() then
            return g_tips.ok_resp
        else
            return g_tips.error_resp
        end
    else
        return g_tips.error_resp
    end
end

-- 获得正在进行的情人礼包活动
function M.c_get_ongoing_lover_activities(role, args)
    local res = role.lover_activities:get_ongoing_lover_activities()
    if res then res.errcode = g_tips.ok
    else res = g_tips.error_resp end
    return res
end

-- 获取已经购买的情人视频
function M.c_get_purchased_lover_videos(role, args)
    local res = role.lover_activities:get_purchased_lover_videos()
    if res then res.errcode = g_tips.ok
    else res = g_tips.error_resp end
    return res
end

function M.c_get_lover_video_reward(role, args)
    local res = role.lover_activities:get_lover_video_reward(args.lover_video_id)
    local ret = {}
    if res then
        ret.reward_status = 1
        ret.errcode = g_tips.ok
    else
        ret.reward_status = 0
        ret.errcode = g_tips.error
    end
    return ret
end

-- 获得正在进行的英雄礼包活动
function M.c_get_ongoing_hero_activities(role, args)
    local res = role.hero_activities:get_ongoing_hero_activities()
    if res then res.errcode = g_tips.ok
    else res = g_tips.error_resp end
    return res
end

-- 获得玩家当前状态的每日礼包
function M.c_get_detail_gift_package_list(role, args)
    local res = role.daily_gift_package_activities:get_all_gift_info(role)
    if res then res.errcode = g_tips.ok
    else res = g_tips.error_resp end
    return res
end

-- 获得玩家当前状态的每日礼包
function M.c_daily_zero_gift(role, args)
    local res = role.daily_gift_package_activities:daily_zero_gift(role , args.gift_id)
    if res then res.errcode = g_tips.ok
    else res = g_tips.error_resp end
    return res
end

return M
