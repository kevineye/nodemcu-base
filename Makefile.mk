PORT=$(wildcard /dev/tty.wchusbserial*)
NODEMCU_UPLOADER=nodemcu-uploader --port $(PORT)

all: upload reset terminal

help:
	@echo "make upload FILE:=<file>  to upload a specific file (i.e make upload FILE:=init.lua)"
	@echo "make upload_all           to upload all"
	@echo "make reset                to reset the controller"
	@echo "make format               to format the filesystem (remove all files but keep the image)"
	@echo "make ls                   to list all files"
	@echo "make all                  to upload all and reboot"

.upload/% : %
	cd $(dir $<) && $(NODEMCU_UPLOADER) upload $(notdir $<)
	@mkdir -p $(dir $@)
	@touch $@

clean:
	@rm -rf .upload

upload: $(patsubst %,.upload/%,$(SRC_FILES))

format:
	$(NODEMCU_UPLOADER) file format

ls:
	$(NODEMCU_UPLOADER) file list

reset:
	$(NODEMCU_UPLOADER) node restart

terminal:
	$(NODEMCU_UPLOADER) terminal
