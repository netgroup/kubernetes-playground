#!/bin/sh

set -e

if ! TEMP="$(getopt -o vdm: --long user: -n 'install-docker' -- "$@")"; then
    echo "Terminating..." >&2
    exit 1
fi
eval set -- "$TEMP"

user=

while true; do
    case "$1" in
    -u | --user)
        user="$2"
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *) break ;;
    esac
done

if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed"
else
    apt-get update
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

    wget -qO- https://get.docker.com | sh
    usermod -aG docker "$user"

    # We configure Docker and containerd here and not with Ansible because we run containers as part of the provisioning
    # and configuration process, so we cannot restart the container engine or containerd daemons
    # during such process and rely on those containers being up and running.

    echo "Copying the Docker daemon configuration files to their destination..."
    mkdir -p /etc/docker
    cp /vagrant/ansible/files/docker.json /etc/docker/daemon.json
    chmod 0755 /etc/docker/daemon.json
    chown root:root /etc/docker/daemon.json

    echo "Ensure the Docker service is enabled and running"
    systemctl enable docker
    if ! systemctl is-active --quiet docker; then
        echo "Starting the docker service..."
        systemctl start docker
    else
        echo "Restarting the docker service..."
        systemctl restart docker
    fi

    echo "Copying the containerd configuration files to their destination..."
    mkdir -p /etc/containerd
    # Uncommend the following line to regenerate the containerd configuration file from defaults
    # containerd config default > /vagrant/ansible/files/containerd-config.toml
    cp /vagrant/ansible/files/containerd-config.toml /etc/containerd/config.toml
    chmod 0644 /etc/containerd/config.toml
    chown root:root /etc/containerd/config.toml

    echo "Ensure the containerd service is enabled and running"
    systemctl enable containerd
    if ! systemctl is-active --quiet docker; then
        echo "Starting the containerd service..."
        systemctl start containerd
    else
        echo "Restarting the containerd service..."
        systemctl restart containerd
    fi
fi

echo "Getting information about the Docker daemon..."
docker info

echo "Getting information about containerd config..."
containerd config dump
