# VPC
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "ID of the NAT gateway"
  value       = aws_nat_gateway.main.id
}

output "nat_eip_public_ip" {
  description = "Public IP of the NAT gateway EIP"
  value       = aws_eip.nat.public_ip
}

# Subnets
output "public_subnet_id" {
  description = "ID of the public subnet (subnet-a)"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet (subnet-b)"
  value       = aws_subnet.private.id
}

# EC2 Instances
output "instance1_id" {
  description = "ID of EC2 instance 1 (public subnet)"
  value       = aws_instance.instance1.id
}

output "instance1_private_ip" {
  description = "Private IP of EC2 instance 1"
  value       = aws_instance.instance1.private_ip
}

output "instance2_id" {
  description = "ID of EC2 instance 2 (private subnet)"
  value       = aws_instance.instance2.id
}

output "instance2_private_ip" {
  description = "Private IP of EC2 instance 2"
  value       = aws_instance.instance2.private_ip
}

# Security
output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.security-group1.id
}

output "public_nacl_id" {
  description = "ID of the public subnet NACL"
  value       = aws_network_acl.public.id
}

output "private_nacl_id" {
  description = "ID of the private subnet NACL"
  value       = aws_network_acl.private.id
}

# VPN
output "customer_gateway_id" {
  description = "ID of the customer gateway"
  value       = aws_customer_gateway.onprem.id
}

output "vpn_gateway_id" {
  description = "ID of the VPN gateway"
  value       = aws_vpn_gateway.main.id
}

output "vpn_connection_id" {
  description = "ID of the VPN connection"
  value       = aws_vpn_connection.onprem.id
}

output "vpn_tunnel1_address" {
  description = "Public IP of VPN tunnel 1"
  value       = aws_vpn_connection.onprem.tunnel1_address
}

output "vpn_tunnel2_address" {
  description = "Public IP of VPN tunnel 2"
  value       = aws_vpn_connection.onprem.tunnel2_address
}

output "vpn_tunnel1_preshared_key" {
  description = "Pre-shared key for VPN tunnel 1"
  value       = aws_vpn_connection.onprem.tunnel1_preshared_key
  sensitive   = true
}

output "vpn_tunnel2_preshared_key" {
  description = "Pre-shared key for VPN tunnel 2"
  value       = aws_vpn_connection.onprem.tunnel2_preshared_key
  sensitive   = true
}

# SSH
output "ssh_command_instance1" {
  description = "SSH command for instance 1 (public subnet)"
  value       = "ssh -i ~/.ssh/aws-vpn-lab ec2-user@${aws_instance.instance1.private_ip}"
}

output "ssh_command_instance2" {
  description = "SSH command for instance 2 (private subnet)"
  value       = "ssh -i ~/.ssh/aws-vpn-lab ec2-user@${aws_instance.instance2.private_ip}"
}

# Vault
output "vault_secret_keys" {
  description = "Available keys in the Vault vpn-lab secret (for verification)"
  value       = keys(data.vault_kv_secret_v2.vpn_secrets.data)
  sensitive   = true
}

# Logging
output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = aws_flow_log.vpc.id
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}
