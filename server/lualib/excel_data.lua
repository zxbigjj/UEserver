local skynet = require('skynet')
local exceldata_dir = "./exceldata/"
local io_utils = require('sys_utils.io_utils')

local TY_PACK = 1
local TY_BIN = 2

local excel_data = DECLARE_MODULE("excel_data")
DECLARE_FINISH(excel_data)

function excel_data.init()
    -- nothing
end

function excel_data.has_loaded()
    return require("share_dict").has("__all_excel")
end

-- 将表数据的子项递归放入share_dict
local function push_data(prefix, t, is_top)
    local need_split
    if is_top then
        assert(type(t) == 'table')
        need_split = true
    elseif type(t) ~= 'table' then
        need_split = false
    else
        need_split = true
        for k, v in pairs(t) do
            if type(v) ~= 'table' then
                need_split = false
                break
            end
        end
    end
    
    if need_split then
        for k,v in pairs(t) do
            t[k] = push_data(string.format("%s:%s", prefix, k), v)
        end
        return t
    else
        require("share_dict").put(prefix, skynet.packstring(t))
        return TY_PACK
    end
end

-- 建立映射关系
local function scan_normal_data(normal_data, reverse_normal)
    for k, v in pairs(require("CSCommon.data_mgr")._excel_mapper) do
        normal_data[v] = v .. ".lua"
        reverse_normal[v .. ".lua"] = v
    end
    for file_p, file_name in pairs(io_utils.getfilesindir(exceldata_dir, ".lua")) do
        if not reverse_normal[file_name] then
            local name = string.sub(file_name, 1, -5)
            normal_data[name] = file_name
            reverse_normal[file_name] = name
        end
    end
    -- normal_data['TimelineData'] = "Timeline/TimelineData.lua"
    -- reverse_normal["Timeline/TimelineData.lua"] = 'TimelineData'
end

local function get_dir_file_key(meta, file_name)
    local begin_len = string.len(meta.begin_with)
    local ext_len = string.len(meta.file_ext)
    local key = string.sub(file_name, begin_len+1, -1-ext_len)
    if meta.num_key then
        return tonumber(key)
    else
        return key
    end
end

function excel_data.load(is_fight)
    print("load excel begin:", skynet.gettimeofday())
    local share_dict = require("share_dict")

    local normal_data = {}
    local reverse_normal = {}
    scan_normal_data(normal_data, reverse_normal)

    local all_excel = {}
    -- 读取所有单个exceldata
    local no_excel_list = {}
    for k, v in pairs(normal_data) do
        local value = io_utils.requirefile(exceldata_dir .. v)
        if not value then
            table.insert(no_excel_list, v)
        else
            all_excel[k] = push_data(k, value, true)
        end
    end
    if next(no_excel_list) then
        print('=============no excel: ' .. table.concat(no_excel_list, " "))
    end

    -- 读取目录下exceldata
    local dir_data = {}
    local reverse_data_dir = {}
    local function scan_dir_data(name, dir_name, begin_with, file_ext, num_key)
        assert(not all_excel[name])
        dir_data[name] = {
            name = name,
            dir_name = dir_name,
            begin_with = begin_with,
            file_ext = file_ext,
            num_key = num_key,
        }
        reverse_data_dir[dir_name] = name

        local scan_key = function()
            local dict = {}
            for file_p, file_name in pairs(io_utils.getfilesindir(exceldata_dir .. dir_name, file_ext)) do
                local key = get_dir_file_key(dir_data[name], file_name)
                local value
                if file_ext == '.lua' then
                    value = io_utils.requirefile(file_p)
                    share_dict.put(string.format("%s:%s", name, key), skynet.packstring(value))
                    dict[key] = TY_PACK
                else
                    value = io_utils.readfile(file_p)
                    share_dict.put(string.format("%s:%s", name, key), value)
                    dict[key] = TY_BIN
                end
            end
            all_excel[name] = dict
        end
        scan_key()
    end

    -- scan_dir_data('Cutscene', "Cutscene", "CutsceneData_", '.lua', false)
    -- scan_dir_data('MapLogicData', "MapLogic", "mlogic", '.lua', true)
    -- scan_dir_data('MapPosData', "MapPos", "mpos", '.lua', true)
    -- if is_fight then
    --     scan_dir_data('AI', "AI", "ai_", '.lua', false)
    --     scan_dir_data('NavMeshData', "navmeshdata", "", '.bytes', false)
    -- end
    share_dict.put("__all_excel", skynet.packstring(all_excel))
    share_dict.put("__excel_meta", skynet.packstring({
        normal_data = normal_data,
        reverse_normal = reverse_normal,
        dir_data = dir_data,
        reverse_data_dir = reverse_data_dir,
    }))

    collectgarbage()
    print("load excel end:", skynet.gettimeofday())
end

