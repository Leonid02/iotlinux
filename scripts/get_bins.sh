#!/bin/sh
dev=$1
top=$(dirname -- "$0")/..
conf=$top/3rdparty/$dev/configs/$dev-bins.conf
server=orion.homelinux.net

get_tarball()
{
   fname=$(grep fname $conf | sed "s/bb_fname=//")
   if [ "$fname""xx" == "xx" ]
   then
       echo "Can't parse device's config file"
       return 1
   fi
   wget http://$server:5252/buildroot-bins/$fname
   if [ $? -ne 0 ]
   then
       echo "File $fname not exists on server:$server"
       return 1
   fi
   tar -zxvf $fname -C $top/3rdparty/$dev
   rm -rf $fname
   return 0
}

## Buildroot ########
if [ ! -d $top/3rdparty/$dev/buildroot-bins-$dev ]
then
    echo "Get the buildroot binaries!"
    get_tarball
    if [ $? -eq 1 ]
    then
        echo "Can't retrieve tarball of buildroot bins"
        exit 1
    fi
fi

# check that hashtag in bin directory is same
bin_tag=`cat $top/3rdparty/$dev/buildroot-bins-$dev/buildroot-hashtag.txt`
required_tag=$(grep "tag=" $conf | sed 's/bb_tag=//')
if [ "$bin_tag" != "$required_tag" ]
then
   rm -rf $top/3rdparty/buildroot-bins-$dev
   get_tarball
   if [ $? -eq 1 ]
   then
       echo "Can't retrieve tarball of buildroot bins"
       exit 1
   fi
fi

exit 0
