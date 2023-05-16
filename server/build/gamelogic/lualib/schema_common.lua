local F = DECLARE_MODULE("schema_common")

local schema = require("db.schema")
require("srv_utils.reload").bind_reload(schema, F)

local ANY = schema.ANY
local PLAIN = schema.PLAIN
local OBJ = schema.OBJ
local STR = schema.STR
local INT = schema.INT
local BIGINT = schema.BIGINT
local NUM = schema.NUM
local BOOL = schema.BOOL
local TS = schema.TS
local DICT = schema.DICT
local LIST = schema.LIST

local function COLLECTION(name, args)
    return schema.COLLECTION(F, name, args)
end

F.UUID = STR(nil, 'varchar(16)')
F.COLOR = OBJ({r = NUM, g = NUM, b = NUM, a = NUM})
F.RECT = OBJ({x = NUM, y = NUM, width = NUM, height = NUM})
F.NAME = STR(nil, 'varchar(32)')

F.ChildObject = OBJ({
    uuid = F.UUID,
    role_name = F.NAME,
    child_id = INT,
    child_name = STR,
    sex = INT,
    grade = INT,
    attr_value = NUM,
    attr_dict = DICT(STR, NUM, true),
    aptitude_dict = DICT(STR, NUM, true),              -- 资质
    apply_time = TS,
    marry_time = TS,
    confirm_status = BOOL,
    display_id = INT,
})

F.RoleInfo = OBJ({
    uuid = F.UUID,
    name = F.NAME,
    level = INT,
    role_id = INT,
    vip = INT,
    server_id = INT,
})

return F
