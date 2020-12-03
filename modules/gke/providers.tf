terraform {
  required_providers {
    google = {
      version = "~> 3.42"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}