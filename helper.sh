
function c1_kctx {
    kubectl config use-context $(kubectl config get-contexts -o name | grep cluster-1-gke)
}
function c2_kctx {
    kubectl config use-context $(kubectl config get-contexts -o name | grep cluster-2-gke)
}
function c3_kctx {
    kubectl config use-context $(kubectl config get-contexts -o name | grep cluster-3-gke)
}

function vault1_ctx {
    c1_kctx 1>/dev/null
    export VAULT_SKIP_VERIFY=1
    export VAULT_ADDR=https://$(kubectl get svc vault-active -o jsonpath={..ip} --allow-missing-template-keys=false):8200
    export VAULT_TOKEN=$(cat cluster-1.root_token)
}
function vault2_ctx {
    c2_kctx 1>/dev/null
    export VAULT_SKIP_VERIFY=1
    export VAULT_ADDR=https://$(kubectl get svc vault-active -o jsonpath={..ip} --allow-missing-template-keys=false):8200
    export VAULT_TOKEN=$(cat cluster-2.root_token)
}

function c1_kctl {
    c1_kctx 1>/dev/null
    kubectl $*
}
function c2_kctl {
    c2_kctx 1>/dev/null
    kubectl $*
}
function c3_kctl {
    c3_kctx 1>/dev/null
    kubectl $*
}

function setup-consul {
    kubectl config use-context $(kubectl config get-contexts -o name | grep cluster-1-gke)
    export CONSUL_HTTP_TOKEN=$(kubectl get secrets  consul-bootstrap-acl-token -o jsonpath={..token} | base64 -D)
    export CONSUL_HTTP_ADDR=https://$(kubectl get svc consul-ui -o jsonpath={..ip})
    echo -n | openssl s_client -connect ${CONSUL_HTTP_ADDR//https:\/\/}:443  | \
        sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > cluster-1.cert
    export CONSUL_CAPATH=$(pwd)/cluster-1.cert
    export CONSUL_TLS_SERVER_NAME=127.0.0.1
}

function detect_endpoints {
    echo ""
    echo "================================================================"
    echo ".: End points detected:"
    c1_kctx 2>&1 1>/dev/null
    echo $(kubectl get svc -o jsonpath={..annotations.'external-dns\.alpha\.kubernetes\.io\/hostname'}) | tr ' ' '\n' | uniq
    c2_kctx 2>&1 1>/dev/null
    echo $(kubectl get svc -o jsonpath={..annotations.'external-dns\.alpha\.kubernetes\.io\/hostname'}) | tr ' ' '\n' | uniq
    echo "================================================================"
    echo "Token: $(c1_kctl get secrets  consul-bootstrap-acl-token -o jsonpath={..token} | base64 -D)"
    echo "================================================================"
    echo ""
}

function bastion {
    c1_kctl exec -it bastion -- bash
}