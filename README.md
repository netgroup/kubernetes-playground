# Kubernetes Playground

This project is a playground to play with Kubernetes.

## Components

1. "Controller" VM: a Vagrant box running Docker where we run an Ansible instance to configure the whole environment
1. 1x Kubernetes Master
1. 3x Kubernetes Minions
1. A hyper-converged, cloud native storage cluster managed with [GlusterFS](https://github.com/gluster/gluster-kubernetes) and [Heketi](https://github.com/heketi/heketi)
1. A monitoring solution based on [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/)

## Dependencies

1. Vagrant >= 2.1.1
1. Virtualbox >= 5.2.8

## How to Run

After installing the dependencies, run:

1. `vagrant up`

to bootstrap the environment:
1. Vagrant will provision master and worker nodes
1. Ansible will install `docker`, `kubeadb`, `kubelet` and `kubectl` and run configuration scripts to initialize the Kubernetes cluster


### Additional Components

The descriptors in the `kubernetes` directory are considered optional and can be deployed by running `kubectl apply -f kubernetes/<descriptor-path>` from the root of the project.
These optional components are:

1. Multiple load balanced nginx server instances
1. A busybox instance, useful for debugging and troubleshooting (run commands with `kubectl exec`. Example: `kubectl exec -ti busybox -- nslookup hostname`)

### Automatic Ansible Inventory Creation

When you run any vagrant command, an Ansible inventory (and related group_vars) will be generated in the ansible directory.
Note that the contents of those file will be overidden on each run.
