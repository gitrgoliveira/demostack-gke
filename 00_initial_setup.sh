#! /bin/bash
# set -eu
# set -o pipefail
export GCP_PROJECT_ID=$(terraform output -json project | jq -r)

gcloud config set project $GCP_PROJECT_ID
gcloud components install gke-gcloud-auth-plugin

DNS_ZONE=$GCP_PROJECT_ID.gcp.sbx.hashicorpdemo.com
old_string=hc-4eaeab05d358430fb89d3ae6329.gcp.sbx.hashicorpdemo.com
# mac version of sed
find . -type f -name "*.yaml" -exec sed -i '' -e "s/$old_string/$DNS_ZONE/g" {} +
find . -type f -name "*.hcl" -exec sed -i '' -e "s/$old_string/$DNS_ZONE/g" {} +
find . -type f -name "*.sh" -exec sed -i '' -e "s/$old_string/$DNS_ZONE/g" {} +

source setup_kubeconfig.sh
source helper.sh

## setting up DNS first
c1_kctl apply -f dns/ExternalDNS-cluster-1.yaml
c2_kctl apply -f dns/ExternalDNS-cluster-2.yaml

detect_endpoints;
c1_kctx;