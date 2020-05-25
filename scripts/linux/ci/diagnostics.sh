#!/bin/bash

set -e
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

echo "Current user: $(whoami)"
echo "Current working directory: $(pwd)"
echo "Hostname (FQDN): $(hostname --fqdn)"

echo "Python path: $(command -v python)"
echo "Python version: $(python --version)"
echo "pip path: $(command -v pip)"
echo "pip version: $(pip --version)"

echo "Python 3 path: $(command -v python3)"
echo "Python 3 version: $(python3 --version)"
echo "pip 3 path: $(command -v pip3)"
echo "pip 3 version: $(pip3 --version)"

echo "Gimme version: $(gimme --version)"
echo "Go version: $(go version)"

echo "Systemd version: $(systemctl --version)"

if command -v docker >/dev/null 2>&1; then
    echo "-------- Docker --------"
    echo "Docker version: $(docker --version)"
    echo "Docker info: $(docker -D info)"
    echo "Downloaded non-dangling Docker images: $(docker images -a --filter='dangling=false' --format '{{.Repository}}:{{.Tag}} {{.ID}}')"
    echo "Docker dir contents: $(ls -al /var/lib/docker)"
    echo "Docker info (JSON): $(docker info --format '{{json .}}')"
    echo "----------------"
fi

if command -v git >/dev/null 2>&1; then
    echo "-------- Git --------"
    echo "git status: $(git status)"
    echo "git branch: $(git branch)"
    echo "git log: $(git log --oneline --graph --all | tail -n 10)"
    echo "----------------"
fi

[ -f env.yaml ] && echo "env.yaml contents: $(cat env.yaml)"

[ -f /etc/exports ] && echo "/etc/exports contents: $(cat /etc/exports)"

echo "ip addr: $(ip addr)"
command -v showmount >/dev/null && echo "showmount localhost: $(showmount -e localhost)"
echo "etc hosts content: $(cat /etc/hosts)"
echo "environment: $(env | sort)"
echo "lsmod: $(lsmod | sort)"

command -v kvm-ok >/dev/null && echo "kvm-ok: $(kvm-ok)"

if command -v vagrant >/dev/null 2>&1; then
    echo "vagrant status: $(VAGRANT_SUPPRESS_OUTPUT="true" vagrant version)"
    echo "vagrant global-status: $(vagrant global-status --prune)"
    echo "vagrant box list: $(VAGRANT_SUPPRESS_OUTPUT="true" vagrant box list -i)"

    if [ -z "$vagrant_vm_name" ]; then
        echo "vagrant ssh-config: $(VAGRANT_SUPPRESS_OUTPUT="true" vagrant ssh-config "$vagrant_vm_name")"
    fi
fi

command -v bundle >/dev/null && echo "bundle list: $(bundle list)"

echo "/var/log/libvirt/qemu contents: $(ls -al /var/log/libvirt/qemu/)"
command -v virsh >/dev/null && echo "virsh list: $(virsh list)"

if command -v gem >/dev/null 2>&1; then
    echo "gem environment: $(gem environment)"
fi

if [ -s "$NVM_DIR"/nvm.sh ]; then
    echo "Found nvm. Switching to the default node version (see .nvmrc)"
    [ -f .nvmrc ] && echo ".nvmrc contents: $(cat .nvmrc)"
    # shellcheck source=/dev/null
    NVM_DIR="${HOME}/.nvm" && [ -s "$NVM_DIR"/nvm.sh ] && . "$NVM_DIR/nvm.sh"
    echo "nvm command: $(command -v nvm)"
    echo "nvm version: $(nvm --version)"
    nvm use
fi

if command -v npm >/dev/null 2>&1; then
    echo "npm command: $(command -v npm)"
    echo "npm version: $(npm --version)"
fi

if [ "$verbose" = "enabled" ]; then
    if command -v docker >/dev/null 2>&1; then
        echo "-------- Docker --------"
        echo "Docker info (JSON): $(docker info --format '{{json .}}')"
        echo "----------------"
    fi
    if command -v vagrant >/dev/null 2>&1; then
        if [ -z "$vagrant_vm_name" ]; then
            echo "vagrant box diagnostics: $(VAGRANT_SUPPRESS_OUTPUT="true" vagrant ssh "$vagrant_vm_name" -C "/vagrant/scripts/linux/ci/diagnostics.sh")"
        fi
    fi

    command -v tree >/dev/null && echo "Current directory tree: $(tree .)"

    if command -v gem >/dev/null 2>&1; then
        echo "Locally installed gems: $(gem query --local)"
    fi

    if command -v inspec >/dev/null 2>&1; then
        echo "inspec help: $(inspec -h)"
        echo "inspec check help: $(inspec check -h)"
    fi

    if command -v npm >/dev/null 2>&1; then
        echo "Installed npm packages: $(npm list -g --depth=0)"
    fi

    [ -f /var/log/libvirt/libvirtd.log ] && echo "libvirtd.log contents: $(cat /var/log/libvirt/libvirtd.log)"
    [ -f "$HOME"/.virt-manager/virt-manager.log ] && echo "virt-manager.log contents: $(cat "$HOME"/.virt-manager/virt-manager.log)"

    command -v dpkg >/dev/null && echo "Installed debian packages: $(dpkg -l | sort)"

    command -v journalctl >/dev/null && echo "journalctl (current boot, warning and above): $(journalctl -xb -p warning --no-pager)"
fi
