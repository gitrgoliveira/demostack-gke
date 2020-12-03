# Vault and Consul Enterprise on GKE

This repo aims to allow testing of Vault and Consul Enterprise and OSS features, using k8s clusters managed by GCP (GKE).

## Cloud Requirements
A GCP account, project and a DNS hosted zone.
I've created my hosted zone using https://github.com/lhaig/dns-multicloud?ref=v1.1

## Client Requirements
The following cli's must be installed:
 - gcloud
 - kubectl
 - helm
 - consul (v1.9.0+)
 - vault (v1.6.0+)

## Customisations
You'll need to change all the refrences to the hosted zone from "ric.gcp.hashidemos.io" to your own.

*more coming soon*