#!/bin/bash

BUILD=/storage/selly-build/root/amilux
if [ "$1" != "" ]; then
    echo "Using build root: '$1'"
    BUILD=$1
fi

AMILUX_SET=`cat ../src/portage/sets/amilux`
echo "# Installed packages in @world set" > ../documentation/packages.md
(
pushd ${BUILD}/var/db/pkg > /dev/null
for pkg in `ls -w0 -d */*` ; do
    DESC=`cat ${pkg}/DESCRIPTION`
    IS_IN_SET="false"
    GRP=
    for set in ${AMILUX_SET}; do
        GRP=`echo $pkg | grep $set`
        if [ ! -z "$GRP" ]; then
            IS_IN_SET="true"
        fi
    done
    if [ $IS_IN_SET = "true" ]; then
        echo "* **${pkg}**: ${DESC}"
    else
        echo "* ${pkg}: ${DESC}"
    fi
done
popd > /dev/null
) >> ../documentation/packages.md
