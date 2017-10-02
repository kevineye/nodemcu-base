local MODULE = 'config'
local log = require 'log'

config = {}
config.data = {}
config.filename = file.exists('config.json') and 'config.json' or 'config.default.json'

if ready ~= nil then ready = ready + 1 end

function config.read_json()
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
    config.save_json()
    log.log(4, MODULE, "updated config " .. key .. " = " .. value)
end

function config.get(key)
    if key == nil then
        return config.data
    else
        return config.data[key]
    end
end

function config.save_json()
    file.remove(config.filename)
    file.open(config.filename, "w")
    file.write(sjson.encode(config.data))
    file.close()
end

config.read_json()

return config
