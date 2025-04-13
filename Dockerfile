FROM ubuntu:18.04
USER root
RUN apt-get update
RUN apt-get install -y wget net-tools inetutils-ping iptables vim git gcc-8 g++-8 curl

# **bitcoin core install**
# RUN cd / && mkdir src && cd /src &&  git clone https://github.com/Nathenial/bitcoin.git
RUN cd / && mkdir src && cd /src
COPY bitcoin/ /src/bitcoin/
#bitcoin/是本地文件地址，/src/bitcoin/是复制到docker中的地址

# Build requirements
RUN apt-get install -y build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 autoconf
# install the required dependencies
RUN apt-get install -y libevent-dev libboost-dev
# SQLite is required for the descriptor wallet
RUN apt-get install -y libsqlite3-dev
# install Berkeley DB4.8
RUN cd /src/bitcoin && ./contrib/install_db4.sh `pwd`

RUN cd /src/bitcoin && ./autogen.sh
RUN cd /src/bitcoin && CC=gcc-8 CXX=g++-8 ./configure --enable-wallet --disable-tests
RUN cd /src/bitcoin && make && make install && make clean

# ** bfgminer install **
# RUN cd /src && git clone https://github.com/5bNeon/bfgminer.git
COPY bfgminer/ /src/bfgminer/

RUN apt-get install -y build-essential autoconf automake libtool pkg-config libcurl4-gnutls-dev libjansson-dev uthash-dev libncursesw5-dev libudev-dev libusb-1.0-0-dev libevent-dev libmicrohttpd-dev libhidapi-dev pkg-config libgcrypt20-dev yasm
RUN cd /src/bfgminer && git clone https://github.com/bitcoin/libblkmaker.git
RUN cd /src/bfgminer && git clone https://github.com/luke-jr/libbase58.git
RUN cd /src/bfgminer && git clone https://github.com/KnCMiner/knc-asic.git
RUN cd /src/bfgminer && ./autogen.sh
# RUN cd /src/bfgminer && git init && ./autogen.sh
RUN cd /src/bfgminer && ./configure --enable-cpumining
RUN cd /src/bfgminer && make && make install && make clean

# fix error while loading shared libraries: libbase58.so.0: cannot open shared object file: No such file or directory
RUN echo '/usr/local/lib' > /etc/ld.so.conf.d/usrlocal.conf && ldconfig

# 根据实际需要映射端口
EXPOSE 18001 18002 18003


