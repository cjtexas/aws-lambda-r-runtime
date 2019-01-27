#!/bin/bash

set -euo pipefail 
export MAKEFLAGS=-j$(($(grep -c ^processor /proc/cpuinfo) - 0))
export PATH="~/.local/bin:$PATH"

R_OUTPUT_FOLDER="/opt/R-package-out"
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


sudo mkdir -p $R_OUTPUT_FOLDER

check_aws_configured()
{

    command -v pip >/dev/null || (information "installing pip" && curl -s "https://bootstrap.pypa.io/get-pip.py" -o get-pip.py && (python get-pip.py || error "unable to install pip"))
    command -v  aws >/dev/null ||(information "installing aws cli"  &&  (pip install awscli --upgrade --user || error "unable to install awscli"))   
    if [ ! -f "/root/.aws/credentials" ]; then
        aws configure || error "unable to configure aws"
    fi
     
   
}

function install_if_not_exists()
{
    IN=${1:-}
    command -v $IN >/dev/null || (information "installing $IN" &&  (yum -y install $IN || error "unable to install $IN"))
}
version_input_check()
{
    VERSION=${1:-}

    if [ -z "$VERSION" ];
    then
        error 'version number required'
        exit 1
    fi
 }
cecho() {

    declare -a colors_i
    local color_black='\E[0;47m'
    local color_red='\E[0;31m'
    local color_green='\E[0;32m'
    local color_yellow='\E[0;33m'
    local color_blue='\E[0;34m'
    local color_magenta='\E[0;35m'
    local color_cyan='\E[0;36m'
    local color_white='\E[0;37m'

    local defaultMSG="No message passed."
    local defaultColor="black"
    local defaultNewLine=true

    while [[ $# -gt 1 ]]; do
        key="$1"

        case $key in
        -c | --color)
            color="$2"
            shift
            ;;
        -n | --noline)
            newLine=false
            ;;
        *)
            # unknown option
            ;;
        esac
        shift
    done

    message=${1:-$defaultMSG}
    color=${color:-$defaultColor}
    newLine=${newLine:-$defaultNewLine}

    color_name="color_$color"
    color_name="${!color_name}"
    echo -en "$color_name"
    echo -en "$message"
    if [ "$newLine" = true ]; then
        echo
    fi
    tput sgr0

    return
}

warning() {
    IN1=${1:-}
    IN2=${2:-}
    cecho -c 'yellow' "$IN1"
    log_debug "warning" "$IN1" "$IN2"

}

error() {
    IN1=${1:-}
     IN2=${2:-}

    cecho -c 'red' "$IN1"
    log_debug "error" "$IN1" "$IN2"
    exit 1

}

information() {
IN1=${1:-}
    IN2=${2:-}
    cecho -c 'blue' "$IN1"
    log_debug "info" "$IN1" "$IN2"
}

success() {
IN1=${1:-}
    IN2=${2:-}
    cecho -c 'green' "$IN1"
    log_debug "success" "$IN1" "$IN2"
}


is_true() {
     IN1=${1:-}
    if [ "$IN1" = true ] || [ "$IN1" = "true" ] || [ "$IN1" = "1" ] || [ "$IN1" = 1 ]; then

        return 1
    fi
    return 0

}
is_debug() {

     DEBUG=${DEBUG:-}

    return $(is_true $DEBUG)
}

log_debug() {
    return 
    IN1=${1:-}
    IN2=${2:-}
     IN3=${3:-}

     LOG_FILE=${LOG_FILE:-}

      if [ -z "$LOG_FILE" ]; then
        LOG_FILE="log.txt"
    fi

    msg=""
    if [ -z "$IN2" ]; then
        return
    fi

    if is_debug; then
        msg="($IN1)==> $IN2"
    fi
    if [ ! -z "$IN3" ]; then

        msg="$msg: $IN3"
    fi
    echo $msg >>$LOG_FILE
}

function install_libs()
{
     IN1=${1:-}
     for lib in "${IN1[@]}"
    do
        echo  "Installing $lib"
       sudo yum -y install $lib 
    done
}