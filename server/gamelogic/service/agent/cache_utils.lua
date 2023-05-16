local role_cls = require("role_cls")
local date = require("sys_utils.date")
local timer = require("timer")

local cache_utils = DECLARE_MODULE("cache_utils")
local _role_dict = DECLARE_RUNNING_ATTR(cache_utils, "_role_dict", {})
local _time_dict = DECLARE_RUNNING_ATTR(cache_utils, "_time_dict", {})
local _clear_timer = DECLARE_RUNNING_ATTR(cache_utils, "_clear_timer", nil)

function cache_utils.get_role_info(uuid, key_list)
    local not_key_list
    local cache = _role_dict[uuid]
    if cache == nil then
        not_key_list = key_list
        cache = {}
        _role_dict[uuid] = cache
    else
        not_key_list = {}
        for _, key in ipairs(key_list) do
            if cache[key] == nil then
                table.insert(not_key_list, key)
            end
        end
    end

    if next(not_key_list) then
        local db_key_list = role_cls.read_db(uuid, not_key_list)
        if not db_key_list then return end
        for key, data in pairs(db_key_list) do
            cache[key] = data
        end
    end

    local role_info = {}
    for _, key in ipairs(key_list) do
        role_info[key] = cache[key]
    end
    _time_dict[uuid] = date.time_second()
    return role_info
end

function cache_utils.save_role_info(uuid, key, value)
    if _role_dict[uuid] then
        _role_dict[uuid][key] = value
        _time_dict[uuid] = date.time_second()
    end
    role_cls.write_db(uuid, key, value)
end

function cache_utils.clear_role_cache(uuid)
    _role_dict[uuid] = nil
    _time_dict[uuid] = nil
end

function cache_utils.start()
    _clear_timer = timer.loop(600, function() cache_utils.check_role_cache() end, 600)
end

function cache_utils.check_role_cache()
    local uuid_list = {}
    local now = date.time_second()
    for uuid, time in pairs(_time_dict) do
        if now-time >= 1800 then
            table.insert(uuid_list, uuid)
        end
    end
    for _, uuid in ipairs(uuid_list) do
        cache_utils.clear_role_cache(uuid)
    end
end

return cache_utils