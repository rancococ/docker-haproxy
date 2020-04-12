#!/bin/bash

set -e

HAPROXY_TMPL="/usr/local/etc/haproxy/haproxy.tmpl"
HAPROXY_JSON="/usr/local/etc/haproxy/haproxy.json"
HAPROXY_CONF="/usr/local/etc/haproxy/haproxy.cfg"

# automatically generated when haproxy.cfg does not exist
if [ ! -e "${HAPROXY_CONF}" ]; then
    echo "the container first start."
    # generate haproxy.cfg from env
    if [ -n "${HAPROXY_JSONDATA}" ] && [ -e "${HAPROXY_TMPL}" ] ; then
        echo generate haproxy.cfg from env and haproxy.tmpl
        eval "printf -v HAPROXY_JSONTEMP \"${HAPROXY_JSONDATA}\""
        echo ""
        echo generate ${HAPROXY_JSON}
        touch ${HAPROXY_JSON}
        printf "${HAPROXY_JSONTEMP}" > ${HAPROXY_JSON}
        echo "generate ${HAPROXY_JSON} success."
        cat ${HAPROXY_JSON}
        echo ""
        echo generate ${HAPROXY_CONF}
        gotmpl --template="f:${HAPROXY_TMPL}" --jsondata="f:${HAPROXY_JSON}" --outfile="${HAPROXY_CONF}"
        chmod 644 ${HAPROXY_CONF}
        echo "generate ${HAPROXY_CONF} success."
        cat ${HAPROXY_CONF}
        echo "remove temp file"
        #\rm -rf ${HAPROXY_JSON}
        echo ""
    else
        echo "HAPROXY_JSONDATA is empty or haproxy.tmpl does not exist"
        echo ""
    fi
fi
