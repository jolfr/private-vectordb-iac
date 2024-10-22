data "google_client_config" "current" {}

data "google_compute_network" "primary" {
  name = var.network
}

data "google_compute_subnetwork" "primary" {
  name = var.subnet
}
