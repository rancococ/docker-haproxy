# from debian:buster-slim
FROM debian:buster-slim

# maintainer
MAINTAINER "rancococ" <rancococ@qq.com>

# set arg info
ENV HAPROXY_VERSION 1.9.15
ENV HAPROXY_URL https://www.haproxy.org/download/1.9/src/haproxy-1.9.15.tar.gz
ENV HAPROXY_SHA256 291871c7f0145da14cc7222d2f68d3a0ec1c10734d91fd933226d3a103aebea5
ENV GOTMPL_URL=https://github.com/rancococ/gotmpl/releases/download/v1.0.2/gotmpl-linux-x86-64

# copy script
COPY docker-entrypoint.sh /
COPY haproxy-setup.sh /
COPY haproxy.tmpl /usr/local/etc/haproxy/

# see https://sources.debian.net/src/haproxy/jessie/debian/rules/ for some helpful navigation of the possible "make" arguments
RUN set -x \
    \
    && savedAptMark="$(apt-mark showmanual)" \
    && apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        gcc \
        libc6-dev \
        liblua5.3-dev \
        libpcre2-dev \
        libssl-dev \
        make \
        curl \
        wget \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    \
    && wget -O haproxy.tar.gz "$HAPROXY_URL" \
    && echo "$HAPROXY_SHA256 *haproxy.tar.gz" | sha256sum -c \
    && mkdir -p /usr/src/haproxy \
    && tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1 \
    && rm haproxy.tar.gz \
    \
    && makeOpts=' \
        TARGET=linux2628 \
        USE_GETADDRINFO=1 \
        USE_LUA=1 LUA_INC=/usr/include/lua5.3 \
        USE_OPENSSL=1 \
        USE_PCRE2=1 USE_PCRE2_JIT=1 \
        USE_ZLIB=1 \
        \
        EXTRA_OBJS=" \
        " \
    ' \
    && nproc="$(nproc)" \
    && eval "make -C /usr/src/haproxy -j '$nproc' all $makeOpts" \
    && eval "make -C /usr/src/haproxy install-bin $makeOpts" \
    \
    && mkdir -p /usr/local/etc/haproxy \
    && cp -R /usr/src/haproxy/examples/errorfiles /usr/local/etc/haproxy/errors \
    && rm -rf /usr/src/haproxy \
    \
    && apt-mark auto '.*' > /dev/null \
    && { [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; } \
    && find /usr/local -type f -executable -exec ldd '{}' ';' \
        | awk '/=>/ { print $(NF-1) }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u \
        | xargs -r apt-mark manual \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && curl --create-dirs -fsSLo /usr/local/bin/gotmpl "${GOTMPL_URL}" \
    && chmod +x /usr/local/bin/gotmpl \
    && chmod +x /docker-entrypoint.sh \
    && chmod +x /haproxy-setup.sh

# https://www.haproxy.org/download/1.8/doc/management.txt
# "4. Stopping and restarting HAProxy"
# "when the SIGTERM signal is sent to the haproxy process, it immediately quits and all established connections are closed"
# "graceful stop is triggered when the SIGUSR1 signal is sent to the haproxy process"
STOPSIGNAL SIGUSR1

# entry point
ENTRYPOINT ["/docker-entrypoint.sh"]
