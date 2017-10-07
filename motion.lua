local MODULE = 'motion'
local m = require 'mqtt-connect'
local log = require 'log'
local config = require 'config'
local sensors = require 'sensors-simple-light';

local motion = {}

motion.RELAY_PIN            = 5
motion.MOTION_PIN           = 6

motion.moving               = false
motion.relay                = false
motion.timer                = nil

gpio.mode(motion.MOTION_PIN, gpio.INT, gpio.FLOAT)
gpio.mode(motion.RELAY_PIN, gpio.OUTPUT)

function motion.onMove()
    motion.moving = gpio.read(motion.MOTION_PIN) == gpio.HIGH
    log.log(7, MODULE, "things are " .. (motion.moving and "moving" or "still"))
    local msg = '{"motion":' .. (motion.moving and "true" or "false") .. '}'
    m.client:publish(m.prefix .. "/motion", msg, 0, 0)
    local delay = config.data['switch_delay']
    local light_t = config.data['light_threshold']
    if delay >= 0 or motion.delay_set then
        if motion.moving and sensors.read_light() < light_t then
            motion.switch(true)
        else
            motion.delay_off(delay)
        end
    end
end

gpio.trig(motion.MOTION_PIN, 'both', motion.onMove)

function motion.switch(state)
    motion.relay = state
    log.log(7, MODULE, "switching " .. (motion.relay and "on" or "off"))
    gpio.write(motion.RELAY_PIN, (state and gpio.HIGH or gpio.LOW))
    local msg = '{"state":"' .. (state and "ON" or "OFF") .. '"}'
    m.client:publish(m.prefix .. "/switch", msg, 0, 1)
    motion.delay_clear()
end

function motion.delay_clear()
    if motion.timer ~= nil then
        log.log(7, MODULE, "canceing delayed switch off")
        motion.timer:stop()
        motion.timer:unregister()
        motion.timer = nil
    end
end

function motion.delay_off(delay)
    motion.delay_clear()
    log.log(7, MODULE, "switching off in " .. delay .. " seconds")
    motion.timer = tmr.create()
    motion.timer:alarm(delay * 1000, tmr.ALARM_SINGLE, function()
        motion.switch(false)
    end)
end

m.onMessage(function(client, t, pl)
    if pl == nil then pl = "" end
    log.log(7, MODULE, "got " .. pl .. " " .. t)
    if (t == m.prefix .. "/switch/set") then
        motion.relay = string.upper(pl) == "ON"
        motion.switch(motion.relay);
    end
    if (t == m.prefix .. "/switch/toggle") then
        motion.relay = string.upper(pl) == "ON"
        motion.switch(motion.relay);
    end
end)

m.onConnect(function()
    m.client:subscribe(m.prefix .. "/switch/set", 0)
end)

return motion
