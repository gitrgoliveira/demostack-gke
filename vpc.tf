provider "google" {
  project = var.project
  region  = var.region
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project}-gke-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"

}