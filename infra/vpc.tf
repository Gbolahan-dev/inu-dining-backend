# infra/vpc.tf

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 8.0"

  project_id   = var.project_id
  network_name = "inu-dining-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = "gke-subnet"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = var.region
    }
  ]

  # This section creates the secondary ranges that the GKE cluster needs.
  # The names here MUST match the names used in cluster.tf
  secondary_ranges = {
    gke-subnet = [
      {
        # This is the range for the Pods
        range_name    = "gke-pods-range"
        ip_cidr_range = "10.20.0.0/16" # A suitable range for pods
      },
      {
        # This is the range for the Services
        range_name    = "gke-services-range"
        ip_cidr_range = "10.30.0.0/20" # A suitable range for services
      }
    ]
  }
         
  depends_on = [google_project_service.apis]
}
