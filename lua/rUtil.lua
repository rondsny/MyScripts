-- @Author: weiyanguang
-- @Date: 2018-05-15 11:39:18
-- @Last Modified by: weiyanguang
-- @Last Modified time: 2018-05-15 17:46:43
-- @Doc: lua base function

-- unixtime/0           -- 时间戳
-- longunixtime/0       -- 长时间戳
-- iosWeekNum/1         -- ios周日历
-- getCurWeekNum/0      -- 今天是第几周
-- isToday/1
-- isSameDay/2
-- isSameMonth/2
-- isSameWeek/2
-- bool2Int/1           -- 1/0
-- between/3

-- @return 时间戳(秒)
function unixtime()
    return os.time()
end

-- 可用于逻辑(用于精细时间差计算)
-- @return 长时间戳(毫秒)
local le_dStart = le_dStart or nil
local le_dClock = le_dClock or nil
function longunixtime()
    if not le_dStart then
        le_dStart = unixtime()
        le_dClock = os.clock()
    end

    local dInterval = os.clock() - le_dClock
    return (le_dStart +  dInterval) * 1000
end

local function getYearBeginDayOfWeek(ts)
    local yearBegin = os.time{year=os.date("*t",ts).year,month=1,day=1}
    local yearBeginDayOfWeek = tonumber(os.date("%w",yearBegin))
    -- sunday correct from 0 -> 7
    if(yearBeginDayOfWeek == 0) then yearBeginDayOfWeek = 7 end
    return yearBeginDayOfWeek
end

local function getDayAdd(ts)
  local yearBeginDayOfWeek = getYearBeginDayOfWeek(ts)
  local dayAdd = 0
  if(yearBeginDayOfWeek < 5 ) then
    -- first day is week 1
    dayAdd = (yearBeginDayOfWeek - 2)
  else
    -- first day is week 52 or 53
    dayAdd = (yearBeginDayOfWeek - 9)
  end
  return dayAdd
end

-- 获取tm是当前年份的第几周
-- 参考维基解释 https://en.wikipedia.org/wiki/ISO_week_date
-- 每周从星期一开始
-- 每年的第一个星期四所在周为第一周
-- @return year, weekNum
function iosWeekNum(ts)
    local tbTime    = os.date("*t",ts)
    local year      = tbTime.year
    local dayOfYear = os.date("%j",ts)
    local dayAdd    = getDayAdd(ts)
    local dayOfYearCorrected = dayOfYear + dayAdd
    if(dayOfYearCorrected < 0) then
        -- week of last year - decide if 52 or 53
        year = tbTime.year - 1
        local lastYearBegin = os.time{year=year,month= 1,day= 1}
        local lastYearEnd   = os.time{year=year,month=12,day=31}
        dayAdd = getDayAdd(lastYearBegin)
        dayOfYear = dayOfYear + os.date("%j",lastYearEnd)
        dayOfYearCorrected = dayOfYear + dayAdd
    end
    local weekNum = math.floor((dayOfYearCorrected) / 7) + 1
    if( (dayOfYearCorrected > 0) and weekNum == 53) then
        -- check if it is not considered as part of week 1 of next year
        year = tbTime.year + 1
        local nextYearBegin = os.time{year=year, month=1,day=1}
        local yearBeginDayOfWeek = getYearBeginDayOfWeek(nextYearBegin)
        if(yearBeginDayOfWeek < 5 ) then
            weekNum = 1
        end
    end
    return year, weekNum
end

function getCurWeekNum()
    local ts = unixtime()
    local _year, num = iosWeekNum(ts)
    return num
end

-- @param st 时间戳
function isToday(ts)
    assert(type(ts) == "number")

    local tbNow  = os.date("*t")
    local dStart = os.time({
            year   = tbNow.year,
            month  = tbNow.month,
            day    = tbNow.day,
            hour   = 0,
            minute = 0,
            second = 0
        })
    if dStart <= ts and ts < dStart + 60*60*24 then
        return true
    end
    return false
end

function isSameDay(ts1, ts2)
    assert(type(ts1) == "number")
    assert(type(ts2) == "number")

    local tb1 = os.date("*t", ts1)
    local tb2 = os.date("*t", ts2)
    if  tb1.year  == tb2.year
    and tb1.month == tb2.month
    and tb1.day   == tb2.day then
        return true
    end
    return false
end

function isSameMonth(ts1, ts2)
    assert(type(ts1) == "number")
    assert(type(ts2) == "number")

    local tb1 = os.date("*t", ts1)
    local tb2 = os.date("*t", ts2)
    if  tb1.year  == tb2.year
    and tb1.month == tb2.month then
        return true
    end
    return false
end

function isSameWeek(ts1, ts2)
    assert(type(ts1) == "number")
    assert(type(ts2) == "number")

    local year1, num1 = iosWeekNum(ts1)
    local year2, num2 = iosWeekNum(ts2)
    if  year1 == year2
    and  num1 == num2  then
        return true
    end
    return false
end

function bool2Int(b)
    assert(type(b) == "boolean")

    return b==true and 1 or 0
end

function int2Bool(d)
    assert(type(d) == "number")

    return d==1 and true or false
end

function between(dVal, dMin, dMax)
    assert(type(dVal) == "number")
    assert(type(dMin) == "number")
    assert(type(dMax) == "number")

    if dVal < dMin then
        return dMin
    elseif dVal > dMax then
        return dMax
    else
        return dVal
    end
end



------------------------------------------------------------------------------
-- -- test
-- function test()
--     print(os.clock())
--     print(os.date("*t"))
--     print(isToday(unixtime()))
--     print(isToday(123))
--     print(isSameDay(123, 1))
--     print(isSameDay(123, unixtime()))
--     print(os.clock())
--     print(longunixtime())
--     print(bool2Int(true), bool2Int(false))
--     print(int2Bool(1), int2Bool(0), int2Bool(2))
--     print(between(3, 1, 4))
--     print(between(0, 1, 4))
--     print(between(5, 1, 4))
--     print(iosWeekNum(unixtime()))

--     print(longunixtime())
-- end

-- test()
