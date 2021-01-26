# Vault and Consul Enterprise on GKE

This repo aims to allow testing of Vault and Consul Enterprise and OSS features, using k8s clusters managed by GCP (GKE).

It deploys 2 k8s clusters with Consul and Vault with the following setup:

 - **Vault**
   - Performance Replication with cluster 2.
   - LDAP auth backend
   - JWT auth backend
   - Identity secrets engine
   - KV secrets engine

 - **Consul**
   - Ingress, Terminating and Mesh gateways
   - SSO
   - Audit
   - JWT auth

---
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
 * [consul_config/webapp-ingress.hcl]()
 * [tls_vault.sh]()
 * [values1_consul.yaml]()
 * [values1_vault.yaml]()
 * [values2_consul.yaml]()
 * [values2_vault.yaml]()

You will also need to ammend the places where a license is written:
 * 00_install_vault.sh (line 56)
 * 01_install_consul.sh (lines 60 and 61)

---
*coming soon*
## Architecture

## Demos
### Vault Performance Replication
Without using the API port for unwrapping.
Only cluster port is necessary to be exposed for the replication to happen.

### Vault Control groups
### Vault as a Service Identity broker (JWT)

### Consul Service Mesh
#### Splitters
#### Canary
#### Gateways
