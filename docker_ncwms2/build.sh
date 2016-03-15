#!/bin/bash -x

/etc/init.d/tomcat7 stop || exit 

echo > /var/lib/tomcat7/logs/catalina.out

ant -Dj2ee.platform.classpath=/usr/share/tomcat7/lib/servlet-api.jar -Dlibs.CopyLibs.classpath=org-netbeans-modules-java-j2seproject-copylibstask.jar 2>&1 | tee ./build.log || exit 

rm -rf /var/lib/tomcat7/webapps/ncwms*   || exit

cp ./dist/ncWMS.war /var/lib/tomcat7/webapps/ncwms.war  -i  || exit

/etc/init.d/tomcat7 start || exit

# less


