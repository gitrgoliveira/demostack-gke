output "region" {
  value       = var.region
  description = "region"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "gcpckms" {
  value = <<EOF
  seal "gcpckms" {
    project     = "${google_kms_key_ring.key_ring.project}"
    region      = "${google_kms_key_ring.key_ring.location}"
    key_ring    = "${google_kms_key_ring.key_ring.name}"
    crypto_key  = "${google_kms_crypto_key.crypto_key.name}"
  }
  EOF
}