FROM icnteam/vserver

WORKDIR /hicn
COPY init.sh .
CMD ["/bin/bash", "/hicn/init.sh"]