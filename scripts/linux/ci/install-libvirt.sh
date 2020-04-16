#!/bin/sh
# installation script for libvirt
# to be run as root
# tested on debian 10

apt-get install -y --no-install-recommends \
    dnsmasq-base=2.80-1 \
    ebtables=2.0.10.4+snapshot20181205-3 \
    libguestfs-tools=1:1.40.2-2 \
    libvirt-clients=5.0.0-4+deb10u1 \
    libvirt-daemon-system=5.0.0-4+deb10u1 \
    libvirt-dev=5.0.0-4+deb10u1 \
    libxml2-dev=2.9.4+dfsg1-7+b3 \
    libxslt-dev \
    qemu-kvm=1:3.1+dfsg-8+deb10u4 \
    qemu-utils=1:3.1+dfsg-8+deb10u4 \
    qemu=1:3.1+dfsg-8+deb10u4 \
    rsync=3.1.3-6 \
    ruby-dev=1:2.5.1 \
    zlib1g-dev=1:1.2.11.dfsg-1
