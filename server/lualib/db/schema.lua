local json = require("json")
local msg_profile = require('msg_utils.msg_profile')

local MOD = DECLARE_MODULE("db.schema")

DECLARE_RUNNING_ATTR(MOD, "is_freshing_dict", {})


local IS_DEBUG = true
local SCHEMA_DEBUG_VERSION = 1

function COMPILE(cls, name, schema)
    return schema[1].new(cls, name, schema[2])
end

-- 任意值
local FieldAny = DECLARE_CLASS(MOD, "FieldAny")
function FieldAny.new(cls, name, args)
    local default_value = args.default_value
    local sql_define = args.sql_define or "JSON"

    cls = cls or {}
    cls.__F_FLAG = "_DB_META_CLS"
    cls.__F_TYPE = "Any"
    cls.__F_IS_PLAIN = false
    cls.__F_NAME = name
    cls.__F_DEFAULT_VALUE = default_value
    cls.__F_VALUE_TYPE = "any"
    cls.__F_SQL_DEFINE = function() return sql_define end
    cls.__F_CONVERTER = function(v)
        return v
    end
    cls.__F_COPY = function(v)
        if type(v) == "table" then
            return table.deep_copy(v)
        else
            return v
        end
    end
    cls.__F_MAKE_DEFAULT = function()
        if type(cls.__F_DEFAULT_VALUE) == "table" then
            return {}
        else
            return cls.__F_DEFAULT_VALUE
        end
    end
    cls.__F_TO_SQL = function(v)
        return v
    end
    cls.__F_FROM_SQL = function(data)
        return data
    end
    cls.copy = cls.__F_COPY
    return cls
end

-- 整数类型
local FieldInt = DECLARE_CLASS(MOD, "FieldInt")
function FieldInt.new(cls, name, args)
    local value_type = 'number'
    local default_value = args.default_value
    local sql_define = args.sql_define
    if not sql_define then
        if default_value then
            sql_define = "int default " .. default_value
        else
            sql_define = "int"
        end
    end

    cls = cls or {}
    cls.__F_FLAG = "_DB_META_CLS"
    cls.__F_TYPE = "Int"
    cls.__F_IS_PLAIN = true
    cls.__F_NAME = name
    cls.__F_DEFAULT_VALUE = default_value
    cls.__F_VALUE_TYPE = value_type
    cls.__F_SQL_DEFINE = function() return sql_define end
    cls.__F_COPY = function(v) return v end
    cls.__F_CONVERTER = function(v)
        if not v then return v end
        if math.type(v) ~= 'integer' then
            error(cls.__F_NAME .. " set error, " .. type(v))
        end
        return v
    end
    cls.__F_MAKE_DEFAULT = function()
        return cls.__F_DEFAULT_VALUE
    end
    cls.__F_TO_SQL = function(v)
        return v
    end
    cls.__F_FROM_SQL = function(data)
        return math.floor(data)
    end
    return cls
end

-- 浮点数类型
local FieldNum = DECLARE_CLASS(MOD, "FieldNum")
function FieldNum.new(cls, name, args)
    local value_type = 'number'
    local default_value = args.default_value
    local sql_define = args.sql_define or "double"

    cls = cls or {}
    cls.__F_FLAG = "_DB_META_CLS"
    cls.__F_TYPE = "Num"
    cls.__F_IS_PLAIN = true
    cls.__F_NAME = name
    cls.__F_DEFAULT_VALUE = default_value
    cls.__F_VALUE_TYPE = value_type
    cls.__F_SQL_DEFINE = function() return sql_define end
    cls.__F_COPY = function(v) return v end
    cls.__F_CONVERTER = function(v)
        if v ~= nil and type(v) ~= 'number' then
            error(cls.__F_NAME .. " set error, " .. type(v))
        end
        return v
    end
    cls.__F_MAKE_DEFAULT = function()
        return cls.__F_DEFAULT_VALUE
    end
    cls.__F_TO_SQL = function(v)
        return v
    end
    cls.__F_FROM_SQL = function(data)
        return data
    end
    return cls
end

