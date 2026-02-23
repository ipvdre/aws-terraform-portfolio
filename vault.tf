data "vault_kv_secret_v2" "vpn_secrets" {
  mount = "secret"
  name  = "vpn-lab"
}
