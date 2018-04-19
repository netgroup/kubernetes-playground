# kubernetes-playground

This project is a playground to play with Kubernetes.

## Components

1. "Controller" VM: a Vagrant box running Docker where we run an Ansible instance to configure the whole environment
1. 1x Kubernetes Master
1. 2x Kubernetes Minions

## Dependencies

1. Vagrant 2.0.3+
1. Virtualbox 5.2.8+

## How to Run

After installing the dependencies, run:

1. `vagrant up`

to bootstrap the environment