-- bool类型
local FieldBool = DECLARE_CLASS(MOD, "FieldBool")
function FieldBool.new(cls, name, args)
    local value_type = 'boolean'
    local default_value = args.default_value
    local sql_define = args.sql_define or "tinyint"

    cls = cls or {}
    cls.__F_FLAG = "_DB_META_CLS"
    cls.__F_TYPE = "Bool"
    cls.__F_IS_PLAIN = true
    cls.__F_NAME = name
    cls.__F_DEFAULT_VALUE = default_value
    cls.__F_VALUE_TYPE = value_type
    cls.__F_COPY = function(v) return v end
    cls.__F_SQL_DEFINE = function() return sql_define end
    cls.__F_CONVERTER = function(v)
        if v ~= nil and type(v) ~= 'boolean' then
            error(cls.__F_NAME .. " set error, " .. type(v))
        end
        return v
    end
    cls.__F_MAKE_DEFAULT = function()
        return cls.__F_DEFAULT_VALUE
    end
    cls.__F_TO_SQL = function(v)
        if v == nil then
            return nil
        end
        return (v and 1 or 0)
    end
    cls.__F_FROM_SQL = function(data)
        return data == nil and nil or (data == 1)
    end
    return cls
end

-- 字符串类型
local FieldStr = DECLARE_CLASS(MOD, "FieldStr")
function FieldStr.new(cls, name, args)
    local value_type = 'string'
    local default_value = args.default_value
    local sql_define = args.sql_define or "text"

    cls = cls or {}
    cls.__F_FLAG = "_DB_META_CLS"
    cls.__F_TYPE = "Str"
    cls.__F_IS_PLAIN = true
    cls.__F_NAME = name
    cls.__F_DEFAULT_VALUE = default_value
    cls.__F_VALUE_TYPE = value_type
    cls.__F_COPY = function(v) return v end
    cls.__F_SQL_DEFINE = function() return sql_define end
    cls.__F_CONVERTER = function(v)
        if v ~= nil and type(v) ~= 'string' then
            error(cls.__F_NAME .. " set error, " .. type(v))
        end
        return v
    end
    cls.__F_MAKE_DEFAULT = function()
        return cls.__F_DEFAULT_VALUE
    end
    cls.__F_TO_SQL = function(v)
        return v
    end
    cls.__F_FROM_SQL = function(data)
        return data
    end
    return cls
end

