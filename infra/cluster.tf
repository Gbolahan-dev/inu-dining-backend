
# infra/cluster.tf

resource "google_container_cluster" "main" {
  project                  = var.project_id
  name                     = var.cluster_name
  location                 = var.zone # This makes it a regional cluster
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection = false

  network    = module.vpc.network_name
  subnetwork = module.vpc.subnets_names[0]

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods-range"
    services_secondary_range_name = "gke-services-range"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "main_pool" {
  name     = "main-pool"
  project  = var.project_id
  # For a regional cluster, the node pool location must be a zone within that region.
  # We will hardcode it here to match your previous setup.
  location = "us-central1-a"
  cluster  = google_container_cluster.main.name

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    machine_type    = "e2-medium"
    disk_size_gb    = 20
    service_account = google_service_account.gke_node_sa.email

    tags = ["gke-node"]
  }
}

