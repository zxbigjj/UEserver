local MOD = DECLARE_MODULE("schema_game")

local schema = require("db.schema")
local ANY = schema.ANY
local PLAIN = schema.PLAIN
local OBJ = schema.OBJ
local STR = schema.STR
local INT = schema.INT
local BIGINT = schema.BIGINT
local NUM = schema.NUM
local TS = schema.TS
local BOOL = schema.BOOL
local DICT = schema.DICT
local LIST = schema.LIST

local F = require("schema_common")
require("srv_utils.reload").bind_reload(F, MOD)

MOD.ALL_COLLECTION = {}

local function COLLECTION(name, args)
    MOD.ALL_COLLECTION[name] = schema.COLLECTION(MOD, name, args)
end

------------------------------ 几个特殊的表
-- t_uuid_alloc(
--     id int unsigned not null auto_increment, 
--     rand_key varchar(16),
--     primary key (id), 
--     unique (rand_key)
-- )
-- t_lua_schema(
--     name not null varchar(255),
--     lua_schema json,
--     primary key (name)
-- )

COLLECTION("ServerCore", {
    db_name = "gamedb",
    primary = "server_name",
    fields = {
        server_name = STR(nil, "varchar(32)"),
        last_role_num = INT(1),

        init_server_flag = BOOL,
        server_open_time = TS(0),
        last_hotfix_version = INT(0),

        last_daily_ts = TS(0),
        last_zero_daily_ts = TS(0),
        last_hour_ts = TS(0),

        last_dynasty_num = INT(0),
        last_arena_rank = INT,

        last_shutdown_ts = TS, -- 服务器关闭时间

        openservice_fund_cnt = INT(0), -- 基金购买人数

        last_global_mail_id = INT(0),
        last_question_id = INT(0),

        yw_roll_notice = ANY,
    }
})

----------------------------------
-- 玩家
COLLECTION("Player", {
    db_name = "gamedb",
    primary = "urs",
    fields = {
        urs = STR(nil, "varchar(128)"),
        uuid = F.UUID,
    },
})

local RoleItem = OBJ({
    guid = STR,
    item_id = INT,
    count = INT(1),
    star_lv = INT,         -- 装备升星等级
    refine_lv = INT,       -- 装备精炼等级
    refine_exp = INT,      -- 装备精炼总经验
    strengthen_lv = INT,   -- 装备强化等级
    strengthen_exp = INT,  -- 装备强化总经验
    smelt_lv = INT,        -- 装备炼化等级
    smelt_exp = INT,       -- 装备炼化经验
    lucky_value = INT,     -- 装备幸运值
    lineup_id = INT,       -- 装备穿戴的标识
    smelt_cost = DICT(INT,INT),    --炼化消耗（用于重生返回材料）
    refine_cost = DICT(INT,INT),    --精炼消耗（用于重生返回材料）
})

local SalonInfo = OBJ({
    salon_id = INT,
    lover_id = INT,
    rank = INT,
    integral = INT,
    pvp_id = INT,
    attr_point_dict = DICT(STR,INT),
})

