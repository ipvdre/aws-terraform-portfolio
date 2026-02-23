# =============================================================================
# Public Subnet NACL
# =============================================================================
resource "aws_network_acl" "public" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "public-nacl"
    }
}
resource "aws_network_acl_association" "public" {
    network_acl_id = aws_network_acl.public.id
    subnet_id      = aws_subnet.public.id
}

# --- Inbound Rules ---
resource "aws_network_acl_rule" "public-allow-icmp-inbound" {
    network_acl_id = aws_network_acl.public.id
    rule_number    = 100
    protocol       = "icmp"
    rule_action    = "allow"
    icmp_code      = -1
    icmp_type      = -1
    egress         = false
    cidr_block     = var.home_subnet_cidr
}
resource "aws_network_acl_rule" "public-allow-ssh-inbound" {
    network_acl_id = aws_network_acl.public.id
    rule_number    = 110
    protocol       = "tcp"
    rule_action    = "allow"
    from_port      = 22
    to_port        = 22
    egress         = false
    cidr_block     = var.home_subnet_cidr
}
resource "aws_network_acl_rule" "public-allow-ephemeral-inbound" {
    network_acl_id = aws_network_acl.public.id
    rule_number    = 200
    protocol       = "tcp"
    rule_action    = "allow"
    from_port      = 1024
    to_port        = 65535
    egress         = false
    cidr_block     = "0.0.0.0/0"
}

# --- Outbound Rules ---
resource "aws_network_acl_rule" "public-allow-icmp-outbound" {
    network_acl_id = aws_network_acl.public.id
    rule_number    = 100
    protocol       = "icmp"
    rule_action    = "allow"
    icmp_code      = -1
    icmp_type      = -1
    egress         = true
    cidr_block     = var.home_subnet_cidr
}
resource "aws_network_acl_rule" "public-allow-http-outbound" {
    network_acl_id = aws_network_acl.public.id
    rule_number    = 110
    protocol       = "tcp"
    rule_action    = "allow"
    from_port      = 80
    to_port        = 80
    egress         = true
    cidr_block     = "0.0.0.0/0"
}
resource "aws_network_acl_rule" "public-allow-https-outbound" {
    network_acl_id = aws_network_acl.public.id
    rule_number    = 120
    protocol       = "tcp"
    rule_action    = "allow"
    from_port      = 443
    to_port        = 443
    egress         = true
    cidr_block     = "0.0.0.0/0"
}
resource "aws_network_acl_rule" "public-allow-ephemeral-outbound" {
    network_acl_id = aws_network_acl.public.id
    rule_number    = 200
    protocol       = "tcp"
    rule_action    = "allow"
    from_port      = 1024
    to_port        = 65535
    egress         = true
    cidr_block     = "0.0.0.0/0"
}

# =============================================================================
# Private Subnet NACL
# =============================================================================
resource "aws_network_acl" "private" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "private-nacl"
    }
}
resource "aws_network_acl_association" "private" {
    network_acl_id = aws_network_acl.private.id
    subnet_id      = aws_subnet.private.id
}

# --- Inbound Rules ---
resource "aws_network_acl_rule" "private-allow-icmp-inbound" {
    network_acl_id = aws_network_acl.private.id
    rule_number    = 100
    protocol       = "icmp"
    rule_action    = "allow"
    icmp_code      = -1
    icmp_type      = -1
    egress         = false
    cidr_block     = var.home_subnet_cidr
}
resource "aws_network_acl_rule" "private-allow-ssh-inbound" {
    network_acl_id = aws_network_acl.private.id
    rule_number    = 110
    protocol       = "tcp"
    rule_action    = "allow"
    from_port      = 22
    to_port        = 22
    egress         = false
    cidr_block     = var.home_subnet_cidr
}
resource "aws_network_acl_rule" "private-allow-ephemeral-inbound" {
    network_acl_id = aws_network_acl.private.id
    rule_number    = 200
    protocol       = "tcp"
    rule_action    = "allow"
    from_port      = 1024
    to_port        = 65535
    egress         = false
    cidr_block     = "0.0.0.0/0"
}

# --- Outbound Rules ---
resource "aws_network_acl_rule" "private-allow-icmp-outbound" {
    network_acl_id = aws_network_acl.private.id
    rule_number    = 100
    protocol       = "icmp"
    rule_action    = "allow"
    icmp_code      = -1
    icmp_type      = -1
    egress         = true
    cidr_block     = var.home_subnet_cidr
}
resource "aws_network_acl_rule" "private-allow-http-outbound" {
    network_acl_id = aws_network_acl.private.id
    rule_number    = 110
    protocol       = "tcp"
    rule_action    = "allow"
    from_port      = 80
    to_port        = 80
    egress         = true
    cidr_block     = "0.0.0.0/0"
}
resource "aws_network_acl_rule" "private-allow-https-outbound" {
    network_acl_id = aws_network_acl.private.id
    rule_number    = 120
    protocol       = "tcp"
    rule_action    = "allow"
    from_port      = 443
    to_port        = 443
    egress         = true
    cidr_block     = "0.0.0.0/0"
}
resource "aws_network_acl_rule" "private-allow-ephemeral-outbound" {
    network_acl_id = aws_network_acl.private.id
    rule_number    = 200
    protocol       = "tcp"
    rule_action    = "allow"
    from_port      = 1024
    to_port        = 65535
    egress         = true
    cidr_block     = "0.0.0.0/0"
}

# =============================================================================
# Security Group
# =============================================================================
resource "aws_security_group" "security-group1" {
    name = var.security_group_name
    description = "Security group for allowing ICMP and SSH traffic"
    vpc_id = aws_vpc.main.id

    tags = {
        Name = var.security_group_name
    }
}
resource "aws_security_group_rule" "allow-ICMP-inbound" {
    type              = "ingress"
    from_port         = -1
    to_port           = -1
    protocol          = "icmp"
    cidr_blocks       = [var.home_subnet_cidr]
    security_group_id = aws_security_group.security-group1.id
}
resource "aws_security_group_rule" "allow-ICMP-outbound" {
    type              = "egress"
    from_port         = -1
    to_port           = -1
    protocol          = "icmp"
    cidr_blocks       = [var.home_subnet_cidr]
    security_group_id = aws_security_group.security-group1.id
}
resource "aws_security_group_rule" "allow-SSH-inbound" {
    type              = "ingress"
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = [var.home_subnet_cidr]
    security_group_id = aws_security_group.security-group1.id
}
resource "aws_security_group_rule" "allow-HTTPS-outbound" {
    type              = "egress"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.security-group1.id
}
resource "aws_security_group_rule" "allow-HTTP-outbound" {
    type              = "egress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.security-group1.id
}
