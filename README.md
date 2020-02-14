# Hicn Http Proxy running in a container

This docker runs the hicn-http-proxy and the whole hicn stack, built on top of the hicn-plugin for VPP.

## Quick start

For running the proxy:

```bash
docker run -e HICN_LISTENER_PORT=33567 \
           -e ORIGIN_ADDRESS=www.google.com \
           -e ORIGIN_PORT=80 \
           -e CACHE_SIZE=10000 \
           -e HICN_MTU=1200 \
           -e FIRST_IPV6_WORD=c001 \
           -e HICN_PREFIX=http://httpserver \
           -d --name vhttpproxy icnteam/vhttpproxy
```

For a quick overview of the hicn-http-proxy capabilities check
[here](https://github.com/FDio/hicn/tree/master/apps#hicn-http-proxy "Hicn Http Proxy")!
