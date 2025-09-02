#############################################################
# Outputs for SSH Port Forwarding Demo
#############################################################

output "bastion_host_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_eip.frontend_public_instance_eip.public_ip
}

output "bastion_host_public_dns" {
  description = "Public DNS name of the bastion host"
  value       = aws_instance.frontend_public_instance01.public_dns
}

output "internal_server_private_ip" {
  description = "Private IP address of the internal server"
  value       = aws_instance.frontend_private_instance01.private_ip
}

output "ssh_key_name" {
  description = "Name of the SSH key pair"
  value       = aws_key_pair.fe_keypair.key_name
}

output "private_key_filename" {
  description = "Filename for the private key (save this key to connect)"
  value       = local.fe_private_key_filename
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.frontend_vpc.cidr_block
}

output "ssh_connection_examples" {
  description = "SSH connection examples for port forwarding"
  value       = <<-EOT
    
    =================================================================
    SSH Port Forwarding Examples:
    =================================================================
    
    1. Save the private key first:
       terraform output -raw private_key > ssh-privatekey.pem
       chmod 400 ssh-privatekey.pem

    2. Load SSH keys
       ssh-add ssh-privatekey.pem

    3. Connect to bastion host and internal-server:
       ssh -i ssh-privatekey.pem ec2-user@<bastion-host-ip>
       ssh -J ec2-user@<bastion-host-ip> ubuntu@<internal-server-ip>

    4. Local Port Forwarding (access internal web service on your local port 80):
       ssh -L 9999:<internal-server-ip>:80 ec2-user@<bastion-host-ip>
       Then access: http://localhost:9999

    5. Local Port Forwarding (access internal web service on your local port 9000):
       ssh -L 9000:<internal-server-ip>:8080 ec2-user@<bastion-host-ip>
       Then access: http://localhost:9000

    =================================================================
  EOT
}

output "private_key" {
  description = "Private key for SSH access (keep this secure!)"
  value       = tls_private_key.fe_keypair.private_key_openssh
  sensitive   = true
}
# terraform output -raw private_key > ssh-privatekey.pem
# chmod 400 ssh-privatekey.pem
# ssh-add ssh-privatekey.pem
