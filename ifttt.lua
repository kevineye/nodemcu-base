local MODULE = 'ifttt'
local log = require 'log'
local config = require 'config'

local ifttt = {}
ifttt.host  = 'maker.ifttt.com'
ifttt.port  = 80
ifttt.key   = config.data['ifttt_key']
ifttt.conn  = nil

ifttt.trigger = function(event, value1, value2, value3)
    log.log(5, MODULE, 'triggering "' .. event .. '"')

    ifttt.conn = net.createConnection(net.TCP, 0)
    local conn = ifttt.conn

    log.log(7, MODULE, "POSTing to http://" .. ifttt.host .. ":" .. ifttt.port .. "/trigger/" .. event .. "/with/key/" .. ifttt.key)
    conn:connect(ifttt.port, ifttt.host)

    conn:on("connection", function(conn, _)
        log.log(9, MODULE, "connected")

        local d = {}
        if value1 then d.value1 = value1 end
        if value2 then d.value2 = value2 end
        if value3 then d.value3 = value3 end
        local body = sjson.encode(d)

        conn:send("POST /trigger/" .. event .. "/with/key/" .. ifttt.key
            .. " HTTP/1.1\r\n"
            .. "Host: " .. ifttt.host .. "\r\n"
            .. "Connection: close\r\n"
            .. "Content-Type: application/json\r\n"
            .. "Content-Length: " .. string.len(body) .. "\r\n"
            .. "Accept: */*\r\n"
            .. "User-Agent: esp8266 Lua\r\n"
            .. "\r\n"
            .. body
        )
    end)

end

return ifttt
