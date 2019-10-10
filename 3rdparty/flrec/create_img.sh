#!/bin/sh

dev=$1
top=$(dirname -- "$0")/../../
currdir=$(dirname -- "$0")
builddir=$currdir/buildimg
images=$currdir/images
image=$builddir/$dev-$(date +%F)-initramfs.cpio.gz
rootfs="${builddir}/rootfs"

prepare_rootfs()
{
	mkdir -p $rootfs
	tar -zxvf $currdir/buildroot-bins-$dev/rootfs.tar.gz -C $rootfs
	tar -zxvf $images/modules.tgz -C $rootfs/lib/
	tar -zxvf $images/firmware.tgz -C $rootfs/lib/
	cp -a $top/overlay/fs-$dev/* $rootfs
}

create_image()
{
	cd $rootfs
	find . -print0 | cpio --null --create --verbose --format=newc | gzip --best > $image
	cd -
	mv $image $images/
	rm -rf $builddir
}

prepare_rootfs
create_image
