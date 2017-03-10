# NodeMCU Lib

Libraries for NodeMCU IoT devices.

Overall NodeMCU docs:

 * https://nodemcu.readthedocs.io/en/dev/

## Lua firmware setup

#### Build firmware
 
The lua-based NodeMCU firmware must be built and flashed to the ESP8266. Then the code is uploaded to the firmware's filesystem.

### Build NodeMCU firmware

Build the firmware using the [NodeMCU cloud build service](https://nodemcu-build.com/). Select at least the following modules:

  * CJSON
  * file (default)
  * GPIO (default)
  * MQTT
  * net (default)
  * node (default)
  * timer (default)
  * UART (default)
  * WiFi (default)

Download the "float" version of the build.

Or, build with docker:

    git clone https://github.com/nodemcu/nodemcu-firmware.git
    cd nodemcu-firmware
    # edit app/include/user_modules.h to select modules to build (see above)
    docker pull marcelstoer/nodemcu-build
    docker run --rm -ti -e FLOAT_ONLY=1 -v `pwd`:/opt/nodemcu-firmware marcelstoer/nodemcu-build
    
Firmware is output in `bin/nodemcu_float_master_*.bin`
 
### Upload firmware (serial)

Download [esptool,py](https://github.com/themadinventor/esptool) to flash firmware.

    export NODEMCU_DEV=/dev/tty.usbserial*
    alias esptool='esptool.py --port $NODEMCU_DEV --baud 115200'
    
    # upgrade esp SDK
    esptool erase_flash
    esptool write_flash -fm dio -fs 32m 0x00000 nodemcu-master-....bin 0x3fc000 esp_init_data_default.bin
    
    # or just flash
    esptool write_flash -fm dio -fs 32m 0x00000 nodemcu-master-....bin

Programming some modules requires a jumper or button to be set while the device is powered on to enter reprogramming mode.

### Terminal monitor/REPL (serial)

    miniterm.py $NODEMCU_DEV 115200

### Local upload all files (serial)

Download [nodemcu-uploader.py](https://github.com/kmpm/nodemcu-uploader) for local (USB/serial) management.

    export NODEMCU_DEV=/dev/tty.usbserial*
    alias nodemcu-uploader='nodemcu-uploader --port $NODEMCU_DEV'

    nodemcu-uploader upload --restart *.lua *.json && \
    nodemcu-uploader terminal

### Remote management (wifi)

Download [luatool.py](https://github.com/4refr0nt/luatool) for remote (telnet) management.

    export NODEMCU_HOST=<device-ip>
    export NODEMCU_PORT=2323
    alias luatool='luatool --ip $NODEMCU_HOST:$NODEMCU_PORT'

    luatool --restart --src <file.lua>
  
    telnet $NODEMCU_HOST $NODEMCU_PORT
    nc $NODEMCU_HOST $NODEMCU_PORT

These commands only work if a telnet server is running on the device. If the device is otherwise inaccessible, be very
careful not to upload code (such as a broken init.lua) that will fail to connect to wifi, have an error before running 
the telnet server or reboot without allowing time to send some commands.

