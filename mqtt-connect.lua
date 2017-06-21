local MODULE = 'mqtt'
local log = require 'log'

local m = {}
m.TIMER             = 3
m.STATUS_INTERVAL   = 5 * 60000
m.clientid          = config.get('mqtt_clientid')
m.user              = config.get('mqtt_user')
m.password          = config.get('mqtt_password')
m.prefix            = config.get('mqtt_prefix')
m.host              = config.get('mqtt_host')
m.port              = config.get('mqtt_port')

if ready ~= nil then ready = ready + 1 end

m.client = mqtt.Client(m.clientid, 60, m.user, m.password)
m.client:lwt(m.prefix .. "/status", '{"status":"offline"}', 0, 1)

function m.send_status()
    local msg = '{"status":"online","ip":"' .. wifi.sta.getip() .. '","heap":' .. node.heap() .. ',"minutesOnline":' .. math.floor(tmr.time() / 60) .. '}'
    log.log(7, MODULE, "sending " .. m.prefix .. "/status " .. msg)
    m.client:publish(m.prefix .. "/status", msg, 0, 1)
end

m.client:on("connect", function()
    log.log(5, MODULE, 'connected to ' .. m.host .. ':' .. m.port)
    if ready ~= nil then ready = ready - 1 end
    m.client:subscribe(m.prefix .. "/ping", 0)
    m.client:subscribe(m.prefix .. "/config", 0)
    m.send_status()
end)

m.client:on("offline", function()
    log.log(1, MODULE, 'disconnected')
end)

m.client:on("message", function(client, t, pl)
    if pl == nil then pl = "" end
    log.log(7, MODULE, "received " .. t .. ": " .. pl)
    if (t == m.prefix .. "/ping") then
        m.send_status()
    elseif config ~= nil and t == m.prefix .. "/config" then
        if (pl == "ping") then
            local msg = cjson.encode(config.get())
            log.log(7, MODULE, "sending " .. m.prefix .. "/config/json: " .. msg)
            m.client:publish(m.prefix .. "/config/json", msg, 0, 0)
        elseif (pl == "restart") then
            node.restart()
        else
            config.set_string(pl)
        end
    end
end)

if m.STATUS_INTERVAL > 0 then
    tmr.alarm(m.TIMER, m.STATUS_INTERVAL, tmr.ALARM_AUTO, m.send_status)
end

log.log(9, MODULE, 'connecting to ' .. m.host .. ':' .. m.port)
m.client:connect(m.host, m.port, 0, 1)

return m
