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
    wget -qO- https://get.docker.com | sh
    usermod -aG docker "$user"

    echo "Copying the Docker daemon configuration files to their destination..."
    mkdir -p /etc/docker
    cp /vagrant/ansible/templates/docker.json.j2 /etc/docker/daemon.json

    echo "Ensure the Docker service is enabled and running"
    systemctl enable docker
    if ! systemctl is-active --quiet docker; then
        echo "Starting the docker service..."
        systemctl start docker
    fi
fi
