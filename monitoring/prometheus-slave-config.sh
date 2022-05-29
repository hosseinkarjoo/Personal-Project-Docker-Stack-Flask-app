#!/usr/bin/env bash

SLAVE_PUB_IP=$(curl ipv4.icanhazip.com)
SLAVE_PRV_IP=$(/usr/sbin/ip a show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)
# awdawd

sed -i -e "s/SLAVE_PUB_IP/$SLAVE_PUB_IP/" prometheus.yml
sed -i -e "s/SLAVE_PRV_IP/$SLAVE_PRV_IP/" prometheus.yml
