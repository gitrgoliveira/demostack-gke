#! /bin/bash
source helper.sh

c1_kctx
SA_TOKEN=$(kubectl get sa default -o jsonpath={.secrets[0].name})
kubectl get secrets $SA_TOKEN -o json | jq -r '.data["ca.crt"]' | base64 -D > cluster-1-ca.pem

c2_kctx
SA_TOKEN=$(kubectl get sa default -o jsonpath={.secrets[0].name})
kubectl get secrets $SA_TOKEN -o json | jq -r '.data["ca.crt"]' | base64 -D > cluster-2-ca.pem
kubectl create secret generic tls-ca-cluster-1 \
    --from-file=cluster-1-ca.pem=cluster-1-ca.pem || true

c1_kctx
kubectl create secret generic tls-ca-cluster-2 \
    --from-file=cluster-2-ca.pem=cluster-2-ca.pem || true
