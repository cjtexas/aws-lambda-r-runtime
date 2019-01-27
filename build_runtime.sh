source ./common.sh

VERSION=${1:-}

version_input_check $VERSION

information "Building Runtime"


if [ -d "$R_OUTPUT_FOLDER/$VERSION/runtime" ]; then
  	rm -rf $R_OUTPUT_FOLDER/$VERSION/runtime
fi
	sudo mkdir -p $R_OUTPUT_FOLDER/$VERSION/runtime || error "Unable to create folder $R_OUTPUT_FOLDER/$VERSION/runtime"


R_COMPILED_ZIP=$R_OUTPUT_FOLDER/R-compiled-$VERSION.zip


if [ ! -f "$R_COMPILED_ZIP" ]; then
	./build_r.sh $VERSION 
fi



cd $R_OUTPUT_FOLDER/$VERSION/runtime

mkdir -p R

unzip -q $R_COMPILED_ZIP -d R/
rm -r R/doc/manual/
#remove some libraries to save space
recommended=(boot class cluster codetools foreign KernSmooth lattice MASS Matrix mgcv nlme nnet rpart spatial survival AnomalyDetection)
for package in "${recommended[@]}"
do
    rm -r R/library/$package/
done

cp $BASE_DIR/bootstrap .
cp $BASE_DIR/runtime.r .

chmod -R 755 bootstrap runtime.r R/

zip -r -q $R_OUTPUT_FOLDER/runtime.zip runtime.r bootstrap R/

success "Runtime package zip located at $R_OUTPUT_FOLDER/runtime.zip"