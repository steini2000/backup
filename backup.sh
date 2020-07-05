#!/bin/bash

# Prepare:
# cd /media oder cd /mnt
# mount: ro: sda1 (efi), sda2 (system)
#        ro: sdb3 (data), sda5 ((scratch)
#        sdc (backup)
# mkdir backup/20170503
# Use:
# sleep 2h ; sdb1/backup.sh sda1 sdb1/20130503
# Zeiten: mind. 2h, besser 3h oder 4h

# true, false, only
DO_CHECK=${DO_CHECK:-true}
# -z for compression
COMPRESS=${COMPRESS:-"--use-compress-program=pigz"}
#COMPRESS=${COMPRESS:-"--use-compress-program='pixz -0'"}
# filename extension
FEXT=${FEXT:-tgz}

if [ "$1" = "" ] || [ "$2" = "" ] ; then
   echo "Source or Destination missing!"
   echo "Usage: $0 SOURCE DESTINATION"
   exit 1
fi

echo "DO_CHECK: \"$DO_CHECK\""
echo "COMPRESS: \"$COMPRESS\""
echo "FEXT: \".${FEXT}\""
echo

if [ "$DO_CHECK" != "only" ] ; then
    echo "start: $(date)"
    CMD="tar -c -v ${COMPRESS} --numeric-owner -f "${2}/${1}.${FEXT}" "${1}/" 2>${2}/${1}_error.log >${2}/${1}.log"
    echo $CMD >"${2}/${1}_backup.cmd"
    echo $CMD
    eval "$CMD"
    RC=$?
    echo $RC >>"${2}/${1}_backup.cmd"
    echo "end: $(date), rc $RC"
    if [ "$RC" != "0" ] ; then 
        echo "Backup FAILED -> STOP"
        echo "$RC" >$1.BACKUP_ERROR
        exit 1
    else 
        echo "Backup OK"
    fi
    echo
fi

if [ "$DO_CHECK" != "false" ] ; then
    echo "Check start: $(date)"
    echo "Starting check..."
    CMD="tar --compare -v ${COMPRESS} -f "${2}/${1}.${FEXT}" >${2}/${1}_check.log 2>${2}/${1}_check_error.log"
    echo $CMD >"${2}/${1}_check.cmd"
    echo $CMD
    eval "$CMD"
    RC=$?
    echo $RC >>"${2}/${1}_check.cmd"
    echo "Check end: $(date), rc $RC"
    if [ "$RC" != "0" ] ; then
        echo "Check FAILED!"
        echo "$RC" >$1.CHECK_ERROR
        exit 1
    else
        echo "Check OK"
    fi
fi
