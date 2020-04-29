#!/bin/sh

dev=$1
top=$(dirname -- "$0")/../../
currdir=$(dirname -- "$0")
builddir=$currdir/buildimg
images=$currdir/images
rootfs="${builddir}/rootfs"

prepare_rootfs()
{
	mkdir -p $rootfs
	tar -zxvf $currdir/buildroot-bins-$dev/rootfs.tar.gz -C $rootfs
	tar -zxvf $images/modules.tgz -C $rootfs/lib/
	#tar -zxvf $images/firmware.tgz -C $rootfs/lib/
	cp -a $top/overlay/fs-$dev/* $rootfs
}

create_image()
{
	make dev=flrec -f $currdir/../../dev.mk kernel
	if [ $? -eq 0 ]
	then
		mv $images/zImage $images/zImage-$dev-$(date +%F)
	else
		echo "Image build failed!"
	fi
	rm -rf $builddir
}

prepare_rootfs
create_image
