#!/bin/sh
# installation script for vagrant and vagrant-libvirt
# tested on debian 10

wget https://releases.hashicorp.com/vagrant/2.2.7/vagrant_2.2.7_x86_64.deb
dpkg -i vagrant_2.2.7_x86_64.deb
rm vagrant_2.2.7_x86_64.deb
apt-get install -y qemu=1:3.1+dfsg-8+deb10u4 \
                   ebtables=2.0.10.4+snapshot20181205-3 \
                   dnsmasq-base=2.80-1 \
                   libxslt-dev \
                   libxml2-dev=2.9.4+dfsg1-7+b3 \
                   libvirt-dev=5.0.0-4+deb10u1 \
                   zlib1g-dev=1:1.2.11.dfsg-1 \
                   ruby-dev=1:2.5.1 \
                   qemu-utils=1:3.1+dfsg-8+deb10u4
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-hostsupdater
usermod -a -G libvirt vagrant