-- 角色
COLLECTION("Role", {
    db_name = "gamedb",
    primary = "uuid",
    fields = {
        uuid = F.UUID,
        urs = STR(nil, "varchar(128)"), -- player key
        name = F.NAME,
        create_ts = TS(0),
        login_type = STR,    --登陆类型：dev, robot, gaea
        login_param = ANY,
        gata_param = ANY,
        init_flag = BOOL,
        hotfix_version = INT(0), -- 对应hotfix版本
        level = INT(1),
        exp = BIGINT(0),
        role_id = INT,
        flag_id = INT,           -- 旗帜id
        score = NUM(0),          -- 帮力
        max_score = NUM(0),
        fight_score = NUM(0),    -- 战力
        max_fight_score = NUM(0),
        login_ts = TS(0),
        logout_ts = TS(0),
        last_offline_ts = TS(0),
        guid = BIGINT(0),
        language = STR,
        vip = OBJ({
            vip_level = INT(0),
            vip_exp = INT(0),
            sell_gift = DICT(INT, BOOL, true),
            daily_gift = BOOL,
            vip_shop = DICT(INT, INT, true),  -- 键为物品id，值为购买次数
            gift_dict = DICT(INT, BOOL(false), true), -- vip等级 => 是否领过(false:未领/true:已领)
        },true),

        vitality = INT,
        vitality_ts = TS,
        random_num = INT(0),
        last_global_mail = INT(0),

        last_daily_ts = TS(0),
        last_weekly_ts = TS(0),
        last_hourly_ts = TS(0),

        currency = DICT(INT, INT(0), true),
        attr_dict = DICT(STR, NUM(0), true),
        raw_attr_dict = DICT(STR, NUM(0), true),
        bag_item_list = LIST(RoleItem, true),

        -- 运维相关
        yw_forbid_speak = OBJ({end_ts = TS, reason = STR}),
        yw_forbid_login = OBJ({end_ts = TS, reason = STR}),
        yw_gift_key = ANY,

        -- 新手指引
        guide_list = LIST(INT, true),              -- 所有未开始的指引组, element: 指引组id
        guide_dict = DICT(INT, INT, true),         -- 正在进行的指引组, key:组id, value:步骤,从0开始
        guide_locked_dict = DICT(INT, BOOL, true), -- 记录还没有解锁的功能, true: 已锁定, nil: 已解锁
        guide_event_dict = DICT(INT, BOOL, true),  -- 记录指引中触发的事件, nil: 未触发, true: 已触发

        -- 宝物
        treasure_dict = DICT(INT, DICT(INT, INT), true),

        info = OBJ({
            num = INT,
            info_id = INT,
            item_id = INT,
            count = INT,
            last_time = TS,
        },true),
        cmd_list = LIST(OBJ{
            num = INT,
            last_time = TS,
        },true),

        -- 英雄
        hero_dict = DICT(INT, OBJ({
            hero_id = INT,
            level = INT(1),
            score = NUM(0),
            attr_dict = DICT(STR, NUM(0), true),
            raw_attr_dict = DICT(STR, NUM(0), true),
            spell_dict = DICT(INT, INT, true),
            fate_dict = DICT(INT, BOOL, true),
            break_lv = INT(0),                                       -- 突破等级
            star_lv = INT(0),                                        -- 升星等级
            destiny_lv = INT(1),                                     -- 天命等级
            destiny_exp = INT(0),                                    -- 天命值
            destiny_lv_cost = INT(0),                                -- 天命升级总消耗
            destiny_curr_cost = INT(0),                              -- 天命当前等级消耗
            book_attr_dict = DICT(STR, NUM, true),
            book_num = INT(0),
        }), true),
        hero_shop = OBJ({
            refresh_ts = TS(0),
            free_refresh_num = INT(0),
            total_refresh_num = INT(0),
            shop_dict = DICT(INT, INT, true),
        }, true),

        -- 阵容
        lineup_dict = DICT(INT, OBJ({
            unlock_status = INT,
            pos_id = INT,
            hero_id = INT,
            lineup_id = INT,
            equip_dict = DICT(INT, STR, true),
            strengthen_master_lv = DICT(INT, INT),     -- 强化大师等级
            refine_master_lv = DICT(INT, INT),         -- 精炼大师等级
            equip_info_dict = DICT(STR, RoleItem, true),  -- 装备详细信息
        }), true),

        -- 援军
        reinforcements_dict = DICT(INT, OBJ({
            pos_id = INT,
            hero_id = INT,
        }), true),

        -- 情人
        lover_dict = DICT(INT, OBJ({
            lover_id = INT,
            level = INT(1),                                         -- 亲密度
            exp = INT(0),
            grade = INT,                                            -- 品级
            old_grade = INT,
            power_value = INT(0),                                   -- 势力值
            children = INT(0),
            attr_dict = DICT(STR, NUM(0), true),
            spell_dict = DICT(INT, INT, true),                      -- 才艺
            fashion_id = INT,
            fashion_dict = DICT(INT, BOOL, true),
            other_fashion_dict = DICT(INT, BOOL, true),              -- 转性前的时装
            star_lv = INT(0),                                        -- 升星等级
        }), true),
        discuss_num = INT,
        discuss_ts = TS(0),
        is_first_dote_lover = BOOL,
        lover_train = OBJ({           -- 情人培训
            event_dict = DICT(INT, OBJ({
                event_id = INT,
                lover_id = INT,
                train_ts = TS,
                is_finish = BOOL,
            }), true),
            grid_num = INT,            -- 事件格子数
            quicken_num = INT,         -- 事件加速次数
        }),
        lover_shop = OBJ({
            refresh_ts = TS(0),
            free_refresh_num = INT(0),
            total_refresh_num = INT(0),
            shop_dict = DICT(INT, INT, true),
        }, true),

        child_grid_num = INT,
        child = DICT(INT, OBJ({
            child_id = INT,
            mother_id = INT,
            name = STR,
            child_status = INT,
            birth_time = INT,
            level = INT(0),
            grade = INT,
            exp = INT,
            sex = INT,
            vitality_num = INT,
            last_time = TS,
            attr_dict = DICT(STR, NUM, true),
            aptitude_dict = DICT(STR, NUM, true),              -- 资质
            apply_uuid = F.UUID,                            --结婚相关
            apply_type = INT,
            apply_time = TS,
            apply_role_name = STR,
            consume_item_id = INT,
            marry = F.ChildObject,
            display_id = INT,
        }), true),
        propose_object_list = LIST(F.ChildObject, true), --提亲请求
        is_first_child = BOOL,

        -- 狩猎
        hunt = OBJ({
            -- 积分
            history_point = INT(0),            -- 历史总狩猎积分
            hunt_shop = DICT(INT, INT(0), true),  -- 积分商店
            -- 猎场
            hunt_ground = DICT(INT, OBJ({
                ground_id = INT,
                animal_num = INT,              -- 已经猎杀的猎物数量
                animal_hp = INT,
                hero_list = LIST(INT),
                arrow_num = INT,               -- 剩余弓箭数
                first_reward = BOOL,           -- 首通奖励领取标志
            }), true),
            hero_dict = DICT(INT, BOOL, true), -- 出战英雄
            curr_ground = INT,                 -- 当前猎场
            -- 珍兽
            hunt_num = INT,                    -- 剩余狩猎珍兽次数
            add_hunt_num = INT,                -- 每天购买狩猎次数
            hunt_ts = INT,                     -- 狩猎珍兽时间
            listen_animal = INT,               -- 监视中的珍兽
        }),

        -- 竞技场
        arena = OBJ({
            history_rank = INT,
            win_num = INT(0),                    -- 连胜次数
            shop_dict = DICT(INT, INT(0), true),
        },true),

        -- 监狱
        prison = OBJ({
            criminal_num = INT(0),
            criminal_id = INT,
            torture_remain_num = INT,
        },true),

        -- 关卡
        stage = OBJ({
            curr_stage = INT,
            curr_part = INT,
            remain_enemy = INT,
            action_point = INT,
            fight_stage_ts = TS,
            stage_dict = DICT(INT, OBJ({
                state = INT,
                star_num = INT,
                victory_num = INT(0),
                first_reward = BOOL,
                reset_num = INT(0),
            }), true),
            -- 城市
            city_dict = DICT(INT, OBJ({
                manager_type = INT,
                manager_id = INT,
                star_num = INT(0),
                is_occupied = BOOL,     -- 被占领
                reward_dict = DICT(INT, BOOL, true)
            }), true),
            city_resource_ts = TS,
            resource_dict = DICT(INT, INT, true),   -- 城市产出资源
            -- 国家
            country_dict = DICT(INT, OBJ({
                occupy_city_num = INT(0),
                reward_dict = DICT(INT, BOOL, true),
            }), true),
        }),

        -- 秘密出行
        travel = OBJ({
            luck = OBJ({
                value = INT,
                set_value = INT,
                set_item_id = INT,
                restore_num = INT,
                restore_ts = TS,
            },true),
            strength_num = INT,
            last_time = TS,
            assign_travel_num = INT,
            area_unlock_dict = DICT(INT, INT, true),
            lover_meet = DICT(INT, OBJ({
                meet_id = INT,
                meet_num = INT,
            }),true),
        }, true),

        -- 邮件
        mail_dict = DICT(STR, OBJ({
            mail_guid = STR,
            mail_id = INT,
            content = STR,
            mail_args = ANY,
            title = STR,
            send_ts = TS,
            deadline_ts = TS,
            is_read = BOOL,
            is_get_item = BOOL,
            item_list = LIST(RoleItem),
        }), true),

        daily_dare_dict = DICT(INT, OBJ({
            dare_id = INT,
            difficult_dict = DICT(INT, INT),
            is_passing = BOOL,
        }), true),

        salon = OBJ({
            attr_point_count = INT,
            attr_point_count_limit = INT,
            attr_point_buy_num = INT(0),
            salon_dict =  DICT(INT, SalonInfo, true),
            old_salon_dict =  DICT(INT, SalonInfo, true),
            shop_dict = DICT(INT, INT, true),
            history_integral = INT(0),
        }, true),

        dare_tower = OBJ({
            pass_num = INT,
            max_tower = INT,
            dare_dict = DICT(INT, BOOL, true),
            treasure_dict = DICT(INT, BOOL, true),
        }, true),

        party = OBJ({
            party_id = INT,
            lover_id = INT,
            not_receive_invite = BOOL,
            invite_dict = DICT(F.UUID, INT, true),                -- 主动邀请,值为邀请状态
            receive_invite_dict = DICT(F.UUID, INT, true),        -- 接收到的邀请， 值为party_id
            open_dict = DICT(INT, BOOL, true),
            join_dict = DICT(INT, INT, true),  -- 每个情人当天只能开启/参加派对一次 , key为lover_id, value为party_id
            join_info = OBJ({
                party_id = INT,
                lover_id = INT,
                gift_id = INT,
                games_num = INT,
            }, true),                -- 参加派对
            shop_dict = DICT(INT, INT, true),
            history_integral = INT(0),
            free_ts = TS(0),
        }, true),
        -- 保存记录
        party_record_list = LIST(OBJ({
            end_type = INT,
            party_id = INT,
            party_type_id = INT,
            lover_id = INT,
            lover_level = INT,
            start_time = TS,
            end_time = TS,
            guests_list = LIST(OBJ({    -- 宾客
                role_info = F.RoleInfo,
                gift_id = INT,
            }), true),
            -- 砸场子
            enemy_info = OBJ({
                role_info = F.RoleInfo,
                interrupt_time = TS,
            }, true),
            -- record
            add_ratio = NUM,
            integral_count = INT,
        }),true),
        party_enemy_dict = DICT(F.UUID, OBJ({       -- 仇人
            uuid = F.UUID,
            interrupt_time = TS,
        }), true),

        friend = OBJ({
            handsel_gift = DICT(F.UUID, BOOL, true),  -- 赠送列表
            receive_gift = LIST(F.UUID, true),        -- 接收列表
            receive_gift_count = INT(0),
            apply_dict = DICT(F.UUID, TS, true),      -- 保存接收到的申请
            black_dict = DICT(F.UUID, BOOL, true),    -- 黑名单
            today_send = DICT(F.UUID, BOOL, true),    -- 今日赠送名单
        }, true),

        first_week = OBJ({
            task_info = DICT(INT, INT, true),         -- dict键为任务类型
            recive_info = DICT(INT, BOOL, true),      -- dict键为任务id
            half_sell = LIST(BOOL, true),
            daily_sell = LIST(DICT(INT, INT), true),
        }, true),

        daily_active = OBJ({
            task_dict = DICT(INT, OBJ({
                progress = INT(0),
                is_receive = BOOL,
            }), true),
            today_level = INT(0),
            unlock_chest_num = INT(0),
            chest_dict = DICT(INT, BOOL, true),
        }, true),

        -- 试炼
        train = OBJ({
            curr_stage = INT(1),
            history_star_num = INT(0),
            curr_star_num = INT(0),
            can_use_star_num = INT(0),
            layer_star_num_list = LIST(INT, true),
            add_attr_dict = DICT(STR, NUM, true),
            add_attr_id_list = LIST(INT, true),
            reset_num = INT(0),
            is_fail = BOOL(false),
            max_stage = INT(0),
            has_buy_treasure = BOOL(false)
        }, true),
        train_shop = DICT(INT, INT(0), true),
        -- 试炼副本
        train_war = OBJ({
            curr_war = INT(0),
            max_war = INT(0),
            fight_num = INT,
            buy_fight_num = INT(0),
        }, true),

        -- 王朝
        dynasty = OBJ({
            apply_dict = DICT(STR, TS, true),
            quit_ts = TS,
            daily_active = INT(0),
            active_reward = DICT(INT, BOOL, true),
            build_type = INT(0),
            build_progress_reward = DICT(INT, BOOL, true),
            task_dict = DICT(INT, OBJ({
                progress = INT,
                task_id = INT,
                is_finish = BOOL,
            }), true),
            spell_dict = DICT(INT, INT, true),
            challenge_reward = DICT(INT, BOOL, true),
            buy_challenge_num = INT(0),
            buy_attack_num = INT(0),
            shop_dict = DICT(INT, INT(0), true),
        }, true),

        -- 月签到
        check_in_monthly = OBJ({
            check_in_monthly_info_list = LIST(INT, true),
            chest_info_list = LIST(INT, true),
            recharge_integral = INT(0),
            today_active_replenish = BOOL,                  -- 今日活跃补签次数获得
            replenish_used_count = INT(0),                  -- 补签已使用次数
            replenish_count = INT(0),                       -- 补签总次数
            replenish_used_today = INT(0),                  -- 补签今日已使用次数
        }, true),

        -- 周签到
        check_in_weekly = OBJ({
            start_day = TS(0),
            cycle = INT(0),
            check_in_weekly_info_list = LIST(INT, true),
            luck_value = INT(0),
            luck_count = INT(0),
        }, true),

        -- 任务
        task = OBJ({
            group_id = INT,
            task_id = INT,
            progress = INT,
            is_finish = BOOL,
            task_type_dict = DICT(INT, INT),
        }, true),

        -- 成就
        achievement_dict = DICT(INT, OBJ({
            progress = INT,
            achievement_id = INT,
            is_reach = BOOL,
        }), true),

        traitor = OBJ({
            traitor_level = INT(1),
            challenge_ticket = INT,
            challenge_ts = TS,
            feats = INT(0),
            feats_reward = DICT(INT, BOOL, true),
            max_hurt = INT(0),
            total_hurt = INT(0),
            shop_dict = DICT(INT, INT(0), true),
            auto_kill = OBJ({
                quality_dict = DICT(INT, INT, true),
                is_share = BOOL,
                is_cost = BOOL,
            }, true),
        }, true),
        traitor_boss = OBJ({
            is_open = BOOL,
            challenge_recover_num = INT(0),
            challenge_num = INT(0),
            buy_challenge_num = INT(0),
            honour = INT(0),
            max_hurt = INT(0),
            reward_dict = DICT(INT, BOOL, true),
        }, true),

        recharge = DICT(INT, BOOL, true),
        first_recharge = BOOL,
        -- 每日单冲
        single_recharge = DICT(INT, OBJ({
            receive_count_dict = DICT(INT, INT),
            reach_dict = DICT(INT, INT(0)),
        }), true),
        -- 超值单冲
        worth_recharge = DICT(INT, OBJ({
            receive_count_dict = DICT(INT, INT),
            reach_dict = DICT(INT, INT(0)),
        }), true),
        -- 充值抽奖
        recharge_draw = OBJ({
            activity_id = INT,
            normal_award_list = LIST(INT, true),
            big_award_list = LIST(OBJ{
                award_id = INT,
                draw_num = INT(0),
                reach_list = LIST(INT, true),
            }, true),
            self_award_list = LIST(OBJ{
                award_id = INT,
                time = TS,
            }, true),
            free_num = INT(0),
            addition_num = INT(0),
            draw_count = INT,
            recharge_count = INT(0),
            shop_dict = DICT(INT, INT, true),
            last_refresh = TS,
        }, true),

        normal_shop = DICT(INT, INT, true),

        crystal_shop = OBJ({
            daily_item = DICT(INT, INT, true),
            week_item = DICT(INT, INT, true),
            refresh_shop_ts = TS(0),
        }, true),

        -- 限时活动
        activity = DICT(INT, OBJ({           -- key 为活动 id (ActivityData)
            progress_dict = DICT(INT, INT),  -- 活动的进度信息 key: 活动详情id, value: 活动进度数值
            reward_dict   = DICT(INT, INT),  -- 可以领取的奖励 key: 活动奖励id, value: CSConst.RewardState
        }), true),

        -- 冲榜活动
        rush_activity = DICT(INT, OBJ({ -- key 为活动 id
            start_ts   = TS,            -- 活动开始时间
            self_value = INT,           -- 玩家的活动数据
        }), true),

        -- 节日活动
        festival_group_id = INT, -- 节日活动组id (FestivalGroupData.id)
        festival_activity = DICT(INT, OBJ({ -- key: 小活动id (FestivalActivityData)
            reward_dict   = DICT(INT, INT), -- 奖励dict, key: reward_id, value: CSConst.RewardState
            progress_dict = DICT(INT, INT), -- 进度dict, key: CSConst.FestivalActivityType, value: 进度
            recharge_dict = DICT(INT, OBJ({remaining_times = INT, available_reward = INT})), -- 充值dict, key: 单笔充值id, value: {剩余充值次数, 奖励可领取次数}
            discount_dict = DICT(INT, INT), -- 折扣dict, key: 限时折扣id, value: 剩余购买次数
            exchange_dict = DICT(INT, INT), -- 兑换dict, key: 商品兑换id, value: 剩余兑换次数
        }), true),

        -- 定点体力
        fixed_action_point = OBJ({
            data_id       = INT, -- excel 表中的 id
            lover_id      = INT, -- 随机的一个情人 id
            reward_status = INT, -- 奖励领取状态 (pick|picked)
            last_init_ts  = TS,  -- 上次初始化的时间
        }, true),

        -- 开服基金
        openservice_fund = OBJ({
            is_buy         = BOOL,           -- 是否买过(true/false)
            fund_reward    = DICT(INT, INT), -- 基金奖励(RewardState)
            welfare_reward = DICT(INT, INT), -- 福利奖励(RewardState)
        }),

        -- 豪华签到, key: SingleRechargeData的id
        luxury_check_in = DICT(INT, OBJ({
            recharge_times = INT, -- 剩余充值次数
            reward_times   = INT, -- 剩余领奖次数
            reward_id      = INT, -- 奖励 id (RewardData)
            init_ts        = TS,  -- 初始化时间戳
        }), true),

        -- 天天充值送好礼
        daily_recharge = OBJ({
            id = INT,                     -- 活动id, DailyRechargeData.id
            cur_day = INT,                -- 当前是活动进行的第几天, 即 1..7
            reward_dict = DICT(INT, INT), -- key: 奖励表id, value: RewardState
            total_recharge_days = INT,    -- 累计充值天数
        }),

        -- 称号系统
        title = OBJ({
            is_worship = BOOL, -- 今天是否膜拜过教父, false:未膜拜, true:已膜拜
            wearing_id = INT, -- 当前正在佩戴的称号id
            title_dict = DICT(INT, TS), -- key: 已获得的称号id, value: 获得称号的时间
        }, true),

        -- 月卡, key: MonthlyCardData.id (已购买且还有效的)
        monthly_card = DICT(INT, OBJ({
            is_received    = BOOL, -- 今日是否领取过月卡奖励, false:没领过, true:已领过
            remaining_days = INT,  -- 剩余有效天数, 向上取整, 对于永久卡/终身卡, 值为nil
        }), true),

        -- 限时累充
        accum_recharge = OBJ({
            start_ts = TS, -- 活动开始时间(区分不同活动)
            level_gear = INT, -- 玩家等级所属档位(下标)
            recharge_amount = INT, -- 累计充值数额
            reward_state_dict = DICT(INT, INT), -- 奖励状态, k:SingleRechargeData.id, v:CSConst.RewardState
        }, true),

        -- 问卷调查
        questionnaire = OBJ({
            last_id = INT,
            reward_dict = DICT(INT, BOOL),
        }, true),

        -- 酒吧
        bar = OBJ({
            hero_dict = DICT(INT, INT), -- k:hero_id, v:剩余挑战次数
            lover_id = INT, -- 酒吧随机的情人id
            lover_cnt = INT, -- 情人的剩余挑战次数
            hero_already_refresh_cnt = INT, -- 英雄-今日刷新过多少次英雄列表
            hero_already_challenge_cnt = INT, -- 英雄-今日买过多少次挑战次数
            hero_remaining_challenge_cnt = INT, -- 英雄-还剩余多少次挑战次数
            lover_already_refresh_cnt = INT, -- 情人-今日刷新过多少次情人列表
            lover_already_challenge_cnt = INT, -- 情人-今日买过多少次挑战次数
            lover_remaining_challenge_cnt = INT, -- 情人-还剩余多少次挑战次数
        }, true),

        -- 评论
        not_comment = BOOL,
        comment_record = LIST(OBJ({
            comment_id = INT,
            star_num = INT,
            content = STR,
        }), true),

        -- 活動:世界boss
        world_boss = OBJ({
            hero_dict = DICT(INT, BOOL, true),
            curr_map = INT,
            world_boss_map = DICT(INT, OBJ({
                map_id = INT,
                world_boss_hp = INT,
                hero_list = LIST(INT),
                first_reward = BOOL,           -- 首通奖励领取标志
            }), true),
            max_hurt = INT(0),
            reward_dict = DICT(INT, BOOL, true),
        }),
    },
    index_list = {
        'index random_num (random_num)',
    },
})

