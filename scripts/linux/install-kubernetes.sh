#!/bin/sh

if ! TEMP="$(getopt -o a:i: --long additional-ansible-arguments:,inventory: -n 'install-kubernetes' -- "$@")"; then
    echo "Terminating..." >&2
    exit 1
fi
eval set -- "$TEMP"

additional_ansible_arguments=
inventory=

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
    --)
        shift
        break
        ;;
    *) break ;;
    esac
done

echo "Ensure the Docker service is enabled and running"
systemctl enable docker
systemctl restart docker

inventory="/etc/$inventory"
echo "Running Ansible playbooks against $inventory inventory, with additional arguments: $additional_ansible_arguments"
docker run --rm \
    -v /vagrant/ansible:/etc/ansible \
    -v /vagrant/ansible/playbooks/files/tls:/opt/tls/self_signed \
    --net=host \
    ferrarimarco/open-development-environment-ansible:2.7.12-alpine \
    /bin/sh -c "ansible-galaxy install -r /etc/ansible/requirements.yml && ansible-playbook -i $inventory $additional_ansible_arguments /etc/ansible/playbooks/kubernetes.yml && ansible-playbook -i $inventory $additional_ansible_arguments /etc/ansible/playbooks/openssl-self-signed-certificate.yml" \
    2>&1 | tee /vagrant/ansible_output.txt
