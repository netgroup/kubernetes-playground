#!/bin/sh

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
