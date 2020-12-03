#! /bin/bash

gcloud container clusters get-credentials \
    $(terraform output -json kubernetes_clusters | jq -r .[0].kubernetes_cluster_name) \
    --region $(terraform output region)

gcloud container clusters get-credentials \
    $(terraform output -json kubernetes_clusters | jq -r .[1].kubernetes_cluster_name) \
    --region $(terraform output region)

# gcloud container clusters get-credentials \
#     $(terraform output -json kubernetes_clusters | jq -r .[2].kubernetes_cluster_name) \
#     --region $(terraform output region)

# kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml

# kubectl apply -f kubernetes-dashboard-admin.rbac.yaml