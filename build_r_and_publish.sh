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
R_COMPILED_ZIP=$R_OUTPUT_FOLDER/R-compiled-$VERSION.zip
if [ ! -f "$R_COMPILED_ZIP" ]; then
	./build_r.sh $VERSION
fi

check_aws_configured

information "Uploading R to aws bucket $BUCKET "
aws s3 cp $R_COMPILED_ZIP \
    s3://$BUCKET/R/R-$VERSION.zip || error "Unable to deploy R to bucket $BUCKET"
success "Uploaded R to aws bucket $BUCKET"