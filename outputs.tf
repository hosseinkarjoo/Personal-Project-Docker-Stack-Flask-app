#output "ec2-public-ip" {
#  value = {
#    for instance in aws_instance.First_ec2 :
#    instance.id => instance.private_ip
#  }
#}
output "JENKINS_MASTER_PRV_IP" {
  value = aws_instance.Jenkins-Master.private_ip
}

output "SLAVE_COMPUTE_PRV_IP" {
  value = aws_instance.Slave-Compute.private_ip
}

output "Monitoring-Stack_PRV_IP" {
  value = aws_instance.Monitoring-Stack.private_ip
}

output "JENKINS_MASTER_PUB_IP" {
  value = aws_instance.Jenkins-Master.public_ip
}

output "SLAVE_COMPUTE_PUB_IP" {
  value = aws_instance.Slave-Compute.public_ip
}

output "Monitoring-Stack_PUB_IP" {
  value = aws_instance.Monitoring-Stack.public_ip
}

output "NEXUS_REGISTRY_PRV_IP" {
  value = aws_instance.Nexus-Registry.private_ip
}

output "NEXUS_REGISTRY_PUB_IP" {
  value = aws_instance.Nexus-Registry.public_ip
}


output "LOGGING_STACK_PRV_IP" {
  value = aws_instance.Logging-Stack.private_ip
}

output "LOGGING_STACK_PUB_IP" {
  value = aws_instance.Logging-Stack.public_ip
}
