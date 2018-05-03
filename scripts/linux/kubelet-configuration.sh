#!/bin/sh

broadcast_address="$1"

echo "Get IP address corresponding to the interface with broadcast address: $broadcast_address"
IP=$(ip addr | grep "$broadcast_address" | awk -F'[ /]+' '{print $3}')
echo "Ensure kubelet uses $IP IP address"
KubeletNode="/etc/systemd/system/kubelet.service.d/90-node-ip.conf"
cat <<-EOF >${KubeletNode}
	[Service]
	Environment="KUBELET_EXTRA_ARGS= $KUBELET_EXTRA_ARGS --node-ip=${IP}"
EOF
chmod 755 "${KubeletNode}"
systemctl daemon-reload
