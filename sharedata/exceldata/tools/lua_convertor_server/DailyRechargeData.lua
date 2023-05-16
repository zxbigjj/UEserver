local M = {}

local WEEK_SEC = 7 * 24 * 60 * 60

function myerror(format, ...)
    error(string.format('\n\n===> '..format..'\n', ...))
end

function get_ts_from_str(date_str)
    local pattern = "(%d%d%d%d)-(%d%d)-(%d%d)"
    local results = {date_str:match(pattern)}
    if #results == 0 then
        myerror('time format error: "%s", correct format: "2018-12-12"', date_str)
    end
    local year, month, day = table.unpack(results)
    return os.time({year = year, month = month, day = day, hour = 0, min = 0, sec = 0})
end

function M:convert(datas)
    for id, data in pairs(datas) do
        if #data.recharge_list ~= 7 then
            myerror("length of recharge_list should be 7, length: %d, activity_id: %d", #data.recharge_list, id)
        end
        if data.recharge_days < 1 or data.recharge_days > #data.recharge_list then
            myerror("recharge_days should be >= 1 and <= 7, value: %d, activity_id: %d", data.recharge_days, id)
        end
        local reward_dict = {[data.luxury_reward] = true}
        for _, reward_id in ipairs(data.reward_list) do
            if reward_dict[reward_id] then
                myerror("duplicate reward_id in reward_list or luxury_reward: reward_id: %d, activity_id: %d", reward_id, id)
            else
                reward_dict[reward_id] = true
            end
        end
        data.start_ts = get_ts_from_str(data.activity_time_list[1])
        data.stop_ts = get_ts_from_str(data.activity_time_list[2])
        if data.stop_ts - data.start_ts ~= WEEK_SEC then
            myerror("duration of activity should be 7 days, duration: %.2f days, activity_id: %d", (data.stop_ts - data.start_ts) / WEEK_SEC * 7, id)
        end
    end
    local rid, rdata = next(datas)
    for id, data in pairs(datas) do
        if id ~= rid then
            if not (data.stop_ts < rdata.start_ts or rdata.stop_ts < data.start_ts) then
                myerror("activity time does not allow overlap, activity_id: %d, %d", id, rid)
            end
        end
    end
    return datas
end

return M