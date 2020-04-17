#!/bin/sh
# installation script for vagrant and vagrant-libvirt
# to be run as root
# tested on debian 10

wget https://releases.hashicorp.com/vagrant/"${VAGRANT_VERSION}"/vagrant_"${VAGRANT_VERSION}"_x86_64.deb
dpkg -i vagrant_"${VAGRANT_VERSION}"_x86_64.deb
rm vagrant_"${VAGRANT_VERSION}"_x86_64.deb

# Workaround for https://github.com/hashicorp/vagrant/issues/11524
vagrant plugin install vagrant-hostsupdater
vagrant plugin install vagrant-libvirt
