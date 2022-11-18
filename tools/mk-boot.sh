#!/bin/bash

# This needs amitools from
# https://github.com/cnvogelg/amitools

BUILD=/storage/selly-build/root/amilux

if [ "$1" != "" ]; then
    echo "Using build root: '$1'"
    BUILD=$1
fi

export PATH=$PATH:$HOME/.local/bin

WB31DISK=files/wbench31.adf
AMIBOOT=files/amiboot-5.6.gz
GIGGLEDISK=files/giggledisk.lha
FAT95=files/fat95.lha
CPULIBS=files/040_060Libs.zip

ABOOT_IMAGE_NAME="amilux.boot"
ABOOT_IMAGE_HDF="$ABOOT_IMAGE_NAME".hdf

rm -f $ABOOT_IMAGE_HDF
xdftool $ABOOT_IMAGE_HDF create size=32Mi + format ABoot ffs

xdftool $ABOOT_IMAGE_HDF makedir C
xdftool $ABOOT_IMAGE_HDF makedir S
xdftool $ABOOT_IMAGE_HDF makedir L
xdftool $ABOOT_IMAGE_HDF makedir Libs
xdftool $ABOOT_IMAGE_HDF makedir Kernels

if [ ! -f $WB31DISK ]; then
	echo "Error! Amiga WorkBench 3.1 disk image not found!"
	exit 1
fi

# Extract minimal needed stuff from WB 3.1 Disk
echo Extract minimal needed stuff from WB 3.1 Disk
TMP_DIR=$(mktemp tmp.XXXXXXXXXX -d)
WB31FILES=( SetPatch Dir List Assign Copy Delete Rename Execute Protect Mount Type Edit Ed )
for WBFILE in ${WB31FILES[@]}; do
    xdftool $WB31DISK read C/$WBFILE $TMP_DIR
    xdftool $ABOOT_IMAGE_HDF write $TMP_DIR/$WBFILE C/
done
WB31FILES=( asl.library diskfont.library )
for WBFILE in ${WB31FILES[@]}; do
    xdftool $WB31DISK read libs/$WBFILE $TMP_DIR
    xdftool $ABOOT_IMAGE_HDF write $TMP_DIR/$WBFILE libs/
done
rm -rf $TMP_DIR

# Copy BigRam utility
xdftool $ABOOT_IMAGE_HDF write files/2632 C/
xdftool $ABOOT_IMAGE_HDF protect C/2632 rwed

# GiggleDisk is needed to mount boot partition, also copy mount script
TMP_DIR=$(mktemp tmp.XXXXXXXXXX -d)
pushd $TMP_DIR >/dev/null
lha x ../$GIGGLEDISK >/dev/null
popd >/dev/null
xdftool $ABOOT_IMAGE_HDF write $TMP_DIR/GiggleDisk/Bin/GiggleDisk_AOS68K C/
rm -rf $TMP_DIR

# FAT95 is needed to mount the LNXBoot partition which is generated as FAT
TMP_DIR=$(mktemp tmp.XXXXXXXXXX -d)
pushd $TMP_DIR >/dev/null
lha x ../$FAT95 >/dev/null
popd >/dev/null
xdftool $ABOOT_IMAGE_HDF write $TMP_DIR/fat95/l/fat95 L/
rm -rf $TMP_DIR

# copy CPU library files
CPULIBFILES=( 68060.library 68040old.library 68040new.library 68040.library )
TMP_DIR=$(mktemp tmp.XXXXXXXXXX -d)
pushd $TMP_DIR >/dev/null
unzip ../$CPULIBS >/dev/null
popd >/dev/null
for CPULIBFILE in ${CPULIBFILES[@]}; do
    xdftool $ABOOT_IMAGE_HDF write $TMP_DIR/$CPULIBFILE Libs/
done
rm -rf $TMP_DIR

