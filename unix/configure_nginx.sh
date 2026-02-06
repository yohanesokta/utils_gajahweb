#!/usr/bin/env bash

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <root_directory> <nginx_port> [--test]"
    exit 1
fi

PORT=$2
ROOTDIR=$1
CONFIG_FILE=./baseconfig/nginx/nginx.conf
CONFIG_SYSTEM=/etc/nginx/nginx.conf
CONFIG_BACKUP=/etc/nginx/nginx.conf.bak
sed -i "s/__nginx_port__/${PORT}/g" $CONFIG_FILE
sed -i "s|__rootdir__|${ROOTDIR}|g" $CONFIG_FILE

if [ "$3" == "--test" ]; then
    echo "Nginx configuration test mode. Configuration file located at $CONFIG_FILE"
else
    if [ ! -f $CONFIG_BACKUP ]; then
        sudo rm -rf $CONFIG_BACKUP
    fi
    
    sudo mv $CONFIG_SYSTEM $CONFIG_BACKUP
    sudo cp $CONFIG_FILE $CONFIG_SYSTEM
fi