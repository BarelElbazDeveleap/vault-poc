path "/secret/*" {
  capabilities = ["read"]
}

path "auth/kubernetes/login" {
  capabilities = ["create", "read"]
}