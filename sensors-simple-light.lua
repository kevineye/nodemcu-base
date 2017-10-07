local MODULE = 'sensors'
local m = require 'mqtt-connect'
local log = require 'log'

local sensors = {}
sensors.SAMPLE_FREQ         = 60000  -- how often to sample sensors (ms)
sensors.LIGHT_PIN           = nil
sensors.LIGHT_REVERSE       = true
sensors.light               = 0      -- current average light level

function sensors.read_light()
    sensors.light = adc.read(sensors.LIGHT_PIN) / 10.24
    if sensors.LIGHT_REVERSE then sensors.light = 100 - sensors.light end
    return sensors.light
end

tmr.create():alarm(sensors.SAMPLE_FREQ, tmr.ALARM_AUTO, function()
    sensors.read_light()
    local s = string.format('{"light":%d}', sensors.light)
    log.log(7, MODULE, 'logging ' .. s)
    m.client:publish(m.prefix .. "/sensors", s, 0, 0)
end)

return sensors
