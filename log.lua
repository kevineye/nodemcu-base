local log = {}

log.level   = 8
log.heap    = log.level >= 7

log.log = function(level, module, message)
    if log.level < level then return end
    local s, ts
    if localtime and localtime.initialized then
        ts = localtime.time()
    elseif rtctime then
        ts = rtctime.get()
    end

    if ts then
        local tm = rtctime.epoch2cal(ts)
        s = string.format("%02d:%02d:%02d", tm["hour"], tm["min"], tm["sec"])
    else
        s = ''
    end

    if log.heap then
        s = s .. string.format('%6d', node.heap())
    end

    print(string.format("[%d %s] %s: %s", level, s, module, message))
end

-- enabling these bloats module's RAM footprint by almost 2KB (2.2x)
-- log.trace = function(...) log.log(9, ...) end
-- log.debug = function(...) log.log(7, ...) end
-- log.info  = function(...) log.log(5, ...) end
-- log.warn  = function(...) log.log(4, ...) end
-- log.error = function(...) log.log(3, ...) end
-- log.fatal = function(...) log.log(1, ...) end

return log
