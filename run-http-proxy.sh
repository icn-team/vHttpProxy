#!/bin/bash

echo "Running proxy!!!"

# Run vpp
/bin/bash /tmp/init.sh &

sleep 2

#Http proxy options
ORIGIN_ADDRESS=${ORIGIN_ADDRESS:-"localhost"}
ORIGIN_PORT=${ORIGIN_PORT:-"80"}
CACHE_SIZE=${CACHE_SIZE:-"10000"}
DEFAULT_CONTENT_LIFETIME=${DEFAULT_CONTENT_LIFETIME:-"7200"}
HICN_MTU=${HICN_MTU:-"1300"}
FIRST_IPV6_WORD=${FIRST_IPV6_WORD:-"b001"}
USE_MANIFEST=${USE_MANIFEST:-"true"}
HICN_PREFIX=${HICN_PREFIX:-"http://webserver"}
UDP_TUNNEL_ENDPOINTS=${UDP_TUNNEL_ENDPOINTS:-""}

# UDP Punting
HICN_LISTENER_PORT=${HICN_LISTENER_PORT:-33567}
TAP_ADDRESS_VPP=192.168.0.2
TAP_ADDRESS_KER=192.168.0.1
TAP_ADDRESS_NET=192.168.0.0/24
TAP_ID=0
TAP_NAME=tap${TAP_ID}

vppctl create tap id ${TAP_ID}
vppctl set int state ${TAP_NAME} up
vppctl set interface ip address ${TAP_NAME} ${TAP_ADDRESS_VPP}/24
ip addr add ${TAP_ADDRESS_KER}/24 brd + dev ${TAP_NAME}
# Redirect the udp traffic on port 33567 (The one used for hicn) to VPP
iptables -t nat -A PREROUTING -p udp --dport ${HICN_LISTENER_PORT} -j DNAT --to-destination ${TAP_ADDRESS_VPP}:${HICN_LISTENER_PORT}
# Masquerade all the traffic coming from VPP
iptables -t nat -A POSTROUTING -j MASQUERADE --src ${TAP_ADDRESS_NET} ! --dst ${TAP_ADDRESS_NET} -o eth0
# Add default route to vpp
vppctl ip route add 0.0.0.0/0 via ${TAP_ADDRESS_KER} ${TAP_NAME}
vppctl ip route add 0.0.0.0/0 table 10 via ${TAP_ADDRESS_KER} ${TAP_NAME}

# Set UDP tunnels

OFS=${IFS}
IFS=","

for endpoint in ${UDP_TUNNEL_ENDPOINTS}; do
  ip=$(echo $endpoint | cut -f1 -d:)
  port=$(echo $endpoint | cut -f2 -d:)
  vppctl udp tunnel add ${TAP_ADDRESS_VPP} ${ip} ${HICN_LISTENER_PORT} ${port}
done

IFS=${OFS}

# Run the http proxy
PARAMS="-S "
PARAMS+="-a ${ORIGIN_ADDRESS} "
PARAMS+="-p ${ORIGIN_PORT} "
PARAMS+="-c ${CACHE_SIZE} "
PARAMS+="-m ${HICN_MTU} "
PARAMS+="-P ${FIRST_IPV6_WORD} "
PARAMS+="-l ${DEFAULT_CONTENT_LIFETIME} "
if [ "${USE_MANIFEST}" = "true" ]; then
  PARAMS+="-M "
fi

hicn-http-proxy ${PARAMS} ${HICN_PREFIX}
