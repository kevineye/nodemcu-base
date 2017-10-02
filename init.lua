local MODULE = 'init'

init = {}
init.STARTUP_DELAY  = 3000

local app = require 'app'
local log = require 'log'
local w = require 'wifi-connect'

w.connect(function()
    log.log(9, MODULE, 'waiting to initialize...')
    tmr.create():alarm(init.STARTUP_DELAY, tmr.ALARM_SINGLE, function()
        if file.open("init.lua") == nil then
            log.log(1, MODULE, 'aborting startup; init.lua deleted or renamed')
        else
            file.close("init.lua")
            app.run()
        end
    end)
end)
