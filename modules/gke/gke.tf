# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.namespace}-gke"
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network_name
  subnetwork = var.subnetwork_name

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    ]
    service_account = google_service_account.vault_kms_service_account.email

    labels = {
      env = var.namespace
      project = var.project
    }

    preemptible  = true
    machine_type = "n1-standard-2"
    tags         = ["gke-node", "${var.namespace}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}