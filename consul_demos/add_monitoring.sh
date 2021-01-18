#! /bin/bash

##############################
# Adding Monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && \
helm repo add grafana https://grafana.github.io/helm-charts && \
helm repo update

c1_kctx
helm install prometheus prometheus-community/prometheus \
    -f monitoring/prometheus-values2.yaml

helm install grafana grafana/grafana \
    -f monitoring/grafana-values.yaml

c2_kctx
helm install prometheus prometheus-community/prometheus \
    -f monitoring/prometheus-values2.yaml

helm install grafana grafana/grafana \
    -f monitoring/grafana-values.yaml \
    --wait
