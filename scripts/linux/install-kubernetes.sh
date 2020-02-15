#!/bin/sh

if ! TEMP="$(getopt -o vdm: --long inventory: -n 'install-docker' -- "$@")" ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"

inventory=

while true; do
  case "$1" in
    -u | --inventory ) inventory="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

echo "Ensure the Docker service is enabled and running"
systemctl enable docker
systemctl restart docker

inventory="/etc/"$inventory

echo "Running Ansible playbooks against $inventory inventory"
docker run --rm \
    -v /vagrant/ansible:/etc/ansible \
    -v /vagrant/ansible/playbooks/files/tls:/opt/tls/self_signed \
    --net=host \
    ferrarimarco/open-development-environment-ansible:2.7.12-alpine \
    /bin/sh -c "ansible-galaxy install -r /etc/ansible/requirements.yml && ansible-playbook -i $inventory /etc/ansible/playbooks/kubernetes.yml && ansible-playbook -i $inventory /etc/ansible/playbooks/openssl-self-signed-certificate.yml"
