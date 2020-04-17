#!/bin/sh
# installation script for libvirt
# to be run as root
# tested on debian 10

apt-get install -y --no-install-recommends \
    dnsmasq-base \
    ebtables \
    libguestfs-tools \
    libvirt-clients \
    libvirt-bin \
    libvirt-dev \
    libxml2-dev \
    libxslt1-dev \
    qemu-kvm \
    qemu-utils \
    qemu \
    rsync \
    ruby-dev \
    zlib1g-dev
