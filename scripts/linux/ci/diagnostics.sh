#!/bin/bash

set -o pipefail

echo "This script has been invoked with: $0 $*"

if ! TEMP="$(getopt -o dhoin:l: --long disk-image,help,host,libvirt-guest,vagrant-vm-name:,vagrant-libvirt-img-path: \
    -n 'diagnostics' -- "$@")"; then
    echo "Terminating..." >&2
    exit 1
fi
eval set -- "$TEMP"

cmd=
vagrant_vm_name=
vagrant_libvirt_img_path=

while true; do
    echo "Decoding parameter $1"
    case "$1" in
    -d | --disk-image)
        echo "Found disk image"
        cmd="disk_image"
        shift
        ;;
    -i | --libvirt-guest)
        echo "Found libvirt guest"
        cmd="libvirt_guest"
        shift
        ;;
    -h | --help)
        echo "Found help parameter"
        cmd="help"
        shift
        ;;
    -n | --vagrant-vm-name)
        echo "Found vagrant VM name parameter"
        vagrant_vm_name="$2"
        shift 2
        ;;
    -o | --host)
        echo "Found host parameter"
        cmd="host"
        shift
        ;;
    -l | --vagrant-libvirt-img-path)
        echo "Found disk image path parameter"
        vagrant_libvirt_img_path="$2"
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *) break ;;
    esac
done

echo "Decoded command: $cmd"
echo "Decoded VM name: $vagrant_vm_name"
echo "Decoded disk image path: $vagrant_libvirt_img_path"

declare -A file_content_exclusions=(
    ["/var/log/auth.log"]="debug1|debug2"
)

directories_to_print=(
    /dev/.udev
    /etc/modules-load.d
    /etc/update-motd.d
    /etc/netplan
    /etc/ssh
    /etc/systemd/network
    /etc/udev/rules.d
    /home/vagrant/.ssh
    /var/lib
    /var/lib/dhcp
    /var/lib/docker
    /var/lib/libvirt/dnsmasq
    /var/lib/NetworkManager
    /var/log
    /var/log/journal
    /var/log/libvirt/qemu
)

files_to_print=(
    "$HOME"/.virt-manager/virt-manager.log
    /etc/exports
    /etc/hosts
    /etc/machine-id
    /etc/network/interfaces
    /etc/shadow
    /etc/ssh/ssh_config
    /etc/ssh/sshd_config
    /var/lib/libvirt/dnsmasq/vagrant-libvirt.leases
    /var/log/auth.log
    /var/log/libvirt/libvirtd.log
    /var/log/messages
    /var/log/syslog
    ~root/virt-sysprep-firstboot.log
    env.yaml
)

print_directory_contents() {
    directory_path="${1}"
    echo "-------- START $directory_path DIRECTORY CONTENTS --------"

    if [ -d "$directory_path" ]; then
        ls -al "$directory_path"
    else
        echo "WARNING: $directory_path not found or it's not a directory"
    fi

    echo "-------- END $directory_path DIRECTORY CONTENTS --------"

    unset directory_path
}

print_file_contents() {
    file_path="${1}"
    grep_pattern_to_exclude="${file_content_exclusions[$file_path]}"
    echo "-------- START $file_path FILE CONTENTS --------"

    if [ -f "$file_path" ]; then
        if [ -z "$grep_pattern_to_exclude" ]; then
            echo "No exclusions configured for $file_path. Showing the full contents."
            cat "$file_path"
        else
            echo "Excluding $grep_pattern_to_exclude from the output of the contents of this file."
            grep -Ev "$grep_pattern_to_exclude" "$file_path"
        fi

    else
        echo "WARNING: $file_path not found"
    fi

    echo "-------- END $file_path FILE CONTENTS --------"

    unset file_path
}

