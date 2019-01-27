#!/bin/bash
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $BASE_DIR/common.sh


VERSION=${1:-}
BUCKET=${2:-}
version_input_check $VERSION

 if [ -z "$BUCKET" ];
    then
        error 'bucket name required'
        exit 1
    fi

if [ ! -f "$R_OUTPUT_FOLDER/recommended.zip" ]; then
	./build_recommended.sh $VERSION $BUCKET
fi

check_aws_configured

success "Uploading recommended packages to aws"
aws lambda publish-layer-version --layer-name r-recommended --zip-file fileb://$R_OUTPUT_FOLDER/recommended.zip

aws s3 cp $R_OUTPUT_FOLDER/recommended.zip \
    s3://$BUCKET/R-$VERSION/R-$VERSION.zip || error "Unable to deploy R to bucket $BUCKET"
success "Uploaded R to aws bucket $BUCKET"


success "Uploaded recommended packages to aws"



 