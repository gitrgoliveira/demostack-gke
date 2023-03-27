resource "random_pet" "gke-key" {
  separator = "-"
}

locals {
  keyring_location  = "global"
  key_ring          = "${var.namespace}-vault-gke-keyring-${random_pet.gke-key.id}"
  crypto_key        = "${var.namespace}-vault-gke-cryptokey-${random_pet.gke-key.id}"
}

resource "google_service_account" "vault_kms_service_account" {
  account_id   = "${var.namespace}-vault-gcpkms"
  display_name = "${var.namespace} Vault KMS for auto-unseal"
}

# Create a KMS key ring
resource "google_kms_key_ring" "key_ring" {
  depends_on = [
    google_project_service.gcp_services
  ]
  project  = var.project
  name     = local.key_ring
  location = local.keyring_location
}

# Create a crypto key for the key ring
resource "google_kms_crypto_key" "crypto_key" {
  name            = local.crypto_key
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "100000s"
}

# Add the service account to the Keyring
resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  key_ring_id = google_kms_key_ring.key_ring.id
  # key_ring_id = "${var.project}/${local.keyring_location}/${local.key_ring}"
  # role = "roles/owner"
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_service_account.vault_kms_service_account.email}",
  ]
}

resource "google_kms_crypto_key_iam_member" "vault-init" {
  crypto_key_id = google_kms_crypto_key.crypto_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.vault_kms_service_account.email}"
}

resource "google_project_iam_member" "viewer" {
  project = var.project
  member  = "serviceAccount:${google_service_account.vault_kms_service_account.email}"
  role    = "roles/compute.viewer"
}

resource "google_project_iam_member" "dnsadmin" {
  project = var.project
  member  = "serviceAccount:${google_service_account.vault_kms_service_account.email}"
  role    = "roles/dns.admin"
}

resource "google_project_iam_member" "storageviewer" {
  project = var.project
  member  = "serviceAccount:${google_service_account.vault_kms_service_account.email}"
  role    = "roles/storage.objectViewer"
}

resource "google_project_iam_member" "kmsadmin" {
  project = var.project
  member  = "serviceAccount:${google_service_account.vault_kms_service_account.email}"
  role    = "roles/cloudkms.admin"
}
resource "google_project_iam_member" "cryptoKeyEncrypterDecrypter" {
  project = var.project
  member  = "serviceAccount:${google_service_account.vault_kms_service_account.email}"
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}

resource "google_project_iam_member" "signerVerifier" {
  project = var.project
  member  = "serviceAccount:${google_service_account.vault_kms_service_account.email}"
  role    = "roles/cloudkms.signerVerifier"
}
