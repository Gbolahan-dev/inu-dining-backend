resource "google_artifact_registry_repository" "app_repo" {
   project = var.project_id
   location = var.region
   repository_id = "inu-dining-backend-repo"
   format = "DOCKER"
   description = "Terraform-managed Docker repo for Inu-Backend"
   depends_on = [google_project_service.apis]
}
