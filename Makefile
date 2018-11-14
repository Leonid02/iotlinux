prj=$(PWD)
include $(prj)/dev.mk

all:	build

build:	test_env
	$(MAKE) get_bins
	@for i in $(apps); do \
		$(MAKE) dev=$(dev) -C $$i; \
		if [ $$? -ne 0 ]; \
		then \
			echo "Component: $$i build failed. Stop!"; \
			exit 1; \
		fi \
	done;

install: build
	@for i in $(apps); do \
		$(MAKE) dev=$(dev) -C $$i install; \
	done;

clean: 
	@for i in $(apps); do \
		$(MAKE) dev=$(dev) -C $$i clean; \
	done

distclean:
	@for i in $(apps); do \
		$(MAKE) dev=$(dev) -C $$i distclean; \
	done;

image:
	$(prj)/scripts/create_img_$(dev).sh $(BUILDROOT_BINS) $(dev);

deploy: build 
	$(MAKE) install
	$(MAKE) image

