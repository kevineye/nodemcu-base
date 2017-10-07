local MODULE = 'config'
local log = require 'log'

local config = {}
config.data = {}
config.filename = file.exists('config.json') and 'config.json' or 'config.default.json'

if ready ~= nil then ready = ready + 1 end

function config.load()
    log.log(7, MODULE, 'loading config from ' .. config.filename)
    file.open(config.filename, "r")
    config.data = sjson.decode(file.read())
    file.close()
    if ready ~= nil then ready = ready - 1 end
end

function config.set_string(s)
    local key, value = string.match(s, "([^=]+)=(.*)")
    if (key) then
        config.set(key, value)
    end
end

function config.set(key, value)
    config.data[key] = value
    log.log(4, MODULE, "updating config " .. key .. " = " .. value)
    config.save()
end

function config.save()
    file.remove(config.filename)
    file.open(config.filename, "w")
    file.write(sjson.encode(config.data))
    file.close()
end

config.load()

return config