-- 整个节点只需要reload_watcher更新
function excel_data.update_excel(excel_list)
    local share_dict = require("share_dict")
    local all_excel = skynet.unpack(share_dict.get("__all_excel"))
    local excel_meta = skynet.unpack(share_dict.get("__excel_meta"))
    scan_normal_data(excel_meta.normal_data, excel_meta.reverse_normal)
    for _, file_path in ipairs(excel_list) do
        excel_data.__update(file_path, all_excel, excel_meta)
    end
    share_dict.put("__all_excel", skynet.packstring(all_excel))
    share_dict.put("__excel_meta", skynet.packstring(excel_meta))
end

function excel_data.__update(file_path, all_excel, excel_meta)
    local share_dict = require("share_dict")
    if string.sub(file_path, 1, string.len(exceldata_dir)) == exceldata_dir then
        file_path = string.sub(file_path, 1+string.len(exceldata_dir))
    end

    local words = string.split(file_path, "/")
    if excel_meta.reverse_normal[file_path] then
        local name = excel_meta.reverse_normal[file_path]
        local value = io_utils.requirefile(exceldata_dir .. file_path)
        if not value then
            print('===================no excel:' .. file_path)
        else
            all_excel[name] = push_data(name, value, true)
        end
    elseif #words > 1 then
        -- 只支持一层就好了
        if excel_meta.reverse_data_dir[words[1]] then
            local name = excel_meta.reverse_data_dir[words[1]]
            local meta = excel_meta.dir_data[name]
            local key = get_dir_file_key(meta, words[2])
            local value
            if meta.file_ext == '.lua' then
                value = io_utils.requirefile(exceldata_dir .. file_path)
                share_dict.put(string.format("%s:%s", name, key), skynet.packstring(value))
                all_excel[name][key] = TY_PACK
            else
                value = io_utils.readfile(exceldata_dir .. file_path)
                share_dict.put(string.format("%s:%s", name, key), value)
                all_excel[name][key] = TY_BIN
            end
            return
        end
    else
    end
end

local ReadonlyCls = {}
function ReadonlyCls:__index(k)
    local value = self.__tmp[k]
    if value ~= nil then return value end
    assert(getmetatable(self) == ReadonlyCls)
    assert(getmetatable(self.__raw) == nil)
    value = self.__raw[k]
    if value == nil then return end
    if type(value) == 'table' then
        value = excel_data.__readonly(value)
    end
    self.__tmp[k] = value
    return value
end
function ReadonlyCls:__newindex(k, v)
    error(string.format("cannot change excel data:%s", k))
end

function ReadonlyCls:__len()
    return #(self.__raw)
end

function ReadonlyCls:__pairs()
    return ReadonlyCls.__next, self, nil
end

function ReadonlyCls:__next(key)
    local nextkey = _HACK_CACHE.next(self.__raw, key)
    if nextkey ~= nil then
        return nextkey, self[nextkey]
    end
end

function excel_data.__readonly(raw)
    if type(raw) ~= 'table' then
        return raw
    end
    return setmetatable({__raw=raw, __tmp={}}, ReadonlyCls)
end

local DataProxy = {}
function DataProxy.new(prefix, key_dict, self)
    self = self or {}
    self.__tmp = {}
    self.__prefix = prefix
    self.__key_dict = key_dict
    return setmetatable(self, DataProxy)
end

function DataProxy:__index(k)
    local value = self.__tmp[k]
    if value ~= nil then return value end
    assert(getmetatable(self) == DataProxy)
    local v = self.__key_dict[k]
    if not v then return end
    if type(v) == 'table' then
        value = DataProxy.new(string.format("%s:%s", self.__prefix, k), v)
    else
        local bin = require("share_dict").get(string.format("%s:%s", self.__prefix, k))
        if not bin then return end
        if v == TY_PACK then
            value = skynet.unpack(bin)
        else
            value = bin
        end
        if type(value) == 'table' then
            value = excel_data.__readonly(value)
        end
    end
    self.__tmp[k] = value
    return value
end
function DataProxy:__newindex(k, v)
    error(string.format("cannot change excel data:%s", k))
end

function DataProxy:__len()
    return #(self.__key_dict)
end

function DataProxy:__pairs()
    return DataProxy.__next, self, nil
end

function DataProxy:__next(key)
    local nextkey = _HACK_CACHE.next(self.__key_dict, key)
    if nextkey ~= nil then
        return nextkey, self[nextkey]
    end
end

function excel_data.reload(excel_list)
    local share_dict = require("share_dict")
    local bin
    bin = share_dict.get("__all_excel")
    if not bin then return end

    local all_excel = skynet.unpack(bin)
    for k, v in pairs(all_excel) do
        if excel_data[k] then
            excel_data[k].__tmp = {}
            excel_data[k].__key_dict = v
        else
            excel_data[k] = DataProxy.new(k, v)
        end
    end
end

function excel_data.__fetch()
    local share_dict = require("share_dict")
    local bin
    bin = share_dict.get("__all_excel")
    if not bin then return end

    local all_excel = skynet.unpack(bin)
    for k, v in pairs(all_excel) do
        excel_data[k] = DataProxy.new(k, v)
    end
end
excel_data.__fetch()

return excel_data