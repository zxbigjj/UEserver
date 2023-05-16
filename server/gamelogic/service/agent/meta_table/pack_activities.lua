local json = require("cjson")
local date = require("sys_utils.date")
local excel_data = require("excel_data")
local schema_game = require("schema_game")
local pack_activities_utils = require("pack_activities_utils")

local role_activities = DECLARE_MODULE("meta_table.pack_activities")
--------------------------------------------------------------  init
function role_activities.new(role)
    local self = {
        role = role,
        uuid = role.uuid,
        db = role.db,
    }
    return setmetatable(self, role_activities)
end

---------------------- timer

---------------------- common

---------------------- get

--------------------------------------------------------------  lover video



return role_activities