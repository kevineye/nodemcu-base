local MODULE = 'wifi'
local log = require 'log'
local config = require 'config'
local timer = tmr.create()

local w = {}
w.ssid      = config.data['wifi_ssid']
w.password  = config.data['wifi_password']

w.connect = function(cb)
    log.log(5, MODULE, 'connecting to ' .. w.ssid .. '...')
    if ready ~= nil then ready = ready + 1 end
    wifi.setmode(wifi.STATION)
    local station = {}
    station.ssid = w.ssid
    station.pwd = w.password
    wifi.sta.config(station)
    timer:alarm(1000, tmr.ALARM_AUTO, function()
        if wifi.sta.getip() == nil then
            log.log(9, MODULE, 'waiting for IP address...')
        else
            timer:stop()
            log.log(5, MODULE, 'wifi connection established')
            log.log(5, MODULE, 'IP address is ' .. wifi.sta.getip())
            if cb ~= nil then cb() end
            if ready ~= nil then ready = ready - 1 end
        end
    end)
end

return w
