local io_utils = require('sys_utils.io_utils')
local sharedata = require("skynet.sharedata")

local exceldata_dir = "./exceldata/"

local exceldataloader = DECLARE_MODULE("exceldataloader")
local data = {}
for k, v in pairs(require("CSCommon.data_mgr")._excel_mapper) do
    data[v] = exceldata_dir .. v .. ".lua"
end

local dir_data = {}
-- dir_data['AIData'] = {exceldata_dir .. "AI", "id"}
-- dir_data['MapLogicData'] = {exceldata_dir .. "MapLogic", "id"}
-- dir_data['MapPosData'] = {exceldata_dir .. "MapPos", "id"}
-- dir_data["Cutscene"] = {exceldata_dir .. "Cutscene", "name"}

local dir_raw_data = {}
-- dir_raw_data["NavMeshData"] = {exceldata_dir .. "navmeshdata", ".bytes"}

local load_func = [==[
    local args = {...}
    local data, dir_data, dir_raw_data = args[1], args[2], args[3]
    local ret = {}
    local io_utils = require('sys_utils.io_utils')

    for data_key_name, file_name in pairs(data) do
        ret[data_key_name] = io_utils.requirefile(file_name)
    end

    for data_key_name, v in pairs(dir_data) do
        local dir_path, key_name, file_ext = v[1], v[2], v[3]
        file_ext = file_ext or ".lua"
        local files_in_dir = io_utils.getfilesindir(dir_path, file_ext)
        ret[data_key_name] = {}
        for file_p, file_name in pairs(files_in_dir) do
            local rf = io_utils.requirefile(file_p)
            ret[data_key_name][rf[key_name]] = rf
        end
    end

    -- ret['TimelineData'] = io_utils.requirefile('./exceldata/Timeline/TimelineData.lua')

    for data_key_name, v in pairs(dir_raw_data) do
        local dir_path, file_ext = v[1], v[2]
        file_ext = file_ext or ".lua"
        local files_in_dir = io_utils.getfilesindir(dir_path, file_ext)
        ret[data_key_name] = {}
        for file_p, file_name in pairs(files_in_dir) do
            local rf = io_utils.readfile(file_p)
            local key = string.sub(file_name, 1, string.len(file_name) - string.len(file_ext))
            ret[data_key_name][key] = rf
        end
    end
    return ret
]==]

function exceldataloader.start()
    sharedata.new("excel_data", load_func, data, dir_data, dir_raw_data)
end

if exceldataloader.__RELOADING then
    sharedata.update("excel_data", load_func, data, dir_data, dir_raw_data)
end

return exceldataloader