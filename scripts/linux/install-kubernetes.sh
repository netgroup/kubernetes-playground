#!/bin/bash

set -e
set -o pipefail

if ! TEMP="$(getopt -o a:i:q --long additional-ansible-arguments:,inventory:,quick-setup \
    -n 'install-kubernetes' -- "$@")"; then
    echo "Terminating..." >&2
    exit 1
fi
eval set -- "$TEMP"

additional_ansible_arguments=
inventory=
quick_setup=

while true; do
    case "$1" in
    -a | --additional-ansible-arguments)
        additional_ansible_arguments="$2"
        shift 2
        ;;
    -i | --inventory)
        inventory="$2"
        shift 2
        ;;
    -q | --quick-setup)
        quick_setup=enabled
        shift
        ;;
    --)
        shift
        break
        ;;
    *) break ;;
    esac
done

if [ "$quick_setup" = "enabled" ]; then
    additional_ansible_arguments="$additional_ansible_arguments --tags quick_setup"
fi

inventory="/etc/$inventory"

# Playbooks paths
kubernetes_playbook_path=/etc/ansible/kubernetes.yml
playbooks="$kubernetes_playbook_path"

ANSIBLE_DOCKER_IMAGE_DIRECTORY_PATH=/vagrant/docker/ansible
ANSIBLE_DOCKER_IMAGE_TAG="ferrarimarco/kubernetes-playground-ansible"
echo "Building the Docker image to run Ansible."
docker build --rm --tag "$ANSIBLE_DOCKER_IMAGE_TAG" --file="$ANSIBLE_DOCKER_IMAGE_DIRECTORY_PATH"/Dockerfile "$ANSIBLE_DOCKER_IMAGE_DIRECTORY_PATH"
unset ANSIBLE_DOCKER_IMAGE_DIRECTORY_PATH

echo "Installing python3-apt..."
apt-get -y update
apt-get -y install \
    python-apt \
    python3-apt

echo ""
echo "Running Ansible $playbooks playbooks against $inventory inventory, with additional arguments: $additional_ansible_arguments"
docker run --rm \
    -v /vagrant/ansible:/etc/ansible \
    -v /vagrant/ansible/files/tls:/opt/tls/self_signed \
    --net=host \
    "$ANSIBLE_DOCKER_IMAGE_TAG" \
    /bin/sh -c "ansible-playbook -i $inventory $additional_ansible_arguments $playbooks" \
    2>&1 | tee /vagrant/ansible_output.txt

unset ANSIBLE_DOCKER_IMAGE_TAG

echo "Pulling Kubernetes images..."
kubeadm config images pull
