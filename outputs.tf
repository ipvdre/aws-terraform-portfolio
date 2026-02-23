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
  value       = aws_customer_gateway.home.id
}

output "vpn_gateway_id" {
  description = "ID of the VPN gateway"
  value       = aws_vpn_gateway.main.id
}

output "vpn_connection_id" {
  description = "ID of the VPN connection"
  value       = aws_vpn_connection.home.id
}

output "vpn_tunnel1_address" {
  description = "Public IP of VPN tunnel 1"
  value       = aws_vpn_connection.home.tunnel1_address
}

output "vpn_tunnel2_address" {
  description = "Public IP of VPN tunnel 2"
  value       = aws_vpn_connection.home.tunnel2_address
}

output "vpn_tunnel1_preshared_key" {
  description = "Pre-shared key for VPN tunnel 1"
  value       = aws_vpn_connection.home.tunnel1_preshared_key
  sensitive   = true
}

output "vpn_tunnel2_preshared_key" {
  description = "Pre-shared key for VPN tunnel 2"
  value       = aws_vpn_connection.home.tunnel2_preshared_key
  sensitive   = true
}
