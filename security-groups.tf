#############################################################
# Security Group for Bastion Host (Public Instance)
#############################################################

resource "aws_security_group" "bastion_sg" {
  name        = "${var.frontend_prefix}-bastion-sg"
  description = "Security group for bastion host with minimum required rules"
  vpc_id      = aws_vpc.frontend_vpc.id

  tags = {
    Name        = "${var.frontend_prefix}-bastion-sg"
    environment = "${var.frontend_environment}"
    Purpose     = "Bastion Host Security Group"
  }
}

# Bastion Host Ingress Rules
resource "aws_vpc_security_group_ingress_rule" "bastion_ssh_ingress" {
  security_group_id = aws_security_group.bastion_sg.id
  description       = "SSH access from internet"

  cidr_ipv4   = "0.0.0.0/0" # In production, replace with your specific IP: "YOUR_IP/32"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  tags = {
    Name = "bastion-ssh-ingress"
  }
}

# Web service port (8080/tcp) to internal server
resource "aws_vpc_security_group_egress_rule" "bastion_web_service_egress" {
  security_group_id = aws_security_group.bastion_sg.id
  description       = "Access to internal web service for port forwarding"

  referenced_security_group_id = aws_security_group.internal_server_sg.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"

  tags = {
    Name = "bastion-web-service-egress"
  }
}

# Bastion Host Egress Rules
/* 
This egress rule is for SSH Jump Connection `ssh -i sshkey.pem -J ec2-user@BASTION_IP ubuntu@PRIVATE_IP`
The bastion host needs to initiate an outbound SSH connection to the private instance. Without this egress rule, the bastion cannot make that connection.
*/
resource "aws_vpc_security_group_egress_rule" "bastion_ssh_egress" {
  security_group_id = aws_security_group.bastion_sg.id
  description       = "SSH to private instances"

  cidr_ipv4   = var.frontend_vpc_address_space # Option 1 - CIDR is more flexible if you add more private instances later
#   referenced_security_group_id = aws_security_group.internal_server_sg.id # Option 2 - More specific
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  tags = {
    Name = "bastion-ssh-egress"
  }
}

resource "aws_vpc_security_group_egress_rule" "bastion_https_egress" {
  security_group_id = aws_security_group.bastion_sg.id
  description       = "HTTPS for package updates"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  tags = {
    Name = "bastion-https-egress"
  }
}

resource "aws_vpc_security_group_egress_rule" "bastion_http_egress" {
  security_group_id = aws_security_group.bastion_sg.id
  description       = "HTTP for package updates"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  tags = {
    Name = "bastion-http-egress"
  }
}

#############################################################
# Security Group for Internal Server (Private Instance)
#############################################################

resource "aws_security_group" "internal_server_sg" {
  name        = "${var.frontend_prefix}-internal-server-sg"
  description = "Security group for internal server with minimum required rules"
  vpc_id      = aws_vpc.frontend_vpc.id

  tags = {
    Name        = "${var.frontend_prefix}-internal-server-sg"
    environment = "${var.frontend_environment}"
    Purpose     = "Internal Server Security Group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "internal_web_service_ingress" {
  security_group_id = aws_security_group.internal_server_sg.id
  description       = "Web service access from bastion"

  referenced_security_group_id = aws_security_group.bastion_sg.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"

  tags = {
    Name = "internal-web-service-ingress"
  }
}

# Internal Server Ingress Rules
resource "aws_vpc_security_group_ingress_rule" "internal_ssh_ingress" {
  security_group_id = aws_security_group.internal_server_sg.id
  description       = "SSH from bastion host"

  referenced_security_group_id = aws_security_group.bastion_sg.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"

  tags = {
    Name = "internal-ssh-ingress"
  }
}

resource "aws_vpc_security_group_ingress_rule" "internal_http_ingress" {
  security_group_id = aws_security_group.internal_server_sg.id
  description       = "HTTP access from bastion"

  referenced_security_group_id = aws_security_group.bastion_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"

  tags = {
    Name = "internal-http-ingress"
  }
}

# Internal Server Egress Rules
resource "aws_vpc_security_group_egress_rule" "internal_https_egress" {
  security_group_id = aws_security_group.internal_server_sg.id
  description       = "HTTPS for package updates"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  tags = {
    Name = "internal-https-egress"
  }
}

resource "aws_vpc_security_group_egress_rule" "internal_http_egress" {
  security_group_id = aws_security_group.internal_server_sg.id
  description       = "HTTP for package updates"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  tags = {
    Name = "internal-http-egress"
  }
}

# resource "aws_vpc_security_group_egress_rule" "internal_response_traffic_egress" {
#   security_group_id = aws_security_group.internal_server_sg.id
#   description       = "Response traffic to bastion"

#   referenced_security_group_id = aws_security_group.bastion_sg.id
#   from_port                    = 1024
#   to_port                      = 65535
#   ip_protocol                  = "tcp"

#   tags = {
#     Name = "internal-response-traffic-egress"
#   }
# }
