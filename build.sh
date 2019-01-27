#!/bin/bash

set -euo pipefail

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

aws s3 cp s3://aws-lambda-r-runtime/R-$VERSION/R-$VERSION.zip .
./build_runtime.sh $VERSION
./build_recommended.sh $VERSION
