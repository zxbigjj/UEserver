local MOD = DECLARE_MODULE("schema_world")

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

COLLECTION("WorldConf", {
    primary = "conf_name",
    db_name = "world_db",
    fields = {
        conf_name = STR(nil, "varchar(32)"),
        conf_content = ANY,
    }
})

COLLECTION("GiftKeyBatch", {
    primary = "batch_id",
    db_name = "world_db",
    fields = {
        batch_id = INT,
        batch_key = STR,
        group_name = STR,
        total_use_count = INT,
        key_count = INT,
        start_ts = TS,
        end_ts = TS,
        item_list = ANY,
    }
})

COLLECTION("GiftKey", {
    db_name = "world_db",
    primary = "gift_key",
    fields = {
        gift_key = STR(nil, "varchar(16)"),
        use_count = INT(0),
    },
})

COLLECTION("PayOrder", {
    db_name = "world_db",
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


return MOD