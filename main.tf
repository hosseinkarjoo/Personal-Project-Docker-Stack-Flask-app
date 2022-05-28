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

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "rt"
  }
}

resource "aws_main_route_table_association" "default" {
  vpc_id         = aws_vpc.my-vpc.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_subnet" "subnet" {
  availability_zone = "us-east-1a"
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}





resource "aws_security_group" "sg" {
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
    description = "allow anyone to access python-flask-app"
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


resource "aws_instance" "Jenkins" {
  ami  = data.aws_ami.amzn-linux-ec2.id
  instance_type = "t3.medium" 
  key_name = aws_key_pair.ssh-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.subnet.id
  tags = {
    Name = "Jenkins"
    
  }
  provisioner "local-exec" {
    command = <<-EOT
#      rm -rf hosts.txt
      echo ${aws_instance.Jenkins.public_ip} > ./Jenkins-addr.txt
#      echo ${aws_instance.Jenkins-Master.private_ip} >> ./hosts.txt
      aws ec2 wait instance-status-ok --region us-east-1 --instance-ids ${self.id} --profile cloud_user && ansible-playbook -i Jenkins-addr.txt -e DOCKER_PRV_IP=${aws_instance.Docker-Stack.private_ip} ./install_jenkins.yaml
    EOT
  }

}
resource "aws_instance" "Docker-Stack" {
  ami  = data.aws_ami.amzn-linux-ec2.id
  instance_type = "t3.medium"
  key_name = aws_key_pair.ssh-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.subnet.id
  tags = {
    Name  = "Docker-Stack"
  }
  provisioner "local-exec" {
    command = <<-EOT
#      rm -rf Doc.txt
      echo ${aws_instance.Slave-Compute.public_ip} > ./Docker-addr.txt
#      echo ${aws_instance.Slave-Compute.private_ip} >> ./hosts-worker.txt
      aws ec2 wait instance-status-ok --region us-east-1 --instance-ids ${self.id} --profile cloud_user && ansible-playbook -i Docker-addr.txt ./install_worker.yaml
    EOT
  }
}


resource "aws_key_pair" "ssh-key" {
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









