prj=$(PWD)
include $(prj)/dev.mk

all:	build

build:	test_env get_bins
	@for i in $(apps); do \
		$(MAKE) dev=$(dev) -C apps/$$i; \
		if [ $$? -ne 0 ]; \
		then \
			echo "Component: $$i build failed. Stop!"; \
			exit 1; \
		fi \
	done;

install: build
	@for i in $(apps); do \
		$(MAKE) dev=$(dev) -C apps/$$i install; \
	done;

clean: 
	@for i in $(apps); do \
		$(MAKE) dev=$(dev) -C apps/$$i clean; \
	done

distclean:
	@for i in $(apps); do \
		$(MAKE) dev=$(dev) -C apps/$$i distclean; \
	done;

image:
	sudo $(prj)/3rdparty/$(dev)/create_img.sh $(dev);

deploy: build 
	$(MAKE) install
	$(MAKE) image

