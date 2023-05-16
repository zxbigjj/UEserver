skynet = require("skynet.manager")
_HACK_CACHE = {}
local skynet_core = require("skynet.core")
-- debug开关
__SERVER_DEBUG_FLAG = true

--schema check
SCHEMA_CHECK_FLAG = true

-- 代表null,要跨节点。。。。
SQL_NULL = "____wpx_skynet_mysql_null____"

---------------------------------------- 常用函数
-- 杀死service, name==nil则自己退出
_HACK_CACHE._skynet_kill = skynet.kill
_HACK_CACHE._skynet_exit = skynet.exit
_HACK_CACHE._skynet_fork = skynet.fork
function KILL(name)
    if not name or name == "" then
        -- 自己退出
        if skynet.localname('.reload_watcher') then
            skynet.send(".reload_watcher", "lua", 
                "ls_x_reload_unregister", skynet.self())
        end
        _HACK_CACHE._skynet_exit()
    else
        -- kill
        if type(name) == "string" and string.sub(name, 1, 1) ~= ":" then
            g_log:error("KILL服务错误:" .. name)
            return
        end
        if skynet.localname('.reload_watcher') then
            skynet.send(".reload_watcher", "lua", 
                "ls_x_reload_unregister", name)
        end
        _HACK_CACHE._skynet_kill(name)
    end
end
skynet.kill = KILL
skynet.exit = KILL

function FORK(func, ...)
    local co = _HACK_CACHE._skynet_fork(func, ...)
    local msg_profile = require("msg_utils.msg_profile")
    if msg_profile.ProfileFlag then
        local info = debug.getinfo(func, "S")
        local tag = string.format("%s:%s", info.source, info.linedefined)
        skynet.set_coroutine_stop_cb(function(used_time)
            msg_profile.on_handle_finish('f-' .. tag, used_time)
        end, co)
    end
    return co
end
skynet.fork = FORK

-- -- send
-- local _core_send = skynet_core.send
-- _HACK_CACHE._skynet_core_send = _core_send
-- local addr_cache = {}
-- local function convert_addr(addr)
--     if string.sub(addr, 1, 1) == "." then
--         local ret = skynet.localname(addr)
--         if not ret then
--             error("unknown addr:" .. addr)
--         end
--         addr_cache[addr] = ret
--         return ret
--     else
--         addr_cache[addr] = addr
--         return addr
--     end
-- end
-- skynet_core.send = function(addr, t, session, msg, sz)
--     if type(addr) == "string" then
--         addr = addr_cache[addr] or convert_addr(addr)
--     end
--     return _core_send(addr, t, session, msg, sz)
-- end

-- 转换为字符串
function STR(obj)
    if type(obj) == "table" then
        return _STR_TABLE(obj)
    elseif type(obj) == "string" then
        return _STR_STRING(obj)
    elseif obj == nil then
        return "nil"
    else
        return tostring(obj)
    end
end

local _esc_table = {
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t",
    ["\b"] = "\\b",
    ["\v"] = "\\v",
    ["\\"] = "\\\\",
    ["\""] = "\\\"",
}
function _STR_STRING(str)
    str = string.gsub(str, ".", function(c)
        return _esc_table[c] or c
    end)
    str = string.gsub(str, "[^%w%p ]", function(c)
        return string.format("\\x%02x", string.byte(c))
    end)
    return '"' .. str .. '"'
end

