# Hicn Http Proxy running in a container

This docker runs the hicn-http-proxy and the whole hicn stack, built on top of the hicn-plugin for VPP.
By default this docker works with UDP tunnels, so the configuration must include
the details regarding the tunnel endpoints.

## Quick start

For running the proxy, tou need to provide the following parameters:

- `HICN_LISTENER_PORT`: Local udp tunnel port
- `ORIGIN_ADDRESS`: IP address of origin server
- `ORIGIN_PORT`: Port of origin server
- `CACHE_SIZE`: Cache size of the http proxy
- `HICN_MTU`: MTU of hicn data packets
- `FIRST_IPV6_WORD`: First 2 bytes to be used when generating the hicn names, hex notations
- `HICN_PREFIX`: Human readable name. Will be hashed into an hicn name starting with ${FIRST_IPV6_WORD}
- `DEFAULT_CONTENT_LIFETIME`: Content lifetime of the hicn data packets
- `USE_MANIFEST`: Use manifests
- `UDP_TUNNEL_ENDPOINTS`: List of remote udp tunnel endpoints.

This is an example you can adapt by modifying the env variables passed to the docker container:

```bash
docker run --cap-add=NET_ADMIN              \
           --device=/dev/vhost-net          \
           --device=/dev/net/tun            \
           -p 33567:33567/udp               \
           -e HICN_LISTENER_PORT=33567      \
           -e ORIGIN_ADDRESS=www.google.com \
           -e ORIGIN_PORT=80                \
           -e CACHE_SIZE=10000              \
           -e HICN_MTU=1200                 \
           -e FIRST_IPV6_WORD=c001          \
           -e HICN_PREFIX=http://httpserver \
           -e DEFAULT_CONTENT_LIFETIME=7200 \
           -e USE_MANIFEST=true             \
           -e UDP_TUNNEL_ENDPOINTS=remote_ip1:remote_port1,remote_ip2:remote_port2 \
           -d --name vhttpproxy icnteam/vhttpproxy
```

For a quick overview of the hicn-http-proxy capabilities check
[here](https://github.com/FDio/hicn/blob/master/docs/source/apps.md#hicn-http-proxy "Hicn Http Proxy")!
