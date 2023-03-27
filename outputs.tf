output "region" {
  value       = var.region
  description = "region"
  sensitive   = false
}

output "project" {
  value       = var.project
  description = "GCP project"
  sensitive   = false
}

output "kubernetes_clusters" {
  value       = module.gke
  description = "GKE Cluster Name"
  sensitive   = false
}
