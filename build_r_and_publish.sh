#!/bin/bash

set -euo pipefail

VERSION=$1
BUCKET=$2

if [ -z "$VERSION" ];
then
    echo 'version number required'
    exit 1
fi

if [ -z "$BUCKET" ];
then
    echo 'BUCKET required'
    exit 1
fi

./build_r.sh $VERSION
aws s3 cp /opt/R/R-$VERSION.zip \
    s3://$BUCKET/R-$VERSION/R-$VERSION.zip
