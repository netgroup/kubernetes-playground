FROM debian:10
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    iperf3=3.6-2 \
    nano=3.2-3 \
    netsniff-ng=0.6.5-1 \
    screen=4.6.2-3 \
    tcpdump=4.9.3-1~deb10u1 \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 5201

ENTRYPOINT ["iperf3"]
CMD ["-s"]
