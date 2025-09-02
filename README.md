# SSH Port Forwarding Demo

This Terraform configuration sets up a complete SSH port forwarding demonstration environment using AWS infrastructure.

## Architecture Overview

The infrastructure consists of:

- **VPC**: Custom VPC with public and private subnets
- **Bastion Host**: EC2 instance in public subnet (Amazon Linux 2)
- **Internal Server**: EC2 instance in private subnet (Ubuntu 24.04) running web services
- **Security Groups**: Minimum required security rules for each component

## Infrastructure Components

### 1. Bastion Host (Public Instance)
- **OS**: Amazon Linux 2
- **Location**: Public subnet with Elastic IP
- **Purpose**: Secure gateway to access private resources
- **Services**: SSH gateway, port forwarding hub

### 2. Internal Server (Private Instance)
- **OS**: Ubuntu 24.04 LTS
- **Location**: Private subnet
- **Services**: 
  - Python web service (port 8080)
- **Purpose**: Simulate internal application server
