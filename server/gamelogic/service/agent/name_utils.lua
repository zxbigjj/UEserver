local excel_data = require("excel_data")
local co_lock = require("srv_utils.co_lock")
local schema_game = require("schema_game")
local httpc = require "http.httpc"
local md5 = require "md5"

local name_utils = DECLARE_MODULE("name_utils")
DECLARE_RUNNING_ATTR(name_utils, "_lock_mgr", nil, function() return co_lock.new_lock_mgr(10) end)

local MAX_RANDOM_NUM = 30

function name_utils.rand_role_name(sex)
    local name_data = excel_data.NameData[sex]
    local name
    for i = 1, MAX_RANDOM_NUM do
        local first_name = name_data[1][math.random(1, #name_data[1])]
        local last_name = name_data[2][math.random(1, #name_data[2])]
        name = first_name .. last_name
        if require("CSCommon.CSFunction").check_player_name_legality(name) then
            if not schema_game.RoleName:load(name) then
                break
            end
        end
    end
    return name
end

function name_utils.use_role_name(uuid, name)
    return name_utils._lock_mgr:run(name, function()
        if schema_game.RoleName:insert(name, {name=name, uuid=uuid}) then
            return true
        else
            return false
        end
    end)
end

function name_utils.is_role_name_repeat(name)
    if schema_game.RoleName:load(name) then
        return true
    end
end

function name_utils.match_user_name(name)
    return schema_game.RoleName:load(name)
end

function name_utils.unuse_role_name(name)
    return name_utils._lock_mgr:run(name, function()
        if schema_game.RoleName:delete(name) then
            return true
        else
            return false
        end
    end)
end

-- 4399平台检查字符串
function name_utils.sdk_4399_check_name(role_name)

    local host = "wo.webgame138.com"
    local url = "/test/matchService.do"
    local secret = "7de1103dacb5a1e5d861f8d24bafaa99" .. role_name
    local sign = md5.sumhexa(secret)

    local form = {
        app = "cydh",
        toCheck = role_name,
        byPinyin = 1,
        sig = sign,
    }
    
    local code, ret_json = httpc.post(host, url, form)
    if code ~= 200 then
        return {ret_code = g_tips.error}
    end

    return ret_json
end

return name_utils