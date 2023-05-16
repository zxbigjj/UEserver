skynet = require "skynet"

local one_day = 24*3600
local one_week = 7 * one_day
local one_hour = 3600

local M = DECLARE_MODULE("sys_utils.date")
DECLARE_RUNNING_ATTR(M, "start_time", skynet.starttime())
DECLARE_RUNNING_ATTR(M, "gm_offset", 0)

function M.set_offset(v)
    M.gm_offset = v
    require("timer").offset_time()
end

function M.now()
    -- 单位百分之一秒
    return math.floor(skynet.now() + M.gm_offset * 100)
end

function M.time_second()
    return math.floor(skynet.time() + M.gm_offset)
end

function M.time_millisecond()
    return math.floor((skynet.time() + M.gm_offset)*1000)
end

function M.time()
    return skynet.time() + M.gm_offset
end

function M.format_time(ts)
    local time = ts or M.time_second()
    -- local ms = skynet.now() % 100
    return os.date("%Y-%m-%d %H:%M:%S", math.floor(time))
end

function M.format_day_time(ts)
    local time = ts or M.time_second()
    return os.date("%Y-%m-%d", math.floor(time))
end

-- 6:00 as begin (2016/1/4 6点 周一)
local base_6 = os.time({year=2016, month=1, day=4, hour=6, min=0, sec=0})

local base_0 = os.time({year=2016, month=1, day=4, hour=0, min=0, sec=0})

local base_challenge = os.time({year=2016, month=1, day=4, hour=20, min=45, sec=0})

function M.get_day6(ts)
    ts = ts or M.time_second()
    return math.floor((ts - base_6) / one_day)
end

-- 今天凌晨12的时间戳
function M.get_residue_seconds_to_tomorrow()
    local toYear=os.date("*t").year
    local toMonth=os.date("*t").month
    local toDay=os.date("*t").day
    local toTime = os.time({year =toYear, month = toMonth, day =toDay, hour =23, min =59, sec = 59})
    --local time=os.time()
    return toTime+1; --为什么+1？因为我们返回的是当日23：59：59的秒数，如果是第二天凌晨的
    --话就需要多加1
end

-- * @description: 通过某一时间点获取时间
-- * @params: @futureDays:0代表的意思是当天,1是明天,@_hour:指的24格式的时间，传入2就是凌晨2点
-- * @return: 时间戳
function M.get_future_time(futureDays, _hour)
    local curTimestamp = os.time()
    local dayTimestamp = 24 * 60 * 60
    local newTime = curTimestamp + dayTimestamp * futureDays
    local newDate = os.date("*t", newTime)
    --这里返回的是你指定的时间点的时间戳
    return os.time({year = newDate.year, month = newDate.month, day = newDate.day, hour = _hour, minute = newDate.minute, second = newDate.second})
end

function M.get_week_num()
    --当前是星期几
    local t = os.time()
    local weekNum = os.date("*t", t).wday - 1
    if weekNum == 0 then
        weekNum = 7
    end
    return weekNum;
end

--返回本周日凌晨时间戳
function M.get_week_last_time()
    --本周
    local weekNum = 7 - M.get_week_num()
    return M.get_future_time(weekNum, 24)
end


--返回本周开始日期
function M.get_week_start_time()
    --本周
    local weekNum = 7 - M.get_week_num()
    local cur_week_start_time = M.get_future_time(weekNum, 24) - one_week
    return M.format_day_time(cur_week_start_time)
end


--返回本周结束日期
function M.get_week_end_time()
    --本周
    local weekNum = 7 - M.get_week_num()
    local cur_week_end_time = M.get_future_time(weekNum, 24)
    return M.format_day_time(cur_week_end_time)
end

function M.get_begin6(ts)
    ts = ts or M.time_second()
    return ts - (ts - base_6) % one_day
end

function M.is_after6(ts)
    ts = ts or M.time_second()
    local hour = tonumber(os.date("%H", math.floor(ts)))
    if hour < 6 then
        return false
    end
    return true
end

function M.get_week_begin6(ts)
    ts = ts or M.time_second()
    return ts - (ts - base_6) % one_week
end

function M.get_week_begin0(ts)
    ts = ts or M.time_second()
    return ts - (ts - base_0) % one_week
end

function M.get_hour_begin(ts)
    ts = ts or M.time_second()
    return ts -ts % 3600
end

function M.get_week_day_begin6(ts, week_day) --week_day [0, 6]
    ts = ts or M.time_second()
    local extra_time = 0
    if week_day == 0 then
        extra_time = (7 - 1) * one_day
    elseif week_day >= 1 and week_day <= 6 then 
        extra_time = (week_day - 1) * one_day
    end
    return ts - (ts - (base_6 + extra_time)) % one_week
end

function M.get_hour_begin6(ts)
    ts = ts or M.time_second()
    return ts - (ts - base_6) % one_hour
end

function M.get_begin0(ts)
    ts = ts or M.time_second()
    return ts - (ts - base_0) % one_day
end

function M.get_begin_challenge(ts)
    ts = ts or M.time_second()
    return ts - (ts - base_challenge) % one_day
end

function M.get_week_day(ts)
    return os.date("%w", ts)
end

function M.get_minute(ts)
    return tonumber(os.date("%M", ts))
end

function M.get_day0(ts)
    ts = ts or M.time_second()
    return math.floor((ts - base_0) / one_day)
end

function M.is_in_same_day0(ts1, ts2)
    if M.get_begin0(ts1)  == M.get_begin0(ts2) then
        return true
    end
    return
end

-- 获取某天某小时的时间
function M.get_day_time(ts, hour)
    ts = ts or M.time_second()
    local date = os.date("*t", ts)
    return os.time({year = date.year, month = date.month, day = date.day, hour = hour})
end

function M.get_hour(ts)
    ts = ts or M.time_second()
    local date = os.date("*t", ts)
    return date.hour
end

return M