COLLECTION("ChildPropose", {
    db_name = "gamedb",
    primary = "uuid",
    fields = {
        uuid = F.UUID,
        propose_object_dict = DICT(INT, F.ChildObject)
    },
})

-- 离线操作
COLLECTION("OfflineCmd", {
    db_name = "gamedb",
    primary = "id",
    fields = {
        id = INT(nil, "int unsigned not null auto_increment"),
        uuid = F.UUID,
        cmd = STR,
        version = INT,
        ts = TS,
        args = ANY,
    },
    index_list = {
        'index uuid (uuid)',
    },
})

-- 排行榜
COLLECTION("Rank", {
    primary = "rank_name",
    db_name = "gamedb",
    fields = {
        rank_name = STR(nil, 'varchar(64)'),
        role_list = LIST(OBJ({
            rank = INT,
            uuid = F.UUID,
            rank_score = NUM,
            level = INT,
            role_id = INT,
            vip = INT,
            name = STR,
            dynasty_name = STR,
        })),
        forbid_dict = DICT(F.UUID, BOOL, true),
    },
})

-- 往期排行榜
COLLECTION("RankHistory", {
    primary = "rank_name",
    db_name = "gamedb",
    fields = {
        rank_name = STR(nil, 'varchar(64)'),
        forbid_dict = DICT(F.UUID, BOOL, true),
        role_list = LIST(OBJ({
            rank = INT,
            uuid = F.UUID,
            rank_score = NUM,
            level = INT,
            role_id = INT,
            vip = INT,
            name = STR,
            dynasty_name = STR,
        })),
    },
})

