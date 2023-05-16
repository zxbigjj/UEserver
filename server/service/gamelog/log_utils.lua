local log_utils = DECLARE_MODULE("log_utils")
local json = require("json")
DECLARE_RUNNING_ATTR(log_utils, "log_dict", {})
DECLARE_RUNNING_ATTR(log_utils, "touched_dict", {})
DECLARE_RUNNING_ATTR(log_utils, "dir_dict", {})

local skynet = require("skynet")
local LOG_ROOT = skynet.getenv("log_path")
LOG_ROOT = string.gsub(LOG_ROOT, "\\", "/")
if string.sub(LOG_ROOT, -1) ~= "/" then
    LOG_ROOT = LOG_ROOT .. "/"
end

function log_utils.ls_x_log(service_tag, file_name, tag, ...)
    local log_queue = log_utils.log_dict[file_name]
    local args = table.pack(...)
    local text = nil
    if args.n == 1 then
        if type(args[1]) == "table" then
            text = json.encode(args[1])
        else
            text = tostring(args[1])
        end
    else
        args.n = nil
        text = json.encode(args)
    end
    if not log_queue then
        log_utils.log_dict[file_name] = {{service_tag=service_tag, tag=tag, text=text}}
    else
        log_queue[1+#log_queue] = {service_tag=service_tag, tag=tag, text=text}
    end
end

function log_utils.lc_x_flush_log()
    log_utils.flush()
end

function log_utils.flush_loop()
    skynet.timeout(100, log_utils.flush_loop)
    log_utils.flush()
end

function log_utils.flush()
    local temp = log_utils.log_dict
    log_utils.log_dict = {}
    for file_name, log_queue in pairs(temp) do
        local status, err = pcall(function()
            if file_name == 'bdclog' then
                log_utils.write_bdclog(log_queue)
            else
                log_utils.write_log(file_name, log_queue)
            end
        end)
        if not status then
            print("log error", file_name, err)
        end
    end
end

function log_utils.write_log(file_name, log_queue)
    local now_ts = math.floor(skynet.time())
    local now = os.date("[%Y-%m-%d %H:%M:%S]", now_ts)
    local now_filename = os.date("_%Y%m%d_%H.log", now_ts)
    local node_name = require("srv_utils.server_env").get_node_name()
    local dirname = LOG_ROOT  .. node_name .. "/" .. os.date("%Y%m%d", now_ts)
    if not log_utils.dir_dict[dirname] then
        os.execute("mkdir -p " .. dirname)
        log_utils.dir_dict[dirname] = true
    end
    dirname = dirname .. "/"
    local fullname = dirname .. file_name .. now_filename

    if not log_utils.touched_dict[fullname] then
        os.execute("touch " .. fullname)
        log_utils.touched_dict[fullname] = true
    end
    local file = io.open(fullname, "a")
    for i,info in ipairs(log_queue) do
        file:write(now, string.format("[%s][%s] ", info.service_tag, info.tag), info.text, "\n")
    end
    file:close()
end

function log_utils.write_bdclog(log_queue)
    local now_ts = math.floor(skynet.time())
    local now_filename = os.date("_%Y%m%d_%H.log", now_ts)
    local server_id = require("srv_utils.server_env").get_server_id()
    local dirname = LOG_ROOT .. string.format("gata/s%d/", server_id) .. os.date("%Y%m%d", now_ts)
    if not log_utils.dir_dict[dirname] then
        os.execute("mkdir -p " .. dirname)
        log_utils.dir_dict[dirname] = true
    end
    dirname = dirname .. "/"
    local fullname = dirname .. "gaea" .. now_filename

    if not log_utils.touched_dict[fullname] then
        os.execute("touch " .. fullname)
        log_utils.touched_dict[fullname] = true
    end
    local file = io.open(fullname, "a")
    for i,info in ipairs(log_queue) do
        file:write(info.text, "\n")
    end
    file:close()
end

function log_utils.start()
    local node_name = require("srv_utils.server_env").get_node_name()
    local server_id = require("srv_utils.server_env").get_server_id()
    print(os.execute("mkdir -p " .. LOG_ROOT))
    print(os.execute(string.format("mkdir -p %s%s", LOG_ROOT, node_name)))
    print(os.execute(string.format("mkdir -p %sgata/s%d", LOG_ROOT, server_id)))
    skynet.timeout(100, log_utils.flush_loop)
end

local lua_handles_utils = require('msg_utils.lua_handles_utils')
lua_handles_utils.add_send_handle("ls_x_log", log_utils.ls_x_log)
lua_handles_utils.add_call_handle("lc_x_flush_log", log_utils.lc_x_flush_log)

return log_utils