host_diagnostics() {
    run_diagnostic_command "whoami" "whoami"
    run_diagnostic_command "hostname" "hostname --fqdn"
    run_diagnostic_command "ip" "ip addr"
    run_diagnostic_command "pwd" "pwd"

    if [ -f /var/run/docker.sock ]; then
        run_diagnostic_command "containerd" "containerd config dump"
        run_diagnostic_command "docker" "docker info --format '{{json .}}'"
        run_diagnostic_command "docker" "docker --version"
        run_diagnostic_command "docker" "docker -D info"
        run_diagnostic_command "docker" "docker images -a --filter='dangling=false' --format '{{.Repository}}:{{.Tag}} {{.ID}}'"
        run_diagnostic_command "docker" "docker info --format '{{json .}}'"
    else
        echo "WARNING: Docker socket not found"
    fi

    run_diagnostic_command "dpkg" "dpkg -l | sort"

    run_diagnostic_command "env" "env | sort"

    run_diagnostic_command "bundle" "bundle list"
    run_diagnostic_command "gem" "gem environment"
    run_diagnostic_command "gem" "gem query --local"

    run_diagnostic_command "gimme" "gimme --version"

    run_diagnostic_command "git" "git status"
    run_diagnostic_command "git" "git branch"
    run_diagnostic_command "git" "git log --oneline --graph --all | tail -n 10"
    run_diagnostic_command "git" "git --no-pager diff"

    run_diagnostic_command "go" "go version"

    run_diagnostic_command "inspec" "inspec -h"
    run_diagnostic_command "inspec" "inspec check -h"

    run_diagnostic_command "journalctl" "journalctl -xb -p warning --no-pager"
    run_diagnostic_command "journalctl" "journalctl -xb --no-pager -u kubelet.service"
    run_diagnostic_command "journalctl" "journalctl -xb --no-pager -u sshd.service"

    run_diagnostic_command "kvm-ok" "kvm-ok"

    run_diagnostic_command "lsmod" "lsmod | sort"

    if [ -s "$NVM_DIR"/nvm.sh ]; then
        echo "Found nvm. Switching to the default node version (see .nvmrc)"
        [ -f .nvmrc ] && echo ".nvmrc contents: $(cat .nvmrc)"
        # shellcheck source=/dev/null
        NVM_DIR="${HOME}/.nvm" && [ -s "$NVM_DIR"/nvm.sh ] && . "$NVM_DIR/nvm.sh"
        echo "nvm command: $(command -v nvm)"
        echo "nvm version: $(nvm --version)"
        nvm use
    fi

    run_diagnostic_command "npm" "command -v npm"
    run_diagnostic_command "npm" "npm --version"

    run_diagnostic_command "npm" "npm list -g --depth=0"

    run_diagnostic_command "pip" "command -v pip"
    run_diagnostic_command "pip" "pip --version"

    run_diagnostic_command "pip3" "command -v pip3"
    run_diagnostic_command "pip3" "pip3 --version"

    run_diagnostic_command "python" "command -v python"
    run_diagnostic_command "python" "python --version"

    run_diagnostic_command "python3" "command -v python3"
    run_diagnostic_command "python3" "python3 --version"

    run_diagnostic_command "showmount" "timeout 15s showmount -e localhost"

    run_diagnostic_command "sshd" "sshd -T"

    run_diagnostic_command "systemctl" "systemctl --version"
    run_diagnostic_command "systemctl" "systemctl list-unit-files | sort"
    run_diagnostic_command "systemctl" "systemctl -l status kubelet.service"
    run_diagnostic_command "systemctl" "systemctl -l status sshd.service"
    run_diagnostic_command "systemctl" "systemctl --failed"

    run_diagnostic_command "vagrant" "vagrant version"
    run_diagnostic_command "vagrant" "vagrant global-status --prune"
    run_diagnostic_command "vagrant" "vagrant box list -i"

    run_diagnostic_command "virsh" "virsh nodeinfo"
    run_diagnostic_command "virsh" "virsh list --all"

    run_diagnostic_command "virt-df" "virt-df -h"

    run_diagnostic_command "virsh" "virsh net-list"
    run_diagnostic_command "virsh" "virsh net-dhcp-leases vagrant-libvirt"

    run_diagnostic_command "tree" "tree ."
    run_diagnostic_command "tree" "tree $HOME/.vagrant.d/boxes"
    run_diagnostic_command "tree" "tree /vagrant"

    for i in "${directories_to_print[@]}"; do
        print_directory_contents "$i"
    done

    for i in "${files_to_print[@]}"; do
        print_file_contents "$i"
    done
}

vagrant_vm_check() {
    local vagrant_vm_name="${1}"
    if [ -z "$vagrant_vm_name" ]; then
        echo "Vagrant VM name is not set."
    else
        run_diagnostic_command "vagrant" "vagrant ssh-config $vagrant_vm_name"
    fi

    unset vagrant_vm_name
}