# amiboot is needed to boot the kernel
TMP_DIR=$(mktemp tmp.XXXXXXXXXX -d)
pushd $TMP_DIR >/dev/null
gzip -d -c ../$AMIBOOT >amiboot-5.6
popd >/dev/null
xdftool $ABOOT_IMAGE_HDF write $TMP_DIR/amiboot-5.6 C/
xdftool $ABOOT_IMAGE_HDF write files/mem C/

echo "Copy kernels..."
# Copy startup sequence
xdftool $ABOOT_IMAGE_HDF write files/Startup-Sequence S/
xdftool $ABOOT_IMAGE_HDF protect S/Startup-Sequence srwd

# Copy one key boot script
rm ${BUILD}/boot/*.old
KERNELS=( `ls -w0 ${BUILD}/boot/vmlinuz*-amilux-*` )
LAST_KERNEL=""
for KERNEL in ${KERNELS[@]}; do
    LAST_KERNEL=`echo ${KERNEL} | sed -n 's/.*vmlinuz-\([0-9\.]\+\)-.*amilux-\([0-9]\+\).*/amilux-\2-\1/p'`
    LAST_KERNEL_VERSION=`echo ${KERNEL} | sed -n 's/.*vmlinuz-\([0-9]\+\.[0-9]\+\)\..*-.*amilux-\([0-9]\+\).*/\1/p'`
    echo "${KERNEL} -> ${LAST_KERNEL}"
    cp ${KERNEL} ${TMP_DIR}/${LAST_KERNEL}.gz
    gunzip ${TMP_DIR}/${LAST_KERNEL}.gz
    xdftool $ABOOT_IMAGE_HDF write ${TMP_DIR}/${LAST_KERNEL} Kernels/
    echo "c:amiboot-5.6 -k :Kernels/${LAST_KERNEL} debug loglevel=7 console=ttyS0,19200 console=tty0 rootdelay=10 root=/dev/sda2 dobtrfs rootfstype=btrfs rootflags=subvol=@ init=/sbin/openrc-init" > ${TMP_DIR}/boot${LAST_KERNEL_VERSION}
    echo "c:amiboot-5.6 -k :Kernels/${LAST_KERNEL} debug loglevel=7 console=ttyS0,19200 console=tty0 root=/dev/hda2 dobtrfs rootfstype=btrfs rootflags=subvol=@ init=/sbin/openrc-init" > ${TMP_DIR}/boot${LAST_KERNEL_VERSION}-ide
    xdftool $ABOOT_IMAGE_HDF write ${TMP_DIR}/boot${LAST_KERNEL_VERSION} C/
    xdftool $ABOOT_IMAGE_HDF protect C/boot${LAST_KERNEL_VERSION} srwd
    xdftool $ABOOT_IMAGE_HDF write ${TMP_DIR}/boot${LAST_KERNEL_VERSION}-ide C/
    xdftool $ABOOT_IMAGE_HDF protect C/boot${LAST_KERNEL_VERSION}-ide srwd
    echo "'boot${LAST_KERNEL_VERSION}'     : ${LAST_KERNEL_VERSION} kernel, rootfs on SCSI disk">> ${TMP_DIR}/motd.list
    echo "'boot${LAST_KERNEL_VERSION}-ide' : ${LAST_KERNEL_VERSION} kernel, rootfs on IDE disk">> ${TMP_DIR}/motd.list
done
cat files/motd.head ${TMP_DIR}/motd.list files/motd.tail > ${TMP_DIR}/motd
cat ${TMP_DIR}/motd

xdftool $ABOOT_IMAGE_HDF write ${TMP_DIR}/motd C/

rm -rf $TMP_DIR

#LAST_ROOTUUID=`cat .lastRootUuid`

xdftool $ABOOT_IMAGE_HDF list

xz -f -T 4 $ABOOT_IMAGE_HDF
mv $ABOOT_IMAGE_HDF.xz ../images/
