FROM debian:latest

RUN apt-get install build-essential pkg-config && \
    apt-get install libtool autotools-dev autoconf automake && \
    apt-get install libssl-dev

RUN apt-get update && \
    apt-get install -y wget unzip && \
    apt-get install -y libevent-dev libboost-all-dev
    
RUN BITCOIN_ROOT=$(pwd) ; \ 
    BDB_PREFIX="${BITCOIN_ROOT}/db5" ; \ 
    mkdir -p $BDB_PREFIX ; \
    wget 'http://download.oracle.com/berkeley-db/db-5.1.29.NC.tar.gz' ; \
    tar -xzvf db-5.1.29.NC.tar.gz ; \
    cd db-5.1.29.NC/build_unix/ ; \
    ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$BDB_PREFIX ; \
    make install ; \
    cd $BITCOIN_ROOT ; \
    ./configure LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/" 
    make

RUN wget https://github.com/LuckyCoinProj/luckycoinV3/releases/download/v3.0.0/Node-v3.0.0-linux.zip -O /tmp/luckycoin.zip && \
    unzip /tmp/luckycoin.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/luckycoind /usr/local/bin/luckycoin-cli /usr/local/bin/luckycoin-tx && \
    rm /tmp/luckycoin.zip

RUN mkdir -p /root/.luckycoin
COPY luckycoin.conf /root/.luckycoin/luckycoin.conf

EXPOSE 22555

CMD ["luckycoind", "-conf=/root/.luckycoin/luckycoin.conf", "-datadir=/root/.luckycoin"]
