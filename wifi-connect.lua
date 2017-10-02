local MODULE = 'wifi'
local log = require 'log'

local w = {}
w.TIMER     = 1
w.ssid      = config.get('wifi_ssid')
w.password  = config.get('wifi_password')

w.connect = function(cb)
    log.log(5, MODULE, 'connecting to ' .. w.ssid .. '...')
    if ready ~= nil then ready = ready + 1 end
    wifi.setmode(wifi.STATION)
    local station = {}
    station.ssid = w.ssid
    station.pwd = w.password
    wifi.sta.config(station)
    tmr.alarm(w.TIMER, 1000, tmr.ALARM_AUTO, function()
        if wifi.sta.getip() == nil then
            log.log(9, MODULE, 'waiting for IP address...')
        else
            tmr.stop(w.TIMER)
            log.log(5, MODULE, 'wifi connection established')
            log.log(5, MODULE, 'IP address is ' .. wifi.sta.getip())
            if cb ~= nil then cb() end
            if ready ~= nil then ready = ready - 1 end
        end
    end)
end

return w
