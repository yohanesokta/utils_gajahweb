#!/usr/bin/env bash
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <root_directory> <apache_port> [--test]"
    exit 1
fi

PORT=$2
ROOTDIR=$1
CONFIG_FILE=./baseconfig/unix/httpd.conf

CONFIG_SYSTEM_DIR=/opt/runtime/apache/conf
CONFIG_SYSTEM=$CONFIG_SYSTEM_DIR/httpd.conf
CONFIG_BACKUP=$CONFIG_SYSTEM.bak

sed -i "s/__apache_port__/${PORT}/g" $CONFIG_FILE
sed -i "s|__rootdir__|${ROOTDIR}|g" $CONFIG_FILE


if [ "$3" == "--test" ]; then
    echo "Apache configuration test mode. Configuration file located at $CONFIG_FILE"
else
    if [ ! -f $CONFIG_BACKUP ]; then
        sudo rm -rf $CONFIG_BACKUP
    fi

    sudo mv $CONFIG_SYSTEM $CONFIG_BACKUP
    sudo cp $CONFIG_FILE $CONFIG_SYSTEM
fi