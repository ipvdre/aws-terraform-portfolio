# Reads pre-deployment secrets (onprem_public_ip, onprem_subnet_cidr) from Vault.
# These values are surfaced as outputs for verification against tfvars inputs.
data "vault_kv_secret_v2" "vpn_secrets" {
  mount = "secret"
  name  = "vpn-lab"
}
