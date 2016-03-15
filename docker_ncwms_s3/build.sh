#!/bin/bash -x

/etc/init.d/tomcat7 stop || exit 


rm /tmp/ncwms/* &> /dev/null
rm /var/lib/tomcat7/logs/*
rm -rf /var/lib/tomcat7/webapps/ncwms* 

#   && rm -rf build dist \
# build
cd $HOME/ncwms \
  && ant -Dj2ee.platform.classpath=/usr/share/tomcat7/lib/servlet-api.jar -Dlibs.CopyLibs.classpath=./org-netbeans-modules-java-j2seproject-copylibstask.jar 2>&1 | tee ./build.log \
  || exit

ln -s $HOME/ncwms/dist/ncWMS.war /var/lib/tomcat7/webapps/ncwms.war || exit


##### start tomcat
/etc/init.d/tomcat7 start || exit

# tail is better than less here, 
# tail -f /var/lib/tomcat7/logs/catalina.out
less /var/lib/tomcat7/logs/catalina.out



