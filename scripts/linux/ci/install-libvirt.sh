#!/bin/sh
# installation script for libvirt
# to be run as root
# tested on debian 10

apt-get install -y --no-install-recommends \
    libvirt-clients=5.0.0-4+deb10u1 \
    libvirt-daemon-system=5.0.0-4+deb10u1 \
    qemu-kvm=1:3.1+dfsg-8+deb10u4
