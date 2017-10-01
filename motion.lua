local MODULE = 'motion'
local m = require 'mqtt-connect'
local log = require 'log'

motion = {}

motion.RELAY_PIN            = 5
motion.MOTION_PIN           = 6

motion.moving               = false
motion.relay                = false

motion.TIMER                = 6
motion.delay_set            = false

gpio.mode(motion.MOTION_PIN, gpio.INT, gpio.FLOAT)
gpio.mode(motion.RELAY_PIN, gpio.OUTPUT)

function saw_motion()
    motion.moving = gpio.read(motion.MOTION_PIN) == gpio.HIGH
    log.log(7, MODULE, "things are " .. (motion.moving and "moving" or "still"))
    local msg = '{"motion":' .. (motion.moving and "true" or "false") .. '}'
    m.client:publish(m.prefix .. "/motion", msg, 0, 0)
    local delay = config.get('switch_delay')
    local light_t = config.get('light_threshold')
    if (delay >= 0 and sensors._avg_light < light_t) or motion.delay_set then
        if motion.moving then
            switch_relay(true)
        else
            switch_delay_off(delay)
        end
    end
end

gpio.trig(motion.MOTION_PIN, 'both', saw_motion)

function switch_relay(state)
    motion.relay = state
    log.log(7, MODULE, "switching " .. (motion.relay and "on" or "off"))
    gpio.write(motion.RELAY_PIN, (state and gpio.HIGH or gpio.LOW))
    local msg = '{"state":"' .. (state and "ON" or "OFF") .. '"}'
    m.client:publish(m.prefix .. "/switch", msg, 0, 1)
    switch_delay_clear()
end

function switch_delay_clear()
    if motion.delay_set then
        log.log(7, MODULE, "canceing delayed switch off")
        tmr.stop(motion.TIMER)
        motion.delay_set = false
    end
end

function switch_delay_off(delay)
    switch_delay_clear()
    log.log(7, MODULE, "switching off in " .. delay .. " seconds")
    tmr.alarm(motion.TIMER, delay * 1000, tmr.ALARM_AUTO, function()
        switch_relay(false)
    end)
end

m.onMessage(function(client, t, pl)
    if pl == nil then pl = "" end
    log.log(7, MODULE, "got " .. pl .. " " .. t)
    if (t == m.prefix .. "/switch/set") then
        motion.relay = string.upper(pl) == "ON"
        switch_relay(motion.relay);
    end
    if (t == m.prefix .. "/switch/toggle") then
        motion.relay = string.upper(pl) == "ON"
        switch_relay(motion.relay);
    end
end)

m.onConnect(function()
    m.client:subscribe(m.prefix .. "/switch/set", 0)
end)

return motion
