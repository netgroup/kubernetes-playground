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
    run_diagnostic_command "bundle" "bundle list"
}

docker_check() {
    if [ -f /var/run/docker.sock ]; then
        run_diagnostic_command "docker" "docker --version"
        run_diagnostic_command "docker" "docker -D info"
        run_diagnostic_command "docker" "docker images -a --filter='dangling=false' --format '{{.Repository}}:{{.Tag}} {{.ID}}'"
        run_diagnostic_command "docker" "docker info --format '{{json .}}'"
        print_directory_contents /var/lib/docker
    else
        echo "WARNING: Docker socket not found"
    fi
}

docker_verbose_check() {
    if [ -f /var/run/docker.sock ]; then
        run_diagnostic_command "docker" "docker info --format '{{json .}}'"
    else
        echo "WARNING: Docker socket not found"
    fi
}

dpkg_verbose_check() {
    run_diagnostic_command "dpkg" "dpkg -l | sort"
}

env_check() {
    run_diagnostic_command "env" "env | sort"
}

gem_check() {
    run_diagnostic_command "gem" "gem environment"
}

gem_verbose_check() {
    run_diagnostic_command "gem" "gem query --local"
}

gimme_check() {
    run_diagnostic_command "gimme" "gimme --version"
}

git_check() {
    run_diagnostic_command "git" "git status"
    run_diagnostic_command "git" "git branch"
    run_diagnostic_command "git" "git log --oneline --graph --all | tail -n 10"
}

git_verbose_check() {
    run_diagnostic_command "git" "git diff"
}

go_check() {
    run_diagnostic_command "go" "go version"
}

hostname_check() {
    run_diagnostic_command "hostname" "hostname --fqdn"
}

inspec_verbose_check() {
    run_diagnostic_command "inspec" "inspec -h"
    run_diagnostic_command "inspec" "inspec check -h"
}

ip_check() {
    run_diagnostic_command "ip" "ip addr"
}

journalctl_verbose_check() {
    run_diagnostic_command "journalctl" "journalctl -xb -p warning --no-pager"
}

kvm_ok_check() {
    run_diagnostic_command "kvm-ok" "kvm-ok"
}

lsmod_check() {
    run_diagnostic_command "lsmod" "lsmod | sort"
}

npm_check() {
    run_diagnostic_command "npm" "command -v npm"
    run_diagnostic_command "npm" "npm --version"

}

npm_verbose_check() {
    run_diagnostic_command "npm" "npm list -g --depth=0"
}

pip_check() {
    run_diagnostic_command "pip" "command -v pip"
    run_diagnostic_command "pip" "pip --version"
}

pip3_check() {
    run_diagnostic_command "pip3" "command -v pip3"
    run_diagnostic_command "pip3" "pip3 --version"
}

python_check() {
    run_diagnostic_command "python" "command -v python"
    run_diagnostic_command "python" "python --version"
}

python3_check() {
    run_diagnostic_command "python3" "command -v python3"
    run_diagnostic_command "python3" "python3 --version"
}

pwd_check() {
    run_diagnostic_command "pwd" "pwd"
}

showmount_check() {
    run_diagnostic_command "showmount" "timeout 15s showmount -e localhost"
}

ssh_check() {
    print_directory_contents /etc/ssh
    print_file_contents /etc/ssh/ssh_config
    print_file_contents /etc/ssh/sshd_config

    run_diagnostic_command "sshd" "sshd -T"

}

systemctl_check() {
    run_diagnostic_command "systemctl" "systemctl --version"
}

tree_verbose_check() {
    run_diagnostic_command "tree" "tree ."
    run_diagnostic_command "tree" "$HOME"/.vagrant.d/boxes
}

vagrant_check() {
    run_diagnostic_command "vagrant" "VAGRANT_SUPPRESS_OUTPUT=true vagrant version"
    run_diagnostic_command "vagrant" "VAGRANT_SUPPRESS_OUTPUT=true vagrant global-status --prune"
    run_diagnostic_command "vagrant" "VAGRANT_SUPPRESS_OUTPUT=true vagrant box list -i"
}

vagrant_verbose_check() {
    vagrant_vm_name="${1}"
    if [ -z "$vagrant_vm_name" ]; then
        echo "ERROR: Vagrant VM name is not set."
        exit 1
    fi

    run_diagnostic_command "vagrant" "VAGRANT_SUPPRESS_OUTPUT=true vagrant ssh-config $vagrant_vm_name"
    run_diagnostic_command "vagrant" "VAGRANT_SUPPRESS_OUTPUT=true VAGRANT_LOG=info VAGRANT_DEFAULT_PROVIDER=$VAGRANT_DEFAULT_PROVIDER vagrant ssh $vagrant_vm_name -- -tt -v sudo /vagrant/scripts/linux/ci/diagnostics.sh --verbose"

    print_file_contents /var/log/libvirt/qemu/"$vagrant_vm_name".log

    unset vagrant_vm_name
}

virsh_check() {
    run_diagnostic_command "virsh" "virsh list"
}

whoami_check() {
    run_diagnostic_command "whoami" "whoami"
}

run_diagnostic_command() {
    command_name="${1}"
    command_function_name="${2}"

    echo "-------- START $command_name ($command_function_name) --------"

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

whoami_check
pwd_check
hostname_check
python_check
pip_check
python3_check
pip3_check
gimme_check
go_check
systemctl_check
docker_check
git_check
ip_check
showmount_check
env_check
lsmod_check
kvm_ok_check
vagrant_check
bundle_check
virsh_check
gem_check
npm_check
ssh_check

print_file_contents env.yaml
print_file_contents /etc/exports
print_file_contents /etc/hosts

print_directory_contents /var/log/libvirt/qemu

echo "VERBOSE: $verbose"
if [ "$verbose" = "enabled" ]; then
    echo "-------- START VERBOSE OUTPUT --------"
    docker_verbose_check
    vagrant_verbose_check "$vagrant_vm_name"

    tree_verbose_check
    gem_verbose_check
    inspec_verbose_check
    npm_verbose_check

    print_file_contents /var/log/libvirt/libvirtd.log
    print_file_contents "$HOME"/.virt-manager/virt-manager.log

    dpkg_verbose_check
    journalctl_verbose_check
    git_verbose_check
    echo "-------- END VERBOSE OUTPUT --------"
fi
