#!/bin/bash

set -e

HAPROXY_TMPL_FILE="/usr/local/etc/haproxy/haproxy.tmpl"
HAPROXY_TEMP_FILE="/usr/local/etc/haproxy/haproxy.temp"
HAPROXY_JSON_FILE="/usr/local/etc/haproxy/haproxy.json"
HAPROXY_CONF_FILE="/usr/local/etc/haproxy/haproxy.cfg"

# automatically generated when haproxy.cfg does not exist
if [ ! -e "${HAPROXY_CONF}" ]; then
    echo "the container first start."
    # generate haproxy.cfg from env, haproxy.json, haproxy.temp, haproxy.tmpl
    if [ -e "${HAPROXY_TMPL_FILE}" ] ; then
        echo generate haproxy.cfg from env, haproxy.json, haproxy.temp, haproxy.tmpl
        if [ -e "${HAPROXY_JSON_FILE}" ] ; then
            # haproxy.json is exist
            echo "${HAPROXY_JSON_FILE} is exist"
            echo "show ${HAPROXY_JSON_FILE}"
            echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
            cat ${HAPROXY_JSON_FILE}
            echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
            echo generate ${HAPROXY_CONF_FILE}
            gotmpl --template="f:${HAPROXY_TMPL_FILE}" --jsondata="f:${HAPROXY_JSON_FILE}" --outfile="${HAPROXY_CONF_FILE}"
            chmod 644 ${HAPROXY_CONF_FILE}
            echo "generate ${HAPROXY_CONF_FILE} success."
        else
            # haproxy.json does not exist
            echo "haproxy.json does not exist"
            if [ -e "${HAPROXY_TEMP_FILE}" ] ; then
                echo "${HAPROXY_TEMP_FILE} is exist"
                # generate haproxy.json from haproxy.temp
                echo "read ${HAPROXY_TEMP_FILE}"
                HAPROXY_TEMP_DATA=$(cat ${HAPROXY_TEMP_FILE})
                echo "show ${HAPROXY_TEMP_FILE}"
                echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
                echo "${HAPROXY_TEMP_DATA}"
                echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                eval "printf -v HAPROXY_JSON_DATA \"${HAPROXY_TEMP_DATA}\""
                echo generate ${HAPROXY_JSON_FILE}
                touch ${HAPROXY_JSON_FILE}
                printf "${HAPROXY_JSON_DATA}" > ${HAPROXY_JSON_FILE}
                echo "generate ${HAPROXY_JSON_FILE} success."
                echo "show ${HAPROXY_JSON_FILE}"
                echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
                cat ${HAPROXY_JSON_FILE}
                echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                echo generate ${HAPROXY_CONF_FILE}
                gotmpl --template="f:${HAPROXY_TMPL_FILE}" --jsondata="f:${HAPROXY_JSON_FILE}" --outfile="${HAPROXY_CONF_FILE}"
                chmod 644 ${HAPROXY_CONF_FILE}
                echo "generate ${HAPROXY_CONF_FILE} success."
            else
                echo "haproxy.temp does not exist"
            fi
        fi
        if [ -e "${HAPROXY_CONF_FILE}" ] ; then
            # show haproxy.cfg
            echo "show ${HAPROXY_CONF_FILE}"
            echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
            cat ${HAPROXY_CONF_FILE}
            echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        else
            echo "haproxy.cfg does not exist"
            exit 1
        fi
    else
        echo "haproxy.tmpl does not exist"
        exit 1
    fi
fi

echo ""
