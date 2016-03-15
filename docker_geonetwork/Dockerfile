
# FROM ubuntu:14.04
# ubuntu has go 1.2 which fails, sid 1.4
# https://github.com/linkeddata/gold/issues/34
# http://www.hostingadvice.com/how-to/install-golang-on-ubuntu/

# FROM debian:sid
FROM debian:jessie

RUN echo "building"

RUN apt-get -y update
RUN apt-get -y upgrade


# Set HOME
ENV HOME /root
WORKDIR /root

RUN chmod 755 /root

###############################

# My environment
# RUN apt-get -y install vim less git screen aptitude locate wget sudo time x11-apps libxml2-utils
RUN apt-get -y install vim less git screen aptitude locate wget sudo time net-tools curl

# Dotfiles
RUN git clone https://github.com/julian1/dotfiles \
  && cd dotfiles \
  && ./install.sh


###############################
# postgres
# do it here because it's expensive
RUN apt-get -y install postgresql-9.4-postgis-2.1



###############################
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
RUN apt-get -y update
RUN apt-get -y install tomcat7

# Maven (will use Oracle Java 1.7)
# RUN apt-get -y install maven


# we create credentials symbolic links even if they dont exist yet
# /etc/tomcat7/context.xml
RUN mv /etc/tomcat7/context.xml /etc/tomcat7/context.old.xml \
  && ln -s --force $HOME/docker/context.xml /etc/tomcat7/context.xml

# /etc/default/tomcat7
RUN mv /etc/default/tomcat7 /etc/default/tomcat7.old \
  && ln -s --force $HOME/docker/tomcat7 /etc/default/tomcat7


# postgres driver needed for tomcat jndi
# should we symbolically link, rather than adding? it would take less space?

ENV T /var/lib/tomcat7

# geonetwork wants to write lock files...
RUN chown -R tomcat7:tomcat7 $T


RUN mkdir $T/lib
COPY postgresql-9.1-901.jdbc4.jar $T/lib/
COPY postgis-jdbc-1.3.3.jar $T/lib/


# IMPORTANT - may also need this flag in /etc/tomcat7/catalina.properties
# tomcat.enable.debug=true

#################


# less /root/docker/create_db.sql
# permissions as postgres
# RUN cat /root/docker/create_db.sql && /etc/init.d/postgresql start && sudo -u postgres psql -f /root/docker/create_db.sql

# we don't symbolically link, because linked file will not be available during build
COPY db.sql $HOME/
RUN /etc/init.d/postgresql start && sudo -u postgres psql -f $HOME/db.sql


RUN wget http://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v3.0.2/geonetwork.war/download -O $T/webapps/geonetwork.war


RUN apt-get -y install unzip

# TODO permissions?
RUN cd $T/webapps/ && unzip geonetwork.war -d geonetwork && chown -R tomcat7:tomcat7 geonetwork



# port mapping, is easier to 

# it would be nicer if the config-overides were outside webapps so that 

# COPY overrides $T/overrides/


# actually might be better to link in symbolically if we pull it from repository
# RUN mkdir $T/geonetwork && chown tomcat7:tomcat7 $T/geonetwork 

# RUN ln -s --force $HOME/docker/geonetwork $T/
# must be able to write the data-directory or the db won't get populated


ENV C $T/logs/catalina.out


# overrides can be symbolic
RUN ln -s --force $HOME/docker/overrides $T/


COPY geonetwork_data $T/geonetwork_data
RUN chown -R tomcat7:tomcat7 $T/geonetwork_data


# should be done with config-overrides                                                                            
COPY srv.xml $T/webapps/geonetwork/WEB-INF/config-node/srv.xml
COPY jndi-postgres-postgis.xml $T/webapps/geonetwork/WEB-INF/config-db/jndi-postgres-postgis.xml 


# start postgres then tomcat then,
# RUN sudo -u postgres psql -d geonetwork -c '\d'


