#!/bin/sh

docker run --rm -v /vagrant/ansible:/etc/ansible -v /vagrant/ansible/playbooks/files/tls:/opt/tls/self_signed --net=host ferrarimarco/open-development-environment-ansible:2.7.12-alpine /bin/sh -c "ansible-galaxy install -r /etc/ansible/requirements.yml && ansible-playbook /etc/ansible/playbooks/kubernetes.yml && ansible-playbook /etc/ansible/playbooks/openssl-self-signed-certificate.yml"
