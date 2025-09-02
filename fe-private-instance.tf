data "aws_ami" "fe_private_instance_ami" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
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
# Frontend Private Instance 01
#############################################################

resource "aws_instance" "frontend_private_instance01" {
  ami                    = data.aws_ami.fe_private_instance_ami.id
  instance_type          = var.fe_instance_type
  subnet_id              = aws_subnet.frontend_private_subnet01.id
  # vpc_security_group_ids = [aws_security_group.internal_server_sg.id, aws_security_group.port_forwarding_sg.id]
  vpc_security_group_ids = [aws_security_group.internal_server_sg.id]
  key_name               = aws_key_pair.fe_keypair.key_name

  # Ensure NAT Gateway and route table are ready before creating instance
  depends_on = [
    aws_nat_gateway.frontend_ngw,
    aws_route_table_association.frontend_private_subnet01_association
  ]

  # User data script to set up Python's built-in web server
  user_data_base64 = base64encode(<<-EOF
#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting user data script execution..."

# Update package list
apt-get update -y

# Install required packages
apt-get install -y python3 htop net-tools traceroute nginx lsof tcpdump nmap telnet curl wget dnsutils iproute2 iptables tree vim

# Start nginx and enable it
systemctl start nginx
systemctl enable nginx

# Create web content directory for Python server
mkdir -p /home/ubuntu/webserver
cd /home/ubuntu/webserver

# Create the HTML content
cat > index.html << 'HTMLEOF'
<h1>Hello from Internal Server!</h1><p>Port forwarding works!</p>
HTMLEOF

# Create additional test files
cat > about.html << 'ABOUTEOF'
<h2>About this server</h2><p>This is a private EC2 instance accessible only through SSH port forwarding via the bastion host.</p>
ABOUTEOF

cat > api.json << 'JSONEOF'
{"message": "Hello from Internal Server!", "service": "Python built-in web server", "port": 8080}
JSONEOF

# Set ownership
chown -R ubuntu:ubuntu /home/ubuntu/webserver

# Create systemd service for Python built-in web server
cat > /etc/systemd/system/python-webserver.service << 'SERVICEEOF'
[Unit]
Description=Python Built-in Web Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/webserver
ExecStart=/usr/bin/python3 -m http.server 8080 --bind 0.0.0.0
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
SERVICEEOF

# Reload systemd and start the service
systemctl daemon-reload
systemctl enable python-webserver
systemctl start python-webserver

# Create HTML page for nginx
cat > /var/www/html/index.html << 'NGINXEOF'
<!DOCTYPE html>
<html>
<head>
    <title>Internal Server - SSH Port Forwarding Demo</title>
</head>
<body>
    <h1>Internal Server</h1>
    <p>This is the internal server accessible only through the bastion host.</p>
    <p>Services running:</p>
    <ul>
        <li>Nginx on port 80</li>
        <li>Python built-in web server on port 8080</li>
    </ul>
    <p>Access this server using SSH port forwarding through the bastion host.</p>
    <hr>
    <p><strong>Test URLs for port 8080:</strong></p>
    <ul>
        <li><a href="http://localhost:9000/">Main page</a> (when port forwarded to localhost:9000)</li>
        <li><a href="http://localhost:9000/about.html">About page</a></li>
        <li><a href="http://localhost:9000/api.json">JSON API</a></li>
    </ul>
</body>
</html>
NGINXEOF

echo "User data script completed successfully!"
EOF
  )

  tags = {
    Name        = "${var.frontend_prefix}-internal-server"
    environment = "${var.frontend_environment}"
    Role        = "Internal Server"
  }
}