local MODULE = 'telnet'
local log = require 'log'

-- adapted from https://github.com/nodemcu/nodemcu-firmware/blob/master/lua_examples/telnet.lua

local telnet = {}
telnet.port = 2323
telnet.server = net.createServer(net.TCP, 180)

log.info(MODULE, 'listening on ' .. wifi.sta.getip() .. ':' .. telnet.port)
telnet.server:listen(telnet.port, function(socket)
    log.info(MODULE, 'client connected')
    local fifo = {}
    local fifo_drained = true

    local function sender(c)
        if #fifo > 0 then
            c:send(table.remove(fifo, 1))
        else
            fifo_drained = true
        end
    end

    local function s_output(str)
        table.insert(fifo, str)
        if socket ~= nil and fifo_drained then
            fifo_drained = false
            sender(socket)
        end
    end

    node.output(s_output, 0)   -- re-direct output to function s_ouput.

    socket:on("receive", function(c, l)
        node.input(l)           -- works like pcall(loadstring(l)) but support multiple separate line
    end)
    socket:on("disconnection", function(c)
        node.output(nil)        -- un-regist the redirect output function, output goes to serial
        log.info(MODULE, 'client disconnected')
    end)
    socket:on("sent", sender)

    log.info(MODULE, 'welcome to NodeMCU')
end)

return telnet
