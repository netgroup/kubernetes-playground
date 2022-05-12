FROM debian:10 as final
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    iperf3 \
    netsniff-ng \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 5201

ENTRYPOINT ["iperf3"]
CMD ["-s"]


FROM final as dev
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    nano \
    screen \
    tcpdump \
    && rm -rf /var/lib/apt/lists/*
