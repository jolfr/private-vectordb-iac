module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.3"

  project_id   = var.project_id
  network_name = "${var.name}-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "${var.name}-subnet"
      subnet_ip     = var.primary_ip_range
      subnet_region = var.location
    },
  ]

  secondary_ranges = {
    "${var.name}-subnet" = [
      {
        range_name    = "${var.name}-gke-services"
        ip_cidr_range = var.service_ip_range
      },
      {
        range_name    = "${var.name}-gke-pods"
        ip_cidr_range = var.pod_ip_range
      }
    ]
  }

  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    },
  ]
}

module "kubernetes-engine" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "33.1.0"
  # required variables
  project_id        = var.project_id
  name              = var.name
  region            = var.location
  network           = module.vpc.network_name
  subnetwork        = module.vpc.subnets_names[0]
  ip_range_services = "${var.name}-gke-services"
  ip_range_pods     = "${var.name}-gke-pods"

  # node configuration
  node_pools = [
    {
      name           = "storage-node-pool"
      machine_type   = "e2-standard-4"
      node_locations = "${var.location}-a,${var.location}-b,${var.location}-c"
      node_count     = 1
      autoscaling    = false
      disk_size_gb   = 20
      disk_type      = "pd-standard"
      image_type     = "UBUNTU_CONTAINERD"
      auto_repair    = true
      auto_upgrade   = true
      preemptible    = false
      spot           = false
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    storage-node-pool = {
      default-node-pool = true
    }
  }

  deletion_protection = false

  depends_on = [module.vpc]
}

resource "kubernetes_namespace" "rook_ceph" {
  metadata {
    name = "rook-ceph"
  }
}

resource "kubernetes_resource_quota" "rook_ceph_namespace" {
  metadata {
    name      = "rook-ceph"
    namespace = "rook-ceph" # kubernetes_namespace.rook_ceph.metadata.0.name
  }
  spec {
    hard = {}

    scope_selector {
      match_expression {
        scope_name = "PriorityClass"
        operator   = "In"
        values     = ["system-node-critical", "system-cluster-critical"]
      }
    }
  }
}

resource "helm_release" "rook_ceph" {
  name      = "rook-ceph"
  namespace = kubernetes_namespace.rook_ceph.metadata.0.name

  repository = "https://charts.rook.io/release"
  chart      = "rook-ceph"
  version    = "v1.15.3"

  depends_on = [kubernetes_resource_quota.rook_ceph_namespace]
}

resource "helm_release" "rook_ceph_cluster" {
  name      = "rook-ceph-cluster"
  namespace = kubernetes_namespace.rook_ceph.metadata.0.name

  repository = "https://charts.rook.io/release"
  chart      = "rook-ceph-cluster"
  version    = "v1.15.3"

  values = [file("${path.module}/manifests/ceph-cluster-spec.yaml")]

  # Calculate the checksum of the values file
  set_sensitive {
    name  = "values_checksum"
    value = filesha256("${path.module}/manifests/ceph-cluster-spec.yaml")
  }

  depends_on = [helm_release.rook_ceph]
}
