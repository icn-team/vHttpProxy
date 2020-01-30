#!/bin/bash

echo "Running proxy!!!"

# Run vpp
/bin/bash /tmp/init.sh &

sleep 2

#Http proxy options
ORIGIN_ADDRESS=${ORIGIN_ADDRESS:-"localhost"}
ORIGIN_PORT=${ORIGIN_PORT:-"80"}
CACHE_SIZE=${CACHE_SIZE:-"10000"}
HICN_MTU=${HICN_MTU:-"1300"}
FIRST_IPV6_WORD=${FIRST_IPV6_WORD:-"b001"}
HICN_PREFIX=${HICN_PREFIX:-"http://webserver"}

# UDP Punting
HICN_LISTENER_PORT=${HICN_LISTENER_PORT:-33567}
TAP_ADDRESS_VPP=192.168.0.2
TAP_ADDRESS_KER=192.168.0.1
TAP_ADDRESS_NET=192.168.0.0/24
TAP_ID=0
TAP_NAME=tap${TAP_ID}

vppctl create tap id ${TAP_ID}
vppctl set int state ${TAP_NAME} up
vppctl set interface ip address tap0 ${TAP_ADDRESS_VPP}/24
ip addr add ${TAP_ADDRESS_KER}/24 brd + dev ${TAP_NAME}

# Redirect the udp traffic on port 33567 (The one used for hicn) to VPP
iptables -t nat -A PREROUTING -p udp --dport ${HICN_LISTENER_PORT} -j DNAT --to-destination ${TAP_ADDRESS_VPP}:${HICN_LISTENER_PORT}
# Masquerade all the traffic coming from VPP
iptables -t nat -A POSTROUTING -j MASQUERADE --src ${TAP_ADDRESS_NET} ! --dst ${TAP_ADDRESS_NET} -o eth0
# Add default route to vpp
vppctl ip route add 0.0.0.0/0 via ${TAP_ADDRESS_KER} ${TAP_NAME}
# Set UDP punting
vppctl hicn punting add prefix ${FIRST_IPV6_WORD}::/16 intfc ${TAP_NAME} type udp4 src_port ${HICN_LISTENER_PORT} dst_port ${HICN_LISTENER_PORT}

# Run the http proxy

hicn-http-proxy -a ${ORIGIN_ADDRESS}    \
                -p ${ORIGIN_PORT}       \
                -c ${CACHE_SIZE}        \
                -m ${HICN_MTU}          \
                -P ${FIRST_IPV6_WORD}   \
                 ${HICN_PREFIX}
