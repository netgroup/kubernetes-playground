# Kubernetes Playground

[![Build Status Master Branch](https://travis-ci.com/ferrarimarco/kubernetes-playground.svg?branch=master)](https://travis-ci.com/ferrarimarco/kubernetes-playground)

This project is a playground where you can work with Kubernetes in a safe
sandbox. It provides:

1. A fully automated installation of Kubernetes over a cluster virtual machines (VMs).
1. The VMs of the cluster are managed with Vagrant.
1. Kubernetes Playground is compatible with the major operating systems
    (Windows, Linux, and macOS) and major hypervisors, such as Virtualbox
        and Libvirt/KVM.
1. You can choose among a number of CNI network plugins and quickly re-provision
    the cluster on the fly.

## Components

1. Kubernetes master. Defaults to 1.
1. Kubernetes workers. Defaults to 3
1. A monitoring solution based on [Prometheus](https://prometheus.io/) and
    [Grafana](https://grafana.com/).
1. [Traefik](https://traefik.io/)
    [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress/)
    .
1. A [Docker Registry](https://docs.docker.com/registry/).

## Dependencies

### Runtime

1. Vagrant. For the exact version, look the `Vagrant.require_version` constraint
    in the [Vagrantfile](Vagrantfile).

#### Vagrant providers

This project currently supports the following Vagrant providers:

1. [Virtualbox](https://www.virtualbox.org/). Dependencies:
    1. Virtualbox >= 6.1.4
1. [libvirt](https://libvirt.org/). Dependencies:
    1. libvirt >= 4.0.0
    1. QEMU >= 2.22.1

#### Vagrant plugins

When you first bring this environment up, the provisioning process will also
install the needed Vagrant plugins:

1. [vagrant-libvirt](https://github.com/vagrant-libvirt/vagrant-libvirt)
    >= 0.0.45

## How to Run

To provision and configure the environment as described, run the following
commands from the root of the repository:

1. Prepare a Vagrant box (`base-box-builder`) that will be used
    as a base for other VMs:
    1. Provision and configure `base-box-builder`:

        ```shell
        vagrant up base-box-builder.k8s-play.local
        ```

    1. Halt `vagrant base-box-builder`:

        ```shell
        vagrant halt base-box-builder.k8s-play.local
        ```

    1. Export a Vagrant box based on `vagrant base-box-builder`:

        ```shell
        VAGRANT_LIBVIRT_VIRT_SYSPREP_OPERATIONS="defaults"
        VAGRANT_LIBVIRT_VIRT_SYSPREP_OPERATIONS="$VAGRANT_LIBVIRT_VIRT_SYSPREP_OPERATIONS,-ssh-userdir"
        VAGRANT_LIBVIRT_VIRT_SYSPREP_OPERATIONS="$VAGRANT_LIBVIRT_VIRT_SYSPREP_OPERATIONS,-ssh-hostkeys"
        VAGRANT_LIBVIRT_VIRT_SYSPREP_OPERATIONS="$VAGRANT_LIBVIRT_VIRT_SYSPREP_OPERATIONS,-lvm-uuids"
        export VAGRANT_LIBVIRT_VIRT_SYSPREP_OPERATIONS
        vagrant package base-box-builder.k8s-play.local \
            --output kubernetes-playground-base.box
        ```

    1. Destroy `base-box-builder` to spare resources:

        ```shell
        vagrant destroy --force base-box-builder.k8s-play.local
        ```

    1. Register the base Vagrant box to make it avaliable to Vagrant:

        ```shell
        vagrant box add --force kubernetes-playground-base.box \
            --name ferrarimarco/kubernetes-playground-node
        ```

1. Provision and configure the rest of the environment:

    ```shell
    vagrant up
    ```

### Automatic Ansible Inventory Creation

When you run any vagrant command, an Ansible inventory (and related group_vars)
will be generated in the ansible directory.
Note that the contents of those file will be overidden on each run.

### Running in Windows Subsystem for Linux (WSL)

If you want to run this project in WSL, follow the instructions in the
[official Vagrant docs](https://www.vagrantup.com/docs/other/wsl.html).

Additionally, you need to enable the [`metadata`](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#set-wsl-launch-settings)
as one of the default mount options. You might want to specify it in
`/etc/wsl.conf` as follows:

```shell
[automount]
enabled = true
options = metadata,uid=1000,gid=1000,umask=0022
```

This is needed because otherwise the SSH private key file that Vagrant generates
has too broad permissions and `ssh` refuses to use it.

### Environment-specific configuration

You can find the default configuration in [`defaults.yaml`](defaults.yaml). If
you want to override any default setting, create a file named `env.yaml` and
save it in the same directory as the `defaults.yaml`. The
[`Vagrantfile`](Vagrantfile) will instruct Vagrant to load it.

You can configure aspects of the runtime environment, such as:

- Default Vagrant provider.
- Default Kubernetes networking plugin.
- Enable or disable verbose output during provisioning and configuration.

### Cleaning up and re-provisioning

If you want to re-test the initializion of the Kubernetes cluster, you can run
two Vagrant provisioners (_cleanup_ and _mount-shared_ ) that do not run during
the normal provisioning phase, and then execute the normal provisioning again:

1. `vagrant provision --provision-with cleanup`
1. `vagrant provision --provision-with mount-shared`
1. `vagrant provision`

The _cleanup_ provisioner also reboots the VMs, then the _mount-shared_
provisioner is needed to restore the shared folders between host and VMs.

### Quick CNI provisioning

If you want to test a different CNI plugin, run:

1. `vagrant provision --provision-with cleanup`
1. `vagrant provision --provision-with mount-shared`
1. edit the [`env.yaml`](env.yaml) to change the network plugin.
1. `vagrant provision --provision-with quick-setup`

## Add-ons

You can install the following, optional, workloads and services in the cluster.

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

## Development and testing

The test suite is executed automatically by Travis CI on each commit, according
to the configuration (see [.travis.yml](.travis.yml)).

You can also run the same test suite locally. To bootstrap a development
environment, you need to install the runtime dependencies listed above, plus the
development environment dependencies.

### Development dependencies

These are the dependencies that you need to install in your development
environment:

1. Docker, 19.03+
1. Ruby 2.6.0+
1. Bundler 1.13.0+
1. [GNU Coreutils](https://www.gnu.org/software/coreutils/)

### Setting up the development environment

After installing the dependencies, run the following scripts to install the
necessary packages:

1. Install Vagrant: [scripts/linux/ci/install-vagrant.sh](scripts/linux/ci/install-vagrant.sh)
1. (only for headless environments) Manually install Vagrant plugins:
    [scripts/linux/ci/install-vagrant.sh](scripts/linux/ci/install-vagrant.sh)
1. Install linting tools: [scripts/linux/ci/install-linting-tools.sh](scripts/linux/ci/install-linting-tools.sh)

### Travis CI environment customization

The `scripts/linux/ci/generate-env-for-travis.sh` script creates and populates
an `env.yaml` file for Travis CI builds.

### Debugging ansible operations

Ansible output is saved in the `/vagrant/ansible_output.txt`.

For debbugging and development purposes, you can add the verbosity flags in your
`env.yaml` as follows:

```yaml
conf:
    additional_ansible_arguments: "-vv"
```

### Running the tests

This section explains how to run linters and the compliance test suites. The
same linters and test suites run automatically on each commit.

#### Linters and formatters

The codebase is checked with linters and against common formatting rules.

To run the same linting that the CI builds run, execute the
[scripts/linux/ci/lint.sh](scripts/linux/ci/lint.sh) script.

##### Linting and formatting rules

We currently check and lint the codebase with [super-linter](https://github.com/github/super-linter).

#### Build the Docker images

To build all the Docker images that the CI builds run, execute the
[scripts/linux/ci/build-docker-images.sh](scripts/linux/ci/build-docker-images.sh)
script.

#### Compliance test suite

The test suite checks the whole environment for compliance using a verifier
([InSpec](https://www.inspec.io/) in this case).

##### How to run the compliance test suites

You can run the test suite against any guest, after provisioning and configuring
it.

1. Provision and configure the desired guest: `vagrant up <guest-name>`, or
`vagrant provision <guest-name>` if the guest is already up.
1. Run the tests: `scripts/linux/ci/run-inspec-against-host.sh <guest-name>`

### Debugging and troubleshooting utilities

1. A script that gathers information about the host:
    [scripts/linux/ci/diagnostics.sh](scripts/linux/ci/diagnostics.sh). You can
    run this script against a host by running it directly, or against a Vagrant
    VM, by executing the `diagnostics` provisioner:

    ```shell
    vagrant provision <guest-name> --provision-with diagnostics
    ```

    The script has a `--help` option that explains how to run it. Additionally,
    the diagnostis script can query the hypervisor directly, without going
    through Vagrant. This is useful when you've issues connecting with
    `vagrant ssh`.

## Contributing

Contributions to this project are welcome! See the instructions in
[CONTRIBUTING.md](CONTRIBUTING.md).
