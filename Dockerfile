FROM alpine:3.9
MAINTAINER stexine<stexine@xpin.io>

RUN set -xe \
    && apk --no-cache add -U iptables ppp pptpd pdnsd supervisor ca-certificates \
    && mkdir -p /etc/myconfig \
    && mkdir -p /usr/local/bin/v2ray
	

COPY assets/src/brook	/usr/local/bin/
COPY assets/config/pptpd/chap-secrets  /etc/ppp/
ADD assets/src/v2ray    /usr/local/bin/v2ray


ENV SS_VER=3.2.5
ENV SS_URL=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v$SS_VER/shadowsocks-libev-$SS_VER.tar.gz

RUN set -ex && \
    apk add --no-cache --virtual .build-deps \
                                autoconf \
                                build-base \
                                curl \
                                libev-dev \
                                linux-headers \
                                libsodium-dev \
                                mbedtls-dev \
                                pcre-dev \
                                tar \
                                c-ares-dev && \
    cd /tmp && \
    curl -sSL $SS_URL | tar xz --strip 1 && \
    ./configure --prefix=/usr --disable-documentation && \
    make install && \
    cd .. && \

    runDeps="$( \
        scanelf --needed --nobanner /usr/bin/ss-* \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
    )" && \
    apk add --no-cache --virtual .run-deps $runDeps && \
    apk del .build-deps && \
    rm -rf /tmp/* && \
    mkdir /etc/supervisor.d && \
    ln -s /etc/myconfig/supervisor/services.ini /etc/supervisor.d/services.ini

EXPOSE 1723 10053/tcp 10053/udp 1017 12085-12090/tcp 12085-12090/udp

CMD set -xe \
    && iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE \
    && pptpd -c /etc/myconfig/pptpd/pptpd.conf \
    && pdnsd -d -c /etc/myconfig/pdnsd/pdnsd.conf\
    && syslogd -O /dev/stdout \
    && supervisord -c /etc/supervisord.conf -n

