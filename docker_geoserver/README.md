
### Oracle jdk7, debug Tomcat configuration + Intelij, Geotools and Geoserver + profiles, geoserver-config

### Build image
```
./build
```

### Create container
```
./create
```

### Run
```

Edit jndi connection parameters in context.xml, which is symbolically linked into tomcat configuation.

docker start geoserver
docker ps -a

ssh root@127.0.0.1 -p 24
/etc/init.d/tomcat7 start

start intelij etc
```

### Web
```
http://localhost:8080/geoserver
```

