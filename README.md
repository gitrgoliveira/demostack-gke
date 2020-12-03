# Consul Enterprise on GKE

This repo aims to allow testing or demoing of Consul Enterprise and OSS features, using k8s clusters managed by GCP (GKE).

## Cloud Requirements
A GCP account with a DNS hosted zone.

## Client Requirements
The following cli's must be installed:
 - gcloud
 - kubectl
 - helm
 - consul (v1.8.4+)

## Customisations
You'll need to change all the refrences to the hosted zone from "ric.gcp.hashidemos.io" to your own.