-- 对象类型, 属性必须定义
local FieldObj = DECLARE_CLASS(MOD, "FieldObj")
function FieldObj.new(cls, name, args)
    local fields = args.fields
    local has_default = args.has_default
    local sql_define = args.sql_define or "json"
    local is_sql_table = args.is_sql_table

    cls = cls or {}
    cls.__F_FLAG = "_DB_META_CLS"
    cls.__F_TYPE = "Obj"
    cls.__F_NAME = name
    cls.__F_SQL_DEFINE = function() return sql_define end
    
    cls.__F_VALUE_TYPE = "table"
    -- 更新属性， 注意热更新
    cls.__F_FIELD_DICT = cls.__F_FIELD_DICT or {}
    for name, schema in pairs(fields) do
        cls.__F_FIELD_DICT[name] = COMPILE(cls.__F_FIELD_DICT[name], name, schema)
    end
    local field_dict = cls.__F_FIELD_DICT
    cls.__F_FROM_SQL = function(data)
        -- 直接使用tb
        if data == nil then return nil end
        local tb
        if type(data) == 'table' then
            tb = data
        else
            tb = json.decode(data)
        end
        if type(tb) ~= "table" then
            error("FieldObj from_sql fail:" .. name .. ":" .. type(tb))
        end
        local field = nil
        for name, value in pairs(tb) do
            field = field_dict[name]
            if field then
                tb[name] = field.__F_FROM_SQL(value)
            else
                tb[name] = nil
            end
        end
        return cls.__F_SETMETA(tb)
    end
    cls.__F_TO_SQL = function(obj)
        if not obj then return nil end
        local meta = getmetatable(obj)
        assert(meta and meta.__F_CLS == cls)
        local ret = {}
        for k, v in pairs(obj.__CON) do
            local field = field_dict[k]
            if field then
                ret[k] = field.__F_TO_SQL(v)
            end
        end
        return ret
    end
    cls.__F_COPY = function(obj)
        if obj == nil then return end
        assert(getmetatable(obj).__F_CLS == cls)
        local ret = {}
        for k, v in pairs(obj.__CON) do
            local field = field_dict[k]
            if field then
                ret[k] = field.__F_COPY(v)
            end 
        end
        return cls.__F_SETMETA(ret)
    end
    cls.__F_MAKE_DEFAULT = function()
        if has_default then
            return cls.new()
        else 
            return nil
        end
    end
    cls.__F_CONVERTER = function(tb)
        if tb == nil then return end
        if type(tb) ~= "table" then
            error(cls.__F_NAME .. " set error, " .. type(tb))
        end
        local meta = getmetatable(tb)
        if meta then
            assert(meta.__F_CLS == cls)
            return tb
        end
        local con = {}
        local field = nil
        for k,v in pairs(tb) do
            field = field_dict[k]
            if field then
                con[k] = field.__F_CONVERTER(v)
            end
        end
        local del_key = next(tb)
        while del_key do
            tb[del_key] = nil
            del_key = next(tb)
        end
        return cls.__F_SETMETA(con, tb)
    end
    cls.__F_INDEX = function(t, k)
        local field = field_dict[k]
        if not field then
            if SCHEMA_CHECK_FLAG then
                error(string.format("%s has no field: %s", cls.__F_NAME, k))
            end
            return nil
        end
        local v = t.__CON[k]
        if v == nil then
            v = field.__F_MAKE_DEFAULT()
            if type(v) == 'table' then
                -- 可修改类型需要存起来
                t.__CON[k] = v
                if is_sql_table then
                    -- 有值了，之前可能被删除过
                    t.__DEL[k] = nil
                end
            end
        end
        return v
    end
    cls.__F_NEWINDEX = function(t, k, v)
        local field = field_dict[k]
        if not field then
            error(string.format("%s has no field: %s", cls.__F_NAME, k))
        end
        v = field.__F_CONVERTER(v)
        if v == nil then
            if is_sql_table then
                t.__DEL[k] = true
            end
        else
            if is_sql_table then
                t.__DEL[k] = nil
            end
        end
        t.__CON[k] = v
    end
    cls.next = function(t, prev_key)
        local key, field = next(field_dict, prev_key)
        if key == nil then
            -- over
            return
        end
        local value = t[key]
        if value == nil then
            return cls.next(t, key)
        else
            return key, value
        end
    end
    cls.__pairs = function(t)
        return cls.next, t, nil
    end
    cls.new = function() 
        return cls.__F_SETMETA({})
    end
    cls.attach = cls.__F_CONVERTER
    cls.copy = cls.__F_COPY
    cls.__F_META = {
        __F_CLS = cls,
        __F_FLAG = "_DB_META_CLS",
        __index = cls.__F_INDEX,
        __newindex = cls.__F_NEWINDEX,
        __pairs = cls.__pairs,
    }
    cls.__F_SETMETA = function(con, obj)
        obj = obj or {}
        obj.__CON = con
        if is_sql_table then
            obj.__DEL = {}
        end
        setmetatable(obj, cls.__F_META)
        return obj
    end
    return cls
end

