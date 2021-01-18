#! /bin/bash
source helper.sh
# set -eu
# set -o pipefail

c1_kctx
source consul_demos/add_monitoring.sh

c1_kctl apply -f c1_manifests/
c2_kctl apply -f c2_manifests/
setup-consul 2>&1 1>/dev/null


# Setting up a generic failover query
curl -k --request POST \
    --data @consul_config/global_query.json \
    --header "X-Consul-Token: $CONSUL_HTTP_TOKEN" \
    $CONSUL_HTTP_ADDR/v1/query


echo ".: adding Consul configurations"
consul config write consul_config/dashboard-defaults.hcl
consul config write consul_config/webapp-defaults.hcl
consul config write consul_config/webapp-resolver.hcl
consul config write consul_config/webapp-splitter.hcl
consul config write consul_config/webapp-router.hcl
consul config write consul_config/local-counter-resolver.hcl


consul config write consul_config/dashboard-ingress-tcp.hcl
consul config write consul_config/webapp-ingress.hcl

# Setup default deny intention.
consul intention create -deny "*/*" "*/*" || true
# Setup allow intentions
# consul intention create -allow "dashboard-service/dashboard-service" default/external-counting || true
# consul intention create -allow "webapp/webapp" default/external-counting || true
consul intention create -allow "dashboard-service/dashboard-service" default/local-counter || true
consul intention create -allow "webapp/webapp" default/local-counter || true
consul intention create -allow dashboard-ingress-gateway "dashboard-service/dashboard-service" || true
consul intention create -allow webapp-ingress-gateway "webapp/webapp" || true

c1_kctx
kubectl wait --for=condition=ready pod/bastion
kubectl exec -it bastion -- apt update
kubectl exec -it bastion -- apt install -y dnsutils iputils-ping
#** to get to the bastion:
# kubectl exec -it bastion -- bash
source consul_demos/azure_AD_consul.sh
source consul_demos/add_jwt_auth.sh


# dig @consul-dns webapp.service.webapp.cluster-1.consul
# dig @consul-dns local-counter.query.consul
# kubectl exec consul-server-0 -- grep -ri bootstrap /consul/data/audit/

# curl http://localhost:19000/clusters?format=json
# curl http://localhost:19000/listeners?format=json
# curl --request POST http://localhost:19000/logging?level=debug
# curl --request POST http://localhost:19000/logging?level=debug
detect_endpoints
c1_kctx