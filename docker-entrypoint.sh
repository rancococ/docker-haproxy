#!/bin/bash

set -e

# exec haproxy-setup.sh
if [ -x "/haproxy-setup.sh" ]; then
    . "/haproxy-setup.sh"
fi

# current user is root
if [ "$(id -u)" = "0" ]; then
    # start haproxy
    exec /usr/local/sbin/haproxy -f /usr/local/etc/haproxy/haproxy.cfg -W -db ${HAPROXY_COMMAND_LINE_ARGUMENTS}
fi

# exec some command
exec "$@"
