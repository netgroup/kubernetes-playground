#!/bin/sh
# installation script for libvirt
# to be run as root
# tested on debian 10

apt-get update -y

apt-get install -y --no-install-recommends \
    bridge-utils \
    cpu-checker \
    dnsmasq-base \
    ebtables \
    libguestfs-tools \
    libvirt-clients \
    libvirt-daemon-system \
    libvirt-bin \
    libvirt-dev \
    libxml2-dev \
    libxslt1-dev \
    nfs-kernel-server \
    qemu-kvm \
    qemu-utils \
    qemu \
    rsync \
    ruby-dev \
    zlib1g-dev

modprobe -a kvm

# This doesn't have effect if you don't open a new shell
adduser "$(id -un)" libvirt
adduser "$(id -un)" kvm
