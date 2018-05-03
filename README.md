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

to bootstrap the environment:
1. Ansible will install `docker`, `kubeadb`, `kubelet` and `kubectl`
1. Vagrant will run provisioning scripts to initialize the Kubernetes cluster

### Automatic Ansible Inventory Creation

When you run any vagrant command, an Ansible inventory (and related group_vars) will be generated in the ansible directory.
Note that the contents of those file will be overidden on each run.
