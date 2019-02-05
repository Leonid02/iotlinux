#!/bin/sh

dev=$1
top=$(dirname -- "$0")/..
builddir=$top/3rdparty/$dev/buildimg
images=$top/3rdparty/$dev/images
image=$builddir/$dev-$(date +%F).img
bootsize=64
rootfs="${builddir}/rootfs"
bootfs="${rootfs}/boot"
bootp=
rootp=
part_position=8192

prepare_image()
{
    rm -rf $builddir
    mkdir -p $builddir
    dd if=/dev/zero of=$image bs=1MB count=1000
    device=`losetup -f --show $image`
    echo "image $image created and mounted as $device"
    
    fdisk $device << EOF
n
p
1
$part_position
+${bootsize}M
t
c
n
p
2
$((part_position+bootsize*1024*2))

w
EOF
	echo "device: $device"
	partprobe -s $device
    bootp=${device}p1
    rootp=${device}p2
    mkfs.vfat $bootp
    mkfs.ext4 $rootp
    mkdir -p $rootfs
    mount $rootp $rootfs
	mkdir $bootfs
    mount $bootp $bootfs
}

prepare_bootfs()
{
    tar -zxvf $images/boot.tgz -C $rootfs
	cp $images/zImage $bootfs/kernel7.img
    cp $images/*.dtb $bootfs
    tar -zxvf $images/overlays.tgz -C $bootfs/overlays
}

prepare_rootfs()
{
	tar -xvJf $top/3rdparty/$dev/buildroot-bins-$dev/rootfs.tar.xz -C $rootfs
	tar -zxvf $images/modules.tgz -C $rootfs/lib/
	tar -zxvf $images/firmware.tgz -C $rootfs/lib/
	cp -a $top/overlay/fs-$dev/* $rootfs
}

finish_image()
{
	umount $bootfs
	umount $rootfs
	losetup -d $device
	mv $image $images/
	rm -rf $builddir
}

prepare_image
prepare_bootfs
prepare_rootfs
finish_image
