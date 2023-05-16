-- 通过./service/reload_watcher/reload.txt集中管理所有服务的热更新
local skynet = require("skynet")
local lfs = require("lfs")

local utils = DECLARE_MODULE("watcher_utils")
DECLARE_RUNNING_ATTR(utils, "_watch_file_name", skynet.getenv('reload_path') .. "reload.txt")
DECLARE_RUNNING_ATTR(utils, "_watch_file_last_ts", 0)
DECLARE_RUNNING_ATTR(utils, "_shuting_ts", nil)
DECLARE_RUNNING_ATTR(utils, "_reload_record", {})
DECLARE_RUNNING_ATTR(utils, "_service_dict", {})

function utils.lc_x_reload_register(service, lua_path)
    if type(service) == "number" then
        service = skynet.address(service)
    end
    lua_path = string.gsub(lua_path, "%?%.", "([%%w_/]+)%%.")
    utils._service_dict[service] = lua_path
    -- 把历史记录合并返回
    local mod_dict = {}
    local excel_dict = {}
    for i, record in ipairs(utils._reload_record) do
        for mod_name, file_name in pairs(utils._parse_module_name(lua_path, record.file_list)) do
            mod_dict[mod_name] = file_name
        end
        for i, data_file_name in ipairs(record.excel_list) do
            excel_dict[data_file_name] = 1
        end
    end
    return {errcode=0, mod_dict=mod_dict, excel_dict=excel_dict}
end

function utils.ls_x_reload_unregister(service)
    if type(service) == "number" then
        service = skynet.address(service)
    end
    utils._service_dict[service] = nil
end

function utils.ls_x_reload_file(file_list)
    utils._check_notify_all({}, file_list)
end


function utils.start()
    utils._watch_file_last_ts = lfs.attributes(utils._watch_file_name, "modification")
    utils._fire_watch()
    -- 注册自己
    utils.lc_x_reload_register(skynet.self(), package.path)

    local shuting_file = string.format('status/%s.shuting', skynet.getenv("cluster_nodename"))
    local ts = lfs.attributes(shuting_file, "modification")
    if ts then
        os.remove(shuting_file)
    end
    skynet.timeout(100, utils.check_shutdown)
end

function utils.check_shutdown()
    local shuting_file = string.format('status/%s.shuting', skynet.getenv("cluster_nodename"))
    local ts = lfs.attributes(shuting_file, "modification")
    skynet.timeout(100, function() utils.check_shutdown() end)
    if not ts then return end
    if ts == utils._shuting_ts then return end
    utils._shuting_ts = ts

    os.remove(shuting_file)
    skynet.call(".debug_console", "lua", 'lc_do_shutdown')
end

function utils._fire_watch(delay)
    delay = delay or 100
    skynet.timeout(delay, function()
        return utils._watch()
    end)
end

function utils._watch()
    local file_name = utils._watch_file_name
    local ts = lfs.attributes(file_name, "modification")
    if not ts then
        -- 文件不存在
        g_log:error("reload fail, cannot open file:" .. file_name)
        utils._fire_watch()
        return
    end
    if utils._watch_file_last_ts == ts then
        -- 未更新
        utils._fire_watch()
        return
    end
    -- 读取文件
    local fobj = io.open(file_name, "r")
    local file_list = {}
    local excel_list = {}
    local file_type = 'data'
    while true do
        local line = fobj:read("l")
        if not line then break end
        while true do
            if string.match(line, "^%-%-") then break end
            if string.match(line, "^%#") then break end
            line = string.strip(line)
            if line == "" then break end
            if line == '[data]' then
                file_type = 'data'
                break
            elseif line == '[script]' then
                file_type = 'script'
                break
            elseif file_type == 'script' then
                table.insert(file_list, line)
                break
            elseif file_type == 'data' then
                table.insert(excel_list, line)
                break
            end
            break
        end
    end
    fobj:close()
    -- 更新
    table.insert(utils._reload_record, {file_list=file_list, excel_list=excel_list, ts=ts})
    g_log:info("excel to reload:\n" .. table.concat(excel_list, "\n"))
    g_log:info("file to reload:\n" .. table.concat(file_list, "\n"))

    utils._watch_file_last_ts = ts
    utils._fire_watch()

    if next(excel_list) then
        local excel_data = require("excel_data")
        if excel_data.has_loaded() then
            excel_data.update_excel(excel_list)
        end
    end
    utils._check_notify_all(excel_list, file_list)
end

function utils._check_notify_all(excel_list, file_list)
    local parse_cache = {}
    for service, lua_path in pairs(utils._service_dict) do
        local mod_dict = parse_cache[lua_path]
        if not mod_dict then
            mod_dict = utils._parse_module_name(lua_path, file_list)
            parse_cache[lua_path] = mod_dict
        end
        if next(mod_dict) or next(excel_list) then
            skynet.send(service, "lua", "ls_x_reload_notify", excel_list, mod_dict)
        end
    end
end

function utils._parse_module_name(lua_path, file_list)
    local result = {}
    local path_list = string.split(lua_path, ";")
    local capture = nil
    for i,file_name in ipairs(file_list) do
        for _, path in ipairs(path_list) do
            capture = string.match(file_name, '^'..path..'$')
            if capture then
                result[string.gsub(capture, "%/", ".")] = file_name
                break
            end
        end
    end
    return result
end

-- 注册
local lua_handles_utils = require("msg_utils.lua_handles_utils")
lua_handles_utils.add_send_handle("ls_x_reload_unregister", utils.ls_x_reload_unregister)
lua_handles_utils.add_call_handle("lc_x_reload_register", utils.lc_x_reload_register)
lua_handles_utils.add_call_handle("ls_x_reload_file", utils.ls_x_reload_file)

return utils