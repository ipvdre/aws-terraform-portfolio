resource "vault_kv_secret_v2" "vpn_secrets" {
    mount = "secret"
    name  = "vpn-lab"

    data_json = jsonencode({
        tunnel1_preshared_key = aws_vpn_connection.home.tunnel1_preshared_key
        tunnel2_preshared_key = aws_vpn_connection.home.tunnel2_preshared_key
        tunnel1_address       = aws_vpn_connection.home.tunnel1_address
        tunnel2_address       = aws_vpn_connection.home.tunnel2_address
        home_public_ip        = var.home_public_ip
    })
}