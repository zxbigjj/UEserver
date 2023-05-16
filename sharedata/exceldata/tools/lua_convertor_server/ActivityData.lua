local M = {}

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
    return os.time({year = year, month = month, day = day, hour = hour, min = min, sec = sec})
end

function check_for_errors(table)
    local all_group_dict = {}
    for id, data in pairs(table) do
        local group_dict = {}
        for _, group_id in ipairs(data.activity_group_list) do
            if group_dict[group_id] then
                myerror("the same activity_group_id is not allowed in the same time-limited activity, id: %d", id)
            else
                group_dict[group_id] = true
            end
            if all_group_dict[group_id] then
                local exlid = all_group_dict[group_id]
                local exldata = table[exlid]
                if not (data.activity_end_timestamp < exldata.activity_start_timestamp or exldata.activity_end_timestamp < data.activity_start_timestamp) then
                    myerror("the same activity_group_id is not allowed in time-limited activities with overlapping time, id: %d, %d", id, exlid)
                end
            else
                all_group_dict[group_id] = id
            end
        end
    end
    return table
end

function M:convert(data)
    local ret = {}
    for k, v in pairs(data) do
        v.activity_start_timestamp = get_timestamp_from_string(v.activity_start_time)
        v.activity_stop_timestamp = get_timestamp_from_string(v.activity_stop_time)
        v.activity_end_timestamp = get_timestamp_from_string(v.activity_end_time)
        ret[k] = v
    end
    return check_for_errors(ret)
end

return M