-- 玩家名字
COLLECTION("RoleName", {
    primary = "name",
    db_name = "gamedb",
    fields = {
        name = F.NAME,
        uuid = F.UUID,
    },
})

-- 竞技场排行
COLLECTION("ArenaRank", {
    primary = "rank_start",
    db_name = "gamedb",
    fields = {
        rank_start = INT,
        role_list = LIST(OBJ({
            uuid = F.UUID,
            role_id = INT,
            rank = INT,
            name = STR,
            seed = INT,
        }))
    },
})

-- 叛军
COLLECTION("Traitor", {
    primary = "traitor_guid",
    db_name = "gamedb",
    fields = {
        traitor_guid = STR(nil, 'varchar(64)'),
        traitor_id = INT,
        traitor_level = INT,
        appear_ts = TS,
        quality = INT,
        max_hp = INT,
        hp_dict = DICT(INT, INT),
        role_name = STR,
        is_share = BOOL,
    },
})

-- 叛军boss
COLLECTION("TraitorBoss", {
    primary = "boss_id",
    db_name = "gamedb",
    fields = {
        boss_id = STR(nil, 'varchar(64)'),
        boss_level = INT(1),
        is_open = BOOL,
        max_hp = INT,
        hp_dict = DICT(INT, INT),
        revive_ts = TS,
        challenge_recover_num = INT,
        killed_role = STR,
    },
})

