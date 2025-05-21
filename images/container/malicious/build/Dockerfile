FROM debian:12.10-slim

RUN <<__EOF__
apt-get update
apt-get install --yes \
    conntrack \
    curl  \
    dsniff \
    iproute2 \
    ipset \
    iptables \
    tcpdump
__EOF__

ENTRYPOINT ["/bin/sh"]
CMD ["-c", "while : ; do sleep 86400 ; done"]
