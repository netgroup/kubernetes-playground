#!/bin/bash

set -o pipefail

if ! TEMP="$(getopt -o n:v --long vagrant-vm-name:,verbose \
    -n 'diagnostics' -- "$@")"; then
    echo "Terminating..." >&2
    exit 1
fi
eval set -- "$TEMP"

vagrant_vm_name=
verbose=

while true; do
    case "$1" in
    -n | --vagrant-vm-name)
        vagrant_vm_name="$2"
        shift 2
        ;;
    -v | --verbose)
        verbose=enabled
        shift
        break
        ;;
    --)
        shift
        break
        ;;
    *) break ;;
    esac
done

print_directory_contents() {
    directory_path="${1}"
    echo "-------- START $directory_path CONTENTS --------"

    if [ -d "$directory_path" ]; then
        ls -al "$directory_path"
    else
        echo "WARNING: $directory_path not found or it's not a directory"
    fi

    echo "-------- END $directory_path CONTENTS --------"

    unset directory_path
}

print_file_contents() {
    file_path="${1}"
    echo "-------- START $file_path CONTENTS --------"

    if [ -f "$file_path" ]; then
        cat "$file_path"
    else
        echo "WARNING: $file_path not found"
    fi

    echo "-------- END $file_path CONTENTS --------"

    unset file_path
}

bundle_check() {
    echo "bundle list"
    bundle list
}

docker_check() {
    if ! [ -f /var/run/docker.sock ]; then
        echo "WARNING: Docker socket not found"
        return 1
    fi

    echo "Docker version"
    docker --version

    echo "Docker info"
    docker -D info

    echo "Downloaded non-dangling Docker images"
    docker images -a --filter='dangling=false' --format '{{.Repository}}:{{.Tag}} {{.ID}}'

    echo "Docker info (JSON)"
    docker info --format '{{json .}}'
}

docker_verbose_check() {
    if ! [ -f /var/run/docker.sock ]; then
        echo "WARNING: Docker socket not found"
        return 1
    fi

    echo "Docker info (JSON)"
    docker info --format '{{json .}}'
}

dpkg_verbose_check() {
    echo "Installed debian packages"
    dpkg -l | sort
}

env_check() {
    echo "environment"
    env | sort
}

gem_check() {
    echo "gem environment"
    gem environment
}

gem_verbose_check() {
    echo "Locally installed gems"
    gem query --local
}

gimme_check() {
    echo "Gimme version"
    gimme --version
}

git_check() {
    echo "git status"
    git status

    echo "git branch"
    git branch

    echo "git log"
    git log --oneline --graph --all | tail -n 10
}

go_check() {
    echo "Go version"
    go version
}

hostname_check() {
    echo "Hostname (FQDN)"
    hostname --fqdn
}

inspec_verbose_check() {
    echo "inspec help"
    inspec -h

    echo "inspec check help"
    inspec check -h
}

ip_check() {
    echo "ip addr"
    ip addr
}

journalctl_verbose_check() {
    echo "journalctl (current boot, warning and above)"
    journalctl -xb -p warning --no-pager
}

kvm_ok_check() {
    echo "kvm-ok"
    kvm-ok
}

lsmod_check() {
    echo "lsmod"
    lsmod | sort
}

npm_check() {
    echo "npm command"
    command -v npm

    echo "npm version"
    npm --version
}

npm_verbose_check() {
    echo "Installed npm packages"
    npm list -g --depth=0
}

pip_check() {
    echo "pip path"
    command -v pip

    echo "pip version"
    pip --version
}

pip3_check() {
    echo "pip3 path"
    command -v pip3

    echo "pip3 version"
    pip3 --version
}

python_check() {
    echo "Python path"
    command -v python

    echo "Python version"
    python --version
}

python3_check() {
    echo "Python 3 path"
    command -v python3

    echo "Python 3 version"
    python3 --version
}

pwd_check() {
    echo "Current working directory"
    pwd
}

showmount_check() {
    echo "showmount localhost (with a timeout)"
    timeout 15s showmount -e localhost
}

systemctl_check() {
    echo "Systemd version"
    systemctl --version
}

tree_verbose_check() {
    echo "Current directory tree"
    tree .
}

vagrant_check() {
    echo "vagrant version"
    VAGRANT_SUPPRESS_OUTPUT="true" vagrant version

    echo "vagrant global-status"
    VAGRANT_SUPPRESS_OUTPUT="true" vagrant global-status --prune

    echo "vagrant box list"
    VAGRANT_SUPPRESS_OUTPUT="true" vagrant box list -i

    unset VAGRANT_SUPPRESS_OUTPUT
}

