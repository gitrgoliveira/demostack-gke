terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "hc-ric-demo"

    workspaces {
      name = "ricardo-gcp-demostack"
    }
  }
}