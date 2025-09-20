# helm.tf
resource "helm_release" "staging" {
  name             = "inu-dining-staging"
  chart            = "../charts/inu-dining-backend" # Path to new chart
  namespace        = kubernetes_namespace.staging.metadata[0].name
  create_namespace = false
  atomic          = true           # auto-rollback on failure
  cleanup_on_fail = true           # remove broken release so name isn’t “stuck”
  timeout         = 900            # 15m to wait for pods to become Ready
  wait            = true

  set {
    name  = "image.repository"
    value = "${google_artifact_registry_repository.app_repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app_repo.repository_id}/inu-dining-backend"
  }
  set {
    name  = "image.tag"
    value = var.image_tag
  }
  set {
    name  = "serviceAccount.name"
    value = "inu-dining-ksa"
  }
    depends_on = [kubernetes_secret.db_secret_staging]

}

resource "helm_release" "production" {
  name             = "inu-dining-prod"
  chart            = "../charts/inu-dining-backend" # Path to new chart
  namespace        = kubernetes_namespace.prod.metadata[0].name
  create_namespace = false
  atomic          = true           # auto-rollback on failure
  cleanup_on_fail = true           # remove broken release so name isn’t “stuck”
  timeout         = 900            # 15m to wait for pods to become Ready
  wait            = true

  set {
    name  = "image.repository"
    value = "${google_artifact_registry_repository.app_repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app_repo.repository_id}/inu-dining-backend"
  }
  set {
    name  = "image.tag"
    value = var.image_tag
  }
  set {
    name  = "serviceAccount.name"
    value = "inu-dining-ksa"
  }

    depends_on = [kubernetes_secret.db_secret_prod]


}
