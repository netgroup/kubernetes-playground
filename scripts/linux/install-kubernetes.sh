#!/bin/sh

docker run --rm -v /vagrant/ansible:/etc/ansible --net=host ferrarimarco/open-development-environment-ansible:2.5.1-alpine /bin/sh -c "apk add --no-cache --update openssl && pip install pyopenssl && ansible-galaxy install -r /etc/ansible/requirements.yml && ansible-playbook /etc/ansible/playbooks/kubernetes.yml"
