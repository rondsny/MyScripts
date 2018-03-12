local bDebug = true

-- release
traceXXX = function () end

-- debug
traceXXX = not bDebug and function () end or
    function (...)
        local tbInfo   = debug.getinfo(2)
        local funcName = tbInfo.name
        local dLine    = tbInfo.currentline
        local source   = tbInfo.source
        local mod      = string.match(source, "/([_%w]+).lua$")
        if not mod then mod = "" end
        local preMsg = string.format("[XXX] %s:%s %s", mod, dLine, funcName)
        
        print(preMsg, ...)
    end

-- e.g.
-- [XXX] myMod:6 test ...
