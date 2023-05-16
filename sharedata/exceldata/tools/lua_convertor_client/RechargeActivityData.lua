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
        v.activity_start_timestamp = v.activity_start_time and get_timestamp_from_string(v.activity_start_time)
        v.activity_end_timestamp = v.activity_end_time and get_timestamp_from_string(v.activity_end_time)
        v.activity_close_timestamp = v.activity_close_time and get_timestamp_from_string(v.activity_close_time)
        ret[k] = v
        if v.activity_type == 4 then
            ret.luxury_check_activity = v.id
        elseif v.activity_type == 5 then
            ret.accum_recharge_activity = v.id
        end
    end
    return ret
end

return M