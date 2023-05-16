local MOD = DECLARE_MODULE("schema_login")

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

MOD.ALL_COLLECTION = {}

local F = require("schema_common")
require("srv_utils.reload").bind_reload(F, MOD)

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

COLLECTION("LoginRolesInfo", {
    primary = "id",
    db_name = "login_db",
    fields = {
        id = INT(nil, "int unsigned not null auto_increment"),
        urs = STR(nil, 'varchar(128)'),
        uuid = F.UUID,
        role_id = INT,
        name = F.NAME,
        server_id = INT,
        level = INT,
    },
    index_list = {
        "index urs (urs)",
        "unique pri_key (urs, uuid)",
    }
})

return MOD