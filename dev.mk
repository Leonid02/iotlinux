ifndef prj 
prj=$(PWD)
endif

is_dev_ok=1
devs="rpi3-router bpi64-media"

ifneq ($(dev),$(filter $(dev), rpi3-router bpi64-media flrec))
	is_dev_ok=0
endif

ifeq ($(dev),)
	is_dev_ok=0
endif

bb_bins=$(prj)/3rdparty/$(dev)/buildroot-bins-$(dev)
staging=$(bb_bins)/staging

ifeq ($(dev),rpi3-router)
cross=$(bb_bins)/host/bin/arm-linux-
host=arm-linux
arch=arm
kern_ver=4.14.68
kern_dir=$(prj)/3rdparty/$(dev)/kernel/linux-4.14.68
kern_defconfig=bcm2709_defconfig
dtb=bcm27*.dtb
apps=logger logger_test
endif

ifeq ($(dev),bpi64-media)
cross=$(bb_bins)/host/bin/aarch64-linux-gnu-
host=arm-linux
arch=arm
kern_ver=4.2.10
kern_defconfig=bcm2709_defconfig
apps=logger logger_test
endif

ifeq ($(dev),flrec)
cross=$(bb_bins)/host/bin/arm-linux-gnueabi-
host=arm-linux
arch=arm
kern_ver=4.19.56
kern_dir=$(prj)/3rdparty/$(dev)/kernel/linux-at91
kern_defconfig=sama5d3-kimdu_defconfig
dtb=at91-sama5d3_xplained.dtb
apps=pwrlost recording-srv
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
	make O=$(prj)/3rdparty/$(dev)/buildroot-output LINUX_DIR=$(kern_dir) LINUX_VERSION=$(kern_ver) -C $(prj)/3rdparty/buildroot-src defconfig BR2_DEFCONFIG=$(prj)/3rdparty/$(dev)/configs/$(dev)-buildroot-defconfig
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

prepare_kernel:
	@if [ ! -d $(kern_dir) ]; \
	then \
		cd $(prj)/3rdparty/$(dev)/kernel/; \
		tar -xvJf linux*; \
		cd -; \
	fi
	
clean_kernel:	prepare_kernel
	@cd $(prj)/3rdparty/$(dev)/kernel/linux*; \
	make ARCH=$(arch) CROSS_COMPILE=$(cross) mrproper; \
	if [ $$? -ne 0 ]; \
	then \
		echo "Kernel clean failed!"; \
		exit 1; \
	fi; \
	cd -

kernel:		prepare_kernel
	@cd $(kern_dir); \
	cp $(prj)/3rdparty/$(dev)/configs/$(kern_defconfig) arch/$(arch)/configs; \
	make -j4 ARCH=$(arch) CROSS_COMPILE=$(cross) $(kern_defconfig); \
	if [ $$? -ne 0 ]; \
	then \
		echo "Kernel create config failed!"; \
		exit 1; \
	fi; \
	make -j4 ARCH=$(arch) CROSS_COMPILE=$(cross); \
	if [ $$? -ne 0 ]; \
	then \
		echo "Kernel build failed!"; \
		exit 1; \
	fi; \
	make -j4 ARCH=$(arch) CROSS_COMPILE=$(cross) dtbs; \
	if [ $$? -ne 0 ]; \
	then \
		echo "Kernel build failed!"; \
		exit 1; \
	fi; \
	make -j4 ARCH=$(arch) CROSS_COMPILE=$(cross) modules; \
	if [ $$? -ne 0 ]; \
	then \
		echo "Kernel build modules failed!"; \
		exit 1; \
	fi; \
	make -j4 ARCH=$(arch) CROSS_COMPILE=$(cross) INSTALL_MOD_PATH=$(prj)/3rdparty/$(dev)/images modules_install; \
	if [ $$? -ne 0 ]; \
	then \
		echo "Kernel install modules failed!"; \
		exit 1; \
	fi; \
	cp arch/$(arch)/boot/zImage $(prj)/3rdparty/$(dev)/images; \
	cp arch/$(arch)/boot/dts/$(dtb) $(prj)/3rdparty/$(dev)/images; \
	if [ -d arch/$(arch)/boot/dts/overlays ]; \
	then \
		cd arch/$(arch)/boot/dts/overlays/ && tar -czvf $(prj)/3rdparty/$(dev)/images/overlays.tgz *.dtbo && cd -; \
	fi; \
	tar -czvf $(prj)/3rdparty/$(dev)/images/modules.tgz -C $(prj)/3rdparty/$(dev)/images/lib modules; \
	rm -rf $(prj)/3rdparty/$(dev)/images/lib; \
	cd -

prepare_kernel_headers: clean_kernel kernel
	@patch -f -d $(prj)/3rdparty/$(dev)/kernel/linux* -p1 < $(prj)/scripts/modules_headers_install.patch; \
	cd $(prj)/3rdparty/$(dev)/kernel/linux*; \
	make ARCH=$(arch) CROSS_COMPILE=$(cross) INSTALL_MODULES_HDR_PATH=$(prj)/3rdparty/$(dev)/kernel/kernel_headers modules_headers_install; \
	if [ $$? -ne 0 ]; \
	then \
		echo "Kernel create_headers failed!"; \
		exit 1; \
	fi; \
	cd -
