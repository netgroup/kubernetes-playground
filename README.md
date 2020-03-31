# Kubernetes Playground

[![Build Status Master Branch](https://travis-ci.com/ferrarimarco/kubernetes-playground.svg?branch=master)](https://travis-ci.com/ferrarimarco/kubernetes-playground)

This project is a playground to play with Kubernetes.

## Components

1. 1x Kubernetes Master VM.
1. 3x Kubernetes Minions VMs.
1. "Controller": a Docker container where we run an Ansible instance to
   configure the whole environment.
1. A hyper-converged, cloud native storage cluster managed with
   [GlusterFS](https://github.com/gluster/gluster-kubernetes) and [Heketi](https://github.com/heketi/heketi).
1. A monitoring solution based on [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/).
1. [Traefik](https://traefik.io/)
   [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress/)
   to map requests to services.
1. A [Docker Registry](https://docs.docker.com/registry/).

## Dependencies

### Runtime

1. Vagrant >= 2.1.1
1. [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)
1. Virtualbox provider:
    1. Virtualbox >= 5.2.8
1. libvirt provider:
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
   `vagrant box add --force kubernetes-playground-base.box --name ferrarimarco/kubernetes-playground-node`
1. Provision and configure the rest of the environment: `vagrant up`

### Running in Windows Subsystem for Linux (WSL)

If you want to run this project in WSL, follow the instructions in the
[official Vagrant docs](https://www.vagrantup.com/docs/other/wsl.html).

### Environment-specific configuration

You can find the default configuration in [`defaults.yaml`](defaults.yaml). If
you want to override any default setting, create `env.yaml` and save it in the
same directory as the `defaults.yaml`. The [`Vagrantfile`](Vagrantfile) will
instruct Vagrant to load it.

#### Use Libvirt as provider

In order to use libvirt as provider you need to set
the value of `conf.vagrant_provider` variable to `libvirt` inside `env.yaml`.
Vagrant needs to know that you want to use libvirt and not default VirtualBox,
then you can use the option `--provider=libvirt`.

#### Select a kubernetes networking plugin (CNI)

The networking plugin is configured by setting
`ansible.group_vars.all.kubernetes_network_plugin`
inside `env.yaml`. The currenlty allowed plugins are `weavenet`, `calico`
and `flannel`. It is also possible to use `no-cni-plugin`. In this case,
the provisioner will only prepare the environment, but will not start any
Kubernetes cluster and will not run `kubeadm join` in the minions.

#### Show verbose output of Ansible operations

Set `conf.additional_ansible_arguments` to `"-vv"` inside `env.yaml` to configure
verbose output in Ansible. Note that Ansible output is always saved on the
`ansible_output.txt` file in the `/vagrant` folder.

### Cleaning up and re-provisioning

If you want to re-test the initializion of the Kubernetes cluster, you can run
a specific Vagrant provisioner that doesn't run during the normal
provisioning phase, and then execute the normal provisioning again:

1. `vagrant provision --provision-with cleanup`
1. `vagrant provision --provision-with mount-shared`
1. `vagrant provision`

### Quick CNI provisioning

If you want to test a different CNI plugin, run:

1. `vagrant provision --provision-with cleanup`
1. `vagrant provision --provision-with mount-shared`

edit the [`defaults.yaml`](defaults.yaml) or better the `env.yaml` to
change the network plugin, then run

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

### Kites experiments

Kites allows you to test the traffic exchanged between Nodes
and Pods.

#### Net-Test DaemonSet

To deploy Net-Test DaemonSet, open a new SSH connection into the master
and run the configuration script:

1. `vagrant ssh kubernetes-master-1.kubernetes-playground.local`
1. `sudo /vagrant/scripts/linux/bootstrap-net-test-ds.sh`

If you want to open a shell in the newly created container,
follow the instructions in the
[official Kubernetes docs](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/).

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

## Development and testing

The test suite is executed automatically by Travis CI on each commit, according
to the configuration (see [.travis.yml](.travis.yml)).

You can also run the same test suite locally. To bootstrap a development
environment, you need to install the runtime dependencies listed above, plus the
development environment dependencies.

### Running the tests

This section explains how to run linters and the compliance test suites. The
same linters and test suites run automatically on each commit.

#### Linters and formatters

The codebase is checked with linters and against common formatting rules.

##### Linters and formatters dependencies

1. Python 3, with pip.
1. NodeJS, with npm.
1. See [requirements.txt](requirements.txt).
1. See [package.json](package.json).

##### Linting and formatting rules

We currently check the following file types, and enforce the following rules:

| File type      | Formatting rules | Linters and validators |
|----------------|------------------|------------------------|
| Travis CI configuration file | See [.editorconfig](.editorconfig) | [travis lint](https://github.com/travis-ci/travis.rb#lint) |
| Shell scripts                | See [.editorconfig](.editorconfig), [shfmt](https://github.com/mvdan/sh) | [Shellcheck](https://github.com/koalaman/shellcheck) |
| All YAML files               | See [.editorconfig](.editorconfig) | [YAMLlint (strict mode)](https://github.com/adrienverge/yamllint) |
| Markdown files               | See [.editorconfig](.editorconfig) | [markdownlint](https://github.com/DavidAnson/markdownlint) |
| Vagrantfile                  | See [.editorconfig](.editorconfig) | [vagrant validate](https://www.vagrantup.com/docs/cli/validate.html) |
| Kubernetes descriptors       | See [.editorconfig](.editorconfig) | [kubeval](https://github.com/instrumenta/kubeval) |
| Ansible playbooks and roles  | See [.editorconfig](.editorconfig) | [ansible-lint](https://docs.ansible.com/ansible-lint/) |
| Dockerfiles                  | See [.editorconfig](.editorconfig) | [hadolint](https://github.com/hadolint/hadolint) |
| All text files               | See [.editorconfig](.editorconfig) | N/A |

#### Compliance test suite

The test suite checks the whole environment for compliance using a verifier
([InSpec](https://www.inspec.io/) in this case).

##### Compliance test suites dependencies

1. Ruby 2.6.0+
1. Bundler 1.13.0+

##### How to run the compliance test suites

You can run the test suite manually. [Test-Kitchen](https://kitchen.ci/) will
manage the lifecycle of the test instances.

1. Install the dependencies (you need to have a working Ruby environment):
    1. Install bundler: `gem install bundler`
    1. Install required gems: `bundle install`
1. Run the tests with Test-Kitchen: `kitchen test`

## Contributing

Contributions to this project are welcome! See the instructions in
[CONTRIBUTING.md](CONTRIBUTING.md).
