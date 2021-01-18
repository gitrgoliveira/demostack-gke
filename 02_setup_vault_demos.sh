#! /bin/bash
source helper.sh

vault1_ctx
vault secrets enable -version=2 kv
vault kv put kv/test message='Hello world'

source vault_demos/setup_policies.sh
source vault_demos/install_openldap.sh
source vault_demos/setup_jwt.sh
