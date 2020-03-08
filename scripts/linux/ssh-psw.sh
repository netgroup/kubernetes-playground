#!/bin/sh

sudo sed -ri 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
