local MOD = DECLARE_MODULE("gift_key")
local date = require("sys_utils.date")

local schema_world = require("schema_world")

local CONF_NAME = "gift_key"

DECLARE_RUNNING_ATTR(MOD, "conf", nil)
DECLARE_RUNNING_ATTR(MOD, "last_batch_id", 0)
DECLARE_RUNNING_ATTR(MOD, "batch_dict", {})
DECLARE_RUNNING_ATTR(MOD, "lock_dict", {})
DECLARE_RUNNING_ATTR(MOD, "cache", {})
DECLARE_RUNNING_ATTR(MOD, "cache_count", 0)
DECLARE_RUNNING_ATTR(MOD, "save_timer", nil, function()
    return require("timer").loop(10, function() MOD.save() end)
end)

function MOD.start()
    local list = schema_world.GiftKeyBatch:load_many()
    for _, batch in ipairs(list) do
        MOD.batch_dict[batch.batch_key] = batch
        if batch.batch_id > MOD.last_batch_id then
            MOD.last_batch_id = batch.batch_id
        end
    end

    local db = schema_world.WorldConf:load(CONF_NAME)
    if not db then
        db = {
            conf_name = CONF_NAME,
            conf_content = {}
        }
        schema_world.WorldConf:insert(CONF_NAME, db)
    end
    MOD.conf = db
end

local VALID_CHAR = '0123456789abcdefghijklmnopqrstuvwxyz'
local CHAR_COUNT = string.len(VALID_CHAR)
local CHAR_LIST = {}
local CHAR_DICT = {}
local CHAR2_LIST = {}
for i=1, CHAR_COUNT do
    table.insert(CHAR_LIST, string.sub(VALID_CHAR, i, i))
    CHAR_DICT[string.sub(VALID_CHAR, i, i)] = true
end
for i=1, CHAR_COUNT do
    for j=1, CHAR_COUNT do
        local xx = string.sub(VALID_CHAR, i, i) .. string.sub(VALID_CHAR, j, j)
        table.insert(CHAR2_LIST, xx)
    end
end

local function pack_batch_id(batch_id)
    local ret = ""
    for i=1,3 do
        ret = CHAR_LIST[1+(batch_id % CHAR_COUNT)] .. ret
        batch_id = math.floor(batch_id/CHAR_COUNT)
    end
    return ret
end

function MOD.check_str_valid(s)
    for i=1, string.len(s) do
        if not CHAR_DICT[string.sub(s, i, i)] then return false end
    end
    return true
end

function MOD.add_gift_batch(tag, total_use_count, key_count, start_ts, end_ts, item_list)
    local batch_id = MOD.last_batch_id + 1
    MOD.last_batch_id = batch_id
    local batch_key = pack_batch_id(batch_id)

    assert(string.len(tag) == 3)
    assert(batch_id < CHAR_COUNT * CHAR_COUNT * CHAR_COUNT)

    local info = {
        batch_id = batch_id,
        batch_key = batch_key,
        tag = tag,
        total_use_count = total_use_count,
        key_count = key_count,
        start_ts = start_ts,
        end_ts = end_ts,
        item_list = item_list,
    }

    MOD.batch_dict[batch_key] = info
    schema_world.GiftKeyBatch:insert(batch_id, info)

    -- 生成礼包码,3位tag  3位batch_key， 10位随机数
    local prefix = tag .. batch_key
    local rand_obj = math.new_rand()
    local words_count = #CHAR2_LIST
    local rand_dict = {}
    local left_count = key_count
    while left_count > 0 do
        local rand_list = {
            prefix,
            CHAR2_LIST[rand_obj:random(1, words_count)],
            CHAR2_LIST[rand_obj:random(1, words_count)],
            CHAR2_LIST[rand_obj:random(1, words_count)],
            CHAR2_LIST[rand_obj:random(1, words_count)],
            CHAR2_LIST[rand_obj:random(1, words_count)],
        }
        local this_key = table.concat(rand_list, "")
        if not rand_dict[this_key] then
            rand_dict[this_key] = true
            left_count = left_count - 1
        end
    end

    -- 插入数据库
    local key_list = table.keys(rand_dict)
    local insert_list = {}
    for i=1, key_count do
        table.insert(insert_list, {gift_key=key_list[i]})
        if i % 10000 == 0 then
            schema_world.GiftKey:batch_insert(insert_list)
            insert_list = {}
        end
    end
    if next(insert_list) then
        schema_world.GiftKey:batch_insert(insert_list)
    end
    return key_list
