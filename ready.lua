ready = 1
local timer = tmr.create()

gpio.mode(PIN_LED, gpio.OUTPUT)
timer:alarm(3000, tmr.ALARM_AUTO, function()
    if (ready <= 0) then
        timer:unregister()
    else
        gpio.serout(PIN_LED, gpio.LOW, { 50000, 50000 }, 3, 1)
    end
end)

return ready
