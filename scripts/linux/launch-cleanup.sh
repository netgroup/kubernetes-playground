#!/bin/sh

#this script is used by Vagrantfile to launch cleanup-k8s-and-cni.sh as vagrant user

/bin/su -c "/vagrant/scripts/linux/cleanup-k8s-and-cni.sh" - vagrant


