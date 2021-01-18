
helm repo add helm-openldap https://jp-gouin.github.io/helm-openldap/

if helm -n vault-demos status openldap 2>&1 1>/dev/null; then
helm upgrade openldap helm-openldap/openldap \
    -f vault_demos/ldap_values.yaml \
    -n vault-demos \
    --version 2.0.4 \
    --create-namespace \
    --wait
else
helm install openldap helm-openldap/openldap \
    -f vault_demos/ldap_values.yaml \
    -n vault-demos \
    --version 2.0.4 \
    --create-namespace \
    --wait
    # --create-namespace --dry-run  > vault_demos/ldap.yaml
fi

vault auth enable -tls-skip-verify ldap || true

vault write -tls-skip-verify auth/ldap/config \
    url="ldap://openldap.vault-demos" \
    binddn="cn=admin,dc=example,dc=org" \
    userattr="uid" \
    bindpass='password' \
    userdn="ou=Users,dc=example,dc=org" \
    groupdn="ou=Groups,dc=example,dc=org" \
    insecure_tls=true

vault auth list -tls-skip-verify -format=json  | jq -r '.["ldap/"].accessor' > accessor.txt
vault write -tls-skip-verify identity/group name="approvers" \
      policies="superuser" \
      type="external"

vault read -tls-skip-verify identity/group/name/approvers  -format=json | jq -r .data.id > approvers_group_id.txt

vault write -tls-skip-verify identity/group-alias name="approvers" \
        mount_accessor=$(cat accessor.txt) \
        canonical_id=$(cat approvers_group_id.txt)

vault write -tls-skip-verify identity/group name="requesters" \
      policies="test" \
      type="external"

vault read -tls-skip-verify identity/group/name/requesters  -format=json | jq -r .data.id > requesters_group_id.txt

vault write -tls-skip-verify identity/group-alias name="requesters" \
        mount_accessor=$(cat accessor.txt) \
        canonical_id=$(cat requesters_group_id.txt)

vault kv put -tls-skip-verify kv/cgtest example=value

rm approvers_group_id.txt
rm requesters_group_id.txt
rm accessor.txt