
FROM debian:jessie

RUN apt-get update
RUN apt-get upgrade

#  net-tools for netstat
RUN apt-get -y install vim less git screen aptitude locate wget sudo time x11-apps libxml2-utils   



# Set HOME
ENV HOME /root
WORKDIR /root

# allow read permissions so tomcat7 can follow symbolic links to various files we will mount 
RUN chmod 755 /root


# ENTRYPOINT /bin/bash
# CMD /bin/bash


# Oracle Java 1.7
# See, # https://github.com/William-Yeh/docker-java7/blob/master/Dockerfile
# add webupd8 repository
# Will create the following links,
# /usr/bin/java -> /etc/alternatives/java
# /etc/alternatives/java -> /usr/lib/jvm/java-7-oracle/jre/bin/java
RUN \
    echo "===> add webupd8 repository..."  && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
    apt-get update  && \
    \
    \
    echo "===> install Java"  && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java7-installer oracle-java7-set-default  && \
    \
    \
    echo "===> clean up..."  && \
    rm -rf /var/cache/oracle-jdk7-installer  && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*


# Tomcat7 (will use Oracle Java 1.7)
RUN apt-get update
RUN apt-get -y install tomcat7

# Maven (will use Oracle Java 1.7)
RUN apt-get -y install maven


# we create credentials symbolic links even if they dont exist yet
# /etc/tomcat7/context.xml
RUN mv /etc/tomcat7/context.xml /etc/tomcat7/context.old.xml \
  && ln -s --force $HOME/docker/context.xml /etc/tomcat7/context.xml

# /etc/default/tomcat7
RUN mv /etc/default/tomcat7 /etc/default/tomcat7.old \
  && ln -s --force $HOME/docker/tomcat7 /etc/default/tomcat7


# postgres driver needed for tomcat jndi
# should we symbolically link, rather than adding? it would take less space?
RUN mkdir /var/lib/tomcat7/lib
ADD postgresql-8.4-701.jdbc3.jar /var/lib/tomcat7/lib/


# IMPORTANT - may also need this flag in /etc/tomcat7/catalina.properties
# tomcat.enable.debug=true

# env pointer to catalina log
ENV C /var/lib/tomcat7/logs/catalina.out


# Install IntelliJ IDEA 
# ultimate.     # http://download.jetbrains.com/idea/ideaIU-14.1.4.tar.gz
# community .   # http://download.jetbrains.com/idea/ideaIC-14.1.4.tar.gz 

RUN wget http://download.jetbrains.com/idea/ideaIU-14.1.4.tar.gz -O /tmp/intellij.tar.gz -q && \
    mkdir -p /opt/intellij && \
    tar -xf /tmp/intellij.tar.gz --strip-components=1 -C /opt/intellij && \
    rm /tmp/intellij.tar.gz



#################

# Customize environment, should be done last, except we want them earlier to resolve issues
# Dotfiles
RUN cd $HOME \
  && git clone https://github.com/julian1/dotfiles \
  && cd $HOME/dotfiles \
  && ./install.sh


# force redeploy update
RUN echo 001



# Clone Geoserver config
RUN cd $HOME \
  && git clone https://github.com/aodn/geoserver-config \
  && chown -R tomcat7:tomcat7 geoserver-config


# link admin credentials for geoserver security
RUN ln -s --force $HOME/docker/users.xml $HOME/geoserver-config/security/usergroup/default/


# pull down jenkins war and deploy
#RUN cd $HOME \
#  && wget --quiet https://jenkins.aodn.org.au/job/geoserver_build/lastSuccessfulBuild/artifact/src/main/target/geoserver-1.0.0-imos.war \
#  && cp $HOME/geoserver-1.0.0-imos.war /var/lib/tomcat7/webapps/geoserver.war



RUN echo "version 001"
ENV GEOTOOLS_BRANCH imos-13.1
# ENV GEOTOOLS_BRANCH imos-master


