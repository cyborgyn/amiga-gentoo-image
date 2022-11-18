#!/bin/sh
BUILD="/storage/selly-build/root/amilux"

if [ "$1" != "" ]; then
    echo "Using build root: '$1'"
    BUILD=$1
fi

TMP_DIR=$(mktemp tmp.XXXXXXXXXX -d)

dd if=/dev/zero of=${TMP_DIR}/amilux.root bs=1048576 count=448
mkfs.btrfs ${TMP_DIR}/amilux.root > ${TMP_DIR}/btrfs.out
ROOTUUID=`grep UUID ${TMP_DIR}/btrfs.out | sed "s/UUID: *//"`

echo "Root fs UUID=$ROOTUUID"
echo $ROOTUUID > .lastRootUuid
mkdir ${TMP_DIR}/{mount,snapshot}

mount ${TMP_DIR}/amilux.root ${TMP_DIR}/mount
mkdir ${TMP_DIR}/mount/snapshots
btrfs subvol snapshot -r ${BUILD} ${TMP_DIR}/snapshot/\@amilux
btrfs send ${TMP_DIR}/snapshot/\@amilux | btrfs receive ${TMP_DIR}/mount/snapshots/
btrfs subvol delete ${TMP_DIR}/snapshot/\@amilux
btrfs subvol snapshot ${TMP_DIR}/mount/snapshots/\@amilux ${TMP_DIR}/mount/\@
btrfs subvol create ${TMP_DIR}/mount/\@home

cat ../src/root/etc/fstab | sed "s/ROOTUID/${ROOTUUID}/g" > ${TMP_DIR}/mount/\@/etc/fstab

sync ${TMP_DIR}/mount
umount ${TMP_DIR}/mount
xz -f -T 4 ${TMP_DIR}/amilux.root
mv ${TMP_DIR}/amilux.root.xz ../images/
rm -rf ${TMP_DIR}
