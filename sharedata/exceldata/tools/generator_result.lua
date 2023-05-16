
local file_list_path = "../data/temp_lua_data/file_list.lua"

local client_lua_path = "./lua_convertor_client/"
local server_lua_path = "./lua_convertor_server/"

local client_output_path = "../data/client/"
local server_output_path = "../data/server/"

if loadstring == nil then
    loadstring = load
end

local function read_file(file_path)
    local file = io.open(file_path, "rb")
    if not file then
        return
    end
    local data = file:read("*a")
    file:close()
    return data
end

local function require_file(file_path)
    local file_data = read_file(file_path)
    if not file_data then
        return
    end
    local succ, msg = loadstring(file_data)
    if not succ then
        print(msg)
        error("load", file_path, "failed")
        return
    end
    return succ()
end

local function write_space(file_handle, count)
    local i = 1
    while (i < count) do
        file_handle:write("    ")
        i = i + 1
    end
end

local function data_key_sort(data)
    local keys = {}
    for k, v in pairs(data) do
        if string.sub(k, 1, 2) ~= "__" then
            table.insert(keys, k)
        end
    end
    table.sort(keys, function (a, b)
        if type(a) == type(b) then
            return a < b 
        else
            return type(a) < type(b)
        end
    end)
    return keys
end

local function deep_copy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return new_table
    end
    return _copy(object)
end


local function serialize(data, file_handle, recursion_depth, name_scheme, is_client)
    d_type = type(data)
    if d_type == 'table' then
        file_handle:write("{\n")
        local has_serialized_tb = {}
        if name_scheme then
            for _, name in ipairs(name_scheme) do
                has_serialized_tb[name] = true
                local v = data[name]
                if v ~= nil then
                    write_space(file_handle, recursion_depth + 1)
                    file_handle:write("[ ")
                    serialize(name, file_handle, recursion_depth + 1, nil, is_client)
                    file_handle:write(" ] = ")
                    serialize(v, file_handle, recursion_depth + 1, nil, is_client)
                    file_handle:write(",\n")
                end
            end
        end
        local keys = data_key_sort(data)
        for _, k in ipairs(keys) do
            if string.sub(k, 1, 2) ~= "__" and (not has_serialized_tb[k]) then
                local v = data[k]
                write_space(file_handle, recursion_depth + 1)
                file_handle:write("[ ")
                serialize(k, file_handle, recursion_depth + 1, nil, is_client)
                file_handle:write(" ] = ")
                serialize(v, file_handle, recursion_depth + 1, nil, is_client)
                file_handle:write(",\n")
            end
        end
        write_space(file_handle, recursion_depth)
        file_handle:write("}")
    elseif d_type == 'number' then
        file_handle:write(data)
    elseif d_type == 'boolean' then
        file_handle:write(data and "true" or "false")
    elseif d_type == 'string' then
        local str = string.sub(data, 1, 5)
        if str == "lang-" then
            data = string.sub(data, 6)
            if is_client then
                file_handle:write(string.format("langexcel[%q]", data))
            else
                file_handle:write(string.format("%q",data))
            end
        else
            file_handle:write(string.format("%q",data))
        end
    end
end

local function write_data_to_file(data, file_path, name_scheme, is_client)
    local file_handle = io.open(file_path, "wb")
    file_handle:write("return ")
    file_handle:write("{\n")
    local recursion_depth = 1
    local keys = data_key_sort(data)
    for _, k in pairs(keys) do
        if string.sub(k, 1, 2) ~= "__" then
            v = data[k]
            write_space(file_handle, recursion_depth + 1)
            file_handle:write("[ ")
            serialize(k, file_handle, recursion_depth + 1, nil, is_client)
            file_handle:write(" ] = ")
            serialize(v, file_handle, recursion_depth + 1, name_scheme, is_client)
            file_handle:write(",\n")
        end
    end
    file_handle:write("}")
    file_handle:close()
end

