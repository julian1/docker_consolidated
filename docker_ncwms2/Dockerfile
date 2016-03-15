
FROM debian:jessie

RUN apt-get -y update
RUN apt-get -y upgrade

#  s3cmd
RUN apt-get -y install vim less git screen aptitude locate wget sudo time x11-apps libxml2-utils net-tools curl


# Set HOME
ENV HOME /root
WORKDIR /root

# allow read permissions so tomcat7 can follow symbolic link to various files
RUN chmod 755 /root

# Customize environment, should be done last
# Dotfiles
RUN cd $HOME \
  && git clone https://github.com/julian1/dotfiles \
  && cd $HOME/dotfiles \
  && ./install.sh



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

# Actually don't really need tomcat...
# Except to demonstrate production configuration

# Tomcat7 (will use Oracle Java 1.7)
RUN apt-get update
RUN apt-get -y install tomcat7


# we create credentials symbolic links even if they dont exist yet
# /etc/tomcat7/context.xml
RUN mv /etc/tomcat7/context.xml /etc/tomcat7/context.old.xml \
  && ln -s --force $HOME/docker/context.xml /etc/tomcat7/context.xml

# /etc/default/tomcat7
RUN mv /etc/default/tomcat7 /etc/default/tomcat7.old \
  && ln -s --force $HOME/docker/tomcat7 /etc/default/tomcat7


# postgres driver needed for tomcat jndi
# RUN mkdir /var/lib/tomcat7/lib
# ADD postgresql-8.4-701.jdbc3.jar /var/lib/tomcat7/lib/


# env pointer to catalina log
ENV C /var/lib/tomcat7/logs/catalina.out

#################


# Maven (will use Oracle Java 1.7)
RUN apt-get -y install maven



# checkout ncwms devel branch
RUN cd $HOME \
  && git clone https://github.com/aodn/edal-java \
  && cd edal-java \
  && git checkout master


# Build ncwms,
# Branch, # c351160bc
#  -Dmaven.test.skip=true
# get maven deps downloaded...
RUN cd $HOME/edal-java \
  && mvn clean install 2>&1 | tee build.log


# tomcat webapps location
ENV W /var/lib/tomcat7/webapps/

# link compiled executable
RUN ln -s /root/edal-java/ncwms/target/ncWMS2.war $W/ncwms.war

# Admin users
RUN ln -s --force /root/docker/tomcat-users.xml /etc/tomcat7/tomcat-users.xml


# ncwms config location
ENV N /usr/share/tomcat7/.ncWMS2/

# make ncwms config location
RUN mkdir $N \
  && chown -R tomcat7:tomcat7 $N  \
  && chmod 777 $N

# ncwms config
RUN ln -s --force /root/docker/config.xml $N/

# ncwms data
RUN ln -s --force /root/docker/opendap /mnt/


# let tomcat have root, which allows us to avoid changing permissions
# on files that are symbolically linked but don't yet exist
#RUN sed -i '/tomcat7/d' /etc/passwd \
#  && echo 'tomcat7:x:0:0::/usr/share/tomcat7:/bin/false' >> /etc/passwd

# we can't symbolically link, because need to change owner to tomcat, but it doesn't exist yet
# ncwms config
# RUN ln -s --force /root/docker/config.xml $N/
# ADD config.xml $N

# It would be much nicer if this could be linked dynamically...
# RUN chown tomcat7:tomcat7 $N/config.xml


