#!/bin/bash

cd /home/cloud_user/Devops-Training/DevOps-Training-Full-Deployment
git checkout monitoring
git pull --no-commit origin monitoring
cat /home/cloud_user/Devops-Training/terraform-ansible-jenkins/hosts-monitoring-stack.txt > /home/cloud_user/Devops-Training/DevOps-Training-Full-Deployment/hosts-monitoring-stack.txt
cat /home/cloud_user/Devops-Training/terraform-ansible-jenkins/hosts-worker.txt > /home/cloud_user/Devops-Training/DevOps-Training-Full-Deployment/hosts-worker.txt
git add hosts-monitoring-stack.txt hosts-worker.txt
git commit -m "upload ips"
git push origin monitoring