local function parse_table_field(raw_data, field_name)
    for k, v in pairs(raw_data) do
        if string.sub(k, 1, 2) ~= "__" and v[field_name] then
            local value = v[field_name]
            if type(value) == 'string' then
                local chunk, err = load("return {" .. value .. "}")
                if not chunk then
                    print(value)
                    print(err)
                    error("parse_table_field error:" .. k)
                end
                v[field_name] = chunk()
            elseif type(value) == 'table' then
                local new_list = {}
                for _, elem in ipairs(value) do
                    local chunk, err = load("return {" .. elem .. "}")
                    if not chunk then
                        print(elem)
                        print(err)
                        error("parse_table_field error:" .. k)
                    end
                    table.insert(new_list, chunk())
                end
                v[field_name] = new_list
            else
                print(type(value))
                error("parse_table_field type error:" .. k)
            end
        end
    end
end

local function main()
    local file_list = require_file(file_list_path)
    if not file_list then
        print("error there a none file_list in lua convertor stage")
        return
    end
    local handle_path = ""
    local client_all_data = {}
    local client_dict = {}

    local server_all_data = {}
    local server_dict = {}

    -- 保证遍历的顺序
    local _pairs = _G["pairs"]
    _G["pairs"] = function(t)
        local keys = {}
        for k,v in _pairs(t) do
            table.insert(keys, k)
        end
        table.sort(keys, function(x,y)
            if type(x) == type(y) then
                return x < y
            else
                return type(x) < type(y)
            end
        end)

        local i=0
        local _next = function(t, key)
            i = i + 1
            local key = keys[i]
            if key == nil then return nil, nil end
            return key, t[key]
        end
        return _next, t, nil
    end

    for path, file_name in pairs(file_list) do
        print (path, file_name)
        handle_path = client_lua_path .. file_name
        local client_convertor = require_file(handle_path)
        local raw_data = require_file(path)

        for _, field_name in ipairs(raw_data["__table_field_list"]) do
            parse_table_field(raw_data, field_name)
        end

        local name_scheme = raw_data["__element_names_scheme"]
        raw_data["__element_names_scheme"] = nil
        raw_data["__table_field_list"] = nil
        local ret_data = deep_copy(raw_data)
        if client_convertor and client_convertor.convert then
            local ok, msg = xpcall(function() ret_data = client_convertor:convert(ret_data) end, debug.traceback)
            if not ok then
                print(msg)
                print("generator failed!")
                os.exit(1)
            end
        end
        if client_convertor and client_convertor.push_convert then
            client_dict[client_convertor] = {
                data = ret_data,
                file_name = file_name,
                name_scheme = name_scheme,
            }
        end
        client_all_data[file_name] = ret_data
        write_data_to_file(ret_data, client_output_path .. file_name, name_scheme, true)

        ret_data = deep_copy(raw_data)
        handle_path = server_lua_path .. file_name
        local server_convertor = require_file(handle_path)
        if server_convertor and server_convertor.convert then
            local ok, msg = xpcall(function() ret_data = server_convertor:convert(ret_data) end, debug.traceback)
            if not ok then
                print(msg)
                print("generator failed!")
                os.exit(1)
            end
        end
        if server_convertor and server_convertor.push_convert then
            server_dict[server_convertor] = {
                data = ret_data,
                file_name = file_name,
            }
        end
        server_all_data[file_name] = ret_data
        write_data_to_file(ret_data, server_output_path .. file_name)
    end
    _G["pairs"] = _pairs
    --全部导表完，在对一些表特殊处理
    local ret_data
    for convertor, info in pairs(client_dict) do
        ret_data = convertor:push_convert(info.data, client_all_data)
        if not ret_data then
            error("push convert error:" .. info.file_name)
        end
        write_data_to_file(ret_data, client_output_path .. info.file_name, info.name_scheme, true)
    end
    for convertor, info in pairs(server_dict) do
        ret_data = convertor:push_convert(info.data, server_all_data)
        if not ret_data then
            error("push convert error:" .. info.file_name)
        end
        write_data_to_file(ret_data, server_output_path .. info.file_name)
    end
end

main()
