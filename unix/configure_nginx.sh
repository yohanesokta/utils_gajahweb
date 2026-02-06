#!/usr/bin/env bash

PORT=$2
ROOTDIR=$1
sed -i "s/__nginx_port__/${PORT}/g" ./baseconfig/nginx.conf
sed -i "s|__rootdir__|${ROOTDIR}|g" ./baseconfig/nginx.conf

if [ "$3" == "--test" ]; then
    echo "Nginx configuration test mode. Configuration file located at ./baseconfig/nginx.conf"
else
    cp ./baseconfig/nginx.conf /etc/nginx/sites-available/default
fi