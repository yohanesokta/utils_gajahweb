#!/usr/bin/env bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <root_directory> <nginx_port> [--test]"
    exit 1
fi

PORT=$2
ROOTDIR=$1
CONFIG_FILE=/opt/runtime/utils/baseconfig/unix/nginx.conf
CONFIG_SYSTEM=/etc/nginx/nginx.conf
CONFIG_BACKUP=/etc/nginx/nginx.conf.bak

# Default values for new parameters
PHP_PORT=${PHP_PORT:-9000}
LOG_DIR=${LOG_DIR:-/var/log/nginx}
TEMP_DIR=${TEMP_DIR:-/tmp}

sed -i "s/__nginx_port__/${PORT}/g" $CONFIG_FILE
sed -i "s|__rootdir__|${ROOTDIR}|g" $CONFIG_FILE
sed -i "s|__PHP_PORT__|${PHP_PORT}|g" $CONFIG_FILE
sed -i "s|__LOG_DIR__|${LOG_DIR}|g" $CONFIG_FILE
sed -i "s|__TEMP_DIR__|${TEMP_DIR}|g" $CONFIG_FILE

if [ "$3" == "--test" ]; then
    echo "Nginx configuration test mode. Configuration file located at $CONFIG_FILE"
else
    # Remove existing backup if it exists to allow mv to succeed
    if [ -f "$CONFIG_BACKUP" ]; then
        sudo rm -f "$CONFIG_BACKUP"
    fi

    if [ -f "$CONFIG_SYSTEM" ]; then
        sudo mv "$CONFIG_SYSTEM" "$CONFIG_BACKUP"
    fi
    sudo cp "$CONFIG_FILE" "$CONFIG_SYSTEM"
fi