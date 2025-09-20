# In infra/secrets.tf

# 1. Creates the "container" for our secret in Google Secret Manager.
resource "google_secret_manager_secret" "db_url" {
  project   = var.project_id
  secret_id = "inu-dining-db-url"

  replication {
    auto {}
  }
}

# 2. A data source to READ the value of the secret's latest version.
#    The actual value must be added manually in the GCP console one time for security.
data "google_secret_manager_secret_version" "db_url_version" {
  project = var.project_id
  secret  = google_secret_manager_secret.db_url.secret_id
  # This ensures we don't try to read the secret before the secret itself exists.
  depends_on = [google_secret_manager_secret.db_url]
}

# 3. Grant our application's Service Account permission to read this secret.
resource "google_secret_manager_secret_iam_member" "app_gsa_secret_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.db_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.app_gsa.email}"
}

# 4. Create the Kubernetes secret in the 'staging' namespace.
resource "kubernetes_secret" "db_secret_staging" {
  metadata {
    name      = "inu-dining-db-secret"
    namespace = kubernetes_namespace.staging.metadata[0].name
  }

  data = {
    # This reads the secret value from the data source.
    DATABASE_URL = data.google_secret_manager_secret_version.db_url_version.secret_data
  }

  depends_on = [
    kubernetes_namespace.staging,
    data.google_secret_manager_secret_version.db_url_version
  ]
}

# 5. Create the Kubernetes secret in the 'production' namespace.
resource "kubernetes_secret" "db_secret_prod" {
  metadata {
    name      = "inu-dining-db-secret"
    namespace = kubernetes_namespace.prod.metadata[0].name
  }

  data = {
    DATABASE_URL = data.google_secret_manager_secret_version.db_url_version.secret_data
  }
  
  depends_on = [
    kubernetes_namespace.prod,
    data.google_secret_manager_secret_version.db_url_version
  ]
}