-- 冲榜活动
COLLECTION("RushActivity", {
    db_name = "gamedb",
    primary = "activity_id",
    fields = {
        activity_id = INT,
        start_ts = TS,
        stop_ts = TS,
        end_ts = TS,
    },
})

-- 冲榜称号历史档案
COLLECTION("RushActivityTitle", {
    db_name = "gamedb",
    primary = "title_id",
    fields = {
        title_id = INT, -- 称号id
        current_uuid = F.UUID, -- 当前获得者
        history_list = LIST(OBJ({ -- 历史获得者(最多20条)
            uuid = F.UUID, -- 玩家uuid
            ts = TS, -- 获得时间
        })),
    },
})

-- 世界boss配置信息
COLLECTION("WorldBoss", {
    primary = "boss_id",
    db_name = "gamedb",
    fields = {
        boss_id = STR(nil, 'varchar(64)'),
        boss_level = INT(1),
        is_open = BOOL,
        max_hp = INT,
        hp_dict = DICT(INT, INT),
        revive_ts = TS,
        challenge_recover_num = INT,
        killed_role = STR,
    },
})

-- 存档
COLLECTION("Archives", {
    db_name = "gamedb",
    primary = "uuid",
    fields = {
        uuid = F.UUID,
        archives_list = LIST(OBJ({
            ts = TS,
            level = INT,
            bin = STR,
        })),
    },
})

