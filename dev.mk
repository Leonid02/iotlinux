ifndef prj 
prj=$(PWD)
endif

is_dev_ok=1
devs="rpi3-router bpi64-media"

ifneq ($(dev),$(filter $(dev), rpi3-router bpi64-media))
	is_dev_ok=0
endif

ifeq ($(dev),)
	is_dev_ok=0
endif

bb_bins=$(prj)/3rdparty/buildroot-bins-$(dev)
staging=$(bb_bins)/staging

ifeq ($(dev),rpi3_router)
cross=$(bb_bins)/host/bin/arm-linux-gnueabihf-
host=arm-linux
arch=arm
kern_ver=4.4.92
apps="logger logger_test"
endif

ifeq ($(dev),bpi64_media)
cross=$(bb_bins)/host/bin/aarch64-linux-gnu-
host=arm-linux
arch=arm
kern_ver=4.2.10
apps="logger logger_test"
endif

all:

test_env:
	@if [ $(is_dev_ok) -eq 0 ]; \
	then \
		echo "The device is not set! Exiting!"; \
		echo "The possible devices: $(devs)"; \
		exit 1; \
	fi

get_bins:
	$(prj)/scripts/get_bins.sh $(dev)

buildroot:	test_env
	make O=$(prj)/3rdparty/$(dev)/buildroot-output -C $(prj)/3rdparty/buildroot-src defconfig BR2_DEFCONFIG=$(prj)/3rdparty/$(dev)/configs/$(dev)-buildroot-defconfig
	@if [ $$? -ne 0 ]; \
		then \
		echo "Buildroot config failed!"; \
		exit 1;\
	fi
	make O=$(prj)/3rdparty/$(dev)/buildroot-output -C $(prj)/3rdparty/buildroot-src
	@if [ $$? -ne 0 ]; \
		then \
		echo "Buildroot build failed!"; \
		exit 1;\
	fi
	cd $(prj)/scripts/; \
	pwd; \
	./create_buildroot_tarball.sh $(dev); \
	cd -

clean_buildroot:
	make O=$(prj)/3rdparty/$(dev)/buildroot-output -C $(prj)/3rdparty/buildroot-src clean
	if [ $$? -ne 0 ]; \
	then \
		echo "Buildroot clean failed!"; \
		exit 1; \
	fi

distclean_buildroot:
	make O=$(prj)/3rdparty/$(dev)/buildroot-output -C $(prj)/3rdparty/buildroot-src distclean
	if [ $$? -ne 0 ]; \
	then \
		echo "Buildroot disclean failed!"; \
		exit 1; \
	fi

clean_kernel:
	@cd $(prj)/3rdparty/kernel/$(dev)/linux*; \
	make ARCH=$(arch) CROSS_COMPILE=$(cross) mrproper; \
	if [ $$? -ne 0 ]; \
	then \
		echo "Kernel clean failed!"; \
		exit 1; \
	fi; \
	cd -

kernel:
	cd $(prj)/3rdparty/kernel/$(dev)/linux*; \
	cp $(prj)/3rdparty/configs/$(dev)_kernel_defconfig arch/$(arch)/configs; \
	make ARCH=$(arch) CROSS_COMPILE=$(cross) $(dev)_kernel_defconfig; \
	if [ $$? -ne 0 ]; \
	then \
		echo "Kernel create config failed!"; \
		exit 1; \
	fi; \
	make ARCH=$(arch) CROSS_COMPILE=$(cross); \
	if [ $$? -ne 0 ]; \
	then \
		echo "Kernel build failed!"; \
		exit 1; \
	fi; \
	make ARCH=$(arch) CROSS_COMPILE=$(cross) modules; \
	if [ $$? -ne 0 ]; \
	then \
		echo "Kernel build modules failed!"; \
		exit 1; \
	fi; \
	make ARCH=$(arch) CROSS_COMPILE=$(cross) INSTALL_MOD_PATH=$(prj)/3rdparty/kernel/$(dev)/images modules_install; \
	if [ $$? -ne 0 ]; \
	then \
		echo "Kernel install modules failed!"; \
		exit 1; \
	fi; \
	cp arch/$(arch)/boot/bzImage $(prj)/3rdparty/kernel/$(dev)/images; \
	tar -czvf $(prj)/3rdparty/kernel/$(dev)/images/modules.tgz -C $(TOP)/kernel/$(dev)/images/lib modules; \
	rm -rf $(prj)/3rdparty/kernel/$(dev)/images/lib; \
	cd -

prepare_kernel_headers: clean_kernel kernel
	@patch -f -d $(prj)/3rdparty/kernel/vspu/linux* -p1 < $(TOP)/scripts/modules_headers_install.patch; \
	cd $(prj)/3rdparty/kernel/$(dev)/linux*; \
	make ARCH=$(arch) CROSS_COMPILE=$(cross) INSTALL_MODULES_HDR_PATH=$(prj)/3rdparty/kernel/$(dev)/kernel_headers modules_headers_install; \
	if [ $$? -ne 0 ]; \
	then \
		echo "Kernel create_headers failed!"; \
		exit 1; \
	fi; \
	cd -
