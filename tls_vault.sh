# set -e
# set -u
# set -o pipefail
# SERVICE is the name of the Vault service in Kubernetes.
# It does not have to match the actual running service, though it may help for consistency.
SERVICE=vault
# NAMESPACE where the Vault service is running.
NAMESPACE=default
# SECRET_NAME to create in the Kubernetes secrets store.
SECRET_NAME=vault-server-tls
# TMPDIR is a temporary working directory.
TMPDIR=/tmp

openssl genrsa -out ${TMPDIR}/vault.key 2048
cat <<EOF >${TMPDIR}/csr.conf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${SERVICE}
DNS.2 = ${SERVICE}.${NAMESPACE}
DNS.3 = ${SERVICE}.${NAMESPACE}.svc
DNS.4 = ${SERVICE}.${NAMESPACE}.svc.cluster.local
DNS.5 = *.vault-internal
DNS.5 = *.hc-7b910e3ece0c4fa386d0665927c.gcp.sbx.hashicorpdemo.com
DNS.6 = vault-0
DNS.7 = vault-1
DNS.8 = vault-2
DNS.9 = vault-0.vault-internal
DNS.10 = vault-1.vault-internal
DNS.11 = vault-2.vault-internal
IP.1 = 127.0.0.1
EOF

openssl req -new -key ${TMPDIR}/vault.key -subj "/CN=${SERVICE}.${NAMESPACE}.svc" -out ${TMPDIR}/server.csr -config ${TMPDIR}/csr.conf
cat <<EOF >${TMPDIR}/csr-approver.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: csr-approver
rules:
- apiGroups:
  - certificates.k8s.io
  resources:
  - certificatesigningrequests
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - certificates.k8s.io
  resources:
  - certificatesigningrequests/approval
  verbs:
  - update
- apiGroups:
  - certificates.k8s.io
  resources:
  - signers
  resourceNames:
  - example.com/my-signer-name # example.com/* can be used to authorize for all signers in the 'example.com' domain
  verbs:
  - approve
EOF
kubectl create -f ${TMPDIR}/csr-approver.yaml || true

GCLOUD_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
cat <<EOF >${TMPDIR}/crb.yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: csr-approver
subjects:
# Google Cloud user account
- kind: User
  name: $GCLOUD_ACCOUNT
roleRef:
  kind: ClusterRole
  name: csr-approver
  apiGroup: rbac.authorization.k8s.io
EOF
kubectl create -f ${TMPDIR}/crb.yaml || true

export CSR_NAME=vault-csr
cat <<EOF >${TMPDIR}/csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${CSR_NAME}
spec:
  signerName: kubernetes.io/kube-apiserver-client
  groups:
  - system:authenticated
  request: $(cat ${TMPDIR}/server.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
  - client auth
EOF
kubectl create -f ${TMPDIR}/csr.yaml || true
kubectl certificate approve ${CSR_NAME}
# wait just 5 seconds for the certificate to be generated 
sleep 5 
serverCert=$(kubectl get csr ${CSR_NAME} -o jsonpath='{.status.certificate}')

echo "${serverCert}" | openssl base64 -d -A -out ${TMPDIR}/vault.crt

kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 -D > ${TMPDIR}/vault.ca

# kubectl delete secret ${SECRET_NAME} || true
kubectl create secret generic ${SECRET_NAME} \
    --namespace ${NAMESPACE} \
    --from-file=vault.key=${TMPDIR}/vault.key \
    --from-file=vault.crt=${TMPDIR}/vault.crt \
    --from-file=vault.ca=${TMPDIR}/vault.ca || true