function _STR_TABLE(obj, indent, checker)
    indent = indent or ""
    if string.len(indent) > 20 then
        return indent .. "..."
    end
    checker = checker or {}
    checker[obj] = true
    local ret = {}
    ret[1+#ret] = indent .. tostring(obj) .. " {\n"
    for k,v in pairs(obj) do
        if type(k) == "table" then
            ret[1+#ret] = indent .. "  " .. tostring(k) .. ": =====>" .. tostring(v) .. "\n"
        elseif type(v) == "table" then
            if checker[v] then
                -- 递归了
                ret[1+#ret] = indent .. "  " .. STR(k) .. ": =====>" .. tostring(v) .. "\n"
            else
                ret[1+#ret] = indent .. "  " .. STR(k) .. ":\n"
                ret[1+#ret] = _STR_TABLE(v, indent .. "  ", checker) .. "\n"
            end
        else
            ret[1+#ret] = indent .. "  " .. STR(k) .. ": " .. STR(v) .. "\n"
        end
    end
    ret[1+#ret] = indent .. "}"
    checker[obj] = nil
    return table.concat(ret, "")
end

-- 调试用的print
function PRINT(...)
    local args = {...}
    local max_index = 0
    for k,v in pairs(args) do
        max_index = k>max_index and k or max_index
    end
    for i=1,max_index do
        args[i] = STR(args[i])
    end
    print(table.concat(args, ", "))
end

function ErrorHandle(...)
    PRINT(...)
end

function IS_DB_OBJ(obj)
    if type(obj) ~= "table" then return end
    local meta = getmetatable(obj)
    if meta and meta.__F_FLAG == "_DB_META_CLS" then
        return true
    end
end

function DB_COPY(obj)
    local meta = getmetatable(obj)
    if meta and meta.__F_FLAG == "_DB_META_CLS" then
        return meta.__F_CLS.copy(obj)
    end
    return table.deep_copy(obj)
end

-- 比直接调用table.insert(self)快点
-- pos可以为负值和0, 0插到最后
function DB_LIST_INSERT(list, pos, value)
    local meta = getmetatable(list)
    if meta and meta.__F_FLAG == "_DB_META_CLS" then
        return meta.__F_CLS.insert(list, pos, value)
    end
    error("not a db object")
end

-- 比直接调用table.remove(self)快点
-- pos可以为负值, -1删除最后一个
function DB_LIST_REMOVE(list, pos)
    local meta = getmetatable(list)
    if meta and meta.__F_FLAG == "_DB_META_CLS" then
        return meta.__F_CLS.remove(list, pos)
    end
    error("not a db object")
end

function DB_LIST_SORT(list, comp)
    local meta = getmetatable(list)
    if meta and meta.__F_FLAG == "_DB_META_CLS" then
        return meta.__F_CLS.sort(list, comp)
    end
    error("not a db object")
end

-- 用途类似c的struct，主要用于传参数，
-- key_list是合法的key列表
function STRUCT(container, name, key_list)
    if __SERVER_DEBUG_FLAG then
        local st = container["__STRUCT__" .. name]
        if not st then
            st = {key_dict={}, meta={}}
            container["__STRUCT__" .. name] = st
        end
        local key_dict = st.key_dict
        local meta = st.meta
        for i, v in ipairs(key_list) do
            key_dict[v] = true
        end
        meta.__index = function(t, key)
            if not key_dict[key] then
                error("read struct key error:" .. key .. " from " .. name)
            end
        end
        meta.__newindex = function(t, key, value)
            if not key_dict[key] then
                error("write struct key error:" .. key .. " from " .. name)
            end
            rawset(t, key, value)
        end
        return function(init_kvs)
            if getmetatable(init_kvs) == meta then
                return init_kvs
            end
            local self = {}
            setmetatable(self, meta)
            if init_kvs then
                for k,v in pairs(init_kvs) do
                    self[k] = v
                end
            end
            return self
        end
    else
        return function(init_kvs)
            return init_kvs
        end
    end
end

function CHECK_ENUM(enum, value)
    enum.__check = enum.__check or {}
    if not next(enum.__check) then
        for k, v in pairs(enum) do
            if k ~= "__check" then
                enum.__check[v] = true
            end
        end
    end
    if enum.__check[value] then
        return value
    else
        error("enum key not exist:" .. value)
    end
end

---------------------------------------- 热更新相关
function DECLARE_MODULE(mod_name, mod_creator)
    local filename = debug.getinfo(2, "S").source
    if string.sub(filename, 1, 1) == '@' then
        filename = string.sub(filename, 2)
    end
    local lua_path = string.gsub(package.path, "%?%.", "([%%w_/]+)%%.")
    local capture = nil
    for _, path in ipairs(string.split(lua_path, ";")) do
        capture = string.match(filename, path)
        if capture then
            capture = string.gsub(capture, "%/", ".")
            break
        end
    end
    if capture ~= mod_name then
        print(mod_name, capture)
        PRINT(package.path)
        error(string.format("DECLARE_MODULE name error:%s", filename))
    end
    local mod = package.loaded[mod_name]
    if not mod then
        if mod_creator then
            mod = mod_creator()
        else
            mod = {}
        end
        mod.__RELOAD_FLAG = true
        mod.__RELOAD_RUNNING_ATTR_NAMES = {}
        mod.__RELOAD_MOD_NAME = mod_name
        mod.__RELOAD_FILENAME = filename

        mod.__RELOAD_CHECK_DEFINE = true
        local define = {}
        mod.__index = define
        setmetatable(mod, {__newindex=function(t,k,v)
            if type(v) == "function" then
                if define[k] then
                    error("function define duplicated, " .. mod_name .. " : " .. k)
                end
            end
            define[k] = v
        end,
        __index = define})
    end
    return mod
end

function DECLARE_FINISH(mod_or_cls)
    if rawget(mod_or_cls, "__RELOAD_CHECK_DEFINE") then
        mod_or_cls.__RELOAD_CHECK_DEFINE = nil
        setmetatable(mod_or_cls, nil)
        for k,v in pairs(mod_or_cls.__index) do
            rawset(mod_or_cls, k, v)
        end
        mod_or_cls.__index = mod_or_cls
        if mod_or_cls.__BASE_CLS then
            setmetatable(mod_or_cls, mod_or_cls.__BASE_CLS)
        end

        for k, v in pairs(mod_or_cls) do
            if type(v) == 'table' and rawget(v, "__RELOAD_CHECK_DEFINE") then
                DECLARE_FINISH(v)
            end
        end
    end
end

function DECLARE_RUNNING_ATTR(container, name, init_value, init_creator)
    if not container.__RELOAD_RUNNING_ATTR_NAMES[name] then
        container.__RELOAD_RUNNING_ATTR_NAMES[name] = 1
        if init_creator then
            container[name] = init_creator()
        else
            container[name] = init_value
        end
    end
    return container[name]
end
function DECLARE_CLASS(container, name, base_cls)
    local cls = container[name]
    if not cls then
        cls = {}
        cls.__index = cls
        cls.__RELOAD_RUNNING_ATTR_NAMES = {}
        cls.__RELOAD_FLAG = true
        cls.__BASE_CLS = base_cls
        container[name] = cls

        cls.__RELOAD_CHECK_DEFINE = true
        local define = {}
        cls.__index = define
        setmetatable(cls, {__newindex=function(t,k,v)
            if type(v) == "function" then
                if define[k] then
                    error("function define duplicated, " .. name .. " : " .. k)
                end
            end
            define[k] = v
        end,
        __index = define})
    end
    return cls
end
--[[
First require queries package.preload[modname].If it has a value, this value (which must be a function) is the loader. 
Otherwise require searches for a Lua loader using the path stored in package.path. 
If that also fails, it searches for a C loader using the path stored in package.cpath. 
If that also fails, it tries an all-in-one loader (see package.searchers).
--]]
local searcher2 = package.searchers[2]
package.searchers[2] = function(...)
    local ret1, ret2 = searcher2(...)
    if type(ret1) == "function" then
        return function(...)
            local mod=ret1(...)
            if type(mod) == 'table' then
                DECLARE_FINISH(mod)
            end
            return mod
        end, ret2
    else
        return ret1, ret2
    end
end
---------------------------------------- 字符串处理函数
-- 哈希函数BKDRHash
function string.hash(str)
    local seed = 131
    local h = 0
    local len = string.len(str)
    local bytes = table.pack(string.byte(str, 1, len))
    for i=1, len do
        h = h * seed + bytes[i]
    end
    return h & 0xffffffff
end

--字符串分割函数
--传入字符串和分隔符，返回分割后的table, 分隔符符合正则格式
function string.split(str, delimiter)
    if str == nil or str == '' then
        return {}
    end

    if delimiter == nil or delimiter == '' then
        return {str}
    end

    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function string.endswith(a, b)
    return string.sub(a, -string.len(b)) == b
end

function string.startswith(a, b)
    return string.sub(a, 1, string.len(b)) == b
end

--去掉空白
function string.strip(str)
    if not str then return str end
    return string.gsub(str, "%s", "")
end

-- 16进制
function string.hex(str)
    str = string.gsub(str, ".", function(c)
        return string.format("%02x", string.byte(c))
    end)
    return str
end

function string.dehex(str)
    str = string.gsub(str, "%x%x", function(c)
        return string.char(tonumber("0x" .. c))
    end)
    return str
end

local _chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
local _rand_chars = {}
local _rand_chars2 = {}
for i=1, string.len(_chars) do
    _rand_chars[i] = string.sub(_chars, i, i)
end
for i=1,string.len(_chars) do
  for j=1,string.len(_chars) do
    _rand_chars2[1+#_rand_chars2] = _rand_chars[i] .. _rand_chars[j]
  end
end
function string.rand_string(size)
    local len2 = #_rand_chars2
    local ret = {}
    for i=1, math.floor(size/2) do
        ret[i] = _rand_chars2[math.random(1, len2)]
    end
    if size % 2 > 0 then
        ret[1+#ret] = _rand_chars[math.random(1, #_rand_chars)]
    end
    return table.concat(ret, "")
end

-- 示例:string.render('some words:{cde}, some value:{abc}', {abc=123, cde='hello'})
function string.render(s, args)
    local pos = 1
    local ret = {}
    while true do
        local idx_start, idx_end = string.find(s, '%b{}', pos)
        if idx_start then
            table.insert(ret, string.sub(s, pos, idx_start-1))
            local name = string.sub(s, idx_start+1, idx_end-1)
            if args[name] == nil then
                error("string.render error, no args:" .. name)
            end
            table.insert(ret, string.format('%s', args[name]))
            pos = idx_end + 1
        else
            table.insert(ret, string.sub(s, pos))
            break
        end
    end
    return table.concat(ret, "")
end

function string.utf8_len(str)
    local len = 0
    for p, c in utf8.codes(str) do
        if c > 127 then
            len = len + 2
        else
            len = len + 1
        end
    end
    return len
end

---------------------------------------- table常用函数
_HACK_CACHE.table_insert = table.insert
_HACK_CACHE.table_remove = table.remove

function table.insert(list, ...)
    local meta = getmetatable(list)
    if meta and meta.__F_FLAG == "_DB_META_CLS" then
        return meta.__F_CLS.insert(list, ...)
    end
    return _HACK_CACHE.table_insert(list, ...)
end

function table.remove(list, ...)
    local meta = getmetatable(list)
    if meta and meta.__F_FLAG == "_DB_META_CLS" then
        return meta.__F_CLS.remove(list, ...)
    end
    return _HACK_CACHE.table_remove(list, ...)
end

-- b覆盖a,等同dict.update
function table.update(a, b)
    if not b then return a end
    for k,v in pairs(b) do
        a[k] = v
    end
    return a
end

--dict.pop
function table.pop(tb, key)
    local v = tb[key]
    tb[key] = nil
    return v
end

--dict.keys
function table.keys(tb)
    local keys = {}
    local index = 1
    for k,v in pairs(tb) do
        keys[index] = k
        index = index + 1
    end
    return keys
end

--dict.values
function table.values(tb)
    local values = {}
    local index = 1
    for k,v in pairs(tb) do
        values[index] = v
        index = index + 1
    end
    return values
end

--shallow copy
function table.copy(tb)
    local ret = {}
    for k,v in pairs(tb) do
        ret[k] = v
    end
    return ret
end

function table.deep_copy(obj)
    if type(obj) ~= "table" then
        return obj
    end
    local lookup_table = {}
    local function _copy(_obj)
        if lookup_table[_obj] then
            return lookup_table[_obj]
        end
        local new_table = {}
        lookup_table[_obj] = new_table
        for index, value in pairs(_obj) do
            if type(index) == 'table' then
                index = _copy(index)
            end
            if type(value) == 'table' then
                value = _copy(value)
            end
            new_table[index] = value
        end
        return new_table
    end
    return _copy(obj)
end

function table.multi(tb, multi)
    local ret = {}
    for k,v in pairs(tb) do
        ret[k] = v * multi
    end
    return ret
end

-- max
function table.max(tb, key_func)
    local max_value = nil
    local key, value
    if key_func then
        for k,v in pairs(tb) do
            value = key_func(v)
            if max_value == nil or max_value < value then
                max_value = value
                key = k
            end
        end
    else
        for k,v in pairs(tb) do
            if max_value == nil or max_value < v then
                max_value = v
                key = k
            end
        end
    end
    return key, max_value
end

-- min
function table.min(tb, key_func)
    local min_value = nil
    local key, value
    if key_func then
        for k,v in pairs(tb) do
            value = key_func(v)
            if min_value == nil or min_value > value then
                min_value = value
                key = k
            end
        end
    else
        for k,v in pairs(tb) do
            if min_value == nil or min_value > v then
                min_value = v
                key = k
            end
        end
    end
    return key, min_value
end

function table.all_min(tb)
    local ret = {}
    local key, min_value = table.min(tb)
    for k,v in pairs(tb) do
        if v == min_value then
            ret[k] = v
        end
    end
    return ret
end

--Return the index where to insert item value in list, assuming list is sorted.
--The return value i is such that all e in list[:i] have e <= value, and all e in
--list[i:] have e > value.  So if value already appears in the list, insert(list, i, value) will
--insert just after the rightmost value already there.
function table.bi_search(list, value, compare_func)
    local left_index = 1
    local right_index = 1 + #list
    local mid
    if compare_func then
        while left_index < right_index do
            mid = math.floor((left_index+right_index) / 2)
            if compare_func(value, list[mid]) then
                right_index = mid
            else
                left_index = mid + 1
            end
        end
    else
        while left_index < right_index do
            mid = math.floor((left_index+right_index) / 2)
            if value < list[mid] then
                right_index = mid
            else
                left_index = mid + 1
            end
        end
    end
    return left_index
end

--Insert item value in list, and keep it sorted assuming list is sorted.
--If value is already in list, insert it to the right of the rightmost value.
function table.bi_insert(list, value, compare_func)
    local idx = table.bi_search(list, value, compare_func)
    table.insert(list, idx, value)
end

--average
function table.average(tb)
    local length = table.length(tb)
    if length <= 0 then return end
    local value = 0
    for k,v in pairs(tb) do
        value = value + v
    end
    return value/length
end


function table.find(tb, func)
    for k, v in pairs(tb) do
        if func(v) then return k, v end
    end
end

function table.find_by_value(tb, value)
    for k, v in pairs(tb) do
        if v==value then return k, v end
    end
end

function table.find_by_attr(tb, attr_name, attr_value)
    for k, v in pairs(tb) do
        if v[attr_name] == attr_value then return k, v end
    end
end

function table.filter(tb, func)
    local ret = {}
    for k, v in pairs(tb) do
        if func(v) then ret[k] = v end
    end
    return ret
end

--list.extend
function table.extend(a, b)
    if not b then return a end
    local len = #a
    for i,v in ipairs(b) do
        a[len+i] = v
    end
    return a
end

-- map
function table.map(tb, func)
    local ret = {}
    for k,v in pairs(tb) do
        ret[k] = func(v)
    end
    return ret
end

--list.index
function table.index(a, value)
    for k,v in ipairs(a) do
        if v==value then return k end
    end
end

function table.index_by_attr(a, attr_name, attr_value)
    for k,v in ipairs(a) do
        if v[attr_name] == attr_value then return k end
    end
end

-- like talbe.remove, but use value and return the index
-- if not find value in list then return -1
function table.delete(list, value)
    for index,v in ipairs(list) do
        if v == value then
            table.remove(list, index)
            return index
        end
    end
end

---list remove by index list
function table.remove_multi(list, index_list)
    for i,index in ipairs(index_list) do
        table.remove(list, index-i+1)
    end
end

--list[i:j+1], 类似string.sub
function table.sub(t, i, j)
    local ret = {}
    i = i>0 and i or #t+i+1
    j = j>0 and j or #t+j+1
    table.move(t,i,j,1,ret)
    return ret
end

function table.list_to_dict(list)
    local dict = {}
    for _, v in ipairs(list) do
        dict[v] = true
    end
    return dict
end

function table.list_build_dict(key_list, value_list)
    local new_dict = {}
    for i=1, #key_list do
        new_dict[key_list[i]] = value_list[i]
    end
    return new_dict
end

function table.dict_attr_add(old_dict, add_attr_dict)
    for name, modifty in pairs(add_attr_dict) do
        old_dict[name] = (old_dict[name] or 0) + modifty
    end
    return old_dict
end

function table.dict_attr_reduce(old_dict, reduce_attr_dict)
    for name, modifty in pairs(reduce_attr_dict) do
        old_dict[name] = (old_dict[name] or 0) - modifty
    end
    return old_dict
end

function table.contains(tb, element)
    if not tb then
        return
    end
    for index, value in pairs(tb) do
        if value == element then
            return index
        end
    end
end

function table.length(tb)
    local index = 0
    for i,_ in pairs(tb) do
        index = index + 1
    end
    return index
end

function table.sample(tb, k)
    local len = #tb
    if k < 0 or k > len then
        error("sample larger than table length")
    end
    local result = {}
    local setsize = 21
    if k > 5 then
        setsize = setsize + 4 ^ (math.ceil(math.log(k * 3, 4)))
    end
    if len < setsize then
        local copy_tb = table.copy(tb)
        for i = 1, k do
            local index = math.random(1, len)
            result[i] = copy_tb[index]
            copy_tb[index] = copy_tb[len]
            len = len - 1
        end
    else
        local dict = {}
        for i = 1, k do
            local index = math.random(1, len)
            while(dict[index]) do
                index = math.random(1, len)
            end
            dict[index] = true
            result[i] = tb[index]
        end
    end
    return result
end

function table.sorted_keys(tb, mapper, comp)
    local insert = table.insert
    local list = {}
    if mapper then
        for k, v in pairs(tb) do
            insert(list, {k, mapper(v)})
        end
    else
        for k, v in pairs(tb) do
            insert(list, {k, v})
        end
    end
    if comp then
        table.sort(list, function(a, b) return comp(a[2], b[2]) end)
    else
        table.sort(list, function(a, b) return a[2] < b[2] end)
    end
    local ret = {}
    for i, v in ipairs(list) do
        insert(ret, v[1])
    end
    return ret
end

function table.count(tb, v_func)
    if not v_func then return end
    local count = 0
    local v_type = type(v_func)
    if v_type == 'function' then
        for _, v in pairs(tb) do
            if v_func(v) then
                count = count + 1
            end
        end
    elseif v_type == 'string' or v_type == 'number' then
        for _, v in pairs(tb) do
            if v == v_func then
                count = count + 1
            end
        end
    else
        assert(false, 'unknown w_func type')
    end
    return count
end

function table.has_repeat_element(tb)
    local dict = {}
    for _, v in pairs(tb) do
        if dict[v] then
            return true
        end
        dict[v] = true
    end
    return false
end

-- 类似python中zip
-- for k, v in table.zip({'a', 'b', 'c'}, {1, 2, 3, 4}) do
--     print(k, v)
-- end
function table.zip(seq1, seq2)
    local index = 0
    local length = math.min(#seq1, #seq2)
    local _next = function(t, _)
        index = index + 1
        if index <= length then
            return seq1[index], seq2[index]
        end
    end
    return _next, nil, nil
end

function table.zip3(seq1, seq2, seq3)
    local index = 0
    local length = math.min(#seq1, #seq2, #seq3)
    local _next = function(t, _)
        index = index + 1
        if index <= length then
            return seq1[index], seq2[index], seq3[index]
        end
    end
    return _next, nil, nil
end

function update_sorted_list(obj_list, self_obj, key, is_add, is_ascending)
    if is_ascending then --升序
        if not self_obj.rank then
            table.insert(obj_list, self_obj)
            self_obj.rank = #obj_list
            is_add = nil
        end
        local index
        if is_add then
            if self_obj.rank == #obj_list then return end
            index = #obj_list
            for i=self_obj.rank+1, #obj_list do
                local obj = obj_list[i]
                if obj[key] >= self_obj[key] then
                    index = i-1
                    break
                else
                    obj.rank = i - 1
                    obj_list[i-1] = obj
                end
            end
        else
            if self_obj.rank == 1 then return end
            index = 1
            for i=self_obj.rank-1, 1, -1 do
                local obj = obj_list[i]
                if obj[key] <= self_obj[key] then
                    index = i+1
                    break
                else
                    obj.rank = i + 1
                    obj_list[i+1] = obj
                end
            end
        end
        obj_list[index] = self_obj
        self_obj.rank = index
    else           -- 降序
        if not self_obj.rank then
            table.insert(obj_list, self_obj)
            self_obj.rank = #obj_list
            is_add = true
        end
        local index
        if is_add then
            if self_obj.rank == 1 then return end
            index = 1
            for i=self_obj.rank-1, 1, -1 do
                local obj = obj_list[i]
                if self_obj[key] <= obj[key] then
                    index = i+1
                    break
                else
                    obj.rank = i + 1
                    obj_list[i+1] = obj
                end
            end
        else
            if self_obj.rank == #obj_list then return end
            index = #obj_list
            for i=self_obj.rank+1, #obj_list do
                local obj = obj_list[i]
                if self_obj[key] >= obj[key] then
                    index = i-1
                    break
                else
                    obj.rank = i - 1
                    obj_list[i-1] = obj
                end
            end
        end
        obj_list[index] = self_obj
        self_obj.rank = index
    end
end
--------------------------------------- 随机函数
-- math.random多线程下有问题
_HACK_CACHE._random = math.random
_HACK_CACHE._randomseed = math.randomseed

local RandCls = {}
local MAX_SEED = 0x10000000
RandCls.__index = RandCls
function RandCls.new(seed)
    seed = seed or math.random(1, MAX_SEED)
    seed = math.floor(seed)

    return setmetatable({_seed=seed, init_seed=seed}, RandCls)
end

function RandCls:get_seed()
    return self._seed
end

function RandCls:__rand()
    self._seed = (22695477 * self._seed + 1) % MAX_SEED
end

function RandCls:seed(value)
    self._seed = value
end

function RandCls:random(m, n)
    self:__rand()
    if not n then
        if not m then
            return self._seed / MAX_SEED
        else
            m, n = 1, m
        end
    end
    return math.floor(m + self._seed / MAX_SEED * (n + 1 - m))
end

function RandCls:frandom(m, n)
    self:__rand()
    return m + self.seed / MAX_SEED * (n - m)
end

-- 初始化全局随机种子
local __global_seed = tonumber(string.sub(tostring({}), 8))
__global_seed = (__global_seed ~ os.time()) % 2147483647
local __global_rand = RandCls.new(__global_seed)

function math.new_rand(seed)
    return RandCls.new(seed)
end

function math.randomseed(x)
    __global_rand:seed(x)
end

function math.random(m, n)
    return __global_rand:random(m, n)
end

function math.roll(weight_table, total_weight, w_func)
    if not w_func then
        if not total_weight then
            total_weight = 0
            for k,v in pairs(weight_table) do
                total_weight = total_weight + v
            end
        end
        local rand = math.random() * total_weight
        for k,v in pairs(weight_table) do
            rand = rand - v
            if rand <= 0 then
                return k
            end
        end
    elseif type(w_func) == 'string' then
        -- w_func是权重属性名
        local w_name = w_func
        if not total_weight then
            total_weight = 0
            for k,v in pairs(weight_table) do
                total_weight = total_weight + v[w_name]
            end
        end
        local rand = math.random() * total_weight
        for k,v in pairs(weight_table) do
            rand = rand - v[w_name]
            if rand <= 0 then
                return k
            end
        end
    elseif type(w_func) == 'function' then
        -- w_func是一个权重函数
        if not total_weight then
            total_weight = 0
            for k,v in pairs(weight_table) do
                total_weight = total_weight + w_func(v)
            end
        end
        local rand = math.random() * total_weight
        for k,v in pairs(weight_table) do
            rand = rand - w_func(v)
            if rand <= 0 then
                return k
            end
        end
    else
        assert(false, 'unknown w_func type')
    end
    -- 随便返回一个
    for k,v in pairs(weight_table) do return k end
end

function math.check_rate(rate)
    local num = math.random() * 100
    return num < rate
end

function math.shuffle(tb)
    local j
    for i=#tb, 2, -1 do
        j = math.random(1, i)
        tb[i], tb[j] = tb[j], tb[i]
    end
end

-- 正态分布
--[[
# mu = mean, sigma = standard deviation
# Uses Kinderman and Monahan method. Reference: Kinderman,
# A.J. and Monahan, J.F., "Computer generation of random
# variables using the ratio of uniform deviates", ACM Trans
# Math Software, 3, (1977), pp257-260.
]]
local NV_MAGICCONST = 4 * math.exp(-0.5)/(2.0^0.5)
function math.normal(mu, sigma)
    local random = math.random
    local log = math.log
    local u1, u2, z
    while true do
        u1 = random()
        u2 = 1.0 - random()
        z = NV_MAGICCONST*(u1-0.5)/u2
        if z*z/4.0 <= -log(u2) then break end
    end
    return mu + z*sigma
end

function math.random_normal(m, n)
    local rand = math.abs(math.normal(0, 0.5))
    rand = rand - math.floor(rand)
    if not m then return rand end
    if not n then
        m,n = 1,m
    end
    return m + math.floor(rand*(n-m+1))
end

function math.frandom_normal(m, n)
    local rand = math.abs(math.normal(0, 0.5))
    rand = rand - math.floor(rand)
    return m + rand*(n-m)
end

function math.frandom(m, n)
    local rand = math.random()
    return m + rand*(n-m)
end

--[[
"""Gaussian distribution.

mu is the mean, and sigma is the standard deviation.  This is
slightly faster than the normalvariate() function.

Not thread-safe without a lock around calls.

"""

# When x and y are two variables from [0, 1), uniformly
# distributed, then
#
#    cos(2*pi*x)*sqrt(-2*log(1-y))
#    sin(2*pi*x)*sqrt(-2*log(1-y))
#
# are two *independent* variables with normal distribution
]]
local gauss_next = nil
function math.gauss(mu, sigma)
    local math = math
    local z = gauss_next
    gauss_next = nil
    if not z then
        local x2pi = math.random() * 2 * math.pi
        local g2rad = (-2.0 * math.log(1.0 - math.random())) ^ 0.5
        z = math.cos(x2pi) * g2rad
        gauss_next = math.sin(x2pi) * g2rad
    end
    return mu + z*sigma
end

function math.random_gauss(m, n)
    local rand = math.abs(math.gauss(0, 0.5))
    rand = rand - math.floor(rand)
    if not m then return rand end
    if not n then
        m,n = 1,m
    end
    return m + math.floor(rand*(n-m+1))
end

function math.frandom_gauss(m, n)
    local rand = math.abs(math.gauss(0, 0.5))
    rand = rand - math.floor(rand)
    return m + rand*(n-m)
end

-- frac可以传0.1，则精确到0.1
function math.fceil(x, frac)
    if not frac then return math.ceil(x) end
    return math.ceil(x/frac)*frac
end

function math.ffloor(x, frac)
    if not frac then return math.floor(x) end
    return math.floor(x/frac)*frac
end

-- 四舍五入， frac可以传0.1，则精确到0.1
function math.round(v, frac)
    if frac then
        assert(frac > 0)
        local i, f = math.modf(v/frac)
        if f>=0.5 then
            return (i+1)*frac
        elseif f<=-0.5 then
            return (i-1)*frac
        else
            return i*frac
        end
    else
        local i, f = math.modf(v)
        if f>=0.5 then
            return i+1
        elseif f<=-0.5 then
            return i-1
        else
            return i
        end
    end
end

function math.between(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

function ItemTypeName(item_id)
    local excel_data = require("excel_data")
    local conf = excel_data.ItemData[item_id]
    if conf then
        return excel_data.ItemTypeData[conf.sub_type].name
    end
end

-- 翻译
function Translatecontent(content, language)
    if not language then
        return content
    end
    local excel_data = require("excel_data")
    local translation_data = excel_data.TranslationData["excel"][content]
    if not translation_data then
        return content
    end
    return translation_data[language] or content
end

-- 检查字符是否缺失
function IsStringBroken(string)
    return utf8.len(string)
end
---------------------------------------- 日志
local print_header = string.format("[%s-%x]", SERVICE_NAME, skynet.self())
local Log = require("sys_utils.log")
g_log = Log.new(SERVICE_NAME)

_HACK_CACHE.print = print
function print(...)
    local date = os.date("[%Y-%m-%d %H:%M:%S]", math.floor(skynet.time()))
    _HACK_CACHE.print(date .. print_header, ...)
end

-- _HACK_CACHE.error = error
-- function error(message, level)
--     level = level or 1
--     _HACK_CACHE.error(string.format("%s%s", print_header, message), level+1)
-- end

_HACK_CACHE.next = next
function next(t, k)
    local meta = getmetatable(t)
    if meta and meta.__next then
        return meta.__next(t, k)
    end
    return _HACK_CACHE.next(t, k)
end

json = require("json")
require("logic_global")
require("strict")

---------------------------------------- gc
collectgarbage('setstepmul', 600)   -- x/200倍的gc扫描速度
collectgarbage('setpause', 150)     -- x/100倍的等待


