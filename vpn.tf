resource "aws_customer_gateway" "home" {
    bgp_asn    = 65000 # required by AWS API; not used for static site-to-site VPN
    ip_address = var.home_public_ip
    type       = "ipsec.1"

    tags = {
        Name = "home-customer-gateway"
    }
}

resource "aws_vpn_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "main-vpn-gateway"
    }
}

resource "aws_vpn_connection" "home" {
  customer_gateway_id = aws_customer_gateway.home.id
  vpn_gateway_id      = aws_vpn_gateway.main.id
  type                = "ipsec.1"
  static_routes_only  = true

  tunnel1_preshared_key            = var.vpn_tunnel1_psk
  tunnel1_ike_versions             = ["ikev1", "ikev2"]
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase1_integrity_algorithms  = ["SHA1"]
  tunnel1_phase1_dh_group_numbers      = [14]
  tunnel1_phase2_encryption_algorithms = ["AES256"]
  tunnel1_phase2_integrity_algorithms  = ["SHA1"]
  tunnel1_phase2_dh_group_numbers      = [14]

  tunnel2_preshared_key            = var.vpn_tunnel2_psk
  tunnel2_ike_versions             = ["ikev1", "ikev2"]
  tunnel2_phase1_encryption_algorithms = ["AES256"]
  tunnel2_phase1_integrity_algorithms  = ["SHA1"]
  tunnel2_phase1_dh_group_numbers      = [14]
  tunnel2_phase2_encryption_algorithms = ["AES256"]
  tunnel2_phase2_integrity_algorithms  = ["SHA1"]
  tunnel2_phase2_dh_group_numbers      = [14]

  tags = {
    Name = "home-vpn-connection"
  }
}

resource "aws_vpn_connection_route" "home" {
    destination_cidr_block = var.home_subnet_cidr
    vpn_connection_id      = aws_vpn_connection.home.id
}

resource "aws_vpn_gateway_route_propagation" "public" {
    vpn_gateway_id = aws_vpn_gateway.main.id
    route_table_id = aws_route_table.public.id
}

resource "aws_vpn_gateway_route_propagation" "private" {
    vpn_gateway_id = aws_vpn_gateway.main.id
    route_table_id = aws_route_table.private.id
}
