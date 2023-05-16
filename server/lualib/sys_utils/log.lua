local skynet = require("skynet")
local Date = require "sys_utils.date"

local addr = skynet.address(skynet.self())
local log = DECLARE_MODULE("sys_utils.log")
DECLARE_FINISH(log)

local PRINT_ALL_LOG = false

log.LevelDef = {
    DEBUG = 0,
    INFO = 1,
    WARN = 5,
    ERROR = 6,
}

local service_tag = string.format("[%s-%x]", SERVICE_NAME, skynet.self())

local bdc_escape = {
    ["\n"] = "\\n",
    ["`"] = " ",
}

function log.format_bdc(data)
    local list = {}
    for i=1, data.length do
        local value = data.data[i]
        if value == nil then
            table.insert(list, "")
        elseif type(value) == 'table' then
            table.insert(list, json.encode(value))
        else
            value = string.gsub(tostring(value), "[`\n]", bdc_escape)
            table.insert(list, value)
        end
    end
    return table.concat(list, "`")
end

function log.__send_log(log_name, tag, data, ...)
    if log_name == 'bdclog' then
        data = log.format_bdc(data)
    end
    skynet.send(".gamelog", "lua", "ls_x_log", service_tag, log_name, tag, data, ...)
end

function log.__print_log(tag, text)
    print(string.format("[%s]%s", tag, text))
end

function log._send_log(log_name, tag, ...)
    log.__send_log(log_name, tag, ...)
    if PRINT_ALL_LOG then
        local text
        local json = require("json")
        local args = table.pack(...)
        if args.n == 1 then
            if type(args[1]) == "table" and next(args[1]) then
                text = json.encode(args[1])
            else
                text = tostring(args[1])
            end
        else
            args.n = nil
            text = json.encode(args)
        end
        log.__print_log(string.format("%s-%s", log_name, tag), text)
    end
end

function log.new(name)
    local self = setmetatable({}, log)
    self.name = name
    self.level = log.LevelDef.DEBUG

    self.trace_handle = self:get_handle("trace")
    self.error_handle = self:get_handle("error")
    return self
end

function log.flush()
    skynet.call(".gamelog", "lua", "lc_x_flush_log")
end

function log.__index(t, k)
    local func = log[k]
    if not func then
        func = function(self, tag, ...)
            log._send_log(k, tag, ...)
        end
        t[k] = func
    end
    return func
end

function log:get_handle(name)
    -- 返回可直接调用的函数， 不需要用冒号调用
    return function(...) log[name](self, ...) end
end

function log:bdclog(tag, data)
    if data.length ~= #(data.data) then
        self:error("bdclog length error:" .. tag)
    end
    log._send_log('bdclog', tag, data)
end

function log:debug(...)
    log.__print_log("debug", ...)
end

function log:debugf(format, ...)
    log.__print_log("debug", string.format(format, ...))
end

function log:log(...)
    log._send_log("info", "info", ...)
end

function log:logf(format, ...)
    log._send_log("info", "info", string.format(format, ...))
end

function log:info(...)
    log._send_log("info", "info", ...)
end

function log:infof(format, ...)
    log._send_log("info", "info", string.format(format, ...))
end

function log:warn(...)
    log.__print_log('warn', ...)
end

function log:warnf(format, ...)
    log.__print_log('warn', string.format(format, ...))
end

function log:error(msg)
    log.__print_log('error', msg)
end

function log:errorf(format, ...)
    log.__print_log('error', string.format(format, ...))
end

function log:trace(msg, ...)
    msg = debug.traceback(msg, 2)
    log.__print_log('error', msg, ...)
end

function log:tracef(format, ...)
    msg = debug.traceback(string.format(format, ...), 2)
    log.__print_log('error', string.format(format, ...))
end

return log