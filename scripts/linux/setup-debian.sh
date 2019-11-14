#!/bin/sh

echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" >> /etc/apt/sources.list.d/virtualbox.list

wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -

apt-get update
apt-get install -y virtualbox-6.0

VAGRANT_VERSION="2.2.6"
TEMP_DEB="$(mktemp)" &&
wget -O "$TEMP_DEB" "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.deb" &&
dpkg -i "$TEMP_DEB"
rm -f "$TEMP_DEB"
