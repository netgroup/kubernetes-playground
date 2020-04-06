#!/bin/sh

if ! TEMP="$(getopt -o a:i:qm --long additional-ansible-arguments:,inventory:,quick-setup,ansible-debug \
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
        break
        ;;
    -m | --ansible-debug)
        ansible_debug=enabled
        shift
        break
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

if [ "$ansible_debug" = "enabled" ]; then
    additional_ansible_arguments="$additional_ansible_arguments --tags ansible_debug"
fi

echo "Ensure the Docker service is enabled and running"
systemctl enable docker
if ! systemctl is-active --quiet docker; then
    echo "Starting the docker service..."
    systemctl start docker
fi

inventory="/etc/$inventory"

# Playbooks paths
kubernetes_playbook_path=/etc/ansible/kubernetes.yml
open_ssl_self_signed_certificate_playbook_path=/etc/ansible/openssl-self-signed-certificate.yml
playbooks="$kubernetes_playbook_path $open_ssl_self_signed_certificate_playbook_path"

echo ""
echo "Running Ansible $playbooks playbooks against $inventory inventory, with additional arguments: $additional_ansible_arguments"
docker run --rm \
    -v /vagrant/ansible:/etc/ansible \
    -v /vagrant/ansible/files/tls:/opt/tls/self_signed \
    --net=host \
    ferrarimarco/open-development-environment-ansible:2.7.12-alpine \
    /bin/sh -c "ansible-playbook -i $inventory $additional_ansible_arguments $playbooks" \
    2>&1 | tee /vagrant/ansible_output.txt
