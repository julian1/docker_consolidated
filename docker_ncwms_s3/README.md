
### Oracle Java 7, Debug Tomcat configuration, and geoserver

### Build image
```
./build 
./create
docker ps -a
docker start ncwms
ssh root@127.0.0.1 -p 23
# change password
start screen etc
docker stop ncwms
```

### Temporarily attach, without stopping container on detach
```
docker exec -it ncwms /bin/bash
```
screen

/etc/init.d/postgresql  start
sudo -u postgres psql -c "create user meteo password 'meteo'"
sudo -u postgres pg_restore /root/docker/harvest.dump -C -d postgres

export DISPLAY=:0


### ssh
ssh -X root@127.0.0.1 -p 23

### Web
```
http://127.0.0.1:8080/ncwms
```



