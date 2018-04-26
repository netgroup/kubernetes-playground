#!/bin/sh

echo "MAC addresses: $(cat /sys/class/net/*/address)"
echo "Product UUID: $(cat /sys/class/dmi/id/product_uuid)"

echo "Disabling swap"
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
