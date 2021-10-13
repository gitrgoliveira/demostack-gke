source helper.sh
c1_kctx
setup-consul
# EXTERNAL_COUNTER=$(kubectl get svc external-counting -o jsonpath={..ip})
tee google.json > /dev/null <<EOF
{
  "Node": "legacy_node",
  "Address": "www.google.com",
  "Service": {
    "ID": "google",
    "Service": "google",
    "Port": 80
  }
}
EOF
curl -k --request PUT \
  --data @google.json \
  --header "X-Consul-Token: $CONSUL_HTTP_TOKEN" \
  $CONSUL_HTTP_ADDR/v1/catalog/register
consul config write consul_config/google-terminating-gateway.hcl

consul acl policy create -name "external-google-policy" \
  -datacenter "cluster-1" \
  -datacenter "cluster-2" \
  -rules -<<EOF
service "google" {
  policy = "write"
}
EOF
ID=$(consul acl token list -format=json | jq -r '.[] | select(.Description | contains("google-terminating-gateway")) | .AccessorID')
consul acl token update -id $ID -policy-name external-google-policy -merge-policies -merge-roles -merge-service-identities
consul intention create -allow "*/*" "google" || true
