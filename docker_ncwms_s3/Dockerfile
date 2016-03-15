
FROM debian:jessie

RUN apt-get -y update
RUN apt-get -y upgrade

# 
RUN apt-get -y install vim less git screen aptitude locate wget sudo time x11-apps libxml2-utils net-tools s3cmd unzip netcdf-bin



# Set HOME
ENV HOME /root
WORKDIR /root

# allow read permissions so tomcat7 can follow symbolic link to various files
RUN chmod 755 /root


#######################
# Customize environment, should be done last
# Dotfiles
RUN cd $HOME \
  && git clone https://github.com/julian1/dotfiles \
  && cd $HOME/dotfiles \
  && ./install.sh


#######################
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

#######################
# Tomcat7 (will use Oracle Java 1.7)
RUN apt-get update
RUN apt-get -y install tomcat7
RUN apt-get -y install tomcat7-admin


# postgres driver needed for tomcat jndi
# should we symbolically link, rather than adding? it would take less space?
RUN mkdir /var/lib/tomcat7/lib
ADD postgresql-8.4-701.jdbc3.jar /var/lib/tomcat7/lib/


# we create credentials symbolic links even if they dont exist yet
# /etc/tomcat7/context.xml
RUN mv /etc/tomcat7/context.xml /etc/tomcat7/context.old.xml \
  && ln -s --force $HOME/docker/context.xml /etc/tomcat7/context.xml

# /etc/default/tomcat7
RUN mv /etc/default/tomcat7 /etc/default/tomcat7.old \
  && ln -s --force $HOME/docker/tomcat7 /etc/default/tomcat7

# Tomcat Admin and gui
RUN  mv /etc/tomcat7/tomcat-users.xml /etc/tomcat7/tomcat-users.xml.old \ 
  && ln -s --force /root/docker/tomcat-users.xml /etc/tomcat7/tomcat-users.xml


# env pointer to catalina log
ENV C /var/lib/tomcat7/logs/catalina.out


#######################
# Install IntelliJ IDEA 
# ultimate.     # http://download.jetbrains.com/idea/ideaIU-14.1.4.tar.gz
# community .   # http://download.jetbrains.com/idea/ideaIC-14.1.4.tar.gz 

RUN wget http://download.jetbrains.com/idea/ideaIU-14.1.4.tar.gz -O /tmp/intellij.tar.gz -q && \
    mkdir -p /opt/intellij && \
    tar -xf /tmp/intellij.tar.gz --strip-components=1 -C /opt/intellij && \
    rm /tmp/intellij.tar.gz

# dependency for intellij, 
RUN apt-get -y install libxtst6


#######################
# Postgres
RUN apt-get -y install locales-all
RUN apt-get -y install postgresql-9.4


#######################

# ant build tool
RUN apt-get -y install ant

# RUN echo "force-update-124"

# checkout ncwms devel branch
RUN cd $HOME \
  && git clone http://github.com/julian1/ncwms \
  && cd ncwms \
  && git checkout origin/develop

#  && git checkout mock

# lib dep, not inside the ncwms dir, because it's an external dependency
#ADD org-netbeans-modules-java-j2seproject-copylibstask.jar $HOME/


# must delete build directory, or .class files left lying about, will get incorporated into the build war...
# build
RUN cd $HOME/ncwms \
  && rm -rf build dist \ 
  && ant -Dj2ee.platform.classpath=/usr/share/tomcat7/lib/servlet-api.jar -Dlibs.CopyLibs.classpath=./org-netbeans-modules-java-j2seproject-copylibstask.jar 2>&1 | tee ./build.log

#  && ant -Dj2ee.platform.classpath=/usr/share/tomcat7/lib/servlet-api.jar -Dlibs.CopyLibs.classpath=org-netbeans-modules-java-j2seproject-copylibstask.jar 2>&1 | tee ./build.log

# deploy
RUN ln -s $HOME/ncwms/dist/ncWMS.war /var/lib/tomcat7/webapps/ncwms.war


# config dir (should move outside deploy dir? path is set in /WEB-INF/WMS-servlet.xml)
RUN mkdir /usr/share/tomcat7/.ncWMS \
  && chown tomcat7:tomcat7 /usr/share/tomcat7/.ncWMS

# start and stop, to generate default config
#RUN /etc/init.d/tomcat7 start \
#  && /etc/init.d/tomcat7 stop

# example config example
# ADD config.xml /usr/share/tomcat7/.ncWMS/
RUN ln -s --force $HOME/docker/config.xml /usr/share/tomcat7/.ncWMS/

# link credentials file
RUN ln -s --force $HOME/docker/aws_credentials /usr/share/tomcat7/credentials


# dir for cached netcdf files
#RUN mkdir /tmp/ncwms \
#  && chown tomcat7:tomcat7 /tmp/ncwms

# Important. There seems to be a bug, that if ncwms cannot write the config.xml with the 
# variables then it will continue to do another pass.

# apt-get install file netcdf-bin


# used by screen 
ENV SHELL /bin/bash


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


# RUN hostname docker-ncwms-s3

