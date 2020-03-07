#!/bin/sh

if ! TEMP="$(getopt -o vdm: --long inventory: -n 'install-kubernetes' -- "$@")" ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"

inventory=

while true; do
  case "$1" in
    -u | --inventory ) inventory="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

ansible_debug="$1"

echo "Ansible debug flag: $ansible_debug"

verbose_flag=
if [ "$ansible_debug" = "on" ]; then
    verbose_flag="-vv"
fi

echo "Verbose verbose_flag value: $verbose_flag"

echo "Ensure the Docker service is enabled and running"

systemctl enable docker
systemctl restart docker

inventory="/etc/"$inventory

echo "Running Ansible playbooks against $inventory inventory"

if [ "$ansible_debug" = 'on' ]; then
    docker run --rm \
        -v /vagrant/ansible:/etc/ansible \
        -v /vagrant/ansible/playbooks/files/tls:/opt/tls/self_signed \
        --net=host \
        ferrarimarco/open-development-environment-ansible:2.7.12-alpine \
        /bin/sh -c "ansible-galaxy install -r /etc/ansible/requirements.yml && ansible-playbook -i $inventory /etc/ansible/playbooks/kubernetes.yml $verbose_flag && ansible-playbook -i $inventory /etc/ansible/playbooks/openssl-self-signed-certificate.yml" \
        2>&1 | tee /vagrant/ansible_output.txt
else
    docker run --rm \
        -v /vagrant/ansible:/etc/ansible \
        -v /vagrant/ansible/playbooks/files/tls:/opt/tls/self_signed \
        --net=host \
        ferrarimarco/open-development-environment-ansible:2.7.12-alpine \
        /bin/sh -c "ansible-galaxy install -r /etc/ansible/requirements.yml && ansible-playbook -i $inventory /etc/ansible/playbooks/kubernetes.yml $verbose_flag && ansible-playbook -i $inventory /etc/ansible/playbooks/openssl-self-signed-certificate.yml"
fi

