local SprotoLoader = require "sprotoloader"
local SprotoCore = require "sproto.core"
local SprotoEnv = require "msg_utils.sproto_msg_env"
local PACKAGE_NAME = SprotoEnv.BASE_PACKAGE

local ENCODE = SprotoCore.encode
local DECODE = SprotoCore.decode
local PACK = SprotoCore.pack
local UNPACK = SprotoCore.unpack

local c2s_sp = SprotoLoader.load(SprotoEnv.PROTO_ID_C2S)
local s2c_sp = SprotoLoader.load(SprotoEnv.PROTO_ID_S2C)
local BASE_PACKAGE = c2s_sp:query_type(SprotoEnv.BASE_PACKAGE)

local msg_utils = DECLARE_MODULE("msg_utils.sproto_msg_utils")

function msg_utils.pack_server_msg(data)
    return string.pack(">s3", data)
end

function msg_utils.pack_client_msg(data)
    return string.pack(">s2", data)
end

function msg_utils.unpack_s2c_size(data)
    if #data < 3 then
        return
    end
    return string.unpack(">I3", data)
end

function msg_utils.unpack_c2s_size(data)
    if #data < 2 then
        return
    end
    return string.unpack(">I2",data)
end

local header_tmp = {}
function msg_utils.decode_client_msg(data)
    local bin = UNPACK(data)
    header_tmp.type = nil
    header_tmp.session = nil
    local header, size = DECODE(BASE_PACKAGE, bin, header_tmp)
    if header.type then
        -- request
        local proto = c2s_sp:query_proto(header.type)
        local result = DECODE(proto.request, bin:sub(size + 1))
        return proto.name, result, header_tmp.session
    else
        error("not support decode_client_msg without header.type")
    end
end

function msg_utils.encode_s2c_req(name, args)
    local proto = s2c_sp:query_proto(name)
    header_tmp.type = proto.tag
    header_tmp.session = nil
    local header = ENCODE(BASE_PACKAGE, header_tmp)

    if proto.request then
        local content = ENCODE(proto.request, args)
        return PACK(header .. content)
    else
        return PACK(header)
    end
end

function msg_utils.encode_c2s_resp(session, name, args)
    local proto = c2s_sp:query_proto(name)
    header_tmp.type = nil
    header_tmp.session = session
    local header = ENCODE(BASE_PACKAGE, header_tmp)
    local content = ENCODE(proto.response, args)
    return PACK(header .. content)
end

function msg_utils.decode_s2c_req(data)
    local bin = UNPACK(data)
    header_tmp.type = nil
    header_tmp.session = nil
    local header, size = DECODE(BASE_PACKAGE, bin, header_tmp)
    if header.type then
        -- s2c request
        local proto = s2c_sp:query_proto(header.type)
        local result = DECODE(proto.request, bin:sub(size + 1))
        return proto.name, result
    else
        error("never got here")
    end
end

function msg_utils.decode_server_msg(data)
    local bin = UNPACK(data)
    header_tmp.type = nil
    header_tmp.session = nil
    local header, size = DECODE(BASE_PACKAGE, bin, header_tmp)
    if header.type then
        -- s2c request
        local proto = s2c_sp:query_proto(header.type)
        local result = DECODE(proto.request, bin:sub(size + 1))
        return 'req', proto.name, result
    else
        -- c2s response
        return 'resp', header_tmp.session, bin:sub(size + 1)
    end
end

function msg_utils.decode_c2s_response(name, content)
    local proto = c2s_sp:query_proto(name)
    return DECODE(proto.response, content)
end

function msg_utils.encode_c2s_req(name, args, session)
    local proto = c2s_sp:query_proto(name)
    header_tmp.type = proto.tag
    header_tmp.session = session
    local header = ENCODE(BASE_PACKAGE, header_tmp)

    if proto.request then
        local content = ENCODE(proto.request, args)
        return PACK(header .. content)
    else
        return PACK(header)
    end
end

function msg_utils.query_c2s_proto(name)
    return c2s_sp:query_proto(name)
end

local function eq(a, b)
    if type(a) == 'table' then
        if type(b) ~= 'table' then return false end
        local keys = table.keys(a)
        table.sort(keys)
        for i, key in ipairs(keys) do
            if not eq(a[key], b[key]) then return false end
        end
        return true
    end
    return a == b
end

function msg_utils.test()
    local value_list = {}
    local v = 1
    for i=1,40 do
        v = v * 2
        table.insert(value_list, v - math.random(1, 20))
        table.insert(value_list, v + math.random(1, 20))
        table.insert(value_list, -v - math.random(1, 20))
        table.insert(value_list, -v + math.random(1, 20))
    end
    for i, value in ipairs(value_list) do
        local test_tb = {time = value, time_list={value, value}, time_dict={[1]=value, [value]=value, [-23]=value}}
        local data = msg_utils.encode_c2s_req('c_test', test_tb, 0)
        local a, test_tb2 = msg_utils.decode_client_msg(data)
        if eq(test_tb, test_tb2) then
            print(i, true, value)
        else
            PRINT(i, false, test_tb, test_tb2)
        end
    end
end

-- msg_utils.test()

return msg_utils
