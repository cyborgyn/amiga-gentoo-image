#!/bin/sh
BUILD="amilux"

if [ "$1" != "" ]; then
    echo "Using $1..."
    BUILD=$1
fi

TMP_DIR=$(mktemp tmp.XXXXXXXXXX -d)

dd if=/dev/zero of=${BUILD}.root bs=1048576 count=448
mkfs.btrfs ${BUILD}.root > ${TMP_DIR}/btrfs.out
ROOTUUID=`grep UUID ${TMP_DIR}/btrfs.out | sed "s/UUID: *//"`

echo "Root fs UUID=$ROOTUUID"
echo $ROOTUUID > .lastRootUuid

mount ${BUILD}.root /mnt/temp/
mkdir /mnt/temp/snapshots
btrfs subvol delete /storage/selly-build/snapshots/\@${BUILD}
btrfs subvol snapshot -r /storage/selly-build/root/${BUILD} /storage/selly-build/snapshots/\@${BUILD}
btrfs send /storage/selly-build/snapshots/\@${BUILD} | btrfs receive /mnt/temp/snapshots/
btrfs subvol snapshot /mnt/temp/snapshots/\@${BUILD} /mnt/temp/\@
btrfs subvol create /mnt/temp/\@home

cat ../src/root/etc/fstab | sed "s/ROOTUID/${ROOTUUID}/g" > /mnt/temp/\@/etc/fstab

sync /mnt/temp
umount /mnt/temp
xz -f -T 4 ${BUILD}.root
rm -rf ${TMP_DIR}
mv ${BUILD}.root.xz ../images/
