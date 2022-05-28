terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "main_VPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Jenkins_test"
  }
}

resource "aws_internet_gateway" "igw-jenkins" {
  vpc_id = aws_vpc.main_VPC.id
}

resource "aws_route_table" "main-table" {
  vpc_id = aws_vpc.main_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-jenkins.id
  }
  tags = {
    Name = "main-table-jenkins"
  }
}

resource "aws_main_route_table_association" "default" {
  vpc_id         = aws_vpc.main_VPC.id
  route_table_id = aws_route_table.main-table.id
}

resource "aws_subnet" "jenkins_subnet" {
  availability_zone = "us-east-1a"
  vpc_id = aws_vpc.main_VPC.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}





resource "aws_security_group" "sg-01" {
  vpc_id = aws_vpc.main_VPC.id
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    protocol = "tcp"
    from_port = 22
    to_port = 22
  }
  ingress {
    description = "allow anyone on port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "allow anyone on port 8080"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "allow anyone on port 8080"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "allow anyone on port 8080"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "allow anyone on port 8080"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "allow anyone on port 8080"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "allow anyone on port 8080"
    from_port   = 9104
    to_port     = 9104
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "allow anyone on port 8080"
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "alertmanager"
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "elastic"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "elastic"
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "elastic"
    from_port   = 24224
    to_port     = 24224
    protocol    = "-1"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "Jenkins-Master" {
  ami  = data.aws_ami.amzn-linux-ec2.id
  instance_type = "t2.medium" 
  key_name = aws_key_pair.sh-key-for-me.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg-01.id]
  subnet_id = aws_subnet.jenkins_subnet.id
  tags = {
    Name = "Jenkins-Master"
    
  }
  provisioner "local-exec" {
    command = <<-EOT
      rm -rf hosts.txt
      echo ${aws_instance.Jenkins-Master.public_ip} >> ./hosts.txt
#      echo ${aws_instance.Jenkins-Master.private_ip} >> ./hosts.txt
      aws ec2 wait instance-status-ok --region us-east-1 --instance-ids ${self.id} --profile cloud_user && ansible-playbook -i hosts.txt -e monitoring_prv_ip=${aws_instance.Monitoring-Stack.private_ip} -e slave_prv_ip=${aws_instance.Slave-Compute.private_ip} -e logging_pub_ip=${aws_instance.Logging-Stack.public_ip} -e logging_prv_ip=${aws_instance.Logging-Stack.private_ip} ./install_jenkins.yaml
    EOT
  }

}
resource "aws_instance" "Slave-Compute" {
  ami  = data.aws_ami.amzn-linux-ec2.id
  instance_type = "t2.medium"
  key_name = aws_key_pair.sh-key-for-me.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg-01.id]
  subnet_id = aws_subnet.jenkins_subnet.id
  tags = {
    Name  = "Slave-Compute"
  }
  provisioner "local-exec" {
    command = <<-EOT
      rm -rf hosts-worker.txt
      echo ${aws_instance.Slave-Compute.public_ip} >> ./hosts-worker.txt
#      echo ${aws_instance.Slave-Compute.private_ip} >> ./hosts-worker.txt
      aws ec2 wait instance-status-ok --region us-east-1 --instance-ids ${self.id} --profile cloud_user && ansible-playbook -i hosts-worker.txt -e nexus_address=${aws_instance.Nexus-Registry.public_ip} -e logging_address=${aws_instance.Logging-Stack.private_ip} ./install_worker.yaml
    EOT
  }
}

resource "aws_instance" "Monitoring-Stack" {
  ami  = data.aws_ami.amzn-linux-ec2.id
  instance_type = "t2.medium"
  key_name = aws_key_pair.sh-key-for-me.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg-01.id]
  subnet_id = aws_subnet.jenkins_subnet.id
  tags = {
    Name = "Monitoring-Stack"

  }
  provisioner "local-exec" {
    command = <<-EOT
      rm -rf hosts-monitoring-stack.txt
      echo ${aws_instance.Monitoring-Stack.public_ip} >> ./hosts-monitoring-stack.txt
#      echo ${aws_instance.Monitoring-Stack.private_ip} >> ./hosts-monitoring-stack.txt
      aws ec2 wait instance-status-ok --region us-east-1 --instance-ids ${self.id} --profile cloud_user && ansible-playbook -i hosts-monitoring-stack.txt -e nexus_address=${aws_instance.Nexus-Registry.public_ip} -e logging_address=${aws_instance.Logging-Stack.private_ip}  ./install_worker.yaml
    EOT
  }
}


resource "aws_instance" "Nexus-Registry" {
  ami  = data.aws_ami.amzn-linux-ec2.id
  instance_type = "t2.medium"
  key_name = aws_key_pair.sh-key-for-me.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg-01.id]
  subnet_id = aws_subnet.jenkins_subnet.id
  tags = {
    Name = "Nexus-Registry"

  }
  provisioner "local-exec" {
    command = <<-EOT
      rm -rf hosts-nexus.txt
      echo ${aws_instance.Nexus-Registry.public_ip} >> ./hosts-nexus.txt
      aws ec2 wait instance-status-ok --region us-east-1 --instance-ids ${self.id} --profile cloud_user && ansible-playbook -i ./hosts-nexus.txt -e logging_address=${aws_instance.Logging-Stack.private_ip}  ./install_nexus.yaml
    EOT
  }
}

resource "aws_instance" "Logging-Stack" {
  ami = data.aws_ami.amzn-linux-ec2.id
  instance_type = "t2.medium" 
  key_name = aws_key_pair.sh-key-for-me.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg-01.id]
  subnet_id = aws_subnet.jenkins_subnet.id
  tags = {
    Name = "Logging-Stack"
  }
  provisioner "local-exec" {
    command = <<-EOT
      rm -rf hosts-elastic.txt
      echo ${aws_instance.Logging-Stack.public_ip} >> ./hosts-elastic.txt
      aws ec2 wait instance-status-ok --region us-east-1 --instance-ids ${self.id} --profile cloud_user && ansible-playbook -i ./hosts-elastic.txt -e nexus_address=${aws_instance.Nexus-Registry.public_ip} -e logging_address=${aws_instance.Logging-Stack.private_ip}  ./install_logging.yaml
    EOT   

  }
}




resource "aws_key_pair" "sh-key-for-me" {
  key_name = "My_Key"
  public_key = file("/root/.ssh/id_rsa.pub")
}

data "aws_ami" "amzn-linux-ec2" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}


resource "null_resource" "push-to-git" {
  provisioner "local-exec" {
    command = "/bin/bash push-to-git.sh"
  }
  depends_on = [aws_instance.Jenkins-Master]
}


#resource "aws_route53_zone" "private" {
#  name = "hkarjoo.com"
#  private_zone = true
#  vpc {
#    vpc_id = aws_vpc.main_VPC.id
#  }
#}

#resource "aws_route53_record" "slave-compute" {
#  zone_id = aws_route53_zone.private.id
#  name    = "slave-compute"
#  type    = "A"
#  ttl     = "300"
#  records = [aws_instance.Slave-Compute.private_ip]
#}


#resource "aws_route53_record" "monitoring-stack" {
#  zone_id = aws_route53_zone.private.id
#  name    = "monitoring-stack"
#  type    = "A"
#  ttl     = "300"
#  records = [aws_instance.Monitoring-Stack.private_ip]
#}





