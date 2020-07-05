#!/bin/bash
# 1. Mount Partition with do backup.sh and backup.sh in directory backup
# 2. Check partitions below
# 3. Run dobackup.sh

PARTITIONS=${PARTITIONS:-"sda1 sda2 sdb3 sdb5"}

BASEDIR=$(dirname $(readlink -f "$0"))

cd "$BASEDIR"

DESTINATION="${BASEDIR}/$(date +%Y%m%d)"
if [ -d "$DESTINATION" ] ; then
    echo "Destination $DESTINATION already exists!"
    exit 1
fi

if [ ! -x "${BASEDIR}/backup.sh" ] ; then
    echo "Backup script not found!"
    exit 1
fi

for i in $PARTITIONS ; do
   if [ -d "$i" ] ; then
        echo "Partition $i already exists!"
        exit 1
    fi
done

echo "Script: ${BASEDIR}/backup.sh"
echo "Partitions: $PARTITIONS"
echo "Destination: $DESTINATION"
echo
echo "Press Return to continue, CTRL+C to cancel..."
read dummy

for i in $PARTITIONS ; do
    mkdir "$i"
    mount -o ro "/dev/${i}" "$i"
    RC=$?
    if [ "$RC" != "0" ] ; then
        echo "Error $RC mounting ${i}!"
        exit 1
    fi
done

mkdir "$DESTINATION"

echo "START: $(date)"

for i in $PARTITIONS ; do
    echo "----------------------- start $i ------------------------"
    "${BASEDIR}/backup.sh" "$i" "$DESTINATION"
    RC=$?
    echo "----------------------- end $i --------------------------"
    if [ "$RC" != "0" ] ; then
        exit 1;
    fi
done

echo "END: $(date)"
for i in $PARTITIONS ; do
    umount "$i"
    rmdir $i
done