vagrant_verbose_check() {
    vagrant_vm_name="${1}"
    if [ -z "$vagrant_vm_name" ]; then
        echo "ERROR: Vagrant VM name is not set."
        exit 1
    fi

    echo "vagrant ssh-config for $vagrant_vm_name VM"
    VAGRANT_SUPPRESS_OUTPUT="true" vagrant ssh-config "$vagrant_vm_name"

    echo "vagrant box diagnostics for the $vagrant_vm_name VM (provider: $VAGRANT_DEFAULT_PROVIDER)"
    VAGRANT_LOG="info" VAGRANT_DEFAULT_PROVIDER="$VAGRANT_DEFAULT_PROVIDER" vagrant ssh "$vagrant_vm_name" -c "ls -al /vagrant/scripts/linux/ci/diagnostics.sh"

    print_file_contents /var/log/libvirt/qemu/"$vagrant_vm_name".log

    unset vagrant_vm_name
    unset VAGRANT_SUPPRESS_OUTPUT
}

virsh_check() {
    echo "virsh list"
    virsh list
}

whoami_check() {
    echo "Current user"
    whoami
}

run_diagnostic_command() {
    command_name="${1}"
    command_function_name="${2}"

    echo "-------- START $command_name --------"

    if command -v "$command_name" >/dev/null 2>&1; then
        $command_function_name "${@:3}"
    else
        echo "WARNING: $command_name command not found"
    fi

    echo "-------- END $command_name --------"

    unset command_name
    unset command_function_name
}

if [ -s "$NVM_DIR"/nvm.sh ]; then
    echo "Found nvm. Switching to the default node version (see .nvmrc)"
    [ -f .nvmrc ] && echo ".nvmrc contents: $(cat .nvmrc)"
    # shellcheck source=/dev/null
    NVM_DIR="${HOME}/.nvm" && [ -s "$NVM_DIR"/nvm.sh ] && . "$NVM_DIR/nvm.sh"
    echo "nvm command: $(command -v nvm)"
    echo "nvm version: $(nvm --version)"
    nvm use
fi

run_diagnostic_command "whoami" "whoami_check"
run_diagnostic_command "pwd" "pwd_check"
run_diagnostic_command "hostname" "hostname_check"
run_diagnostic_command "python" "python_check"
run_diagnostic_command "pip" "pip_check"
run_diagnostic_command "python3" "python3_check"
run_diagnostic_command "pip3" "pip3_check"
run_diagnostic_command "gimme" "gimme_check"
run_diagnostic_command "go" "go_check"
run_diagnostic_command "systemctl" "systemctl_check"
run_diagnostic_command "docker" "docker_check"
run_diagnostic_command "git" "git_check"
run_diagnostic_command "ip" "ip_check"
run_diagnostic_command "showmount" "showmount_check"
run_diagnostic_command "env" "env_check"
run_diagnostic_command "lsmod" "lsmod_check"
run_diagnostic_command "kvm-ok" "kvm_ok_check"
run_diagnostic_command "vagrant" "vagrant_check"
run_diagnostic_command "bundle" "bundle_check"
run_diagnostic_command "virsh" "virsh_check"
run_diagnostic_command "gem" "gem_check"
run_diagnostic_command "npm" "npm_check"

print_file_contents env.yaml
print_file_contents /etc/exports
print_file_contents /etc/hosts

print_directory_contents /var/log/libvirt/qemu
print_directory_contents /var/lib/docker

if [ "$verbose" = "enabled" ]; then
    run_diagnostic_command "docker" "docker_verbose_check"
    run_diagnostic_command "vagrant" "vagrant_verbose_check" "$vagrant_vm_name"

    run_diagnostic_command "tree" "tree_verbose_check"
    run_diagnostic_command "gem" "gem_verbose_check"
    run_diagnostic_command "inspec" "inspec_verbose_check"
    run_diagnostic_command "npm" "npm_verbose_check"

    print_file_contents /var/log/libvirt/libvirtd.log
    print_file_contents "$HOME"/.virt-manager/virt-manager.log

    run_diagnostic_command "dpkg" "dpkg_verbose_check"
    run_diagnostic_command "journalctl" "journalctl_verbose_check"
fi
