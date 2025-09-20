resource "kubernetes_namespace" "staging" {
    metadata {
       name = "staging"
   }
   depends_on = [google_container_cluster.main]
}
resource "kubernetes_namespace" "prod" {
    metadata {
        name = "prod"
  }
  depends_on = [google_container_cluster.main]
}
