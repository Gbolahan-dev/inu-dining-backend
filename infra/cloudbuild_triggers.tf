
resource "google_cloudbuildv2_connection" "github_connection" {
  provider = google-beta
  project  = var.project_id
  location = var.region
  name     = "github-connection"

  # only set on first apply; ignore drift later
  dynamic "github_config" {
    for_each = var.github_app_installation_id == null ? [] : [1]
    content { app_installation_id = var.github_app_installation_id }
  }

  depends_on = [google_project_service.apis]
  lifecycle { ignore_changes = [github_config] }
}

resource "google_cloudbuildv2_repository" "github_repo" {
  provider          = google-beta
  project           = var.project_id
  location          = var.region
  name              = var.cloudbuild_repo_id
  parent_connection = google_cloudbuildv2_connection.github_connection.name
  remote_uri        = "https://github.com/${var.github_owner}/${var.github_repo_name_on_github}.git"
  depends_on        = [google_project_service.apis]
}

# ===== TRIGGERS =====

# 1) STAGING: runs automatically on every push to main
resource "google_cloudbuild_trigger" "staging" {
  project  = var.project_id
  location = var.region
  name     = "inu-dining-staging"          # unique name
  filename = "cloudbuild.yaml"

  service_account = "projects/${var.project_id}/serviceAccounts/${var.cb_runner_sa_email}"
  substitutions   = { _TARGET_ENV = "staging" }

  repository_event_config {
    repository = google_cloudbuildv2_repository.github_repo.id
    push { branch = "^main$" }
  }
}

# 2) PROD: runs on version tags (e.g. v1.2.3) and REQUIRES APPROVAL
resource "google_cloudbuild_trigger" "prod" {
  project  = var.project_id
  location = var.region
  name     = "inu-dining-prod"             # different unique name
  filename = "cloudbuild.yaml"

  service_account = "projects/${var.project_id}/serviceAccounts/${var.cb_runner_sa_email}"
  substitutions   = { _TARGET_ENV = "prod" }
  approval_config { approval_required = true }

  repository_event_config {
    repository = google_cloudbuildv2_repository.github_repo.id
    push { tag = "^v[0-9]+\\.[0-9]+\\.[0-9]+$" }  # v1.2.3
  }
}

# 3) (optional) PR checks against main
resource "google_cloudbuild_trigger" "pr" {
  project  = var.project_id
  location = var.region
  name     = "inu-dining-pr"               # unique name
  filename = "cloudbuild.pr.yaml"

  service_account = "projects/${var.project_id}/serviceAccounts/${var.cb_runner_sa_email}"

  repository_event_config {
    repository = google_cloudbuildv2_repository.github_repo.id
    pull_request { branch = "^main$" }
  }
}


