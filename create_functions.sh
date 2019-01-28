BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

VERSION=${1:-}
REGION=${2:-}

ROLE_ARN=${3:-}

RUNTIME_ARN=${4:-}
RECOMENDED_ARN=${5:-}

FUNCTION_ZIP=${6:-}

 


 if [ -z "$VERSION" ];
    then
        error 'VERSION name required'
        exit 1
    fi

 






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


  if [ -z "$RUNTIME_ARN" ];
    then
        error 'RUNTIME_ARN required'
        exit 1
    fi

     if [ -z "$RECOMENDED_ARN" ];
    then
        error 'RECOMENDED_ARN required'
        exit 1
    fi

if [ -z "$FUNCTION_ZIP" ];
    then
        error 'FUNCTION_ZIP required'
        exit 1
    fi
cd $BASE_DIR/example/
chmod 755 matrix.r
zip function.zip matrix.r 

 

aws lambda create-function --function-name r-matrix-example \
    --zip-file fileb://$FUNCTION_ZIP --handler matrix.handler \
    --runtime provided --timeout 60 --memory-size 3008 \
    --layers $RUNTIME_ARN \
        $RECOMENDED_ARN \
    --role $ROLE_ARN --region $REGION




 