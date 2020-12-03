output "region" {
  value       = var.region
  description = "region"
}

output "kubernetes_clusters" {
  value       = module.gke
  description = "GKE Cluster Name"
}