virsh_domain_check() {
    local virsh_domain_name="${1}"
    if [ -z "$virsh_domain_name" ]; then
        echo "WARNING: virsh domain name is not set."
    else
        run_diagnostic_command "virsh" "virsh dumpxml $virsh_domain_name"
        run_diagnostic_command "virsh" "virsh domifaddr $virsh_domain_name"
        run_diagnostic_command "virsh" "virsh domifaddr $virsh_domain_name --source arp"
        print_file_contents "/var/log/libvirt/qemu/$virsh_domain_name.log"

        run_diagnostic_command "virt-filesystems" "virt-filesystems --all -d $virsh_domain_name"
        run_diagnostic_command "virt-log" "virt-log -d $virsh_domain_name"

        for i in "${directories_to_print[@]}"; do
            run_diagnostic_command "virt-ls" "virt-ls -hl -d $virsh_domain_name $i"
        done

        for i in "${files_to_print[@]}"; do
            run_diagnostic_command "virt-cat" "virt-cat -d $virsh_domain_name $i"
        done

        timeout 15s expect -c "
            set timeout 10
            spawn virsh console $virsh_domain_name
            expect {
            \"Escape character\" {send \"\r\r\" ; exp_continue}
            \"Escape character\" {send \"\r\r\" ; exp_continue}
            \"login:\" {send \"vagrant\r\"; exp_continue}
            \"Password:\" {send \"vagrant\r\";}
            }
            expect \"~ $\"
            send \"echo  123\r\"
            expect \"~ #\"
            send \"date\r\"
            send \"exit\r\"
            expect \"login:\"
            send \"\"
            expect eof
        "
    fi
    unset virsh_domain_name
}

virsh_disk_image_check() {
    local vagrant_libvirt_img_path="${1}"
    if [ -z "$vagrant_libvirt_img_path" ]; then
        echo "WARNING: virsh img path is not set."
    else
        run_diagnostic_command "virt-filesystems" "virt-filesystems --all -a $vagrant_libvirt_img_path"
        run_diagnostic_command "virt-log" "virt-log -a $vagrant_libvirt_img_path"

        for i in "${directories_to_print[@]}"; do
            run_diagnostic_command "virt-ls" "virt-ls -hl -a $vagrant_libvirt_img_path $i"
        done

        for i in "${files_to_print[@]}"; do
            run_diagnostic_command "virt-cat" "virt-cat -a $vagrant_libvirt_img_path $i"
        done
    fi

    unset vagrant_libvirt_img_path
}

run_diagnostic_command() {
    command_name="${1}"
    command_function_name="${2}"

    echo "-------- START $command_function_name, pwd: $(pwd) --------"

    if command -v "$command_name" >/dev/null 2>&1; then
        eval "$command_function_name"
    else
        echo "WARNING: $command_name command not found"
    fi

    echo "-------- END $command_function_name, pwd: $(pwd) --------"

    unset command_name
    unset command_function_name
}

usage() {
    echo "Usage:"
    echo "  -a, --disk-image                                  - run diagnostics against a disk image. Set the path to the image with -l, --vagrant-libvirt-img-path."
    echo "  -h, --help                                        - show this help."
    echo "  -o, --host                                        - run diagnostics against the host system."
    echo "  -i, --libvirt-guest                               - run diagnostics against a libvirt guest. Set the guest name with -n, --vagrant-vm-name."
}

main() {
    local cmd=$1

    if [[ -z "$cmd" ]]; then
        echo "ERROR: no command selected. Exiting..."
        usage
        exit 1
    fi

    echo "Selected command: $cmd"

    if [[ $cmd == "host" ]]; then
        host_diagnostics
    elif [[ $cmd == "libvirt_guest" ]]; then
        echo "Selected VM name: $vagrant_vm_name"
        vagrant_vm_check "$vagrant_vm_name"
        virsh_domain_check "$vagrant_vm_name"
    elif [[ $cmd == "disk_image" ]]; then
        echo "Selected disk image path: $vagrant_libvirt_img_path"
        virsh_disk_image_check "$vagrant_libvirt_img_path"
    elif [[ $cmd == "help" ]]; then
        usage
    else
        usage
    fi
}

main "$cmd"