COLLECTION("GlobalMail", {
    primary = "guid",
    db_name = "gamedb",
    fields = {
        guid = STR(nil, 'varchar(64)'),
        last_global_mail_id = INT,
        -- 公有参数
        start_ts = INT,
        end_ts = INT,
        is_all_channel = BOOL,
        channel = STR,
        role_create_ts1 = TS,
        role_create_ts2 = TS,
        attach = ANY,
        title = DICT(STR, STR),
        content = DICT(STR, STR),
        deadline_ts = TS,
    },
})

-- 调查问卷
COLLECTION("Questionnaire", {
    primary = "guid",
    db_name = "gamedb",
    fields = {
        guid = STR(nil, 'varchar(64)'),
        question_id = INT,
        activity_id = INT,
        title = STR,
        start_ts = INT,
        end_ts = INT,
        role_minlv = INT,
    },
})


-- 订单
COLLECTION("order", {
    primary = "order_id",
    db_name = "gamedb",
    fields = {
        order_id = STR(nil, 'varchar(64)'),
        uuid = F.UUID,
        recharge_id = STR(nil, 'varchar(64)'),
        status = INT,
        pay_channel = STR(nil, 'varchar(64)'),
        local_price = NUM(0),
        product_number = INT,
        start_ts = STR(nil, 'varchar(64)'),
        end_ts = STR(nil, 'varchar(64)'),
        pay_ts = STR(nil, 'varchar(64)'),
        refund_ts = STR(nil, 'varchar(64)'),
    },
})

