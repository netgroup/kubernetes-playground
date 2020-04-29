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
    qemu-kvm \
    qemu-utils \
    qemu \
    rsync \
    ruby-dev \
    tree \
    zlib1g-dev
