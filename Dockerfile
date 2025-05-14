FROM ubuntu:14

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    wget unzip git build-essential pkg-config autotools-dev autoconf libtool \
    libssl-dev libboost-all-dev libevent-dev python3

WORKDIR /opt

RUN git clone https://github.com/luiselzate/luckycoin_1.8 && \
    cd luckycoin_1.8 && \
    wget http://download.oracle.com/berkeley-db/db-5.1.29.NC.tar.gz && \
    tar -xzvf db-5.1.29.NC.tar.gz && \
    mkdir -p db5 && \
    cd db-5.1.29.NC/build_unix && \
    ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=/opt/luckycoin_1.8/db5 && \
    make install && \
    cd /opt/luckycoin_1.8 && \
    ./autogen.sh && \
    ./configure LDFLAGS="-L/opt/luckycoin_1.8/db5/lib/" CPPFLAGS="-I/opt/luckycoin_1.8/db5/include/" && \
    make && \
    cp src/luckycoind /usr/local/bin/luckycoind && \
    cp src/luckycoin-cli /usr/local/bin/luckycoin-cli

RUN mkdir -p /root/.luckycoin

# Optional: mount your config file or copy it
# COPY ./luckycoin.conf /root/.luckycoin/luckycoin.conf

EXPOSE 9917

CMD ["luckycoind", "-conf=/root/.luckycoin/luckycoin.conf", "-datadir=/root/.luckycoin"]
