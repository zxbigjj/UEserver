local M = {}

local MIN_SEC = 60
local HOUR_SEC = MIN_SEC * 60

function myerror(format, ...)
    error(string.format('\n\n===> '..format..'\n', ...))
end

-- time_string, eg: "12:30"
function get_second_of_day(time_string)
    local pattern = "(%d%d):(%d%d)"
    local hour, min = time_string:match(pattern)
    if not hour or not min then 
        myerror('time format error: "%s", correct format: "12:30"', time_string) 
    end
    return hour * HOUR_SEC + min * MIN_SEC
end

function check_for_errors(datas)
    for key, data in pairs(datas) do
        if data.lover_exp_ratio < 0 or data.lover_exp_ratio > 1 then
            myerror("ratio range error: '%.2f', valid range: [0, 1]", data.lover_exp_ratio)
        end
    end
    local rkey, rdata = next(datas)
    for key, data in pairs(datas) do
        if key ~= rkey then
            if not (rdata.stop_sec < data.start_sec or data.stop_sec < rdata.start_sec) then
                myerror("activity time overlap, id: %d, %d", key, rkey)
            end
        end
    end
    return datas
end

function M:convert(old_datas)
    local new_datas = {}
    for key, data in pairs(old_datas) do
        data.start_sec = get_second_of_day(data.start_time)
        data.stop_sec = get_second_of_day(data.stop_time)
        new_datas[key] = data
    end
    return check_for_errors(new_datas)
end

return M