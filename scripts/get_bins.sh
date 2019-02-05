#!/bin/sh
dev=$1
top=$(dirname -- "$0")/..
conf=$top/3rdparty/$dev/configs/$dev-bins.conf
server=orion.homelinux.net

get_tarball()
{
	fname=$1
	targetdir=$2
	wget http://$server:5252/buildroot-bins/$1
	if [ $? -ne 0 ]
	then
		echo "File $1 not exists on server:$server"
		return 1
	fi
	tar -zxvf $fname -C $targetdir
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
	bbarchive=$(grep fname $conf | sed "s/bb_fname=//")
	if [ "$bbarchive""xx" == "xx" ]
	then
		echo "Can't parse device's config file"
		exit 1
	fi
	get_tarball $bbarchive $top/3rdparty/$dev
	if [ $? -eq 1 ]
	then
		echo "Can't retrieve tarball of buildroot bins"
		exit 1
	fi
fi

# download Linux kernel sources
kernarchive=$(grep fname $conf | sed "s/bb_fname=//")
if [ "$kernarchive""xx" == "xx" ]
then
	echo "Can't parse device's config file"
	exit 1
fi
get_tarball $kernarchive $top/3rdparty/$dev/kernel
if [ $? -eq 1 ]
then
	echo "Can't retrieve tarball of buildroot bins"
	exit 1
fi

exit 0
