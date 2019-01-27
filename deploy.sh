#!/bin/bash

set -euo pipefail

VERSION=${1:-}
BUCKET=${2:-}
REGION=${3:-}


 if [ -z "$VERSION" ];
    then
        error 'VERSION name required'
        exit 1
    fi

 if [ -z "$BUCKET" ];
    then
        error 'bucket name required'
        exit 1
    fi
 if [ -z "$REGION" ];
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
    echo "Copying layer $layer_name to bucket $bucket in region $region"
    aws s3 cp /opt/R/$layer.zip s3://$bucket/$resource --region $region
    response=$(aws lambda publish-layer-version --layer-name $layer_name \
        --content S3Bucket=$bucket,S3Key=$resource --region $region)
    echo $response > /opt/R/R-$region-$VERSION-$layer-response.txt
    
    version_number=$(jq -r '.Version' <<< "$response")

    echo "Layer $layer_name copied to bucket $bucket in region $region \n"

    echo "Publishing $layer_name to region $region \n"
    aws lambda add-layer-version-permission --layer-name $layer_name \
        --version-number $version_number --principal "*" \
        --statement-id publish --action lambda:GetLayerVersion \
        --region $region

    layer_arn=$(jq -r '.LayerVersionArn' <<< "$response")
    echo "Published layer $layer_arn \n"
}
 
releaseToRegion $VERSION $REGION  runtime  $BUCKET
releaseToRegion $VERSION $REGION recommended  $BUCKET