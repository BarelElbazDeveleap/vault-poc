### The task:
migrate from hardcoded K8s secrets to the hashicorp vault

Make a POC of how to use the hashicorp vault to store secrets and use them in the application.

Assume values.yaml contains a list of keys, hashicorp vault helm chart is intalled in the same cluster.

My direction was:
1. Create local minikube cluster
2. Install vault and secrets-store-csi-driver
3. Configure vault:
    * Enable kubernetes auth method
    * Create a policy
    * Create a role

4. Create service account and role binding
5. Create a simple app that uses the secrets-store-csi-driver to get the secrets from the vault

### The result:
```
MountVolume.SetUp failed for volume "vault-secrets" : rpc error: code = Unknown desc = failed to mount secrets store objects for pod default/sample-6b454479-7r68f, err: rpc error: code = Unknown desc = error making mount request: couldn't read secret "databasePassword": failed to login: Error making API request. URL: POST http://vault:8200/v1/auth/kubernetes/login Code: 403. Errors: * permission denied
```

### Resources:
* https://developer.hashicorp.com/vault/docs/auth/kubernetes
* https://developer.hashicorp.com/vault/tutorials/kubernetes/agent-kubernetes
* https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
* https://github.com/learnwithgvr/kubernets-vault-secret-csi-volume/blob/master/steps.sh
* https://www.youtube.com/watch?v=6pGcb9JE3vU&t=1004s
* 

### Prerequisites
minikube start

helm repo add hashicorp https://helm.releases.hashicorp.com

### install vault with the csi driver provider
helm install vault hashicorp/vault --set "server.dev.enabled=true" --set "csi.enabled=true"

### install the secrets-store-csi-driver
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system

### Steps I performed to configure the vault
cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt

kubectl get secret vault-auth-secret -n default -o jsonpath="{.data.token}" | base64 --decode

vault auth enable kubernetes
vault write auth/kubernetes/config @kubernetes-auth.json
vault policy write app-policy app-policy.hcl
vault write auth/kubernetes/role/app-role @app-role.json