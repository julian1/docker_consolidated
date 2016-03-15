
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

RUN apt-get -y install python make gcc g++

RUN apt-get -y install build-essential libgmp-dev libgmp3-dev libcrypto++-dev \
  git automake libtool libleveldb-dev yasm unzip python-all-dev libbz2-dev

RUN apt-get -y install scons libboost-all-dev libv8-dev libjsoncpp-dev libcurl3-dev libmicrohttpd-dev

# needed for libweb3core
RUN apt-get -y install libminiupnpc-dev

# for libjson-rpc-cpp
RUN apt-get -y install libargtable2-dev


RUN git clone https://github.com/mmoss/cryptopp
# TODO test master branch/tag
# cryptopp
RUN cd cryptopp \
  && git checkout 2772f7b \
  && scons --shared --prefix=/usr/local

# cmake
# https://github.com/ethereum/libweb3core/issues/16
# also needed for libjson-rpc-cpp
RUN wget https://cmake.org/files/v3.4/cmake-3.4.0.tar.gz -O $HOME/cmake-3.4.0.tar.gz
RUN tar xf cmake-3.4.0.tar.gz \
  && cd cmake-3.4.0 \
  && ./configure \
  && make \
  && make install


# libjson-rpc
# https://github.com/ethereum/cpp-ethereum/issues/617
# In sid, not jessie
RUN git clone https://github.com/cinemast/libjson-rpc-cpp \
  && cd libjson-rpc-cpp \
  && git checkout tags/v0.6.0 \
  && mkdir -p build \
  && cd build \
  && cmake .. && make \
  && make install \
  && ldconfig


# https://github.com/ethereum/webthree-umbrella/wiki/Building-on-Ubuntu
# https://github.com/ethereum/webthree-umbrella/wiki/Linux--Generic-Building


ENV CPP_BRANCH release

# build third party libraries
RUN git clone https://github.com/ethereum/webthree-helpers \
  && cd webthree-helpers/utils \
  && git checkout $CPP_BRANCH \
  && mkdir build \
  && cd build \
  && cmake .. \
  && make -j 8

# build libweb3core
RUN git clone https://github.com/ethereum/libweb3core
RUN cd libweb3core \
  && git checkout $CPP_BRANCH \
  && mkdir build && cd build && cmake .. && make -j 8


# build libethereum
RUN git clone https://github.com/ethereum/libethereum
# -- ETHASHCL         Build OpenCL components                  ON
# -- EVMJIT  llvm
RUN cd libethereum \
  && git checkout $CPP_BRANCH \
  && mkdir build && cd build && cmake .. -DETHASHCL=0 -DEVMJIT=0 && make -j 8

# build solidity
RUN git clone https://github.com/ethereum/solidity
RUN cd solidity \
  && git checkout $CPP_BRANCH \
  && mkdir build && cd build && cmake .. -DETHASHCL=0 -DEVMJIT=0 && make -j 8

# clone web3.js (needed by webthree)
RUN git clone https://github.com/ethereum/web3.js
RUN cd web3.js \
  && git checkout $CPP_BRANCH

# build webthree
RUN git clone https://github.com/ethereum/webthree
RUN cd webthree \
  && git checkout $CPP_BRANCH \
  && mkdir build && cd build && cmake .. -DETHASHCL=0 -DEVMJIT=0 && make -j 8

# exports
# think symbolically linking would be better
# RUN echo "export PATH=$PATH:$HOME/webthree/build/eth/" >> ~/.bashrc
# RUN echo "export PATH=$PATH:$HOME/solidity/build/solc" >> ~/.bashrc

RUN ln -s $(pwd)/webthree/build/eth/eth /usr/local/bin/ \
  && ln -s $(pwd)/solidity/build/solc/solc /usr/local/bin/ \
  && ln -s $(pwd)/solidity/build/solc/libsoljson.so /usr/local/bin/

###############################


# Go
RUN curl -O https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz \
  && tar -C /usr/local -xzf go1.4.2.linux-amd64.tar.gz \
  && echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc

# Geth
RUN git clone https://github.com/ethereum/go-ethereum

ENV GETH_BRANCH master

RUN cd go-ethereum \
  && git checkout $GETH_BRANCH \
  && export "PATH=$PATH:/usr/local/go/bin" \
  && make

RUN ln -s $(pwd)/go-ethereum/build/bin/geth /usr/local/bin/

# TODO move to start
# RUN apt-get -y install apt-utils
RUN apt-get -y install psmisc


###############################

# npm
RUN curl -sL https://deb.nodesource.com/setup | bash -

# node
RUN apt-get -y install nodejs

# web3 
# TODO use the github web3.js version we already installed for cpp-ethereum
RUN npm install web3

# gulp
# RUN npm install -g gulp

## dont really need this.
# express  
# RUN npm install express body-parser

# websockets
# RUN apt-get -y install python g++ 
# RUN npm install ws

