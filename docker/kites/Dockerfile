FROM debian:latest
MAINTAINER Simone Zaccariello <simone.zaccariello@gmail.com>
# install binary and remove cache
RUN apt-get update \
    && apt-get install -y iperf3 netsniff-ng nano tcpdump screen \
    && rm -rf /var/lib/apt/lists/*

# Expose the default iperf3 server port
EXPOSE 5201

# entrypoint allows you to pass your arguments to the container at runtime
# very similar to a binary you would run. For example, in the following
# docker run -it <IMAGE> --help' is like running 'iperf3 --help'
ENTRYPOINT ["iperf3"]
CMD ["-s"]