#! /bin/bash
source setup_kubeconfig.sh
source helper.sh

c1_kctx
helm uninstall vault
kubectl delete $(kubectl get pvc -o name | grep vault | tr '\n' ' ')
kubectl delete csr vault-csr
kubectl delete secret vault-server-tls
kubectl delete secret tls-ca-cluster-2
kubectl delete vault-kms-config

c2_kctx
helm uninstall vault
kubectl delete $(kubectl get pvc -o name | grep vault | tr '\n' ' ')
kubectl delete csr vault-csr
kubectl delete secret vault-server-tls
kubectl delete secret tls-ca-cluster-1
kubectl delete vault-kms-config

rm -f token.jwt
rm -f *.delete
rm -f example.*
rm -f *.root_token
rm -f *.pem
rm -f *.cert
rm -f *.key
rm -f *.crt
rm -f keys*

c1_kctx
helm uninstall consul
helm uninstall prometheus
helm uninstall grafana
kubectl delete -f c1_manifests/
kubectl delete -f bookinfo/bookinfo.yaml
kubectl delete $(kubectl get pvc -o name | grep consul| tr '\n' ' ')
kubectl delete $(kubectl get sa -o name | grep consul)
kubectl delete $(kubectl get secrets -o name | grep consul)

c2_kctx
helm uninstall consul
kubectl delete -f consul-federation-secret.yaml
kubectl delete -f consul-acl-replication-acl-token.yaml
kubectl delete -f c2_manifests/
kubectl delete $(kubectl get pvc -o name | grep consul| tr '\n' ' ')
kubectl delete $(kubectl get sa -o name | grep consul)
kubectl delete $(kubectl get secrets -o name | grep consul)

# c3_kctl delete -f c3_manifests/

rm -f consul-federation-secret.yaml
rm -f consul-acl-replication-acl-token.yaml
rm -f external-counter.json