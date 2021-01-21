locals {
  namespaces = ["cluster-1", "cluster-2"]
}

module "gke" {
  count           = length(local.namespaces)
  source          = "./modules/gke"
  namespace       = local.namespaces[count.index]
  project         = var.project
  region          = var.region
  network_name    = google_compute_network.vpc.name
  subnetwork_name = google_compute_subnetwork.subnet.name
}


