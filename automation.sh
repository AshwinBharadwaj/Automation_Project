#!/bin/bash

logger()
{
    local messageType=$1
    local message=$2

    #Defining Colours
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    TIMESTAMP=$(date +%H:%M:%S)
    if [[ "${messageType}" == "ERROR" ]]; then
    {
        COLOR="${RED}"
    }
    elif [[ "${messageType}" == "WARN" ]]; then
    {
        COLOR="${YELLOW}"
    }
    elif [[ "${messageType}" == "SUCCESS" ]]; then
    {
        COLOR="${GREEN}"
    }
    elif [[ "${messageType}" == "INFO" ]]; then
    {
        COLOR="${BLUE}"
    }
    else
    {
        COLOR="${NC}"
    }
    fi
    echo -e "\n$TIMESTAMP: ${COLOR}${messageType}: ${message}${NC}"
}

s3_bucket="upgrad-ashwin"
my_name="Ashwin"
timestamp=$(date '+%d%m%Y-%H%M%S')

logger "INFO" "Updating packages"

sudo apt update -y

isApacheInstalled=$(dpkg --get-selections | grep apache)

if [[ -z $isApacheInstalled ]]; then
	logger "INFO" "Installing apache2"
	sudo apt install apache2 -y
else
	logger "INFO" "Apache is already installed"
fi

isApacheRunning=$(sudo systemctl status apache2)

if [[ $isApacheRunning == *"active (running)"* ]]; then
 	logger "INFO" "process is running"
else 
	logger "WARN" "process is not running"
fi

tar -cvf /tmp/${my_name}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log

logger "INFO" "Uploading archive into S3 - $s3_bucket"

aws s3 \
cp /tmp/${my_name}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${my_name}-httpd-logs-${timestamp}.tar

if [[ $? -eq 0 ]]; then
{
    logger "INFO" "Archive uploaded successfully with the archive name as : ${my_name}-httpd-logs-${timestamp}.tar"
}
else
{
    logger "ERROR" "Uploading archive failed. Check above for error"
}
fi