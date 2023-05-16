local skynet = require('skynet')
local mysql = require('skynet.db.mysql')
local json = require("json")

local db_cls = DECLARE_MODULE("db.mysql_db")

DECLARE_RUNNING_ATTR(db_cls, "_trans_guid", 1)

DECLARE_RUNNING_ATTR(db_cls, "_debug_timer", nil, function()
    return require("timer").loop(1, function() db_cls.debug_info() end)
end)

db_cls.quote_sql_str = mysql.quote_sql_str

function db_cls:close()
    local _c = self._client
    if not _c then return end
    self._client = nil
    g_log:sql("SqlClose", {host=self._opts.host, user=self._opts.user})
    mysql.disconnect(_c)
end

db_cls.__gc = db_cls.close

function db_cls:connect()
    g_log:sql("SqlConnect", {host=self._opts.host, user=self._opts.user})
    local opts = table.deep_copy(self._opts)
    opts.on_connect = function(client)
        self:on_connect(client)
    end
    if not pcall(function()
        self._client = mysql.connect(opts)
    end) then
        error(string.format("sql connect error:%s,%s", self._opts.host, self._opts.port))
    end
end

function db_cls:on_connect(client)
    self._client = client
    
    if not pcall(db_cls.use_database, self, self.db_name) then
        pcall(db_cls.create_database, self, self.db_name)
        self:use_database(self.db_name)
    end
    self:query("SET NAMES utf8mb4")
end

