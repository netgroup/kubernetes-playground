#!/bin/bash

set -e
set -o pipefail

hosts_to_add_input="$1"

IFS=';' read -r -a hosts_to_add <<<"$hosts_to_add_input"

echo "Hosts to add (input parameter): ${hosts_to_add_input}"
echo "Hosts to add: ${hosts_to_add[*]}"

HOSTS_FILE_PATH=/etc/hosts

for element in "${hosts_to_add[@]}"; do
    IFS=',' read -r -a host_to_ip <<<"$element"
    HOSTNAME="${host_to_ip[0]}"
    IP="${host_to_ip[1]}"

    if grep -q "$HOSTNAME" /etc/hosts; then
        echo "$HOSTNAME already exists: $(grep "$HOSTNAME" "$HOSTS_FILE_PATH")"
    else
        HOSTS_LINE="$IP $HOSTNAME"
        echo "Adding $HOSTS_LINE to $ETC_HOSTS"
        echo "$HOSTS_LINE" >>$HOSTS_FILE_PATH
    fi
done

echo "$HOSTS_FILE_PATH contents: $(cat $HOSTS_FILE_PATH)"
