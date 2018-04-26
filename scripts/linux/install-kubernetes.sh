#!/bin/sh

docker run --rm -v /vagrant/ansible:/etc/ansible --net=host ferrarimarco/open-development-environment-ansible:2.5.1-alpine /bin/sh -c "ansible-galaxy install ferrarimarco.kubernetes && ansible-playbook /etc/ansible/playbooks/kubernetes.yml"
