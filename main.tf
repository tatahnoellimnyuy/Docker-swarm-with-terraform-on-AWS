# Create a VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

# Create Web Public Subnet
resource "aws_subnet" "web-subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Web-1a"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = var.internet_gateway
  }
}

# Create Web layber route table
resource "aws_route_table" "web-rt" {
  vpc_id = aws_vpc.my-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "WebRT"
  }
}

# Create Web Subnet association with Web route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.web-subnet.id
  route_table_id = aws_route_table.web-rt.id
 }


  # Create Web Security Group
resource "aws_security_group" "web-sg" {
    name        = "Web-SG"
    description = "Allow ssh inbound traffic"
    vpc_id      = aws_vpc.my-vpc.id
  
    ingress {
      description = "ssh from VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    
   ingress {
  description = "Docker client communication"
  from_port   = 2379
  to_port     = 2379
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
    }
   ingress {
  description = "This port is used for communication between the nodes of a Docker Swarm"
  from_port   = 2377
  to_port     = 2377
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
    }
  ingress {
  description = "for overlay network traffic (container ingress networking)"
  from_port   = 4789
  to_port     = 4789
  protocol    = "udp"
  cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "container network discovery"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    }
 ingress {
    description = "container network discovery"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    tags = {
      Name = "Web-SG"
    }
}
  
# Generates a secure private k ey and encodes it as PEM
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
# Create the Key Pair
resource "aws_key_pair" "ec2_key" {
  key_name   = "keypair"  
  public_key = tls_private_key.ec2_key.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  filename = "keypair.pem"
  content  = tls_private_key.ec2_key.private_key_pem
}

#data for amazon linux

data "aws_ami" "amazon-2" {
    most_recent = true
  
    filter {
      name = "name"
      values = ["amzn2-ami-hvm-*-x86_64-ebs"]
    }
    owners = ["amazon"]
  }
 
#create ec2 instances 

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 3.0"

  for_each = toset(["master", "node1", "node2"])

  name = "instance-${each.key}"

  ami                    = "${data.aws_ami.amazon-2.id}"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ec2_key.key_name
  monitoring             = true
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]
  subnet_id              = aws_subnet.web-subnet.id
  user_data            = file("install.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}