-- 容器类型，key固定类型,value固定类型
ContainerKeyType = {
    Int = true,
    Str = true,
    Num = true,
}
local FieldContainer = DECLARE_CLASS(MOD, "FieldContainer")
function FieldContainer.new(cls, name, args)
    local key_schema = args.key_schema
    local value_schema = args.value_schema
    local has_default = args.has_default
    local sql_define = args.sql_define or "json"

    cls = cls or {}
    cls.__F_FLAG = "_DB_META_CLS"
    cls.__F_TYPE = "Container"
    cls.__F_NAME = name
    cls.__F_SQL_DEFINE = function() return sql_define end
    
    cls.__F_VALUE_TYPE = "table"
    -- 更新属性， 注意热更新
    cls.__F_FIELD_KEY = COMPILE(cls.__F_FIELD_KEY, name .. "_key", key_schema)

    if not (ContainerKeyType[cls.__F_FIELD_KEY.__F_TYPE]) then
        error("key必须为简单类型:" .. name)
    end
    cls.__F_USE_NUM_KEY = cls.__F_FIELD_KEY.__F_VALUE_TYPE == "number"
    cls.__F_FIELD_VALUE = COMPILE(cls.__F_FIELD_VALUE, name .. "_value", value_schema)
    cls.__F_KEY_CONVERTER = cls.__F_FIELD_KEY.__F_CONVERTER
    cls.__F_VALUE_CONVERTER = cls.__F_FIELD_VALUE.__F_CONVERTER
    cls.__F_VALUE_DEFAULT = cls.__F_FIELD_VALUE.__F_MAKE_DEFAULT
    cls.__F_VALUE_COPY = cls.__F_FIELD_VALUE.__F_COPY
    cls.__F_FROM_SQL = function(data)
        local v_from_sql = cls.__F_FIELD_VALUE.__F_FROM_SQL

        if data == nil then return nil end
        local tb
        if type(data) == 'table' then
            tb = data
        else
            tb = json.decode(data)
        end
        local con = {}
        local use_num_key = cls.__F_USE_NUM_KEY
        for k,v in pairs(tb) do
            if use_num_key then
                k = tonumber(k)
            end
            con[k] = v_from_sql(v)
        end
        return cls.__F_SETMETA(con)
    end
    cls.__F_TO_SQL = function(obj)
        if not obj then return nil end
        local meta = getmetatable(obj)
        assert(meta and meta.__F_CLS == cls)
        local ret = {}
        local v_to_sql = cls.__F_FIELD_VALUE.__F_TO_SQL
        local use_num_key = cls.__F_USE_NUM_KEY
        for k, v in pairs(obj.__CON) do
            if use_num_key then
                k = tostring(k)
            end
            ret[k] = v_to_sql(v)
        end
        return ret
    end
    cls.__F_MAKE_DEFAULT = function()
        if has_default then
            return cls.new()
        else
            return nil
        end
    end
    cls.__F_CONVERTER = function(tb)
        if tb == nil then return end
        if type(tb) ~= "table" then
            error(cls.__F_NAME .. " set error, " .. type(tb))
        end
        local meta = getmetatable(tb)
        if meta then
            assert(meta.__F_CLS == cls)
            return tb
        end
        local con = {}
        local converter = cls.__F_VALUE_CONVERTER
        local use_num_key = cls.__F_USE_NUM_KEY
        for k,v in pairs(tb) do
            if use_num_key then
                assert(type(k) == "number")
            else
                assert(type(k) == 'string')
            end
            con[k] = converter(v)
        end
        local del_key = next(tb)
        while del_key do
            tb[del_key] = nil
            del_key = next(tb)
        end
        return cls.__F_SETMETA(con, tb)
    end
    cls.__F_COPY = function(dict)
        if dict == nil then return end
        assert(getmetatable(dict).__F_CLS == cls)
        local ret = {}
        local copy = cls.__F_VALUE_COPY
        for k,v in pairs(dict.__CON) do
            ret[k] = copy(v)
        end
        return cls.__F_SETMETA(ret)
    end
    cls.__pairs = function(t)
        return pairs(t.__CON)
    end
    cls.__F_INDEX = function(t, k)
        local v = t.__CON[k]
        if v == nil then
            v = cls.__F_VALUE_DEFAULT()
            if type(v) == 'table' then
                -- 可修改类型， 存下来
                t.__CON[k] = v
            end
        end
        return v
    end
    cls.__F_NEWINDEX = function(t, k, v)
        k = cls.__F_KEY_CONVERTER(k)
        if v ~= nil then
            if t.__CON[k] == nil then
                t.__COUNT = t.__COUNT + 1
            end
            t.__CON[k] = cls.__F_VALUE_CONVERTER(v)
        else
            if t.__CON[k] ~= nil then
                t.__COUNT = t.__COUNT - 1
            end
            t.__CON[k] = nil
        end
    end
    cls.__F_LEN = function(t)
        return t.__COUNT
    end
    cls.new = function()
        return cls.__F_SETMETA({})
    end
    cls.attach = cls.__F_CONVERTER
    cls.copy = cls.__F_COPY
    cls.clear = function(self)
        self.__COUNT = 0
        self.__CON = {}
    end
    cls.sort = function(self, comp)
        table.sort(self.__CON, comp)
    end
    cls.move = function(self, f, e, t, other)
        if other then
            return table.move(self.__CON, f, e, t, other.__CON or other)
        else
            return table.move(meta.__CON, f, e, t)
        end
    end
    -- 比直接调用table.insert(self)快点
    -- pos可以为负值和0, 0插到最后
    cls.insert = function(self, pos, value)
        if value == nil then
            value = pos
            pos = self.__COUNT + 1
            assert(value ~= nil)
        else
            pos = pos or 0
            if pos <= 0 then
                pos = self.__COUNT + pos + 1
            end
        end
        value = cls.__F_VALUE_CONVERTER(value)
        self.__COUNT = self.__COUNT + 1
        table.insert(self.__CON, pos, value)
    end
    -- 比直接调用table.remove(self)快点
    -- pos可以为负值, -1删除最后一个
    cls.remove = function(self, pos)
        pos = pos or self.__COUNT
        if pos <= 0 then
            pos = self.__COUNT + pos + 1
        end
        local value = table.remove(self.__CON, pos)
        if value == nil then
        else
            self.__COUNT = self.__COUNT - 1
        end
        return value
    end
    
    cls.__F_META = {
        __F_FLAG = "_DB_META_CLS",
        __F_CLS = cls,
        __index = cls.__F_INDEX,
        __newindex = cls.__F_NEWINDEX,
        __len = cls.__F_LEN,
        __pairs = cls.__pairs,
    }
    cls.__F_SETMETA = function(con, obj)
        local count = 0
        for k, v in pairs(con) do
            count = count + 1
        end
        obj = obj or {}
        obj.__COUNT = count
        obj.__CON = con
        setmetatable(obj, cls.__F_META)
        return obj
    end
    return cls
