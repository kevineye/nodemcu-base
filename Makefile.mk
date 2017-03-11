NODEMCU_DEV=$(wildcard /dev/tty.wchusbserial*)
NODEMCU_PORT=2323

NODEMCU_UPLOADER=nodemcu-uploader --port $(NODEMCU_DEV)

LUATOOL=luatool --ip $(NODEMCU_IP):$(NODEMCU_PORT)
NC=nc $(NODEMCU_IP) $(NODEMCU_PORT)

ESPTOOL=esptool.py --port $(NODEMCU_DEV) --baud 115200
NODEMCU_FIRMWARE_DIR=../nodemcu-firmware
NODEMCU_FIRMWARE=$(wildcard $(NODEMCU_FIRMWARE_DIR)/bin/nodemcu_float_*.bin)
NODEMCU_INIT_DATA=$(NODEMCU_FIRMWARE_DIR)/sdk/esp_iot_sdk_v2.0.0/bin/esp_init_data_default.bin

all: upload restart terminal

.upload/% : %
ifdef NODEMCU_IP
	cd $(dir $<) && $(LUATOOL) --src $(notdir $<)
else
	cd $(dir $<) && $(NODEMCU_UPLOADER) upload $(notdir $<)
endif
	@mkdir -p $(dir $@)
	@touch $@

clean:
	@rm -rf .upload

upload: $(patsubst %,.upload/%,$(SRC_FILES))

format:
ifdef NODEMCU_IP
	$(LUATOOL) --wipe
else
	$(NODEMCU_UPLOADER) file format
endif

ls:
ifdef NODEMCU_IP
	$(LUATOOL) --list
else
	$(NODEMCU_UPLOADER) file list
endif

restart:
ifdef NODEMCU_IP
	echo 'node.restart()' | $(NC)
	sleep 10
else
	$(NODEMCU_UPLOADER) node restart
endif

terminal:
ifdef NODEMCU_IP
	$(NC)
else
	$(NODEMCU_UPLOADER) terminal
endif

flash:
	$(ESPTOOL) erase_flash
	sleep 5
	$(ESPTOOL) write_flash -fm dio -fs 32m 0x00000 $(NODEMCU_FIRMWARE) 0x3fc000 $(NODEMCU_INIT_DATA)
