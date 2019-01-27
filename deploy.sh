#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $BASE_DIR/common.sh

VERSION=${1:-}
BUCKET=${2:-}
RGION=${3:-}
version_input_check $VERSION

 if [ -z "$BUCKET" ];
    then
        error 'bucket name required'
        exit 1
    fi
 if [ -z "$RGION" ];
    then
        error 'region name required'
        exit 1
    fi

 

function releaseToRegion {
    version=$1
    region=$2
    layer=$3
    bucket=$4
    resource="R/$region/$VERSION/$layer.zip"
    layer_name="r-$layer-$version"
    layer_name="${layer_name//\./_}"
    information "Copying layer $layer_name to bucket $bucket in region $region"
    aws s3 cp $R_OUTPUT_FOLDER/$layer-$VERSION.zip s3://$bucket/$resource --region $region
    response=$(aws lambda publish-layer-version --layer-name $layer_name \
        --content S3Bucket=$bucket,S3Key=$resource --region $region)
    version_number=$(jq -r '.Version' <<< "$response")

    information "Layer $layer_name copied to bucket $bucket in region $region \n"

    information "Publishing $layer_name to region $region \n"
    aws lambda add-layer-version-permission --layer-name $layer_name \
        --version-number $version_number --principal "*" \
        --statement-id publish --action lambda:GetLayerVersion \
        --region $region
    layer_arn=$(jq -r '.LayerVersionArn' <<< "$response")
    information "Published layer $layer_arn \n"
}

regions=(us-east-1 ap-south-1 ca-central-1 eu-central-1 sa-east-1)


source $BASE_DIR/build_r_and_publish.sh $1 $2
source $BASE_DIR/build_recommended.sh $1
source $BASE_DIR/build_runtime.sh $1

for region in "${regions[@]}"
do
   releaseToRegion $VERSION $region  runtime  $BUCKET
   releaseToRegion $VERSION $region recommended  $BUCKET
done
