local M = {}

local CST_OFFSET = 8 * 60 * 60
local DAY_SECOND = 24 * 60 * 60

function myerror(format, ...)
    error(string.format('\n\n===> '..format..'\n', ...))
end

function get_timestamp_from_string(datetime_string)
    local pattern = "(%d%d%d%d)-(%d%d)-(%d%d) (%d%d):(%d%d):(%d%d)"
    local results = {datetime_string:match(pattern)}
    if #results == 0 then
        myerror('time format error: "%s", correct format: "2018-12-12 12:12:12"', datetime_string)
    end
    local year, month, day, hour, min, sec = table.unpack(results)
    local ts = os.time({year = year, month = month, day = day, hour = hour, min = min, sec = sec})
    if (ts + CST_OFFSET) % DAY_SECOND ~= 0 then
        myerror('open_time invalid: "%s", it is should be "00:00"', datetime_string)
    end
    return ts
end

function check_for_errors(data)
    local all_activity_list = data.all_activity_list
    data.all_activity_list = nil
    local rk, rv = next(data)
    for k, v in pairs(data) do
        if rk ~= k then
            if not (rv.close_ts < v.open_ts or v.close_ts < rv.open_ts) then
                myerror('activity time does not allow overlap: id: %d, %d', k, rk)
            end
        end
    end
    data.all_activity_list = all_activity_list
    return data
end

function check_for_record(record)
    if record.welfare_stuff == record.luxury_stuff then
        myerror('duplicate exchange_stuff_id, id = %d)', record.id)
    end
    local activity_dict = {}
    for i, activity_id in ipairs(record.activity_list) do
        if activity_dict[activity_id] then
            myerror("duplicate activitiy_id(%d), id = %d", activity_id, record.id)
        else
            activity_dict[activity_id] = true
        end
    end
    return record
end

function M:convert(data)
    local ret = {}
    ret.all_activity_list = {}
    for k, v in pairs(data) do
        local open_ts = get_timestamp_from_string(v.open_time)
        local duration = v.activity_duration * DAY_SECOND
        local close_ts = open_ts + duration * #v.activity_list - 1
        for index, activity_id in ipairs(v.activity_list) do
            local activity_obj = {group_id = k, activity_id = activity_id}
            activity_obj.start_ts = open_ts + duration * (index - 1)
            activity_obj.stop_ts = activity_obj.start_ts + duration - 1
            activity_obj.end_ts = close_ts
            activity_obj.close_ts = close_ts + DAY_SECOND * v.exchange_day
            activity_obj.welfare_stuff = v.welfare_stuff
            activity_obj.luxury_stuff = v.luxury_stuff
            table.insert(ret.all_activity_list, activity_obj)
        end
        v.open_ts = open_ts
        v.close_ts = close_ts + DAY_SECOND * v.exchange_day
        ret[k] = check_for_record(v)
    end
    return check_for_errors(ret)
end

return M