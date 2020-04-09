#!/bin/sh

dev=$1
top=$(dirname -- "$0")/../../
currdir=$(dirname -- "$0")
builddir=$currdir/buildimg
mkimage=$currdir/buildroot-bins-$dev/host/bin/mkimage
images=$currdir/images
image=$builddir/$dev-$(date +%F)-initramfs.cpio.gz
ubootImage=$builddir/$dev-$(date +%F)-initramfs-uboot.img
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
	rm -rf $builddir
}

#create_image()
#{
#	cd $rootfs
#	find . -print0 | cpio --null --create --verbose --format=newc | gzip --best > $image
#	$mkimage -A arm -T ramdisk -C none -d $image $ubootImage
#	cd -
#	mv $image $images/
#	mv $ubootImage $images/
#	rm -rf $images/flrec.img
#	cd $images
#	ln -s $(basename $ubootImage) flrec.img
#	cd -
#	rm -rf $builddir
#}

prepare_rootfs
create_image
