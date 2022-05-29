#!/usr/bin/env bash

MONITOR_PUB_IP=$(cat ./hosts-monitoring-stack.txt)
SLAVE_PUB_IP=$(cat ./hosts-worker.txt)


sed -i -e "s/MONITOR_PUB_IP/${MONITOR_PUB_IP}/" ./prometheus.yml
sed -i -e "s/SLAVE_PUB_IP/${SLAVE_PUB_IP}/" ./prometheus.yml
sed -i -e "s/prometheus-var/${MONITOR_PUB_IP}/" ./datasource.yml
