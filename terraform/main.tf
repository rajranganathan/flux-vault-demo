provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "example" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = var.kubernetes_host
  disable_iss_validation = true
}

data "vault_policy_document" "read_secrets" {
  rule {
    path         = "secret/*"
    capabilities = ["read", "list"]
    description  = "read secrets"
  }
}

resource "vault_policy" "read_secrets" {
  name   = "read-secrets"
  policy = data.vault_policy_document.read_secrets.hcl
}

resource "vault_kubernetes_auth_backend_role" "flux_vault_demo" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "flux-vault-demo"
  bound_service_account_names      = ["flux-vault-demo"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 3600
  token_policies                   = ["read-secrets"]
  audience                         = "vault"
}