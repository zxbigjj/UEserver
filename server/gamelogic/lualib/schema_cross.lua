local MOD = DECLARE_MODULE("schema_cross")

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
        party_id = INT(1),
    }
})

COLLECTION("ChildPropose", {
    db_name = "gamedb",
    primary = "uuid",
    fields = {
        uuid = F.UUID,
        propose_object_dict = DICT(INT, F.ChildObject)
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

COLLECTION("Salon", {
    primary = "day_index",
    db_name = "gamedb",
    fields = {
        day_index = INT,
        record_list = LIST(OBJ({
            salon_id = INT,
            pvp_id = INT,
            role_dict = DICT(F.UUID, OBJ({
                uuid = F.UUID,
                role_id = INT,
                name = STR,
                level = INT,
                vip = INT,
                attr_point_dict = DICT(STR, INT),
                lover = OBJ({
                    grade = INT,
                    level = INT,
                    lover_id = INT,
                    attr_dict = DICT(STR, NUM),
                }),
                index = INT,
                server_id = INT,
            })),
            round = LIST(OBJ({
                rank_list = LIST(OBJ({
                    uuid = F.UUID,
                    score = INT,
                })),
            })),
            total_rank = LIST(OBJ({
                uuid = F.UUID,
                score = INT,
            })),
        })),
    },
})

COLLECTION("Party",{
    db_name = "gamedb",
    primary = "party_id",
    fields = {
        party_id = INT,
        is_private = BOOL,
        party_info = OBJ({
            end_type = INT,
            party_id = INT,
            party_type_id = INT,
            host_info = F.RoleInfo,
            lover_id = INT,
            lover_level = INT,
            start_time = TS,
            end_time = TS,
            guests_list = LIST(OBJ({    -- 宾客
                role_info = F.RoleInfo,
                lover_id = INT,
                gift_id = INT,
                integral = INT,
                games_num = INT,
            }), true),
            -- 砸场子
            enemy_info = OBJ({
                role_info = F.RoleInfo,
                interrupt_time = TS,
            }, true),
            add_ratio = NUM,
            integral_count = INT,
        }),
    },
})

-- 王朝争霸
COLLECTION("DynastyCompete", {
    primary = "dynasty_id",
    db_name = "gamedb",
    fields = {
        dynasty_id = STR(nil, 'varchar(64)'),
        dynasty_name = STR,
        building_dict = DICT(INT, OBJ({
            member_dict = DICT(F.UUID, BOOL),
        })),
    },
})

return MOD