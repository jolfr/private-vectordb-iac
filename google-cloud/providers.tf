
provider "google" {
  # Configuration options
  project = var.project_id
  region  = var.location
}

provider "kubernetes" {
  host                   = "https://${module.kubernetes-engine.endpoint}"
  cluster_ca_certificate = base64decode(module.kubernetes-engine.ca_certificate)
  token                  = data.google_client_config.current.access_token
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.kubernetes-engine.endpoint}"
    cluster_ca_certificate = base64decode(module.kubernetes-engine.ca_certificate)
    token                  = data.google_client_config.current.access_token
  }
}