-- 月卡订单
COLLECTION("CardOrder", {
    primary = "order_id",
    db_name = "gamedb",
    fields = {
        order_id = STR(nil, 'varchar(64)'),
        uuid = F.UUID,
        card_id = STR(nil, 'varchar(64)'),
        status = INT,
        pay_channel = STR(nil, 'varchar(64)'),
        local_price = NUM(0),
        product_number = INT,
        start_ts = STR(nil, 'varchar(64)'),
        end_ts = STR(nil, 'varchar(64)'),
        pay_ts = STR(nil, 'varchar(64)'),
        refund_ts = STR(nil, 'varchar(64)'),
    },
})

-- 情人礼包订单
COLLECTION("LoverPackageOrder", {
    primary = "order_id",
    db_name = "gamedb",
    fields = {
        order_id = STR(nil, 'varchar(64)'),
        uuid = F.UUID,
        package_id = STR(nil, 'varchar(64)'),
        status = INT,
        pay_channel = STR(nil, 'varchar(64)'),
        local_price = NUM(0),
        product_number = INT,
        start_ts = STR(nil, 'varchar(64)'),
        end_ts = STR(nil, 'varchar(64)'),
        pay_ts = STR(nil, 'varchar(64)'),
        refund_ts = STR(nil, 'varchar(64)'),
    },
})


-- 情人礼包订单
COLLECTION("HeroPackageOrder", {
    primary = "order_id",
    db_name = "gamedb",
    fields = {
        order_id = STR(nil, 'varchar(64)'),
        uuid = F.UUID,
        package_id = STR(nil, 'varchar(64)'),
        status = INT,
        pay_channel = STR(nil, 'varchar(64)'),
        local_price = NUM(0),
        product_number = INT,
        start_ts = STR(nil, 'varchar(64)'),
        end_ts = STR(nil, 'varchar(64)'),
        pay_ts = STR(nil, 'varchar(64)'),
        refund_ts = STR(nil, 'varchar(64)'),
    },
})
-- 礼包订单
COLLECTION("GiftPackageOrder", {
    primary = "order_id",
    db_name = "gamedb",
    fields = {
        order_id = STR(nil, 'varchar(64)'),
        uuid = F.UUID,
        gift_id = STR(nil, 'varchar(64)'),
        status = INT,
        pay_channel = STR(nil, 'varchar(64)'),
        local_price = NUM(0),
        product_number = INT,
        start_ts = STR(nil, 'varchar(64)'),
        end_ts = STR(nil, 'varchar(64)'),
        pay_ts = STR(nil, 'varchar(64)'),
        refund_ts = STR(nil, 'varchar(64)'),
    },
})

