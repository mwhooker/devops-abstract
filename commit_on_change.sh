#!/bin/bash

TARGET=$1

st_mtime=0
COUNT=0

while [ 1 ]; do
    old_mtime=$st_mtime
    eval $(stat -s $TARGET)

    if [[ $st_mtime > $old_mtime ]]; then
        echo "committing for the count $COUNT"
        git add $TARGET || exit
        git commit -m "WIP commit $COUNT" || exit
        COUNT=`echo $COUNT + 1 | bc`
    fi
    sleep 1
done
