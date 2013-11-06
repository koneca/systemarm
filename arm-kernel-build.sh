#!/bin/sh

version="linux-3.4.66"
bb="busybox-1.21.1"
arch="ARCH=arm"
cross_compile="CROSS_COMPILE=arm-linux-gnueabi-"


#-----------------------------------------------------------
if [ ! -e "$version.tar.bz2" ];
then
	echo "Downloading linux kernel"
	wget https://www.kernel.org/pub/linux/kernel/v3.0/$version.tar.bz2
	echo "unpacking"
	tar -xjf "$version.tar.bz2"
fi
echo "$version downloaded and extracted!"

#-----------------------------------------------------------
if [ ! -e "$bb.tar.bz2" ];
then
	echo "Downloading $bb"
	wget http://www.busybox.net/downloads/$bb.tar.bz2
	echo "unpacking"
	tar -xjf "$bb.tar.bz2"
fi
echo "$bb downloaded and extracted!"

echo "-----------------------------------------------------------"
echo "building $version"
cd $version
make $arch $cross_compile menuconfig
make $arch $cross_compile
cd ..
sleep 3
echo "building $bb"
cd $bb
make $arch $cross_compile menuconfig
make $arch $cross_compile install
cd ..
echo "-----------------------------------------------------------"
echo "completing rootfs"

cd rootfs
pwd
mkdir proc
mkdir sys
mkdir dev
mkdir etc
mkdir etc/init.d
arm-linux-gnueabi-gcc -static ../sysinf.c -o sbin/sysinfo

chmod +x etc/init.d/rcS
find . | cpio -o --format=newc > ../rootfs.img
cd ..
gzip -c rootfs.img > rootfs.img.gz

echo "-----------------------------------------------------------"
echo ""
echo " .-----------------------------------------------------------."
echo " |  done building !!                                         |"
echo " |                                                           |"
echo " .-----------------------------------------------------------."

read input
echo "starting qemu"
qemu-system-arm -M vexpress-a9 -kernel $version/arch/arm/boot/zImage -initrd rootfs.img.gz -append "root=/dev/ram rdinit=/sbin/init"

exit