end

local Collection = DECLARE_CLASS(MOD, "Collection")
function Collection.new(cls, name, fields, primary, db_name, index_list)
    cls = cls or {}
    setmetatable(cls, Collection)
    cls.name = name
    cls.table_name = "t_" .. name
    assert(fields[primary])
    
    cls.primary = primary
    cls.schema = MOD.OBJ(fields, false, true)
    cls.db_name = db_name
    cls.fields = fields
    cls.index_list = index_list or {}
    table.insert(cls.index_list, 1, string.format('primary key (%s)', cls.primary))

    local cluster_utils = require("msg_utils.cluster_utils")
    cls.db_proxy = {}
    setmetatable(cls.db_proxy, {
        __index = function(t, k)
            local f = function(_, ...)
                return cluster_utils.call_db("lc_" .. k, cls.db_name, rawget(t, '_key'), ...)
            end
            t[k] = f
            return f
        end
    })

    cls.root_obj_cls = COMPILE(cls.root_obj_cls or {}, name, cls.schema)
    return cls
end

function Collection:get_field_schema(name)
    return self.root_obj_cls.__F_FIELD_DICT[name]
end

function Collection:sql_field_define_dict()
    local ret = {}
    for name, _ in pairs(self.fields) do
        ret[name] = self:get_field_schema(name).__F_SQL_DEFINE()
    end
    return ret
end

function Collection:sql_index_define_list()
    return self.index_list
end

function Collection:get_db_client(key)
    self.db_proxy._key = key
    return self.db_proxy
end

function Collection:get_table_name()
    return self.table_name
end

function Collection:get_primary_name()
    return self.primary
end

function Collection:get_primary(obj)
    return obj[self.primary]
end

function Collection:print_create_sql()
    local field_define = self:sql_field_define_dict()
    local index_define = self:sql_index_define_list()
    local ret = {"create table ", self.table_name, "(\n"}

    local field_name_list = table.keys(field_define)
    table.sort(field_name_list)
    for _, field_name in ipairs(field_name_list) do
        table.insert(ret, field_name .. " " .. field_define[field_name] .. ",\n")
    end
    for _, idx in ipairs(index_define) do
        table.insert(ret, idx .. ",\n")
    end
    table.insert(ret, ")\n")
    return table.concat(ret, "")
end

