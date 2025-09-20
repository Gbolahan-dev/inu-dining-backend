terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0"}
    google-beta = { source = "hashicorp/google-beta", version = "~> 5.0"}
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.20"}
    helm = { source = "hashicorp/helm", version = "~> 2.9"}

 }
}

provider "google" {
   project = var.project_id
   region = var.region
}

provider "google-beta" {
   project = var.project_id
   region = var.region
}

data "google_client_config" "default" {}

provider "kubernetes" {
   host = "https://${google_container_cluster.main.endpoint}"
   token = data.google_client_config.default.access_token
   cluster_ca_certificate =  base64decode(
    google_container_cluster.main.master_auth[0].cluster_ca_certificate
  )

}

provider "helm" {
  kubernetes {
    host = "https://${google_container_cluster.main.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate =  base64decode(
    google_container_cluster.main.master_auth[0].cluster_ca_certificate
  )
 }
}
