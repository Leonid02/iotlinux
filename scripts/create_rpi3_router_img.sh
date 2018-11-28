#!/bin/sh

dev=$1
top=$(dirname -- "$0")/..
builddir=$top/3rdparty/$dev/buildimg
images=$top/3rdparty/$dev/images
image=$builddir/$dev-$(date +%F).img
bootsize="64M"
rootfs="${builddir}/rootfs"
bootfs="${rootfs}/boot"
bootp=
rootp=

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
+$bootsize
t
c
n
p
2
w
EOF
    losetup -d $device
    device=`kpartx -va $image | sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1`
    device="/dev/mapper/${device}"
    bootp=${device}p1
    rootp=${device}p2
    mkfs.vfat $bootp
    mkfs.ext4 $rootp
    mkdir -p $rootfs
    mount $rootp $rootfs
    mount $bootp $bootfs
}

prepare_bootfs()
{
    tar -zxvf $images/boot.tgz -C $rootfs
	cp $images/zImage $bootfs/kernel8.img
    cp $images/dtbs/*.dtb $bootfs
    cp $images/dtbs/overlays $bootfs/ -a
}

finish_image()
{
if [ "$image" != "" ]; then
  kpartx -d $image
  echo "created image $image"
fi
}
