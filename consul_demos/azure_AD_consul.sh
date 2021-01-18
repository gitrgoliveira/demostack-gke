#!/bin/sh

AUTH_SP_NAME=ric-consul-oidc
AUTH_CLIENT_SECRET=MyConsulTestPasswordChangeMe
AUTH_TENANT=$(az account show |jq -r '.tenantId')

AUTH_REDIRECT_URL1=http://localhost:8550/oidc/callback
AUTH_REDIRECT_URL2=${CONSUL_HTTP_ADDR}/ui/oidc/callback
AUTH_REDIRECT_URL3=https://$(kubectl get svc consul-ui  -o jsonpath={..annotations.'external-dns\.alpha\.kubernetes\.io\/hostname'})/ui/oidc/callback

az ad app create --display-name ${AUTH_SP_NAME} \
  --password ${AUTH_CLIENT_SECRET} \
  --reply-urls ${AUTH_REDIRECT_URL1} ${AUTH_REDIRECT_URL2} ${AUTH_REDIRECT_URL3} \
  --output none

AUTH_CLIENT_ID=$(az ad app list --display-name ${AUTH_SP_NAME} |jq -r '.[0].appId')

tee auth_config.json > /dev/null <<EOF
{
  "AllowedRedirectURIs": [
    "${AUTH_REDIRECT_URL1}",
    "${AUTH_REDIRECT_URL2}",
    "${AUTH_REDIRECT_URL3}"
  ],
  "BoundAudiences": [
      "${AUTH_CLIENT_ID}"
  ],
  "ClaimMappings": {
    "sub": "sub",
    "email": "email"
    },
    "ListClaimMappings": {
      "roles": "groups"
  },
  "OIDCClientID": "$AUTH_CLIENT_ID",
  "OIDCClientSecret": "$AUTH_CLIENT_SECRET",
  "OIDCDiscoveryURL": "https://login.microsoftonline.com/${AUTH_TENANT}/v2.0",
  "VerboseOIDCLogging": true
}
EOF
consul acl auth-method create -type oidc \
    -name="aad" \
    -description="azuread" \
    -token-locality="global" \
    -max-token-ttl=5m \
    -config=@auth_config.json || true

rm auth_config.json

consul acl binding-rule create \
  -bind-name=admin \
  -bind-type=role \
  -method=aad \
  -selector='list.groups is empty'

consul acl role create -name admin -policy-name global-management || true

# consul login -type=oidc -method=aad -token-sink-file=./token