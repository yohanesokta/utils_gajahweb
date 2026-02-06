#!/bin/bash
if [ "$1" = "start" ]; then
	echo "Starting..."
	sudo systemctl start nginx
	BASE_DIR=$(cd "$(dirname "$0")" && pwd)
	export LD_LIBRARY_PATH="$BASE_DIR/lib:$LD_LIBRARY_PATH"
	exec "$BASE_DIR/php/bin/php-cgi" \
	  -d session.save_path=/opt/runtime/php/session \
	  -b 127.0.0.1:9000 \
	  -c "$BASE_DIR/php/etc/php.ini"
elif [ "$1" = "stop" ]; then
	echo "Stoping..."
	sudo systemctl stop nginx
	pkill php-cgi
else
	echo "Command Not Found"
fi
