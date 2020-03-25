FROM debian:10
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    iperf3 \
    netsniff-ng \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 5201

ENTRYPOINT ["iperf3"]
CMD ["-s"]