end

function MOD.query_gift_key(gift_key)
    local tag = string.sub(gift_key, 1, 3)
    local batch_key = string.sub(gift_key, 4, 6)
    local batch_info = MOD.batch_dict[batch_key]
    if not batch_info then return false end
    local key_info = schema_world.GiftKey:load(gift_key)
    if not key_info then return false end

    return {
        total_use_count = batch_info.total_use_count,
        use_count = key_info.use_count,
        end_ts = batch_info.end_ts,
        start_ts = batch_info.start_ts,
    }
end

function MOD.use_gift_key(gift_key)
    local tag = string.sub(gift_key, 1, 3)
    local batch_key = string.sub(gift_key, 4, 6)
    local batch_info = MOD.batch_dict[batch_key]
    if not batch_info then
        return false, g_tips.gift_key_wrong
    end
    if date.time_second() > batch_info.end_ts then
        return false, g_tips.gift_key_expire
    end
    if date.time_second() < batch_info.start_ts then
        return false, g_tips.gift_key_too_early
    end

    while MOD.lock_dict[gift_key] do
        skynet.sleep(0.2)
    end
    MOD.lock_dict[gift_key] = true

    local ok, use_ok, err_msg = xpcall(function()

        local key_info = MOD.cache[gift_key] or schema_world.GiftKey:load(gift_key)
        if not key_info then
            return false, g_tips.gift_key_wrong
        end
        if key_info.use_count >= batch_info.total_use_count then
            return false, g_tips.gift_key_used
        end
        key_info.use_count = key_info.use_count + 1
        if not MOD.cache[gift_key] then
            MOD.cache[gift_key] = key_info
            MOD.cache_count = MOD.cache_count + 1
        end
        return true
    end, g_log.trace_handle)

    MOD.lock_dict[gift_key] = nil

    if MOD.cache_count >= 500 then
        skynet.fork(function() MOD.save() end)
    end
    if ok then
        if use_ok then
            return true, batch_info.item_list
        else
            return false, err_msg
        end
    end
    return false, g_tips.server_error
end

function MOD.save()
    local cache_count = MOD.cache_count
    local cache = MOD.cache
    MOD.cache = {}
    MOD.cache_count = 0

    if cache_count == 0 then return end
    if cache_count == 1 then
        for _, key_info in pairs(cache) do
            schema_world.GiftKey:save(key_info)
        end
        return
    end

    -- 批量更新
    local values = {}
    for key, key_info in pairs(cache) do
        table.insert(values, string.format("('%s',%d)", key, key_info.use_count))
    end
    local query = string.format("insert into %s (gift_key, use_count) VALUES ", schema_world.GiftKey.table_name)
    query = query .. table.concat(values, ",")
    query = query .. " ON DUPLICATE KEY UPDATE use_count=VALUES(use_count);"
    schema_world.GiftKey:get_db_client():query(query)
end

function MOD.set_close_status(channel, is_close)
    local conf_content = MOD.conf.conf_content
    conf_content.close_dict = conf_content.close_dict or {}
    if is_close then
        conf_content.close_dict[channel] = true
    else
        conf_content.close_dict[channel] = false
    end
    schema_world.WorldConf:save(MOD.conf)
    return conf_content.close_dict or {}
end

function MOD.query_close_dict()
    return MOD.conf.conf_content.close_dict or {}
end

return MOD