#!/bin/sh

version="linux-3.4.66"
bb="busybox-1.21.1"
arch="ARCH=arm"
cross_compile="CROSS_COMPILE=arm-linux-gnueabi-"


#-----------------------------------------------------------
if [ ! -e $version ];
then
	echo "Downloading linux kernel"
	wget https://www.kernel.org/pub/linux/kernel/v3.0/$version.tar.bz2
	echo "unpacking"
	tar -xjf $version
fi
echo "$version downloaded and extracted!"

#-----------------------------------------------------------
if [ ! -e $bb ];
then
	echo "Downloading $bb"
	wget http://www.busybox.net/downloads/$bb.tar.bz2
	echo "unpacking"
	tar -xjf $bb
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
make $arch $cross_compile install
cd ..
echo "-----------------------------------------------------------"
echo "completing rootfs"

cd $bb/_install
mkdir proc sys dev etc etc/init.d
echo "#!bin/sh

mount -t proc none /proc

mount -t sysfs none /sys

/sbin/mdev -s" > etc/init.d/rcS

chmod +x etc/init.d/rcS
find . | cpio -o --format=newc > ../rootfs.img
cd ..
gzip -c rootfs.img > ../rootfs.img.gz
cd ..

echo "-----------------------------------------------------------"
echo ""
echo " .-----------------------------------------------------------."
echo " |  done building !!                                         |"
echo " |                                                           |"
echo " .-----------------------------------------------------------."

read input
echo "starting qemu"
qemu-system-arm -M versatilepb -m 128M -kernel $version/arch/arm/boot/zImage -initrd $bb/rootfs.img -append “root=/dev/ram rdinit=/sbin/init”

exit

