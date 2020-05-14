#!/bin/sh

# Workaround for https://github.com/hashicorp/vagrant/issues/11524
# When updating this, ensure that the versions you specify here match
# with Vagrantfile
vagrant plugin install vagrant-libvirt --plugin-version "= 0.1.2"
