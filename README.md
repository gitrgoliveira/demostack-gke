# Vault and Consul Enterprise on GKE

This repo aims to allow testing of Vault and Consul Enterprise and OSS features, using k8s clusters managed by GCP (GKE).

## Cloud Requirements
A GCP account, project and a DNS hosted zone.
I've created my hosted zone using https://github.com/lhaig/dns-multicloud?ref=v1.1

## Client Requirements
The following cli's must be installed:
 - gcloud
 - kubectl
 - helm3
 - consul (v1.9.1+)
 - vault (v1.6.1+)

## Customisations
You'll need to change all the references to the hosted zone from `ric.gcp.hashidemos.io` to your own.

These can be found in:
 * [dns/ExternalDNS-cluster-1.yaml]()
 * [dns/ExternalDNS-cluster-2.yaml]()
 * [values1_consul.yaml]()
 * [values1_vault.yaml]()
 * [values2_consul.yaml]()
 * [values2_vault.yaml]()


*more coming soon*