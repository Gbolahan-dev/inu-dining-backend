# This codifies the APIs our project requires.
# Terraform will enable them before creating resources that depend on them.
resource "google_project_service" "apis" {
      for_each = toset([
        "compute.googleapis.com",
        "container.googleapis.com",
        "artifactregistry.googleapis.com",
        "cloudbuild.googleapis.com",
        "developerconnect.googleapis.com",
        "iam.googleapis.com",
        "iamcredentials.googleapis.com",
        "secretmanager.googleapis.com",
        "logging.googleapis.com",
        "monitoring.googleapis.com"
      ])
      project            = var.project_id
      service            = each.key
      disable_on_destroy = false # This will turn the APIs off when we destroy
}