function Collection:_create_table(client)
    local field_define = self:sql_field_define_dict()
    local index_define = self:sql_index_define_list()
    -- 创建表
    local field_list = {}
    for k, v in pairs(field_define) do
        table.insert(field_list, k .. " " .. v)
    end
    client:create_table(self.table_name, field_list, index_define)
    client:insert('t_lua_schema', {
        name=self.table_name,
        lua_schema={
            field_define=field_define, 
            index_define=index_define, 
            debug_version=SCHEMA_DEBUG_VERSION,
        }})
end

function Collection:_modify_all_field(client, old_field_define)
    local t_name = self.table_name
    local new_field_define = self:sql_field_define_dict()
    local dirty = false
    -- 先删除
    for name, value in pairs(old_field_define) do
        if not new_field_define[name] then
            client:drop_column(t_name, name)
            dirty = true
        end
    end
    -- 增改
    for name, value in pairs(new_field_define) do
        if not old_field_define[name] then
            client:add_column(t_name, name, value)
            dirty = true
        elseif value ~= old_field_define[name] then
            dirty = true
            if old_field_define[name] == 'double' and (value == 'int' or value == 'bigint') then
                client:add_column(t_name, name .. "_tmp_for_modify", value)
                client:query({"update", t_name, "set", name .. "_tmp_for_modify=round(" .. name .. ")"})
                client:drop_column(t_name, name)
                client:change_column(t_name, name .. "_tmp_for_modify", name, value)
            elseif (old_field_define[name] == 'int' or old_field_define[name] == 'bigint') and value == 'double' then
                client:add_column(t_name, name .. "_tmp_for_modify", 'double')
                client:query({"update", t_name, "set", name .. "_tmp_for_modify=" .. name})
                client:drop_column(t_name, name)
                client:change_column(t_name, name .. "_tmp_for_modify", name, 'double')
            else
                client:modify_column(t_name, name, value)
                g_log:warn("unknow field change:" .. old_field_define[name] .. "=>" .. value)
            end
        end
    end
    return dirty
end

function Collection:_modify_all_index(client, old_index_define)
    local new_index_define = self:sql_index_define_list()
    local dirty = false
    -- 先删除
    for _, idx in ipairs(old_index_define) do
        if not table.index(new_index_define, idx) then
            -- todo 删除
            dirty = true
            local idx_name = string.match(idx, "index%s+([%w_]+)")
            assert(idx_name)
            client:drop_index(self.table_name, idx_name)
        end
    end
    -- 增加
    for _, idx in ipairs(new_index_define) do
        if not table.index(old_index_define, idx) then
            -- todo 添加
            dirty = true
            local idx_name, tail = string.match(idx, "index%s+([%w_]+)(.+)")
            assert(idx_name and tail)
            client:add_index(self.table_name, idx_name, tail)
        end
    end
    return dirty
end

function Collection:check_create_table()
    if not IS_DEBUG then return end
    local client = self:get_db_client(1)
    if not client:is_table_exist("t_lua_schema") then
        client:create_table('t_lua_schema',
            {
            'name varchar(255) not null',
            'lua_schema json',
            }, 
            {
            'primary key (name)',
            })
    end
    local last_schema = client:select_one('t_lua_schema', {name=self.table_name})
    if last_schema then
        last_schema = json.decode(last_schema.lua_schema)
    end
    if last_schema and (last_schema.debug_version or 0) < SCHEMA_DEBUG_VERSION then
        client:drop_table(self.table_name)
        client:delete('t_lua_schema', {name=self.table_name})
        last_schema = nil
    end
    if not last_schema then
        self:_create_table(client)
    else
        -- 已经存在
        local dirty = false
        dirty = dirty or self:_modify_all_field(client, last_schema.field_define)
        dirty = dirty or self:_modify_all_index(client, last_schema.index_define)
        if dirty then 
            client:update('t_lua_schema', {name=self.table_name}, {lua_schema={
                field_define=self:sql_field_define_dict(), 
                index_define=self:sql_index_define_list(),
                debug_version=SCHEMA_DEBUG_VERSION,
            }})
        end
    end
end

