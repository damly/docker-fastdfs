#!/bin/bash
#set -e

http_port="8080"

if [ "$1" = "storage" ] ; then
FASTDFS_MODE="storage"
else 
FASTDFS_MODE="tracker"
fi

if [ -n "$PORT" ] ; then  
sed -i "s|^port=.*$|port=${PORT}|g" /etc/fdfs/"$FASTDFS_MODE".conf
fi

if [ -n "$TRACKER_SERVER" ] ; then  

sed -i "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/storage.conf
sed -i "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/client.conf
sed -i "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/mod_fastdfs.conf
fi

if [ -n "$GROUP_NAME" ] ; then  

sed -i "s|group_name=.*$|group_name=${GROUP_NAME}|g" /etc/fdfs/storage.conf
sed -i "s|group_name=.*$|group_name=${GROUP_NAME}|g" /etc/fdfs/mod_fastdfs.conf

fi 

if [ -n "$HTTP_PORT" ] ; then  

http_port = ${HTTP_PORT}

fi

sed -i "s|http.server_port=.*$|http.server_port=${http_port}|g" /etc/fdfs/storage.conf

echo "

worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;

    keepalive_timeout  65;

    server {
        listen       ${http_port};
        server_name  localhost;


        location ~/group([0-9])/M00 {
            ngx_fastdfs_module;
        }

        location / {
            root   html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}

" > /etc/nginx/nginx.conf


FASTDFS_LOG_FILE="${FASTDFS_BASE_PATH}/logs/${FASTDFS_MODE}d.log"
PID_NUMBER="${FASTDFS_BASE_PATH}/data/fdfs_${FASTDFS_MODE}d.pid"

echo "try to start the $FASTDFS_MODE node..."
if [ -f "$FASTDFS_LOG_FILE" ]; then 
	rm "$FASTDFS_LOG_FILE"
fi
# start the fastdfs node.	
fdfs_${FASTDFS_MODE}d /etc/fdfs/${FASTDFS_MODE}.conf start

# wait for pid file(important!),the max start time is 5 seconds,if the pid number does not appear in 5 seconds,start failed.
TIMES=5
while [ ! -f "$PID_NUMBER" -a $TIMES -gt 0 ]
do
    sleep 1s
	TIMES=`expr $TIMES - 1`
done

if [ "$1" = "storage" ] ; then
ln -s /var/fdfs/data/ /var/fdfs/data/M00
/usr/sbin/nginx -c /etc/nginx/nginx.conf
fi

# if the storage node start successfully, print the started time.
# if [ $TIMES -gt 0 ]; then
#     echo "the ${FASTDFS_MODE} node started successfully at $(date +%Y-%m-%d_%H:%M)"
	
# 	# give the detail log address
#     echo "please have a look at the log detail at $FASTDFS_LOG_FILE"

#     # leave balnk lines to differ from next log.
#     echo
#     echo

    
	
# 	# make the container have foreground process(primary commond!)
#     tail -F --pid=`cat $PID_NUMBER` /dev/null
# # else print the error.
# else
#     echo "the ${FASTDFS_MODE} node started failed at $(date +%Y-%m-%d_%H:%M)"
# 	echo "please have a look at the log detail at $FASTDFS_LOG_FILE"
# 	echo
#     echo
# fi

tail -f "$FASTDFS_LOG_FILE"
