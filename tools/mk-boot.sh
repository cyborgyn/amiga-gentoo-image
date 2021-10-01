#!/bin/bash

# This needs amitools from
# https://github.com/cnvogelg/amitools

export PATH=$PATH:$HOME/.local/bin

WB31DISK=../../wbench31.adf
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


# Extract minimal needed stuff from WB 3.1 Disk
echo Extract minimal needed stuff from WB 3.1 Disk
TMP_DIR=$(mktemp tmp.XXXXXXXXXX -d)
WB31FILES=( SetPatch Dir List Assign Copy Delete Rename Execute Protect Mount Type Edit )
for WBFILE in ${WB31FILES[@]}; do
    xdftool $WB31DISK read C/$WBFILE $TMP_DIR
    xdftool $ABOOT_IMAGE_HDF write $TMP_DIR/$WBFILE C/
done
rm -rf $TMP_DIR

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
xdftool $ABOOT_IMAGE_HDF write files/motd C/

echo "Copy kernels..."
# Copy startup sequence
xdftool $ABOOT_IMAGE_HDF write files/Startup-Sequence S/
xdftool $ABOOT_IMAGE_HDF protect S/Startup-Sequence srwd

# Copy one key boot script
KERNELS=( `ls -w0 /storage/selly-build/root/amilux/boot/vmlinuz*-amilux-*` )
LAST_KERNEL=""
for KERNEL in ${KERNELS[@]}; do
    LAST_KERNEL=`echo ${KERNEL} | sed 's\/.*-gentoo-\\\g'`
    echo "${KERNEL} -> ${LAST_KERNEL}"
    cp ${KERNEL} ${TMP_DIR}/${LAST_KERNEL}.gz
    gunzip ${TMP_DIR}/${LAST_KERNEL}.gz
    xdftool $ABOOT_IMAGE_HDF write ${TMP_DIR}/${LAST_KERNEL} Kernels/
done
rm -rf $TMP_DIR

LAST_ROOTUUID=`cat .lastRootUuid`
echo "c:amiboot-5.6 -k :Kernels/${LAST_KERNEL} root=/dev/sda2 dobtrfs rootfstype=btrfs rootflags=subvol=@ init=/sbin/openrc-init" > files/boot
echo "c:amiboot-5.6 -k :Kernels/${LAST_KERNEL} root=/dev/hda2 dobtrfs rootfstype=btrfs rootflags=subvol=@ init=/sbin/openrc-init" > files/boot-ide

xdftool $ABOOT_IMAGE_HDF write files/boot C/
xdftool $ABOOT_IMAGE_HDF protect C/boot srwd
xdftool $ABOOT_IMAGE_HDF write files/boot-ide C/
xdftool $ABOOT_IMAGE_HDF protect C/boot-ide srwd

xdftool $ABOOT_IMAGE_HDF list

xz -f -T 4 $ABOOT_IMAGE_HDF
mv $ABOOT_IMAGE_HDF.xz ../images/