#!/bin/bash

DEST="s3://com.simple.mwhooker/cloud_native"
TARGET=$1
export AWS_DEFAULT_REGION=us-standard


if [ !  $TARGET ]; then
    echo "you need a target."
    exit -1
fi

while [ 1 ]; do
    markdown $TARGET > $TARGET.html
    aws s3 cp $TARGET.html $DEST/$TARGET.html --acl public-read
    sleep 10
done
