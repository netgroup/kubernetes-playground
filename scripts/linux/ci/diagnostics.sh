#!/bin/sh

echo "Current user: $(whoami)"
echo "Current working directory: $(pwd)"

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

command -v docker >/dev/null && echo "Docker version: $(docker --version)"

if command -v git >/dev/null 2>&1; then
    echo "git status: $(git status)"
    echo "git branch: $(git branch)"
    echo "git log: $(git log --oneline --graph --all | tail -n 10)"
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
    echo "vagrant box list: $(VAGRANT_SUPPRESS_OUTPUT="true" vagrant box list -i)"
    echo "vagrant ssh-config: $(VAGRANT_SUPPRESS_OUTPUT="true" vagrant ssh-config)"
fi

command -v bundle >/dev/null && echo "bundle list: $(bundle list)"

echo "/var/log/libvirt/qemu contents: $(ls -al /var/log/libvirt/qemu/)"
command -v virsh >/dev/null && echo "virsh list: $(virsh list)"

# More verbose stuff

command -v tree >/dev/null && echo "Current directory tree: $(tree .)"

if command -v gem >/dev/null 2>&1; then
    echo "gem environment: $(gem environment)"
    echo "Locally installed gems: $(gem query --local)"
fi

if [ -s "$NVM_DIR"/nvm.sh ]; then
    echo "Found nvm. Switching to the default node version (see .nvmrc)"
    # shellcheck source=/dev/null
    NVM_DIR="${HOME}/.nvm" && [ -s "$NVM_DIR"/nvm.sh ] && . "$NVM_DIR/nvm.sh"
    nvm use
    echo "nvm command: $(command -v nvm)"
    echo "nvm version: $(nvm --version)"
fi

if command -v node >/dev/null 2>&1; then
    echo "node command: $(command -v node)"
    echo "Node.JS version: $(node --version)"
fi

if command -v npm >/dev/null 2>&1; then
    echo "npm command: $(command -v npm)"
    echo "npm version: $(npm --version)"
    npm list -g --depth=0
fi

if command -v inspec >/dev/null 2>&1; then
    echo "inspec help: $(inspec -h)"
    echo "inspec check help: $(inspec check -h)"
fi

[ -f /var/log/libvirt/libvirtd.log ] && echo "libvirtd.log contents: $(cat /var/log/libvirt/libvirtd.log)"
[ -f "$HOME"/.virt-manager/virt-manager.log ] && echo "virt-manager.log contents: $(cat "$HOME"/.virt-manager/virt-manager.log)"

command -v dpkg >/dev/null && echo "Installed debian packages: $(dpkg -l | sort)"
[ -f /var/log/syslog ] && echo "syslog contents: $(cat /var/log/syslog)"
command -v journalctl >/dev/null && echo "journalctl: $(journalctl --no-pager)"