function Collection:from_sql(data)
    local ok, ret = xpcall(function()
        return msg_profile.time_run("_from_sql", function()
            for k, v in pairs(data) do
                local field = self:get_field_schema(k)
                if not field.__F_IS_PLAIN then
                    data[k] = json.decode(v)
                end
            end
            return self.root_obj_cls.__F_FROM_SQL(data)
        end)
    end, g_log.trace_handle)
    if ok then return ret end
    PRINT("schema from_sql error" .. ret)
    PRINT(data)
    error("schema from_sql error" .. ret)
end

function Collection:attach(doc)
    local meta = getmetatable(doc)
    if meta and meta.__F_CLS == self.root_obj_cls then
        return doc
    end
    return self.root_obj_cls.attach(doc)
end

function Collection:new_obj(key)
    return self:attach({[self.primary] = key})
end

function Collection:load(key)
    print("key.."..key)
    local data = self:get_db_client(key):select_one(
        self.table_name, 
        {[self.primary] = key}
    )
    if not data then return end
    return self:from_sql(data)
end

function Collection:load_many(condition, selector, order, limit)
    local data_list = self:get_db_client():select_many(
        self.table_name,
        condition, selector, order, limit)
    for i, data in ipairs(data_list) do
        data_list[i] = self:from_sql(data)
    end
    return data_list
end

function Collection:delete_many(condition)
    self:get_db_client():delete(self.table_name, condition)
end

function Collection:query_count()
    return self:get_db_client():query_count(self.table_name)
end

function Collection:to_sql(obj)
    local ok, ret = pcall(function()
        return msg_profile.time_run("_to_sql", function()
            local ret = self.root_obj_cls.__F_TO_SQL(obj)
            for k, v in pairs(ret) do
                local field = self:get_field_schema(k)
                if not field.__F_IS_PLAIN then
                    ret[k] = json.encode(v)
                end
            end
            for k, v in pairs(obj.__DEL) do
                ret[k] = SQL_NULL
            end
            return ret
        end)
    end)
    if ok then return ret end
    PRINT("schema to_sql error: " .. ret)
    PRINT(obj)
    error("schema to_sql error: " .. ret)
end

function Collection:get_save_query(obj)
    local meta = getmetatable(obj)
    assert(meta and meta.__F_CLS == self.root_obj_cls)
    local key = obj[self.primary]
    assert(key)
    return table.pack(self.table_name, {[self.primary] = key}, self:to_sql(obj))
end

function Collection:save(obj)
    local query = self:get_save_query(obj)
    local key = obj[self.primary]
    return self:get_db_client(key):update(table.unpack(query, 1, query.n))
end

function Collection:make_key_query(key)
    return {[self.primary] = key}
end

function Collection:set_field(condition, kv_dict)
    local key = nil
    if type(condition) == 'table' then
        key = condition[self.primary]
    end
    local new_dict = {}
    for k, v in pairs(kv_dict) do
        local field = self:get_field_schema(k)
        if field and not field.__F_IS_PLAIN and v ~= SQL_NULL then
            v = DB_COPY(v)
            v = field.__F_CONVERTER(v)
            v = field.__F_TO_SQL(v)
            new_dict[k] = json.encode(v)
        else
            new_dict[k] = v
        end
    end
    return self:get_db_client(key):update(self.table_name, condition, new_dict)
end

-- careful
function Collection:json_update(condition, field_name, ...)
    local key = nil
    if type(condition) == 'table' then
        key = condition[self.primary]
    end
    assert(self:get_field_schema(field_name))
    return self:get_db_client(key):json_update(self.table_name, condition, field_name, ...)
end

function Collection:read_field(condition, selector)
    local key = nil
    if type(condition) == 'table' then
        key = condition[self.primary]
    end
    local data = self:get_db_client(key):select_one(
        self.table_name, condition, selector)
    if not data then return end
    for _, k in ipairs(selector) do
        local field = self:get_field_schema(k)
        if data[k] == nil then
            data[k] = field.__F_MAKE_DEFAULT()
        else
            if not field.__F_IS_PLAIN then
                print(data[k])
                data[k] = field.__F_FROM_SQL(json.decode(data[k]))
            end
        end
    end
    return data
end

