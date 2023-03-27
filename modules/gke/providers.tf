terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.53.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.17.0"
    }
  }
}

locals {
  gcp_service_list = [
    "cloudkms.googleapis.com",
  ]
}
resource "google_project_service" "gcp_services" {
  for_each = toset(local.gcp_service_list)
  project = var.project
  service = each.key
}
