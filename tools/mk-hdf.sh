#!/bin/bash

# Daphne-Agnus-Portia... We will never forget.

# This needs amitools from
# https://github.com/cnvogelg/amitools

export PATH=$PATH:$HOME/.local/bin

IMAGE_FILE_NAME="amilux.hdf"

ABOOT=../images/amilux.boot.hdf.xz
LNXROOT=../images/amilux.root.xz
LNXSWAP=../images/amilux.swap.xz

echo "Creating and partitioning image..."

rm -f $IMAGE_FILE_NAME
rdbtool $IMAGE_FILE_NAME create size=514Mi + init
rdbtool $IMAGE_FILE_NAME add size=32MiB name=ABOOT dostype=DOS1 max_transfer=0x1fe00 bootable
rdbtool $IMAGE_FILE_NAME add size=448MiB name=LNXROOT dostype=LNX0 max_transfer=0x1fe00 automount=false
rdbtool $IMAGE_FILE_NAME add size=32MiB name=LNXSWAP dostype=LNX0 max_transfer=0x1fe00 automount=false

rdbtool $IMAGE_FILE_NAME info

echo "Populating final image..."

CYL_BLOCKS=`rdbtool $IMAGE_FILE_NAME info | grep -m 1 cyl_blks | awk -F"=" '{print $NF}'`
BLOCK_SIZE=`rdbtool $IMAGE_FILE_NAME info | grep -m 1 block_size | awk -F"=" '{print $NF}'`
CYL_SIZE=$((CYL_BLOCKS*BLOCK_SIZE))

ABOOT_START=`rdbtool $IMAGE_FILE_NAME info | grep -m 1 ABOOT | awk '{print $4}'`
LNXROOT_START=`rdbtool $IMAGE_FILE_NAME info | grep -m 1 LNXROOT | awk '{print $4}'`
LNXSWAP_START=`rdbtool $IMAGE_FILE_NAME info | grep -m 1 LNXSWAP | awk '{print $4}'`

xz -d -c $ABOOT | dd of=$IMAGE_FILE_NAME conv=notrunc bs=$CYL_SIZE seek=$ABOOT_START status=none
xz -d -c $LNXROOT | dd of=$IMAGE_FILE_NAME conv=notrunc bs=$CYL_SIZE seek=$LNXROOT_START status=none
xz -d -c $LNXSWAP | dd of=$IMAGE_FILE_NAME conv=notrunc bs=$CYL_SIZE seek=$LNXSWAP_START status=none

gzip $IMAGE_FILE_NAME
mv $IMAGE_FILE_NAME.gz ../images/