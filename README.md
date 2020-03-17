# Kubernetes Playground

[![Build Status Master Branch](https://travis-ci.org/ferrarimarco/kubernetes-playground.svg?branch=master)](https://travis-ci.org/ferrarimarco/kubernetes-playground)

This project is a playground to play with Kubernetes.

## Components

1. "Controller" VM: a Vagrant box running Docker where we run an Ansible
   instance to configure the whole environment
1. 1x Kubernetes Master
1. 3x Kubernetes Minions
1. A hyper-converged, cloud native storage cluster managed with
   [GlusterFS](https://github.com/gluster/gluster-kubernetes) and [Heketi](https://github.com/heketi/heketi)
1. A monitoring solution based on [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/)
1. [Traefik](https://traefik.io/)
   [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress/)
   to map requests to services
1. A [Docker Registry](https://docs.docker.com/registry/)

## Dependencies

1. Vagrant >= 2.1.1
1. [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)
1. Virtualbox >= 5.2.8

### Dependencies Libvirt provider

1. libvirt >= 4.0.0
1. QUEMU >= 2.22.1
1. [vagrant-libvirt](https://github.com/vagrant-libvirt/vagrant-libvirt)

## How to Run

The provisioning and configuration process has two phases:

1. Prepare a base Vagrant box.
   1. Provision and configure the `base-box-builder.k8s-play.local` VM.
   1. Export a Vagrant box based on the
      `vagrant base-box-builder.k8s-play.local` VM.
1. Provision and configure the rest of the environment using the base box.

To provision and configure the environment as described, run the following
commands from the root of the repository:

1. Provision and configure the base VM: `vagrant up base-box-builder.k8s-play.local`
1. Export the base Vagrant box:
   `vagrant package base-box-builder.k8s-play.local --output kubernetes-playground-base.box`
1. Destroy the base VM: `vagrant destroy --force base-box-builder.k8s-play.local`
1. Register the base Vagrant box to make it avaliable to Vagrant:
   `vagrant box add kubernetes-playground-base.box --name ferrarimarco/kubernetes-playground-node`
1. Provision and configure the rest of the environment: `vagrant up`

### Environment-specific configuration

You can find the default configuration in [`defaults.yaml`](defaults.yaml). If
you want to override any default setting, create `env.yaml` and save it in the
same directory as the `defaults.yaml`. The [`Vagrantfile`](Vagrantfile) will
instruct Vagrant to load it.

#### Use Libvirt as provider

In order to use libvirt as provider you need to set
the value of `vagrant_provider` variable to `libvirt` inside `env.yaml`.
Vagrant needs to know that you want to use libvirt and not default VirtualBox,
then you can use the option `--provider=libvirt.

### Cleaning up and re-provisioning

If you want to re-test the initializion of the Kubernetes cluster, you can run
a specific Vagrant provisioner that doesen't run in during the normal
provisioning phase, and then execute the normal provisioning again:

1. `vagrant provision --provision-with cleanup`
1. `vagrant provision`

### Quick CNI provisioning

If you want to test a different CNI plugin, run:

1. `vagrant provision --provision-with cleanup`
1. `vagrant provision --provision-with quick-setup`

### Cloud Native Storage

To deploy GlusterFS, SSH into the master and run the configuration script:

1. `vagrant ssh kubernetes-master-1.kubernetes-playground.local`
1. `sudo /vagrant/scripts/linux/bootstrap-glusterfs.sh`

### Ingress Controller

To deploy the Ingress controller, SSH into the master and run the configuration
script:

1. `vagrant ssh kubernetes-master-1.kubernetes-playground.local`
1. `sudo /vagrant/scripts/linux/bootstrap-ingress-controller.sh`

The Traefik monitoring UI is accessible at `http://kubernetes-master-1.kubernetes-playground.local/monitoring/ingress`

### Helm

To initialize Helm, SSH into the master and run the configuration script:

1. `vagrant ssh kubernetes-master-1.kubernetes-playground.local`
1. `sudo /vagrant/scripts/linux/bootstrap-helm.sh`

### Monitoring

To deploy the monitoring solution, SSH into the master and run the configuration
script:

1. `vagrant ssh kubernetes-master-1.kubernetes-playground.local`
1. Initialize Helm as described
1. Initialize the Ingress Controller as described
1. `sudo /vagrant/scripts/linux/bootstrap-monitoring.sh`

The monitoring dashboard is accessible at `http://kubernetes-master-1.kubernetes-playground.local/monitoring/cluster`

### Docker Registry

To deploy a private Docker Registry, SSH into the master and run the
configuration script:

1. `vagrant ssh kubernetes-master-1.kubernetes-playground.local`
1. Initialize Helm as described
1. Initialize the Ingress Controller as described
1. `sudo /vagrant/scripts/linux/bootstrap-docker-registry.sh`

The registry is accessible at `https://registry.kubernetes-playground.local`

### Additional Components

1. Multiple load balanced nginx server instances
1. A busybox instance, useful for debugging and troubleshooting (run commands
with `kubectl exec`. Example: `kubectl exec -ti busybox -- nslookup hostname`)

### Automatic Ansible Inventory Creation

When you run any vagrant command, an Ansible inventory (and related group_vars)
will be generated in the ansible directory.
Note that the contents of those file will be overidden on each run.

### Secure Communication

We generate a self-signed wildcard certificate to use for all the ingress
controllers.