function Collection:make_insert_query(key, doc)
    doc = doc or {[self.primary] = key}
    assert(key == doc[self.primary])
    local obj = self:attach(doc)
    return table.pack(self.table_name, self:to_sql(obj))
end

function Collection:insert(key, doc)
    doc = doc or {[self.primary] = key}
    assert(key == doc[self.primary])
    local obj = self:attach(doc)
    if self:get_db_client(key):insert(self.table_name, self:to_sql(obj)) then
        return obj
    else
        return
    end
end

function Collection:batch_insert(docs)
    for i, doc in ipairs(docs) do
        local obj = self:attach(doc)
        docs[i] = self:to_sql(obj)
    end
    if self:get_db_client():batch_insert(self.table_name, docs) then
        return docs
    else
        return
    end
end

function Collection:delete(key)
    self:get_db_client(key):delete(self.table_name, {[self.primary] = key})
end

MOD.ANY = {FieldAny, {}}
MOD.STR = {FieldStr, {}}
MOD.NUM = {FieldNum, {}}
MOD.BOOL = {FieldBool, {}}
MOD.INT = {FieldInt, {}}
MOD.BIGINT = {FieldInt, {sql_define='bigint'}}
MOD.TS = {FieldNum, {sql_define='double'}}
setmetatable(MOD.ANY, {__call=function(_, default_value, sql_define)
    return {FieldAny, {default_value=default_value, sql_define=sql_define}}
end})
setmetatable(MOD.STR, {__call=function(_, default_value, sql_define)
    return {FieldStr, {default_value=default_value, sql_define=sql_define}}
end})
setmetatable(MOD.NUM, {__call=function(_, default_value, sql_define)
    return {FieldNum, {default_value=default_value, sql_define=sql_define}}
end})
setmetatable(MOD.BOOL, {__call=function(_, default_value, sql_define)
    return {FieldBool, {default_value=default_value, sql_define=sql_define}}
end})
setmetatable(MOD.INT, {__call=function(_, default_value, sql_define)
    return {FieldInt, {default_value=default_value, sql_define=sql_define}}
end})
setmetatable(MOD.TS, {__call=function(_, default_value, sql_define)
    return {FieldNum, {default_value=default_value, sql_define=sql_define or 'double'}}
end})
setmetatable(MOD.BIGINT, {__call=function(_, default_value, sql_define)
    return {FieldInt, {default_value=default_value, sql_define=sql_define or 'bigint'}}
end})

function MOD.OBJ(fields, has_default, is_sql_table)
    return {FieldObj, {fields=fields, has_default=has_default, is_sql_table=is_sql_table}}
end

function MOD.DICT(key_schema, value_schema, has_default)
    return {FieldContainer, {key_schema=key_schema, value_schema=value_schema, has_default=has_default}}
end

function MOD.LIST(value_schema, has_default)
    return MOD.DICT(MOD.INT, value_schema, has_default)
end

function MOD.COLLECTION(mod, name, args)
    local cls = DECLARE_CLASS(mod, name)
    DECLARE_FINISH(cls)
    return Collection.new(cls, name, args.fields, args.primary, 
        args.db_name, args.index_list)
end

function MOD._refresh_schema(schema_mod_name)
    if MOD.is_freshing_dict[schema_mod_name] then
        skynet.timeout(10, function() MOD._refresh_schema(schema_mod_name) end)
    end

    MOD.is_freshing_dict[schema_mod_name] = true

    local schema_mod = require(schema_mod_name)
    g_log:info("refresh schema:" .. schema_mod_name)
    for k, schema in pairs(schema_mod.ALL_COLLECTION) do
        schema:check_create_table()
    end

    MOD.is_freshing_dict[schema_mod_name] = false
end

function MOD.check_refresh_schema(schema_mod_name)
    local schema_mod = require(schema_mod_name)
    require("srv_utils.reload").set_reload_after_callback(schema_mod, function()
        skynet.timeout(1, function() MOD._refresh_schema(schema_mod_name) end)
    end)
    MOD._refresh_schema(schema_mod_name)
end

-------------------------------------------------- 测试示例
local function test()
    
end

-- require("skynet").timeout(0, test)
-----------------------------------------------------

return MOD
