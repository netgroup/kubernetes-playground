#!/bin/sh

docker run --rm -it -v /vagrant/ansible:/etc/ansible --net=host dedalus/docker-ansible:latest ansible-playbook kubernetes-master.yml
