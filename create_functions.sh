BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $BASE_DIR/common.sh

VERSION=${1:-}
REGION=${2:-}

ROLE_ARN=${3:-}

version_input_check $VERSION


 if [ -z "$REGION" ];
    then
        error 'region name required'
        exit 1
    fi

     if [ -z "$ROLE_ARN" ];
    then
        error 'Role ARN name required'
        exit 1
    fi


cd $BASE_DIR/example/
chmod 755 matrix.r
zip function.zip matrix.r

 RUNTIME_LAYER_NAME="r-runtime-$VERSION"
 RUNTIME_LAYER_NAME="${RUNTIME_LAYER_NAME//\./_}"

  RECOMENDED_LAYER_NAME="r-recomended-$VERSION"
  RECOMENDED_LAYER_NAME="${RECOMENDED_LAYER_NAME//\./_}"



aws lambda create-function --function-name r-matrix-example \
    --zip-file fileb://function.zip --handler matrix.handler \
    --runtime provided --timeout 60 --memory-size 3008 \
    --layers arn:aws:lambda:$REGION:131329294410:layer:$RUNTIME_LAYER_NAME:1 \
        arn:aws:lambda:eu-central-1:131329294410:layer:$RECOMENDED_LAYER_NAME:1 \
    --role $ROLE_ARN --region $REGION


