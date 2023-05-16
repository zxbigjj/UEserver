local M = DECLARE_MODULE("CSCommon.sandbox")

local function _load_string(str, name, env)
    if _VERSION == "Lua 5.1" then
        local chunk = loadstring(str, name)
        setfenv(chunk, env)
        return chunk
    else
        return load(str, name, nil, env)
    end
end

local common_env = {}
common_env.print = print
common_env.ipairs = ipairs
common_env.pairs = pairs
common_env.next = next
common_env.tonumber = tonumber
common_env.tostring = tostring
common_env.type = type
common_env.math = math
common_env.string = string
common_env.table = table

local data_mgr = require("CSCommon.data_mgr")

common_env.GetData = function(data_name, key)
    local func = "Get" .. data_name
    return data_mgr[func] and data_mgr[func](data_mgr, key)
end

local grow_cache = {}
function M.get_hero_level_grow(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(hero_id, curr_level, curr_break_lv) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

function M.get_hero_level_cost(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(hero_id, next_level) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

function M.get_hero_break_cost(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(hero_id, next_break_lv) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

function M.get_hero_star_cost(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(hero_id, next_star_lv) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

function M.get_hero_star_attr(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(hero_id, curr_star_lv) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

function M.get_hero_destiny_attr(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(hero_id, curr_destiny_lv) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

function M.get_equip_strengthen_cost(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(item_id, next_strengthen_lv) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

function M.get_equip_star_cost(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(item_id, next_star_lv) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

function M.get_equip_smelt_cost(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(item_id, next_smelt_lv) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

function M.get_robot_hero_attr(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(hero_id, curr_level) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

function M.get_monster_attr(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(monster_id, curr_level) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

function M.get_dynasty_spell_cost(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(spell_id, next_level) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

function M.get_dynasty_spell_attr_value(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(spell_id, curr_level) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

function M.get_equip_star_attr_grow(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(item_id, curr_star_lv) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

function M.get_lover_star_cost(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(lover_id, next_star_lv) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

function M.get_lover_star_attr(key)
    local func = grow_cache[key]
    if not func then
        local str = string.format('return function(lover_id, curr_star_lv) %s end',
            data_mgr:GetGrowData(key).lua)
        func = _load_string(str, "growdata_" .. key, common_env)()
        grow_cache[key] = func
    end
    return func
end

return M