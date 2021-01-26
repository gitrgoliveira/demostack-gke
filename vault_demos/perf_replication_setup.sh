#! /bin/bash
# source helper.sh
# set -eu
# set -o pipefail

vault1_ctx
vault write -force  sys/replication/performance/primary/disable || true
sleep 2
vault write sys/replication/performance/primary/enable primary_cluster_addr=https://$(kubectl get svc vault-active -o jsonpath={..ip} --allow-missing-template-keys=false):8201
sleep 2

export VAULT_ADDR=https://$(kubectl get svc vault-active -o jsonpath={..ip} --allow-missing-template-keys=false):8200
echo "Checking if Vault is ready"
while ! curl -k $VAULT_ADDR/sys/health -s --show-error; do
  sleep 2
  echo "Waiting for Vault to be ready"
done

vault2_ctx
echo ".: generated secondary_public_key"
# c1_kctx exec vault-1
# vault
vault write -f /sys/replication/performance/secondary/generate-public-key -format=json | jq -r .data.secondary_public_key > secondary_public_key.delete

vault1_ctx
vault write sys/replication/performance/primary/secondary-token id=vault-200 \
    ttl=2h secondary_public_key=$(cat secondary_public_key.delete) \
    -format=json | jq -r .data.token > token.jwt

# exit 0

echo ".: got the token, now setting up second cluster"
vault2_ctx
vault write  -force  /sys/replication/performance/secondary/disable || true
sleep 2
vault write /sys/replication/performance/secondary/enable \
    token=$(cat token.jwt)

sleep 5
echo "Checking if Vault 2 is ready"
while ! curl -k $VAULT_ADDR/sys/health -s --show-error; do
  sleep 2
  echo "Waiting for Vault 2 to be ready"
done
# Generate new root token
echo ".: generating root token for cluster-2"
vault operator generate-root -generate-otp -format=json | jq -r .otp > otp.delete
vault operator generate-root -init -otp=$(cat otp.delete) -format=json | jq -r .nonce > nonce.delete
vault operator generate-root -format=json -nonce=$(cat nonce.delete) $(grep -h 'Recovery Key 1' keys1.txt | awk '{print $NF}') | jq -r .encoded_token > encoded_token.delete
vault operator generate-root \
  -decode=$(cat encoded_token.delete) \
  -otp=$(cat otp.delete) > cluster-2.root_token

vault1_ctx