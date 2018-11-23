#!/bin/bash -x

dev=$1
top=$(dirname -- "$0")/..
if [ $# -lt 1 ]
then
   echo "Device type should be supplied!!!"
   exit -1
fi

outdir=buildroot-bins-$dev
indir=$top/3rdparty/$dev/buildroot-output
conf=$top/3rdparty/$dev/configs/$dev-bins.conf
fname=$outdir-$(date +%F)-$(git rev-parse HEAD | cut -c1-8).tgz

rm -rf $outdir
mkdir -p $outdir

cp -a ./$indir/images/rootfs.tar* $outdir/
cp -a ./$indir/images/bzImage $outdir/
cp -a ./$indir/host $outdir/
cd $outdir
ln -s $(find . -name sysroot) staging
cd -
echo $(git rev-parse HEAD) >> $outdir/buildroot-hashtag.txt
tar -czvf $fname $outdir

sed "s/fname=.*/fname=$fname/" -i $conf
sed "s/md5=.*/md5=`md5sum $fname | awk '{print $1}'`/" -i $conf
sed "s/tag=.*/tag=`git rev-parse HEAD`/" -i $conf
rm -rf $outdir;
echo "####################"
cp $fname /opt/3rdparty-repo/buildroot-bins
rm -rf $fname
