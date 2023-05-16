local MOD = DECLARE_MODULE("schema_dynasty")

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

local DynastyRoleInfo = OBJ({
    uuid = F.UUID,
    name = STR,
    level = INT,
    fight_score = NUM,
    score = NUM,
    role_id = INT,
    vip = INT,
    join_ts = TS,
    offline_ts = TS,
    job = INT,
    history_dedicate = INT,
    challenge_num = INT,                          -- 剩余挑战次数
    challenge_total_num = INT,                    -- 已挑战的总次数
    max_challenge_hurt = INT,                     -- 最高挑战伤害
    stage_box = DICT(INT, DICT(INT, BOOL)),       -- 挑战关卡的宝箱领取状态
    building_id = INT,                            -- 王朝争霸驻守建筑id
    total_mark = INT,                             -- 王朝争霸总战绩
    daily_mark = INT,                             -- 王朝争霸每日战绩
    attack_num = INT,                             -- 王朝争霸可用进攻次数
    compete_reward = DICT(INT, BOOL),             -- 王朝争霸奖励领取状态
    traitor_honour = INT,
})

COLLECTION("Dynasty", {
    primary = "dynasty_id",
    db_name = "gamedb",
    fields = {
        dynasty_id = STR(nil, 'varchar(64)'),
        dynasty_name = STR,
        dynasty_level = INT(1),
        dynasty_exp = INT(0),
        dynasty_badge = INT(1),
        is_init_badge = BOOL,
        dynasty_score = NUM(0),
        member_count = INT(1),
        dynasty_notice = STR,
        dynasty_declaration = STR,
        apply_dict = DICT(F.UUID, DynastyRoleInfo, true),
        member_dict = DICT(F.UUID, DynastyRoleInfo, true),
        build_progress = INT(0),               -- 建设进度
        build_num = INT(0),                    -- 建设次数
        spell_dict = DICT(INT, INT, true),     -- 王朝技能
        daily_refresh_ts = TS(0),
        rush_list_activity_exp = INT, -- 冲榜活动累计增长的经验
        traitor_honour = INT(0),

        -- 挑战
        challenge = OBJ({
            curr_stage = INT(1),
            max_victory_stage = INT(0),
            stage_dict = DICT(INT, OBJ({              -- 今日挑战的关卡数据
                janitor_dict = DICT(INT, OBJ({        -- 关卡守卫数据
                    max_hp = INT,
                    hp_dict = DICT(INT, INT),
                    reward_list = LIST(OBJ({
                        value = INT,
                        role_name = STR,
                    }))
                })),
            })),
            hurt_rank = LIST(OBJ({                    -- 挑战伤害排行
                rank = INT,
                uuid = F.UUID,
                max_hurt = INT,
            })),
            setting = DICT(INT, BOOL, true)
        }, true),

        -- 争霸
        compete = OBJ({
            is_open = BOOL,
            is_apply = BOOL,
            total_mark = INT(0),                      -- 总战绩
            attack_mark = INT(0),                     -- 每场攻打战绩
            defend_mark = INT(0),                     -- 每场防守战绩
            defend_info = DICT(STR, OBJ({             -- 防守详细信息
                dynasty_name = STR,
                building_dict = DICT(INT, INT),
            })),
            total_attack_num = INT(0),                -- 总进攻次数
            compete_index = INT(0),                   -- 场次
            building_dict = DICT(INT, OBJ({           -- 建筑信息
                member_dict = DICT(F.UUID, BOOL),
            })),
            enemy_dict = DICT(STR, OBJ({              -- 敌军信息
                dynasty_name = STR,
                building_dict = DICT(INT, OBJ({
                    building_hp = INT,
                    role_dict = DICT(F.UUID, INT),
                })),
            })),
        }, true)
    },
})

COLLECTION("DynastyRank", {
    primary = "rank_name",
    db_name = "gamedb",
    fields = {
        rank_name = STR(nil, 'varchar(64)'),
        dynasty_list = LIST(OBJ({
            rank = INT,
            dynasty_id = STR,
            rank_score = NUM,
            dynasty_name = STR,
            dynasty_level = INT,
            dynasty_badge = INT,
        }))
    },
})

return MOD