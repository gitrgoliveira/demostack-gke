#! /bin/bash

gcloud container clusters get-credentials \
    $(terraform output -json kubernetes_clusters | jq -r .[0].kubernetes_cluster_name) \
    --region $(terraform output -json region | jq -r)

gcloud container clusters get-credentials \
    $(terraform output -json kubernetes_clusters | jq -r .[1].kubernetes_cluster_name) \
    --region $(terraform output -json region | jq -r)

# gcloud container clusters get-credentials \
#     $(terraform output -json kubernetes_clusters | jq -r .[2].kubernetes_cluster_name) \
#     --region $(terraform output region)
