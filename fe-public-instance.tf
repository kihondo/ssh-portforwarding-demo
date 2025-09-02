data "aws_ami" "fe_public_instance_ami" {
  most_recent = true
  owners      = ["amazon"] # Amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

#############################################################
# Frontend Public Instance 01
#############################################################
resource "aws_eip" "frontend_public_instance_eip" {
  tags = {
    Name        = "${var.frontend_prefix}-public-instance01-eip"
    environment = "${var.frontend_environment}"
  }
}

resource "aws_eip_association" "fe_public_instance_eip_assoc" {
  instance_id   = aws_instance.frontend_public_instance01.id
  allocation_id = aws_eip.frontend_public_instance_eip.id
}

resource "aws_instance" "frontend_public_instance01" {
  ami                    = data.aws_ami.fe_public_instance_ami.id
  instance_type          = var.fe_instance_type
  subnet_id              = aws_subnet.frontend_public_subnet01.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.fe_keypair.key_name

  # User data script to set up the bastion host
  user_data_base64 = base64encode(<<-EOF
#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting bastion host setup script..."

# Update the system
yum update -y

# Install essential networking and troubleshooting tools
yum install -y \
    net-tools \
    lsof \
    tcpdump \
    nmap \
    telnet \
    curl \
    wget \
    bind-utils \
    iproute \
    iptables \
    htop \
    tree \
    vim \
    nc \
    traceroute

amazon-linux-extras install nginx1

echo "Bastion host setup completed successfully!"
echo "Available commands: netcheck, testports, connectprivate"
EOF
  )

  tags = {
    Name        = "${var.frontend_prefix}-bastion-host"
    environment = "${var.frontend_environment}"
    Role        = "Bastion Host"
  }
}
