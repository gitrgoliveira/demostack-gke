variable "namespace" {
  description = "namespace"
}
variable "project" {
  description = "project"
}
variable "region" {
  description = "region"
}
variable "network_name" {
  description = "google_compute_network.vpc.name"
}
variable "subnetwork_name" {
  description = "google_compute_subnetwork.subnet.name"
}

# =================================================================
# Optional

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 3
  description = "number of gke nodes"
}