# Resolve geotools dependencies
# && git pull upstream
RUN cd $HOME \
  && git clone https://github.com/aodn/geotools \
  && cd $HOME/geotools \
  && git remote add upstream http://github.com/geotools/geotools \
  && git fetch upstream \
  && git checkout $GEOTOOLS_BRANCH \
  && time mvn dependency:resolve -Dmaven.test.skip=true 2>&1 \
  | tee resolve.log

# ENV GEOSERVER_BRANCH imos-master
ENV GEOSERVER_BRANCH imos-2.7.1

# must be here to checkit updated branch
RUN echo "whoot2"

# Actually fails... but the subsequent build works.
# Resolve geoserver dependencies
RUN cd $HOME \
  && git clone https://github.com/aodn/geoserver \
  && cd $HOME/geoserver/ \
  && git remote add upstream http://github.com/geoserver/geoserver \
  && git fetch upstream \
  && git checkout $GEOSERVER_BRANCH \
  && cd $HOME/geoserver/src \
  && mvn dependency:resolve -P wps,xslt,ncdfgenerator,layer-filter,csv-with-metadata-header \
  | tee resolve.log



###########
# IMPORTANT the most volatile code should go at the end of the dockerfile, to minimize new image generation

# At least geotools fails tests without this flag
# -Djava.awt.headless=true

# Compile geotools
RUN cd $HOME/geotools \
  && mvn clean install -Dmaven.test.skip=true | tee build.log

# Compile geoserver
RUN cd $HOME/geoserver/src \
  && mvn clean install -P wps,xslt,ncdfgenerator,layer-filter,csv-with-metadata-header -Dmaven.test.skip=true | tee build.log


# compile and run specific geotools unit test
# time  mvn    -Dtest=SubProgressListenerTest      -pl org.geotools:gt-main  test

#
# compile and run specific geoserver unit test
# 2>&1 |  less
# mvn -P wps -Dtest=ExecutionLimitsTest -pl org.geoserver.extension:gs-wps-core test 
# mvn -P wps -Dtest=InputLimitsTest -pl org.geoserver.extension:gs-wps-core test
#
# time mvn install -pl org.geoserver:gs-wcs1_0
#
# - specific module tests
# mvn -pl org.geoserver:gs-wfs  test
# - using geoserver defines to disable a specific test, when building in a module
# time mvn -pl org.geoserver:gs-wfs -Dtest.exclude.pattern="**/*ResourceAccessManagerWFSTest.java" test
#
# time mvn -Dtest.exclude.pattern="**/*ResourceAccessManagerWFSTest.java" TEST

# using the exclude pattern
# mvn install -P wps,xslt,ncdfgenerator,layer-filter,csv-with-metadata-header -Dtest.exclude.pattern="**/wcs/*Test.java"   | tee build.log

#
# continuing from the past failure point
# mvn install -rf wfs

# geotools wps-core test
# mvn test -P wps -pl org.geoserver.extension:gs-wps-core | tee build.log


# mvn  -Dmaven.surefire.debug="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8001 -Xnoagent -Djava.compiler=NONE"  test  -pl org.geoserver:gs-wcs1_0   2>&1 | tee out

### todo - CHECkout the specific versions of geoserver.
# cp /root/.m2/repository/org/geoserver/web/gs-web-app/2.8-SNAPSHOT/gs-web-app-2.8-SNAPSHOT.war tmp/

RUN ln -s /root/geoserver/src/web/app/target/geoserver.war /var/lib/tomcat7/webapps/

### 
# docker run -h somehostname can be used to set the hostname.
# RUN hostname docker-geoserver

# used by screen 
# ENV SHELL /bin/bash


#######################
## sshd 
## http://docs.docker.com/examples/running_ssh_service/ 
RUN apt-get -y install ssh
# set root login pass for ssh
RUN echo 'root:root' | chpasswd
# permit root ssh login
RUN sed -i 's/PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
# for postgres, perl, 
# locale-gen en_AU.UTF-8
# dpkg-reconfigure locales
RUN mkdir /var/run/sshd \
  && chmod 0755 /var/run/sshd
# EXPOSE 22
# should be able to put this in the create, except it's unclear how to pass the 
# argument, to tell sshd not to detach. 
CMD ["/usr/sbin/sshd", "-D"]



# RUN apt-get -y install psmisc 