function db_cls:do_transaction(func)
    while self._trans_co do
        -- 不应该重入
        assert(self._trans_co ~= coroutine.running())
        self:_trans_wait()
    end
    self._trans_co = coroutine.running()
    local begin_ts = skynet.time()
    local guid = db_cls._trans_guid
    db_cls._trans_guid = guid + 1
    pcall(function() self._client:query("begin") end)
    g_log:sql("BeginTrans", {guid=guid, wait_count=#self._trans_waiting_list})
    local ok, err = xpcall(func, g_log.trace_handle)
    if ok then
        ok = pcall(function() self._client:query("commit") end)
        g_log:sql("CommitTrans", {guid=guid, use_time=skynet.time() - begin_ts})
    else
        pcall(function() self._client:query("rollback") end)
        g_log:sql("RollbackTrans", {guid=guid, use_time=skynet.time() - begin_ts})
    end
    self._trans_co = nil
    if next(self._trans_waiting_list) then
        skynet.wakeup(table.remove(self._trans_waiting_list, 1))
    end
    return ok
end

function db_cls:_trans_wait()
    local co = coroutine.running()
    table.insert(self._trans_waiting_list, co)
    skynet.wait()
end

local QUERY_COUNT = 0

function db_cls:query(query)
    if type(query) == 'table' then
        query = table.concat(query, " ")
    end
    if self._trans_co then
        if self._trans_co == coroutine.running() then
            -- nothing
        else
            self:_trans_wait()
            if next(self._trans_waiting_list) then
                skynet.wakeup(table.remove(self._trans_waiting_list, 1))
            end
        end
    end
    local begin_ts = skynet.time()
    local result = self._client:query(query)
    QUERY_COUNT = QUERY_COUNT + 1
    
    if result.badresult then
        g_log:sql("SqlError", {query=query, result=result})
        error("sql query error:" .. query)
    else
        local len = string.len(query)
        local query_log = nil
        if len > 80 then
            query_log = string.sub(query, 1, 40) .. " ... " .. string.sub(query, len-40, len)
        else
            query_log = query
        end
        g_log:sql("SqlQuery", {query=query_log, size=len, use_time=skynet.time() - begin_ts})
    end
    return result
end

function db_cls.debug_info()
    if QUERY_COUNT > 0 then
        g_log:info(string.format("SqlQueryCount: %s", QUERY_COUNT))
        QUERY_COUNT = 0
    end
end

function db_cls:create_database(db_name)
    return self:query(string.format("create database %s character set utf8mb4", 
        db_name))
end

function db_cls:drop_table(table_name)
    return self:query("drop table " .. table_name)
end

function db_cls:create_table(table_name, field_list, index_list)
    local query = string.format("create table %s(\n", table_name)
    query = query .. table.concat(field_list, ",\n")
    query = query .. ",\n"
    query = query .. table.concat(index_list, ",\n")
    query = query .. ")  DEFAULT CHARSET=utf8mb4"
    return self:query(query)
end

function db_cls:add_column(t_name, field_name, define)
    local query = {'alter table', t_name, 'add column', field_name, define}
    return self:query(query)
end

function db_cls:drop_column(t_name, field_name)
    local query = {'alter table', t_name, 'drop column', field_name}
    return self:query(query)
end

function db_cls:modify_column(t_name, field_name, define)
    local query = {'alter table', t_name, 'modify', field_name, define}
    return self:query(query)
end

function db_cls:change_column(t_name, old_name, new_name, define)
    local query = {'alter table', t_name, 'change', old_name, new_name, define}
    return self:query(query)
end

function db_cls:drop_index(t_name, index_name)
    return self:query({'alter table', t_name, "drop index", index_name})
end

function db_cls:add_index(t_name, index_name, index_tail)
    return self:query({'alter talbe', t_name, 'add index', index_name, index_tail})
end

function db_cls:is_table_exist(table_name)
    local ok, result = pcall(function()
        return self:query("select count(*) from " .. table_name)
    end)
    if not ok or result.badresult then
        return false
    else
        return true
    end
end

function db_cls:query_one(query)
    return self:query(query)[1]
end

function db_cls:make_condition(tb)
    if type(tb) ~= 'table' then return tb end
    local list = {}
    for k, v in pairs(tb) do
        local vtype = type(v)
        if vtype == 'string' then
            v = mysql.quote_sql_str(v)
        elseif vtype == 'number' then
        elseif vtype == 'boolean' then
            v = v and 1 or 0
        else
            error("unknown condition type:" .. vtype)
        end
        table.insert(list, k .. "=" .. v)
    end
    if #list > 0 then
        return table.concat(list, "&&")
    else
        return nil
    end
end

function db_cls:convert_value(v)
    local vtype = type(v)
    if v == SQL_NULL or v == nil then
        v = 'null'
    elseif vtype == 'string' then
        v = mysql.quote_sql_str(v)
    elseif vtype == 'number' then
        v = tostring(v)
    elseif vtype == 'boolean' then
        v = tostring(v and 1 or 0)
    elseif vtype == 'table' then
        v = string.format('cast(%s as json)', mysql.quote_sql_str(json.encode(v)))
    else
        error("unknown value type:" .. vtype)
    end
    return v
end

function db_cls:make_setter(tb)
    local list = {}
    for k, v in pairs(tb) do
        v = self:convert_value(v)
        table.insert(list, k .. "=" .. v)
    end
    return table.concat(list, ",")
end

function db_cls:make_values(tb)
    local keys, values = {}, {}
    for k, v in pairs(tb) do
        v = self:convert_value(v)
        table.insert(keys, k)
        table.insert(values, v)
    end
    return "(" .. table.concat(keys, ",") .. ")",
            "(" .. table.concat(values, ",") .. ")"
end

function db_cls:make_order(order)
    local order_list = {}
    for k, v in pairs(order) do
        if v > 0 then
            table.insert(order_list, k .. " asc")
        else
            table.insert(order_list, k .. " desc")
        end
    end
    return table.concat(order_list, ",")
end

-- condition可以是一个表，或者一个写好的sql字符串
function db_cls:select_one(t_name, condition, selector)
    condition = self:make_condition(condition)
    if selector then
        selector = table.concat(selector, ",")
    else
        selector = "*"
    end
    local query = string.format("select %s from %s", selector, t_name)
    if condition and condition ~= "" then
        query = query .. " where " .. condition
    else
        error("select one must have condition")
    end
    return self:query(query)[1]
end

-- condition可以是一个表，或者一个写好的sql字符串
function db_cls:select_many(t_name, condition, selector, order, limit)
    condition = self:make_condition(condition)
    if selector then
        selector = table.concat(selector, ",")
    else
        selector = "*"
    end
    local query = {'select', selector, 'from', t_name}
    if condition and condition ~= "" then
        table.insert(query, 'where ' .. condition)
    end
    if order then
        if type(order) == 'table' then
            order = self:make_order(order)
        end
        table.insert(query, 'order by ' .. order)
    end
    if limit then
        table.insert(query, 'limit ' .. limit)
    end
    return self:query(query)
end

function db_cls:update(t_name, condition, setter)
    condition = self:make_condition(condition)
    if not condition or condition == '' then
        error("update must have condition")
    end
    if not setter or not next(setter) then
        error("update setter is empty")
    end
    local query = {"update", t_name, "set", self:make_setter(setter), 
            "where", condition}
    return self:query(query)
end

function db_cls:json_update(t_name, condition, field_name, ...)
    condition = self:make_condition(condition)
    if not condition or condition == '' then
        error("update must have condition")
    end
    local arg_list = table.pack(...)
    if arg_list.n < 1 then
        error("json_update arg_list is empty")
    end

    local set_str = string.format("%s = json_set(%s", field_name, field_name)
    for i=1, arg_list.n, 2 do
        local path = arg_list[i]
        local value = arg_list[i+1]
        set_str = set_str .. string.format(", %s, %s", mysql.quote_sql_str(path), self:convert_value(value))
    end
    set_str = set_str .. ")"

    local query = {"update", t_name, "set", set_str, 
            "where", condition}
    return self:query(query)
end

function db_cls:insert(t_name, doc, use_replace)
    local keys, values = self:make_values(doc)
    local first = use_replace and 'replace into' or 'insert into'
    local query = {first, t_name, keys, "values", values}
    if pcall(self.query, self, query) then
        return true
    else
        return false
    end
end

function db_cls:batch_insert(t_name, doc_list)
    local len = #doc_list
    local keys, query = nil, {"insert into", t_name}
    for i, doc in ipairs(doc_list) do
        local key, value = self:make_values(doc)
        if not keys then
            keys = key
            table.insert(query, keys)
            table.insert(query, "values")
        end
        if i < len then
            table.insert(query, value .. ",")
        else
            table.insert(query, value .. ";")
        end
    end
    if pcall(self.query, self, query) then
        return true
    else
        return false
    end
end

function db_cls:delete(t_name, condition)
    condition = self:make_condition(condition)
    if not condition or condition == '' then
        error("delete must have condition")
    end
    return self:query({'delete from', t_name, 'where', condition})
end

function db_cls:query_count(t_name)
    return self:query({'select count(*) from', t_name})[1]["count(*)"]
end

function db_cls:use_database(db_name)
    return self:query("use " .. db_name)
end

function db_cls.new(db_cfg)
    local opts = {
        host = db_cfg.host,
        port = db_cfg.port, --3306
        user = db_cfg.user,
        password = db_cfg.passwd, -- 'wpxHJS_2017',
        max_packet_size = 1024*1024*64,   
    }
    local client = {
        db_name = db_cfg.db_name,
        _opts = opts,
        _trans_co = nil,
        _trans_waiting_list = {}
    }
    setmetatable(client, db_cls)

    xpcall(client.connect, g_log.trace_handle, client)

    return client
end

function test()
    local db_cfg = require("srv_utils.server_env").get_db_cfg('gamedb')
    local db = db_cls.new(db_cfg)
    db:query("use zc_game3")
    

    skynet.fork(function()
        skynet.sleep(50)
        PRINT(db:query("select count(*) from test"))
        skynet.sleep(100)
        PRINT(db:query("select count(*) from test"))
        skynet.sleep(100)
        PRINT(db:query("select count(*) from test"))
        collectgarbage()
    end)

    skynet.timeout(100, function()
        db:do_transaction(function()
            db:query("insert test (data) values ('sdfsdf')")
            skynet.sleep(300)
            db:query("insert test (data) values ('sdfsdf')")
        end)
    end)


    
end

return db_cls


