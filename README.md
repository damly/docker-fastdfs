# FastDFS Docker

Usage:
```
docker run -dti --network=host --name tracker -v /var/fdfs/tracker:/var/fdfs docker-fdfs tracker

docker run -dti --network=host --name storage0 -e TRACKER_SERVER=192.168.31.111:22122 -v /var/fdfs/storage0:/var/fdfs docker-fdfs storage

docker run -dti --network=host --name storage1 -e TRACKER_SERVER=192.168.31.111:22122  -v /var/fdfs/storage1:/var/fdfs docker-fdfs storage

docker run -dti --network=host --name storage2 -e TRACKER_SERVER=192.168.31.111:22122 -e GROUP_NAME=group2 -e PORT=22222 -v /var/fdfs/storage2:/var/fdfs docker-fastdfs storage
```


docker run --restart=always //自动重启

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker images
docker rmi docker-fdfs
docker build -t docker-fdfs .
docker run -dti --network=host  -v /var/fdfs/tracker:/var/fdfs docker-fdfs   /bin/bash
docker attach <ContainerID>
