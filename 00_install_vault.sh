#! /bin/bash
source setup_kubeconfig.sh
source helper.sh
# set -eu
# set -o pipefail

## setting up DNS first
c1_kctl apply -f dns/ExternalDNS-cluster-1.yaml
c2_kctl apply -f dns/ExternalDNS-cluster-2.yaml

VAULT_HELM_VERSION=0.9.0

source cross_tls.sh
function setup-vault {
  source tls_vault.sh
  let cluster_id=$1-1
  terraform output -json | jq -r .kubernetes_clusters.value[$cluster_id].gcpckms > seal_config.hcl
  kubectl create secret generic vault-kms-config \
    --from-file=seal_config.hcl
  rm -f seal_config.hcl

  if helm status vault 2>&1 1>/dev/null; then
  helm upgrade vault hashicorp/vault -f values$1_vault.yaml \
    --version $VAULT_HELM_VERSION
  else
  helm install vault hashicorp/vault -f values$1_vault.yaml \
    --version $VAULT_HELM_VERSION
  fi

  echo ".: waiting for Cluster-$1 Vault IP address"
  while ! kubectl get svc vault -o jsonpath={..ip} --allow-missing-template-keys=false 2>/dev/null; do
    sleep 3
  done
  echo ""
  export VAULT_ADDR=https://$(kubectl get svc vault -o jsonpath={..ip} --allow-missing-template-keys=false):8200
  echo $VAULT_ADDR
  export VAULT_SKIP_VERIFY=1

  sleep 5
  vaultinit=0
  vault operator init -status || vaultinit=$?
  if [ $vaultinit -eq 2 ]; then
  echo "Initializing Vault $1 cluster"
  vault operator init -recovery-shares=1 -recovery-threshold=1 > keys$1.txt
  sleep 15 # waiting for the unsealing process and for the nodes to join.
  fi

  echo ".: Waiting for Cluster-$1 Vault Active Leader IP address"
  while ! kubectl get svc vault-active -o jsonpath={..ip} --allow-missing-template-keys=false 2>/dev/null; do
    sleep 3
  done
  echo ""
  export VAULT_ADDR=https://$(kubectl get svc vault-active -o jsonpath={..ip} --allow-missing-template-keys=false):8200
  echo "Checking if Vault $1 is ready"
  while ! curl -k $VAULT_ADDR/sys/health -s --show-error; do
    sleep 2
    echo "Waiting for Vault $1 to be ready"
  done
  grep -h 'Initial Root Token' keys$1.txt | awk '{print $NF}' > cluster-$1.root_token
  export VAULT_TOKEN=$(cat cluster-$1.root_token)
  vault write /sys/license text=$(cat /Users/rgoliveira/Documents/vault_v2lic.hclic)
}

c1_kctx
setup-vault "1"
c2_kctx
setup-vault "2"

detect_endpoints;
c1_kctx;
