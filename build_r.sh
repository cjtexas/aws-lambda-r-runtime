 #!/bin/bash
source ./common.sh

VERSION=${1:-}

version_input_check $VERSION

information "Building R"

R_OUTPUT_FOLDER="/opt/R-package-out"
R_SOURCE_FOLDER=${R_OUTPUT_FOLDER}/R-$VERSION


if [ -d "${R_SOURCE_FOLDER}" ]; then
  	rm -rf $R_SOURCE_FOLDER
fi
	sudo mkdir -p $R_SOURCE_FOLDER || error "Unable to create folder ${R_SOURCE_FOLDER}"

 
 
if [ ! -f "${R_OUTPUT_FOLDER}/R-$VERSION.tar.gz" ]; then
	install_if_not_exists "wget"
	information "downloading R package"
	wget https://cran.uni-muenster.de/src/base/R-3/R-$VERSION.tar.gz -O  "${R_OUTPUT_FOLDER}/R-$VERSION.tar.gz"
else
	information "R package already downloaded"
fi



install_if_not_exists "tar"

TMP=$(mktemp -d)
sudo chown $(whoami) ${R_SOURCE_FOLDER}
tar -xf $R_OUTPUT_FOLDER/R-$VERSION.tar.gz -C $TMP


mv $TMP/R-$VERSION/* $R_SOURCE_FOLDER

rm -rf $TMP
 
libs=( git file wget make zip readline-devel xorg-x11-server-devel libX11-devel libXt-devel curl-devel gcc-c++ gcc-gfortran zlib-devel bzip2 bzip2-libs bzip2-devel xz-devel pcre-devel openssl-devel libxml2-devel )
install_libs $libs




information "Require libs  installed \n\n"
 


# workaround for making R build work
# issue seems similar to https://stackoverflow.com/questions/40639138/configure-error-installing-r-3-3-2-on-ubuntu-checking-whether-bzip2-support-suf
 
cd ${R_SOURCE_FOLDER}
Infortmation "Installing Dev tools"
yum groupinstall "Development Tools"

./configure --prefix=$R_SOURCE_FOLDER --exec-prefix=$R_SOURCE_FOLDER --with-libpth-prefix=/opt/	

make -j
cp /usr/lib64/libgfortran.so.4 lib/
cp /usr/lib64/libgomp.so.1 lib/
cp /usr/lib64/libquadmath.so.0 lib/
cp /usr/lib64/libstdc++.so.6 lib/
./bin/Rscript -e 'chooseCRANmirror(graphics=FALSE, ind=34); install.packages("httr")'
./bin/Rscript -e 'chooseCRANmirror(graphics=FALSE, ind=34); install.packages("aws.s3")'
./bin/Rscript -e 'chooseCRANmirror(graphics=FALSE, ind=34); install.packages("rjson")'
./bin/Rscript -e 'chooseCRANmirror(graphics=FALSE, ind=34); install.packages("devtools")'
./bin/Rscript -e 'chooseCRANmirror(graphics=FALSE, ind=34); devtools::install_github("twitter/AnomalyDetection")'



zip -r $R_OUTPUT_FOLDER/R-compiled-$VERSION.zip bin/ lib/ lib64/ etc/ library/ doc/ modules/ share/


success "R zip located at $R_OUTPUT_FOLDER/R-compiled-$VERSION.zip"