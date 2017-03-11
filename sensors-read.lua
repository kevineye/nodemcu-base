local MODULE = 'sensors'
local m = require 'mqtt-connect'
local log = require 'log'

if sensors._sample_count < sensors.AVG_PERIOD then
    sensors._sample_count = sensors._sample_count + 1
end

if sensors._sample_count == 1 then
    if bme280 ~= nil and sensors.BME280_PIN_SCL and sensors.BME280_PIN_SDA then
        local res = bme280.init(sensors.BME280_PIN_SDA, sensors.BME280_PIN_SCL)
        log.log(5, MODULE, "initialized BME280 sensor: "..res)
    end
    if dht ~= nil and sensors.DHT_PIN then
        log.log(5, MODULE, "using DHT sensor")
    end
    if adc ~= nil and sensors.LIGHT_PIN then
        log.log(5, MODULE, "using light sensor")
    end
end

local status
local temp = 0
local humi = 0
local light = 0

if bme280 ~= nil and sensors.BME280_PIN_SCL and sensors.BME280_PIN_SDA then
    temp = bme280.temp()
    if temp ~= nil then
        temp = temp * 9 / 500 + 32;
        temp = temp + sensors.temp_offset;
    else
        temp = sensors._avg_temp
    end
end

if dht ~= nil and sensors.DHT_PIN then
    status, temp, humi = dht.read(sensors.DHT_PIN)
    if status ~= dht.OK then
        log.log(4, MODULE, 'error reading from DHT')
        temp = sensors._avg_temp
        humi = sensors._avg_humi
    else
        temp = temp * 9 / 5 + 32;
        temp = temp + sensors.temp_offset;
    end
end

if adc ~= nil and sensors.LIGHT_PIN then
    light = adc.read(sensors.LIGHT_PIN) / 3.5
end

sensors._avg_temp = sensors._avg_temp + (temp  - sensors._avg_temp) / sensors._sample_count
sensors._avg_humi = sensors._avg_humi + (humi  - sensors._avg_humi) / sensors._sample_count
sensors._avg_light = sensors._avg_light + (light - sensors._avg_light) / sensors._sample_count

log.log(9, MODULE, "raw readings temperature="..temp.." humidity="..humi.." light="..light)

if sensors._countdown_to_report == 0 then
    sensors._countdown_to_report = sensors.REPORT_PERIOD
    local msg = {}
    if (bme280 ~= nil and sensors.BME280_PIN_SCL and sensors.BME280_PIN_SDA) or (dht ~= nil and sensors.DHT_PIN) then
        table.insert(msg, string.format('"temperature":%0.1f', sensors._avg_temp))
    end
    if dht ~= nil and sensors.DHT_PIN then
        table.insert(msg, string.format('"humidity":%d', sensors._avg_humi))
    end
    if adc ~= nil and sensors.LIGHT_PIN then
        table.insert(msg, string.format('"light":%d', sensors._avg_light))
    end
    if sensors.zone ~= nil then
        table.insert(msg, '"zone":"' .. sensors.zone .. '"')
    end
    local s = '{' .. table.concat(msg, ',') .. '}'
    log.log(7, MODULE, 'logging ' .. s)
    m.client:publish(m.prefix .. "/sensors", s, 0, 0)
end

sensors._countdown_to_report = sensors._countdown_to_report - 1
