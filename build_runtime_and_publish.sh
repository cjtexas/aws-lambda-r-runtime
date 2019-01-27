#!/bin/bash
source ./common.sh

VERSION=${1:-}
BUCKET=${2:-}
version_input_check $VERSION

 if [ -z "$BUCKET" ];
    then
        error 'bucket name required'
        exit 1
    fi

if [ ! -f "$R_OUTPUT_FOLDER/runtime.zip" ]; then
	./build_runtime.sh $VERSION $BUCKET
fi

check_aws_configured

success "Uploading runtime to aws"

aws lambda publish-layer-version --layer-name r-runtime --zip-file fileb://$R_OUTPUT_FOLDER/runtime.zip
