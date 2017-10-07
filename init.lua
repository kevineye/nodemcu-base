local MODULE = 'init'

local app = require 'app'
local log = require 'log'
local w = require 'wifi-connect'

w.connect(function()
    log.log(9, MODULE, 'waiting to initialize...')
    tmr.create():alarm(3000, tmr.ALARM_SINGLE, function()
        if file.open("init.lua") == nil then
            log.log(1, MODULE, 'aborting startup; init.lua deleted or renamed')
        else
            file.close("init.lua")
            app.run()
        end
    end)
end)
