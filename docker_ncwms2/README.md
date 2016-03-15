
### Oracle Java 7, Debug Tomcat configuration, and ncwms2

### Build image
```
# perhaps edit dotfiles in Dockerfile
./build 

```
### 
```
copy opendap data, into docker container
```

### Run container, and start tomcat
```
./run
# /etc/init.d/tomcat7 start

```

### Web
```
http://127.0.0.1:8080/ncwms
```

### Debug
```
jnx debug on 8000
```




