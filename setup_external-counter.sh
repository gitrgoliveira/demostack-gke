source helper.sh
c3_kctx
EXTERNAL_COUNTER=$(kubectl get svc external-counting -o jsonpath={..ip})
tee external-counter.json > /dev/null <<EOF
{
  "Node": "legacy_node",
  "Address": "$EXTERNAL_COUNTER",
  "NodeMeta": {
    "external-node": "true",
    "external-probe": "true"
  },
  "Service": {
    "ID": "counting1",
    "Service": "external-counting",
    "Port": 9001
  }
}
EOF
curl -k --request PUT \
  --data @external-counter.json \
  --header "X-Consul-Token: $CONSUL_HTTP_TOKEN" \
  $CONSUL_HTTP_ADDR/v1/catalog/register
consul config write consul_config/counting-terminating-gateway.hcl

consul acl policy create -name "external-counting-write-policy" \
  -datacenter "cluster-1" \
  -datacenter "cluster-2" \
  -rules -<<EOF
service "external-counting" {
  policy = "write"
}
EOF
ID=$(consul acl token list -format=json | jq -r '.[] | select(.Description | contains("counting-terminating-gateway")) | .AccessorID')
consul acl token update -id $ID -policy-name external-counting-write-policy -merge-policies -merge-roles -merge-service-identities
