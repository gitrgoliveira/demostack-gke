variable "project" {
  description = "project id"
}

variable "region" {
  description = "region"
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
