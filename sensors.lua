sensors = {}
sensors.SAMPLE_FREQ         = 20000  -- how often to sample sensors (ms)
sensors.REPORT_PERIOD       = 3      -- report every N samples
sensors.AVG_PERIOD          = 3      -- moving average of N samples

sensors.TIMER               = 4

sensors.BME280_PIN_SCL      = 1
sensors.BME280_PIN_SDA      = 2
sensors.DHT_PIN             = nil
sensors.LIGHT_PIN           = nil
sensors.LIGHT_REVERSE       = true

sensors.zone                = config.get('zone')
sensors.temp_offset         = config.get('temp_offset')

sensors._countdown_to_report    = 0      -- number of samples until next report
sensors._sample_count           = 0      -- how many sampless in the average
sensors._avg_temp               = 0      -- current average temp
sensors._avg_humi               = 0      -- current average humidity
sensors._avg_light              = 0      -- current average light level

tmr.alarm(sensors.TIMER, sensors.SAMPLE_FREQ, tmr.ALARM_AUTO, function() dofile 'sensors-read.lua' end)

return sensors
