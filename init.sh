#!/bin/bash

/usr/bin/vpp -c /etc/vpp/startup.conf &>log.txt &
sleep 5

sysrepod -d -l 0 &
sleep 5

sysrepo-plugind -d -l 0 &
sleep 5

netopeer2-server -d -v 0 &
sleep 5

echo 'root:1' | chpasswd

# Enable hicn
/usr/bin/vppctl hicn control start

# Run the http proxy
ORIGIN_ADDRESS=${ORIGIN_ADDRESS:-"localhost"}
ORIGIN_PORT=${ORIGIN_PORT:-"80"}
CACHE_SIZE=${CACHE_SIZE:-"10000"}
HICN_MTU=${HICN_MTU:-"1300"}
FIRST_IPV6_WORD=${FIRST_IPV6_WORD:-"b001"}
HICN_PREFIX=${HICN_PREFIX:-"http://webserver"}

hicn-http-proxy -a ${ORIGIN_ADDRESS} \
                -p ${ORIGIN_PORT}    \
                -c ${CACHE_SIZE}     \
                -m ${HICN_MTU}       \
                -P ${FIRST_IPV6_WORD}\
                 ${HICN_PREFIX}