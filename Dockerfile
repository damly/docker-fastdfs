FROM centos:7

LABEL maintainer "8051263@qq.com"

ENV FASTDFS_PATH=/opt/fdfs \
    FASTDFS_BASE_PATH=/var/fdfs \
    PORT= \
    GROUP_NAME= \
    TRACKER_SERVER= \
	HTTP_PORT= 

  
#get all the dependences
RUN yum install -y git gcc make pcre pcre-devel openssl openssl-devel zlib zlib-devel

#create the dirs to store the files downloaded from internet
RUN mkdir -p ${FASTDFS_PATH}/libfastcommon \
 && mkdir -p ${FASTDFS_PATH}/fastdfs \
 && mkdir -p ${FASTDFS_PATH}/nginx \
 && mkdir ${FASTDFS_BASE_PATH} 

#compile the libfastcommon
WORKDIR ${FASTDFS_PATH}/libfastcommon

RUN git clone --branch V1.0.36 --depth 1 https://github.com/happyfish100/libfastcommon.git ${FASTDFS_PATH}/libfastcommon \
 && ./make.sh \
 && ./make.sh install \
 && rm -rf ${FASTDFS_PATH}/libfastcommon

#compile the fastdfs
WORKDIR ${FASTDFS_PATH}/fastdfs

RUN git clone --branch V5.11 --depth 1 https://github.com/happyfish100/fastdfs.git ${FASTDFS_PATH}/fastdfs \
 && ./make.sh \
 && ./make.sh install \
 && rm -rf ${FASTDFS_PATH}/fastdfs

#compile the nginx
WORKDIR ${FASTDFS_PATH}/nginx

RUN git clone https://github.com/happyfish100/fastdfs-nginx-module.git ${FASTDFS_PATH}/nginx/fastdfs-nginx-module \
 && git clone --branch tengine-2.1.2 --depth 1 https://github.com/alibaba/tengine.git  ${FASTDFS_PATH}/nginx/tengine \
 && cd ${FASTDFS_PATH}/nginx/tengine \
 && ./configure --prefix=/usr/local/tengine --add-module=${FASTDFS_PATH}/nginx/fastdfs-nginx-module/src/ --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf \
 && make \
 && make install \ 
 && cd ${FASTDFS_PATH} \ 
 && rm -rf ${FASTDFS_PATH}/nginx
 

VOLUME ["$FASTDFS_BASE_PATH", "/etc/fdfs"]   

COPY conf/*.* /etc/fdfs/

COPY start.sh /usr/bin/

#make the start.sh executable 
RUN chmod 777 /usr/bin/start.sh

ENTRYPOINT ["/usr/bin/start.sh"]
CMD ["tracker"]
