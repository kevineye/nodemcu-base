local MODULE = 'sensors'
local m = require 'mqtt-connect'
local log = require 'log'

motion = {}

motion.RELAY_PIN            = 1
motion.MOTION_PIN           = 2

motion.moving               = false
motion.relay                = false

function saw_motion()
    motion.moving = gpio.read(motion.MOTION_PIN) == gpio.HIGH
    log.log(7, MODULE, "things are " .. (motion.moving and "moving" or "still"))
    local msg = '{"motion":' .. (motion.moving and "true" or "false") .. '}'
    m.client:publish(m.prefix .. "/motion", msg, 0, 0)
end

gpio.mode(motion.MOTION_PIN, gpio.INT, gpio.FLOAT)
gpio.trig(motion.MOTION_PIN, 'both', saw_motion)


gpio.mode(motion.RELAY_PIN, gpio.OUTPUT)

function switch_relay(state)
    motion.relay = state
    log.log(7, MODULE, "switching " .. (motion.relay and "on" or "off"))
    gpio.write(motion.RELAY_PIN, (state and gpio.HIGH or gpio.LOW))
    local msg = '{"state":"' .. (state and "ON" or "OFF") .. '"}'
    m.client:publish(m.prefix .. "/switch", msg, 0, 1)
end

m.client:on("message", function(client, t, pl)
    if pl == nil then pl = "" end
    log.log(7, MODULE, "got " .. pl .. " " .. t)
    if (t == m.prefix .. "/switch/set") then
        motion.relay = string.upper(pl) == "ON"
        switch_relay(motion.relay);
    end
end)

m.client:on("connect", function()
    m.client:subscribe(m.prefix .. "/switch/set", 0)
end)

return motion
