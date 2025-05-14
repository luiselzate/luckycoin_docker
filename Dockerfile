FROM debian:latest

RUN apt-get install build-essential pkg-config && \
    apt-get install libtool autotools-dev autoconf automake && \
    apt-get install libssl-dev

RUN apt-get update && \
    apt-get install -y wget git unzip && \
    apt-get install -y libevent-dev libboost-all-dev
    
RUN git clone https://github.com/luiselzate/luckycoin_1.8 ; \ 
    cd luckycoin_1.8 ; \ 
    BITCOIN_ROOT=$(pwd) ; \ 
    BDB_PREFIX="${BITCOIN_ROOT}/db5" ; \ 
    mkdir -p $BDB_PREFIX ; \
    wget 'http://download.oracle.com/berkeley-db/db-5.1.29.NC.tar.gz' ; \
    tar -xzvf db-5.1.29.NC.tar.gz ; \
    cd db-5.1.29.NC/build_unix/ ; \
    ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$BDB_PREFIX ; \
    make install ; \
    cd $BITCOIN_ROOT ; \
    ./autogen.sh ; \
    ./configure LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/" ; \ 
    make

RUN cp $BITCOIN_ROOT/src/luckycoind /usr/local/bin/luckycoind ; \ 
    cp $BITCOIN_ROOT/src/luckycoin-cli /usr/local/bin/luckycoin-cli ; \ 
    cp $BITCOIN_ROOT/src/dogecoind /usr/local/bin/luckycoind ; \ 
    cp $BITCOIN_ROOT/src/dogecoin-cli /usr/local/bin/luckycoin-cli ; \ 

RUN mkdir -p /root/.luckycoin
COPY luckycoin.conf /root/.luckycoin/luckycoin.conf

EXPOSE 9917

CMD ["luckycoind", "-conf=/root/.luckycoin/luckycoin.conf", "-datadir=/root/.luckycoin"]
