FROM icnteam/vserver:amd64

RUN apt-get update                                  && \
    apt-get -y install iptables                     && \
    rm -rf /var/lib/apt/lists/*                 && \
    apt-get clean

WORKDIR /hicn
COPY run-http-proxy.sh .
ENTRYPOINT ["/bin/bash", "-x", "/hicn/run-http-proxy.sh"]
