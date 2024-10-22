terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.7.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.33.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = "2.16.1"
    }
  }
}