-- 情人礼包活动配置
COLLECTION("LoverActivities",{
    primary="id",
    db_name="gamedb",
    fields={
        id = INT(nil, "int unsigned not null auto_increment"),
        server_id = INT,
        price = INT,
        discount = INT,
        icon = STR(nil, 'varchar(32)'),
        face_time = STR(nil, 'varchar(32)'),
        lover_id = INT,                 -- 情人unit id
        lover_fashion = INT,            -- 情人时装 id
        lover_piece = INT,              -- 情人碎片 id
        lover_type = INT,               -- 0,视频; 1,图片
        activity_name_fir = STR,
        activity_name_sec = STR,
        status = STR(nil,'varchar(20)'),
        item_list = LIST(OBJ({
            item_id=INT,
            count=INT,
        })),
        end_ts = INT,
        refresh_interval = INT,         -- 刷新间隔,秒
        purchase_count = INT,
        purchase_status = INT,          -- 0,没买; 1,买了
    },
})

-- 英雄礼包活动配置
COLLECTION("HeroActivities",{
    primary="id",
    db_name="gamedb",
    fields={
        id = INT(nil, "int unsigned not null auto_increment"),
        server_id = INT,
        price = INT,
        discount = INT,
        icon = STR(nil, 'varchar(32)'),
        hero_id = INT,
        hero_left_id = INT(-1),
        hero_right_id = INT(-1),
        activity_name_fir = STR,
        activity_name_sec = STR,
        status = STR(nil, 'varchar(20)'),
        item_list = LIST(OBJ({
            item_id = INT,
            count = INT,
        })),
        end_ts = INT,
        refresh_interval = INT,                     -- 刷新间隔,秒
        -- purchase_count = INT,
        purchase_status = INT,                      -- 0,没买; 1,买了
    },
})

-- 情人礼包购买记录表
COLLECTION("LoverActivitiesDealInfo", {
    primary = "id",
    db_name = "gamedb",
    fields = {
        id = INT(nil, "int unsigned not null auto_increment"),
        uuid = INT,
        lover_activity_id = INT,
        deal_count = INT(0),
        deal_time = TS,
    },
})

-- 英雄礼包购买记录表
COLLECTION("HeroActivitiesDealInfo", {
    primary = "id",
    db_name = "gamedb",
    fields = {
        id = INT(nil, "int unsigned not null auto_increment"),
        uuid = INT,
        hero_activity_id = INT,
        deal_count = INT(0),
        deal_time = TS,
    },
})

COLLECTION("RolePurchasedLoverActivities", {
    primary = "id",
    db_name = "gamedb",
    fields = {
        id = INT(nil, "int unsigned not null auto_increment"),
        uuid = F.UUID,
        activity_id = INT,
        lover_id = INT,
        lover_type = INT,               -- 0,视频; 1,图片
        reward_status = INT(0),            -- 0,没领取; 1,已领取
    },
})

COLLECTION("RolePurchasedHeroActivities", {
    primary = "id",
    db_name = "gamedb",
    fields = {
        id = INT(nil, "int unsigned not null auto_increment"),
        uuid = F.UUID,
        activity_id = INT,
        hero_id = INT,
        -- reward_status = INT(0), -- 0,没领取; 1,已领取
    },
})

COLLECTION("PayOrder", {
    db_name = "gamedb",
    primary = "transaction_id",
    fields = {
        transaction_id = STR(nil, "varchar(256)"),
        order_id = STR(nil, "varchar(256)"),
        status = STR(nil, "varchar(256)"),
        user_id = STR(nil, "varchar(256)"),
        game_id = STR(nil, "varchar(256)"),
        item_id = STR(nil, "varchar(256)"),
        item_name = STR(nil, "varchar(256)"),
        unit_price = NUM(0),
        quantity = NUM(0),
        image_url = STR(nil, "varchar(256)"),
        description = STR(nil, "varchar(256)"),
    },
})

COLLECTION("DailyGiftPackage", {
    db_name = "gamedb",
    primary = "id",
    fields = {
        id = INT(nil, "int unsigned not null auto_increment"),
        user_id = STR(nil, "varchar(256)"),
        reward_id = INT,
        reward_date = STR(nil, "varchar(256)"),
        reset_cycle = INT,
    },
})

return MOD