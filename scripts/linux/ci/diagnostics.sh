#!/bin/sh

echo "Current user: $(whoami)"
echo "Current working directory: $(pwd)"

if command -v git >/dev/null 2>&1; then
    echo "git status: $(git status)"
    echo "git branch: $(git branch)"
    echo "git log: $(git log --oneline --graph --all)"
fi

echo

[ -f env.yaml ] && echo "env.yaml contents: $(cat env.yaml)"

command -v dpkg >/dev/null && echo "Docker version: $(docker --version)"

command -v tree >/dev/null && echo "Current directory tree: $(tree .)"

[ -f /etc/exports ] && echo "/etc/exports contents: $(cat /etc/exports)"

echo "ip addr: $(ip addr)"
echo "showmount localhost: $(showmount -e localhost)"
echo "etc hosts content: $(cat /etc/hosts)"
echo "environment: $(env | sort)"
echo "lsmod: $(lsmod | sort)"

command -v dpkg >/dev/null && echo "Installed debian packages: $(dpkg -l | sort)"
command -v kvm-ok >/dev/null && echo "kvm-ok: $(kvm-ok)"

if command -v vagrant >/dev/null 2>&1; then
    echo "vagrant status: $(VAGRANT_SUPPRESS_OUTPUT="true" vagrant version)"
    echo "vagrant box list: $(VAGRANT_SUPPRESS_OUTPUT="true" vagrant box list -i)"
    echo "vagrant status: $(VAGRANT_SUPPRESS_OUTPUT="true" vagrant status)"
    echo "vagrant box list: $(VAGRANT_SUPPRESS_OUTPUT="true" vagrant box list -i)"
fi

if command -v gem >/dev/null 2>&1; then
    echo "gem environment: $(gem environment)"
    echo "Locally installed gems: $(gem query --local)"
fi

command -v bundle >/dev/null && echo "bundle list: $(bundle list)"

if command -v inspec >/dev/null 2>&1; then
    echo "inspec help: $(inspec -h)"
    echo "inspec check help: $(inspec check -h)"
fi

[ -f /var/log/libvirt/libvirtd.log ] && echo "libvirtd.log contents: $(cat /var/log/libvirt/libvirtd.log)"
[ -f "$HOME"/.virt-manager/virt-manager.log ] && echo "virt-manager.log contents: $(cat "$HOME"/.virt-manager/virt-manager.log)"

ls -al /var/log/libvirt/qemu/
command -v virsh >/dev/null && echo "virsh list: $(virsh list)"

[ -f /var/log/syslog ] && echo "syslog contents: $(cat /var/log/syslog)"

command -v journalctl >/dev/null && echo "journalctl: $(journalctl --no-pager)"
