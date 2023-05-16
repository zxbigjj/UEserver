local M = {}

function get_timestamp_from_string(datetime_string)
    local pattern = "(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d):(%d%d)"
    local results = {datetime_string:match(pattern)}
    if #results == 0 then
        error(string.format('\n\n=====> 时间格式错误: %s，正确格式: 2018-12-12 12:12:12 <=====\n', datetime_string))
    end
    local year, month, day, hour, min, sec = table.unpack(results)
    return os.time({year = year, month = month, day = day, hour = hour, min = min, sec = sec})
end

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.open_timestamp = get_timestamp_from_string(v.open_time)
        ret[k] = v
    end
    return ret
end

return M