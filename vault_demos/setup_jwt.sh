#! /bin/bash

# works on MacOS only
_decode_base64_url() {
  local len=$((${#1} % 4))
  local result="$1"
  if [ $len -eq 2 ]; then result="$1"'=='
  elif [ $len -eq 3 ]; then result="$1"'='
  fi
  echo "$result" | tr '_-' '/+' | base64 -D
}

# $1 => JWT to decode
# $2 => either 1 for header or 2 for body (default is 2)
decode_jwt() { _decode_base64_url $(echo -n $1 | cut -d "." -f ${2:-2}) | jq 'if .exp then (.expStr = (.exp|gmtime|strftime("%Y-%m-%dT%H:%M:%S %Z"))) else . end'; }

VAULT_HOSTNAME=$(kubectl get svc vault-active  -o jsonpath={..annotations.'external-dns\.alpha\.kubernetes\.io\/hostname'})
vault auth enable jwt || true


vault  write  identity/oidc/config \
  issuer=https://$VAULT_HOSTNAME:8200

vault write identity/oidc/key/test_key allowed_client_ids="*"
vault read  identity/oidc/key/test_key



VAULT_USER_TOKEN=$(vault write  -field=token auth/ldap/login/ricardo password=password -field=token)
VAULT_USER_MOUNT_LDAP_ACCESSOR=$(vault auth list -format=json | jq -r .\"ldap/\".accessor)
VAULT_USER_MOUNT_JWT_ACCESSOR=$(vault auth list -format=json | jq -r .\"jwt/\".accessor)

BASE64_TEMPLATE=$(base64 <<EOF
{
  "issuing_entity": {
     "entity_name": {{identity.entity.name}},
     "groups": {{identity.entity.groups.names}},
     "metadata": {{identity.entity.metadata}},
     "entity_aliases_ldap": {{identity.entity.aliases.$VAULT_USER_MOUNT_LDAP_ACCESSOR.name}},
     "entity_aliases_jwt": {{identity.entity.aliases.$VAULT_USER_MOUNT_JWT_ACCESSOR.name}}
  },
  "nbf": {{time.now}}
}
EOF
)

vault write  identity/oidc/role/test_app key=test_key \
  client_id=test_app \
  template=$BASE64_TEMPLATE

vault write  identity/oidc/role/superuser key=test_key \
  client_id=superuser \
  template=$BASE64_TEMPLATE

echo "Generating a _wrapped_ JWT token"

VAULT_TOKEN=$VAULT_USER_TOKEN vault read -wrap-ttl=5m identity/oidc/token/test_app
JWT_TOKEN=$(VAULT_TOKEN=$VAULT_USER_TOKEN vault read -field=token identity/oidc/token/test_app)

echo "Decoding JWT token"
decode_jwt $JWT_TOKEN 1
decode_jwt $JWT_TOKEN 2

echo "OpenID config"
curl -sk \
  --request GET \
  https://$VAULT_HOSTNAME:8200/v1/identity/oidc/.well-known/openid-configuration \
  | jq .




### Setting up JWT auth in Vault

echo "Setting up JWT auth in Vault"
# Configure the JWT method using your tenant ID:
vault write auth/jwt/config \
    oidc_discovery_url="https://$VAULT_HOSTNAME:8200/v1/identity/oidc" \
    oidc_discovery_ca_pem=@cluster-1-ca.pem \
    default_role="test_app"

# Create a role in the method:
vault write auth/jwt/role/test_app \
    role_type="jwt" \
    bound_audiences="test_app" \
    user_claim="aud" policies="test"

vault write auth/jwt/role/superuser \
    role_type="jwt" \
    bound_audiences="superuser" \
    user_claim="aud" policies="superuser"

echo $JWT_TOKEN > example.vault.token
vault write auth/jwt/login role="test_app" jwt=$JWT_TOKEN
